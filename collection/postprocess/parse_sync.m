clear all; close all; clc;

%% Script Options

receiver_rssi_file = 'recv_ber.csv';
transmitter_rssi_file = 'xmit_ber.csv';

receiver_sync_file = 'recv_new_sync.csv';
trasmitter_sync_file = 'xmit_new_sync.csv';

receiver_positions_file = 'recv_new_pos.csv';
transmitter_positions_file = 'xmit_new_pos.csv';

rssi2dbm_func = @(x) x./3 - 100;
rssi_ewma_factor = 3/8; % 0 if no ewma desired

log_file = 1; % or fopen("log_file.txt", "a");
plot_rssi_vs_time = 0;
plot_position_vs_time = 0;
plot_distance_vs_rssi = 0;
plot_stamp_sync = 0;

sow_start = 392750;
sow_end = 392950;

Pt_ = 10.^(4/10); %4dBm tranmission power assumed.
freq_ = (2425 * 10^6); %Frequency for Channel 15 
rxthresh_ = 10.^(-84/10); %-84dBm rx threshold assumed.
csthresh_ = 10.^(-100/10); %-100dBm cs threshold assumed.

slice_width =  3;
time_delta = 0.02;
%% Load Transmitter Positions Table
xmit_ber = readtable(transmitter_rssi_file);
recv_ber = readtable(receiver_rssi_file);
xmit_pos = readtable(receiver_positions_file);
recv_pos = readtable(transmitter_positions_file);
recv_pos = recv_pos(recv_pos.latitude > 1, :);
xmit_pos = xmit_pos(xmit_pos.latitude > 1, :);

%% Synchronisation for STAMP data
if exist('recv_ber.gps_sow','var') == 0
    recv_ber.gps_sow = sync_tables(readtable(receiver_sync_file),recv_ber,plot_stamp_sync);
    xmit_ber.gps_sow = sync_tables(readtable(trasmitter_sync_file),xmit_ber,plot_stamp_sync);
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
    
    recv_ber.rssi = filter(rssi_filter.arg1, rssi_filter.arg2, recv_ber.rssi);
end
 recv_ber.dbm = rssi2dbm_func(recv_ber.rssi);

%% Grand Table
grand_table = array2table([recv_ber.gps_sow, ...
    interp1(recv_pos.gps_sow, recv_pos{:, { 'x', 'y', 'z', 'height' } }, recv_ber.gps_sow), ...
    interp1(xmit_pos.gps_sow, xmit_pos{:, { 'x', 'y', 'z', 'height' } }, recv_ber.gps_sow), ...
    recv_ber.dbm
    ],...
    'VariableNames',{ 'gps_sow' 'rx' 'ry' 'rz' 'rh' 'tx' 'ty' 'tz' 'th' 'dbm'});

grand_table.distance = sqrt((grand_table.tx - grand_table.rx).^2 + ...
    (grand_table.ty - grand_table.ry).^2 + ...
    (grand_table.tz - grand_table.rz).^2 ...
    );
grand_table.angle = abs(grand_table.rh - grand_table.th)./grand_table.distance;


data_filter = ~isnan(grand_table.distance);

if (sow_start > 0)
    data_filter = data_filter & grand_table.gps_sow > (sow_start);
end

if (sow_end > 0)
    data_filter = data_filter & grand_table.gps_sow < (sow_end);
end

tmp_table = grand_table(data_filter, ...
    {'gps_sow', 'angle', 'distance', 'dbm', ...
    'rx', 'ry', 'rz', 'tx', 'ty', 'tz' });
if size(tmp_table,1) == 0
    disp('No Valid data!');
    return
end

%% Distance/RSSI vs Time
if plot_rssi_vs_time
    figure
    hold on
    scatter(tmp_table.gps_sow, tmp_table.dbm);
    scatter(tmp_table.gps_sow, tmp_table.distance);
end

%% Position vs Time
if plot_position_vs_time
    figure
    hold on
    scatter3(tmp_table.tx, tmp_table.ty, tmp_table.tz, [], tmp_table.gps_sow);
    scatter3(tmp_table.rx, tmp_table.ry, tmp_table.rz, [], tmp_table.gps_sow);
end

%% Values for NS2

rssi_model = path_loss_exponent_modeller(tmp_table.distance, tmp_table.dbm, Pt_, freq_, plot_distance_vs_rssi, log_file);
fprintf(log_file, 'Phy/WirelessPhy set CSThresh_ %.5e\n', csthresh_);
fprintf(log_file, 'Phy/WirelessPhy set RXThresh_ %.5e\n', rxthresh_);
fprintf(log_file, '#--------------------------------------\n');

%% PRR Processing
all_slices = sow_start:slice_width:sow_end;
packet_error_modeller(recv_ber, xmit_ber, all_slices, time_delta, [000 1400]);
