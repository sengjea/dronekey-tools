clear all; close all; clc;
%% Script Options

receiver_rssi_file = 'recv_ber.csv';
transmitter_rssi_file = 'xmit_ber.csv';

receiver_sync_file = 'recv_new_sync.csv';
trasmitter_sync_file = 'xmit_new_sync.csv';

receiver_positions_file = 'recv_new_pos.csv';
transmitter_positions_file = 'xmit_new_pos.csv';

rssi2dbm_func = @(x) x/3 - 100;
rssi_ewma_factor = 3/8; % 0 if no ewma desired

log_file = fopen('matlab.tcl','w');
plot_rssi_vs_time = 1;
plot_distance_vs_rssi = 1;
plot_stamp_sync = 0;

sow_start = 392750;
sow_end = 392950;

tx_pwr_dbm = 3;
rxthresh_dbm = -87;
csthresh_dbm = -100;

freq_ = (2425 * 10^6); %Frequency for Channel 15

lag = 0;

slice_width =  3;
time_delta = 0.2;
run_ns2 = 1;
%% Load Transmitter Positions Table

prr_modelling = exist('transmitter_rssi_file', 'var');
if prr_modelling
    xmit_pkt = readtable(transmitter_rssi_file);
end
recv_pkt = readtable(receiver_rssi_file);
xmit_pos = readtable(receiver_positions_file);
recv_pos = readtable(transmitter_positions_file);
recv_pos = recv_pos(recv_pos.latitude > 1, :);
xmit_pos = xmit_pos(xmit_pos.latitude > 1, :);

%% Synchronisation for STAMP data
if ismember('gps_sow',recv_pkt.Properties.VariableNames) == 0
    recv_pkt.gps_sow = sync_tables(readtable(receiver_sync_file),recv_pkt,plot_stamp_sync);
    if prr_modelling
        xmit_pkt.gps_sow = sync_tables(readtable(trasmitter_sync_file),xmit_pkt,plot_stamp_sync);
    end
end

%% Convert GPS co-ordinates to x,y,z
[recv_pos.x, recv_pos.y, recv_pos.z] = ...
    geodetic2ecef(recv_pos.latitude *pi/180 , ...
    recv_pos.longitude *pi/180, ...
    recv_pos.height,referenceEllipsoid('wgs84'));

[xmit_pos.x, xmit_pos.y, xmit_pos.z] = ...
    geodetic2ecef(xmit_pos.latitude *pi/180, ...
    xmit_pos.longitude *pi/180, ...
    xmit_pos.height,referenceEllipsoid('wgs84'));

%% RSSI processing

if rssi_ewma_factor > 0
    rssi_filter.arg1 = rssi_ewma_factor;
    rssi_filter.arg2 = [ 1 (rssi_ewma_factor-1) ];
    
    recv_pkt.rssi = filter(rssi_filter.arg1, rssi_filter.arg2, recv_pkt.rssi);
end
recv_pkt.dbm = rssi2dbm_func(recv_pkt.rssi);

%% Grand Table

grand_table = array2table([recv_pkt.gps_sow + lag, ...
    interp1(recv_pos.gps_sow, recv_pos{:, { 'x', 'y', 'z', 'height' } }, recv_pkt.gps_sow + lag), ...
    interp1(xmit_pos.gps_sow, xmit_pos{:, { 'x', 'y', 'z', 'height' } }, recv_pkt.gps_sow + lag), ...
    recv_pkt.dbm
    ],...
    'VariableNames',{ 'gps_sow' 'rx' 'ry' 'rz' 'rh' 'tx' 'ty' 'tz' 'th' 'dbm'});

grand_table.distance = sqrt((grand_table.tx - grand_table.rx).^2 + ...
    (grand_table.ty - grand_table.ry).^2 + ...
    (grand_table.tz - grand_table.rz).^2 ...
    );
grand_table.angle = abs(grand_table.rh - grand_table.th)./grand_table.distance;

grand_table.h2 = grand_table.rh.^2 .* grand_table.th.^2;

data_filter = ~isnan(grand_table.distance);
data_filter = data_filter & grand_table.h2 > 4e8;

if (sow_start > 0)
    data_filter = data_filter & grand_table.gps_sow > (sow_start);
end

if (sow_end > 0)
    data_filter = data_filter & grand_table.gps_sow < (sow_end);
end

tmp_table = grand_table(data_filter, ...
    {'gps_sow', 'angle', 'distance', 'dbm', ...
    'rx', 'ry', 'rz', 'tx', 'ty', 'tz', 'rh', 'th', 'h2'});
if size(tmp_table,1) == 0
    disp('No Valid data!');
    return
end

%% Distance/RSSI vs Time
if plot_rssi_vs_time
    figure;
    hold on;
    subplot(2,1,1);
    scatter(grand_table.gps_sow, grand_table.dbm, '+');
    grid on;
    subplot(2,1,2);
    scatter(grand_table.gps_sow, grand_table.distance, [], grand_table.h2, '+');
    grid on;
end

%% Values for NS2
rxthresh_ = 10.^(rxthresh_dbm/10);
csthresh_ = 10.^(csthresh_dbm/10);
rssi_model = path_loss_exponent_modeller(tmp_table.distance, tmp_table.dbm, [], tx_pwr_dbm, freq_, plot_distance_vs_rssi, log_file);
if log_file > 0
fprintf(log_file, 'Phy/WirelessPhy set CSThresh_ %.5e ;# CS Threshold of %d dBm\n', csthresh_, csthresh_dbm);
fprintf(log_file, 'Phy/WirelessPhy set RXThresh_ %.5e ;# RX Threshold of %d dBm\n', rxthresh_, rxthresh_dbm);
fprintf(log_file, '#--------------------------------------\n');
end
if run_ns2
    !python model_test.py;
end
%% PRR Processing
if prr_modelling
    tmp_recv_ber = recv_pkt;
    tmp_recv_ber.log_distance = interp1(tmp_table.gps_sow, log10(tmp_table.distance), tmp_recv_ber.gps_sow);
    tmp_recv_ber.dbm = predict(rssi_model, tmp_recv_ber.log_distance);
    all_slices = sow_start:slice_width:sow_end;
    packet_length_range = [000 1400];
    error_table = packet_error_analyser(recv_pkt, xmit_pkt, all_slices, time_delta, packet_length_range, log_file);
    error_table.distance = interp1(tmp_table.gps_sow, tmp_table.distance, error_table.gps_sow);
%     figure; % To determine xmit to recv lag.
%     hold on;
%     scatter(recv_pkt.gps_sow, (recv_pkt.dbm./recv_pkt.dbm) * (-40.05));
%     scatter(xmit_pkt.gps_sow(xmit_pkt.status == 0), xmit_pkt.numtx(xmit_pkt.status == 0)*(-40));
    sim_table = readtable('sim_output.csv');
    figure;
    hold on;
    scatter(error_table.distance, error_table.prr, 'x');
    plot(sim_table.distance, sim_table.prr, '-r');
    legend('Measured PRR', 'Simulated PRR');
    xlabel('Distance (m)');
    ylabel('Packet Reception Rate');
    error_table = error_table(~isnan(error_table.distance),:);
    error_table.sim_prr = interp1(sim_table.distance, sim_table.prr, error_table.distance);
    fit_mse = goodnessOfFit(error_table.prr, error_table.sim_prr, 'NRMSE');
    fprintf(1, '#Simulation Fit RMSE: %.05e\n', fit_mse);
end
fclose(log_file);