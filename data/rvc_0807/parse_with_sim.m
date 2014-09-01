clear all; close all; clc;
%% Script Options

analyse_wifi = 0;
use_asctec = 0;

log_file = fopen('ns2/matlab.tcl','w');

if analyse_wifi
    receiver_rssi_file = 'wifi.csv';
    transmitter_rssi_file = 'xmit_wifi.csv';
    rssi2dbm_func = @(x) x; %x/3 - 100; 
    rssi_ewma_factor = 0; % 0 if no ewma desired
    rssi_defilter_numer = 0; % 0 if no ewma defilter needed.
    rssi_defilter_denom = 8;
    sow_start = 392540; % 392750;
    sow_end = 392700; % 392950;
    lag = 223;
    rxthresh_dbm = -75;
    csthresh_dbm = -100;
    fprintf(log_file, '##-----Generated 802.11.g parameters -------\n');
    !python faker.py 0.15
else
    receiver_rssi_file = 'recv_ber.csv';
    transmitter_rssi_file = 'xmit_ber.csv';
    rssi2dbm_func = @(x) x/3 - 100;
    rssi_ewma_factor = 3/8;
    rssi_defilter_numer = 0;
    sow_start = 392550;
    sow_end = 392950;
    lag = 0;
    rxthresh_dbm = -87;
    csthresh_dbm = -100;
    fprintf(log_file, '##-----Generated 802.15.4 parameters -------\n');
end

if use_asctec
    receiver_positions_file = 'golf.csv';
    transmitter_positions_file = 'foxtrot.csv';
else
    receiver_sync_file = 'recv_new_sync.csv';
    trasmitter_sync_file = 'xmit_new_sync.csv';
    receiver_positions_file = 'recv_new_pos.csv';
    transmitter_positions_file = 'xmit_new_pos.csv';
end

%% Plotting Options
plot_rssi_vs_time = 0;
plot_distance_vs_rssi = 1;
plot_stamp_sync = 0;
tx_pwr_dbm = 3;

%% Parameters
freq_ = (2425 * 10^6); %Frequency for Channel 15

%% Analysis Options
slice_width =  2;
time_delta = 0.1;
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
    recv_pkt.gps_sow = recv_pkt.gps_sow + lag;
    %xmit_pkt.gps_sow = xmit_pkt.gps_sow;


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
if rssi_defilter_numer > 0
    rssi_defilter.arg1 = [ rssi_defilter_denom, (rssi_defilter_numer - rssi_defilter_denom) ];
    rssi_defilter.arg2 = rssi_defilter_numer;
    
    recv_pkt.rssi = filter(rssi_defilter.arg1, rssi_defilter.arg2, recv_pkt.rssi);
end

if rssi_ewma_factor > 0
    rssi_filter.arg1 = rssi_ewma_factor;
    rssi_filter.arg2 = [ 1 (rssi_ewma_factor-1) ];
    
    recv_pkt.rssi = filter(rssi_filter.arg1, rssi_filter.arg2, recv_pkt.rssi);
end
recv_pkt.dbm = rssi2dbm_func(recv_pkt.rssi);

grand_table = distance_interpolater(recv_pkt, xmit_pos, recv_pos);

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
    scatter(tmp_table.gps_sow, tmp_table.dbm, '+');
    grid on;
    subplot(2,1,2);
    scatter(tmp_table.gps_sow, tmp_table.distance, [], tmp_table.h2, '+');
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

%% NS2 Simulation
if run_ns2
    unix('cd ns2; python model_test.py bootscript_udisk.tcl udisk_output.csv;');
    unix('cd ns2; python model_test.py bootscript.tcl model_output.csv;');
end

%% PRR Processing
if prr_modelling
    tmp_recv_ber = recv_pkt;
    tmp_recv_ber.log_distance = log10(interp1(tmp_table.gps_sow, tmp_table.distance, tmp_recv_ber.gps_sow));
    tmp_recv_ber.dbm = predict(rssi_model, tmp_recv_ber.log_distance);
    all_slices = sow_start:slice_width:sow_end;
    %packet_length_range = [000 1400];
    error_table = packet_error_analyser(recv_pkt, xmit_pkt, all_slices, time_delta);
    error_table.distance = interp1(tmp_table.gps_sow, tmp_table.distance, error_table.gps_sow);
    

    f = figure;
    set(f,'OuterPosition', [ 100 100 570 380 ]);
    hold on;
    scatter(error_table.distance, error_table.prr, 'x');
    
    sim_table = readtable('ns2/model_output.csv');
    udisk_table = readtable('ns2/udisk_output.csv');
    sim_table = sim_table(sim_table.distance < 200,:);
    plot(sim_table.distance, sim_table.prr, '-r');
    plot(udisk_table.distance, udisk_table.prr, '-g');
    error_table = error_table(~isnan(error_table.distance),:);
    error_table.sim_prr = interp1(sim_table.distance, sim_table.prr, error_table.distance);
    error_table.udisk_prr = interp1(udisk_table.distance, udisk_table.prr, error_table.distance);
    fit_mse = goodnessOfFit(error_table.prr, error_table.sim_prr, 'MSE');
    fprintf(1, '#Model MSE: %.05e\n', fit_mse);
    fit_mse = goodnessOfFit(error_table.prr, error_table.udisk_prr, 'MSE');
    fprintf(1, '#UDISK MSE: %.05e\n', fit_mse);
    legend('Measured PRR', 'Simulated PRR (Log Shadow Model)', 'Simulated PRR (Unit Disk of 10.7m)');
    xlabel('Distance (m)');
    ylabel('Packet Reception Rate');
    title('Plot of Packet Reception Rate against Distance');
    
    f = figure;
    set(f,'OuterPosition', [ 100 100 570 380 ]);
    hold on;
    scatter(error_table.distance, error_table.ber);    
    xlabel('Distance (m)');
    ylabel('Bit Error Rate');
    title('Plot of Bit Error Rate against Distance');
end
fclose(log_file);
