%function y = parse_csv(data_prefix)
%%Stuff for non function mode:
clear all; close all; clc;
data_prefix = '';

%Load xmit table
xmit_ber = readtable('xmit_ber.csv');

%Load rssi, mag and loc tables
rssi_table = readtable(strcat(data_prefix,'-rssi.csv'));
magagnetometer_table = readtable(strcat(data_prefix,'-mag.csv'));
location_table = readtable(strcat(data_prefix,'-loc.csv'));
time_offset = rssi_table.embtime(1);
rssi_table.embtime = (rssi_table.embtime - time_offset)./1000;
magagnetometer_table.embtime = (magagnetometer_table.embtime - time_offset)./1000;
location_table.embtime = (location_table.embtime - time_offset)./1000;

rsquares = [ ];
ewma_factor = 1/8;
window_size = 20;
antenna_radiation_function = @(c,x) c(1)*sind(x(:,1));
path_loss_function = @(c,x) c(1)./x(:,1).^c(2);
plot_symbols = [ '.' '+' 'o' 'x' ];
rssi_filter.arg1 = ewma_factor;
rssi_filter.arg2 = [ 1 (ewma_factor-1) ];
mag_filter.arg1 = ones(window_size,1)./window_size;
mag_filter.arg2 = 1;

grand_table = array2table([ rssi_table.embtime rssi_table.rssi rssi_table.prr ...
    interp1(magagnetometer_table.embtime,location_table{:,{'x' 'y' 'z' 'roll' 'pitch' 'yaw'}},rssi_table.embtime) ...
    interp1(magagnetometer_table.embtime,magagnetometer_table{:,{'mag_x' 'mag_y' 'mag_z'}},rssi_table.embtime) ], ...
    'VariableNames',{'embtime' 'rssi' 'prr' 'x' 'y' 'z' 'roll' 'pitch' 'yaw' 'mag_x' 'mag_y' 'mag_z'});
dead_rows = isnan(grand_table.x) | isnan(grand_table.y) | isnan(grand_table.z) | grand_table.rssi < 10;
grand_table(dead_rows,:) = [];
grand_table.rssi = ...
    filter(rssi_filter.arg1, rssi_filter.arg2, grand_table.rssi);
grand_table{:,{'mag_x' 'mag_y' 'mag_z'}} = ...
    filter(mag_filter.arg1, mag_filter.arg2, grand_table{:,{'mag_x' 'mag_y' 'mag_z'}});

grand_table.distance = sqrt(sum(grand_table{:,{'x' 'y' 'z'}}.^2,2));
grand_table.angle = sqrt(sum(grand_table{:,{'x' 'y'}}.^2,2))./grand_table.distance;
grand_table(1:window_size,:) = [ ];
%     grand_table.direction = atan2(grand_table.mag_x, grand_table.mag_y);

path_loss_model =  fitnlm(grand_table.distance, ...
    grand_table.rssi,...
    path_loss_function, [1500 2]);

rsquares = [ rsquares path_loss_model.Rsquared.Adjusted ];
%% Plotting function
figure(1);
scatter(grand_table.distance,grand_table.rssi,[], abs(grand_table.angle),'x');
hold on
path_loss_model_line = predict(path_loss_model, grand_table.distance);
plot(grand_table.distance, path_loss_model_line,'-r');
hold off
figure(2);
plot(grand_table.embtime, grand_table{:,{'rssi','distance','angle'}});

%% Logging Function
f = fopen('log.txt','a');
fprintf(f, 'ts: %s\n', datestr(now,'yyyymmdd_HHMMSS'));
fprintf(f, 'path_loss_function = %s\n',func2str(path_loss_function));
% fprintf(f, 'rssi_filter ='); fprintf(f,'%0.5f ',rssi_filter); fprintf(f,'\n');
% fprintf(f, 'mag_filter ='); fprintf(f,'%0.5f ',mag_filter); fprintf(f,'\n');
fprintf(f, 'rsquares = ');fprintf(f, '%.5f ', rsquares);fprintf(f,'\n');
fprintf(f, '----------------------------------------------------------\n');
fclose(f);
%end