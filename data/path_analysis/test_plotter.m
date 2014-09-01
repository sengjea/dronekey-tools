clear all; clc; close all;
sensor_data = readtable('Test3/data.csv');
range_data = readtable('Test4/data.csv');


i=30;

f = figure;
set(f,'OuterPosition', [ 100 100 640 480 ]);
tmp_range_data = range_data(range_data.num_sensors == i,:);
boxplot(tmp_range_data.shortcut, tmp_range_data{:,{'range' 'algo_type'}}, ...
        'labels', { 'KSplit 10m' 'mGA 10m' 'KSplit 15m' 'mGA 15m' 'KSplit 20m' 'mGA 20m' 'KSplit 25m' 'mGA 25m'}, ...
        'labelorientation', 'inline');
ylabel('Optimisation Length (m)');
title(sprintf('Plot of Shortcut Optimisation vs Communication Range for %d sensors',i));

%'labels', { 'KSplit 10m' 'mGA 10m' 'KSplit 15m' 'mGA 15m' 'KSplit 20m' 'mGA 20m' 'KSplit 25m' 'mGA 25m'}, ...
        
i=25;
f = figure;
set(f,'OuterPosition', [ 100 100 640 480 ]);
tmp_range_data = range_data(range_data.range == i,:);
boxplot(tmp_range_data.shortcut, tmp_range_data{:,{'num_sensors' 'algo_type'}}, ...
        'labels', { 'KSplit 20' 'mGA 20' 'KSplit 30' 'mGA 30' 'KSplit 40' 'mGA 40' 'KSplit 50' 'mGA 50' }, ...
        'labelorientation', 'inline');
ylabel('Optimisation Length (m)');
title(sprintf('Plot of Shortcut Optimisation vs Number of Sensors for %dm range',i));

f = figure;
set(f,'OuterPosition', [ 100 100 640 480 ]);
boxplot(sensor_data.distance, sensor_data{:,{'num_sensors' 'algo_type'}}, ...
     'labels', { 'KSplit 20' 'mGA 20' 'KSplit 30' 'mGA 30' 'KSplit 40' 'mGA 40' 'KSplit 50' 'mGA 50' }, ...
        'labelorientation', 'inline');
ylabel('Path Length (m)');
title('Plot of Path Length vs Number of Sensors');

data_filter = sensor_data.num_sensors == 20;
[h, p, ci, stats] = ttest2(sensor_data.distance(data_filter & sensor_data.algo_type == 0),...
                           sensor_data.distance(data_filter  & sensor_data.algo_type == 1))
