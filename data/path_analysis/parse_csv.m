clear all; clc;
input_csv = readtable('increasing_sensors.csv');
data_filter = input_csv.num_sensors == 15;
[h, p, ci, stats] = ttest2(input_csv.k_split(data_filter),input_csv.ga(data_filter))

% Transpose

transposed_table = [input_csv{:,1} zeros(size(input_csv,1),1) input_csv{:,3} ; input_csv{:,1} ones(size(input_csv,1),1) input_csv{:,2}];
boxplot(transposed_table(:,3), transposed_table(:,1:2), 'labels', repmat({'GA'; 'KSPLIT'},5,1))