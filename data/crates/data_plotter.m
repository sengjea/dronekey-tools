clear all; clc; close all;
!rm prr_data.csv collection_data.csv
!python log_parser.py mGA modified_ga_log_shadow/communication.log modified_ga_log_shadow/UAV*.tr
!python log_parser.py kSplit ksplit_log_shadow/communication.log ksplit_log_shadow/UAV*.tr
!python log_parser.py kSplit2 ksplit_log_shadow_2/communication.log ksplit_log_shadow_2/UAV*.tr
!python log_parser.py mGA2 modified_ga_log_shadow_2/communication.log modified_ga_log_shadow_2/UAV*.tr
prr_data = readtable('prr_data.csv'); 
collection_data = readtable('collection_data.csv'); 
model_data = readtable('model_output.csv');
run = 0;

if run
    collection_data = collection_data(collection_data.run == run, :);
    prr_data = prr_data(prr_data.run == run, :);
end
dist_int = 1;
dist_slices = [0:dist_int:30].';
unique_ids = unique(prr_data.id, 'rows');
prr_table = table(repmat(dist_slices, size(unique_ids,1),1), ...
                            repmat(unique_ids, size(dist_slices, 1), 1),...
                            zeros(size(dist_slices,1).* size(unique_ids,1),1), ...
                        'VariableNames', {'distance' 'id' 'prr'});
for i=1:size(prr_table,1)
        filtered_distances = prr_data.distance > prr_table.distance(i) & prr_data.distance <= prr_table.distance(i) + dist_int;
        filtered_id = strcmp(prr_table.id(i),prr_data.id);
        all = size(prr_data.success(filtered_id & filtered_distances),1);
        success = sum(prr_data.success(filtered_id & filtered_distances));
        prr_table.prr(i) = success/all;
        
end
prr_table = prr_table(~isnan(prr_table.prr),:);


f = figure;
set(f,'OuterPosition', [ 100 100 570 380 ]);
hold on;
cc=hsv(size(unique_ids,1));
symbols = 'x+.o';
% for i=1:size(unique_ids)
    %grouping = strcmp(unique_ids(i),prr_table.id);
    plot_table = prr_table(:, {'distance' 'prr'});
    plot_table = sortrows(plot_table,'distance');
    scatter(plot_table.distance, plot_table.prr, symbols(1));
    
% end
plot(model_data.distance, model_data.prr);
%unique_ids;
legend('CRATES Simulation', 'NS2 Simulation');
title(sprintf('Plot of PRR vs Distance'));

f = figure;
set(f,'OuterPosition', [ 100 100 570 380 ]);
subplot(1,2,1)
b_axes = [0,size(unique_ids,1) + 1,0,75];
boxplot(collection_data.sent, collection_data.id);
title(sprintf('Comparison of Request Messages Sent'));
axis(b_axes);
subplot(1,2,2);
boxplot(collection_data.received, collection_data.id);
title(sprintf('Comparison of Data Messages Received'));
axis(b_axes);

[h, p, ci, stats] = ttest2(collection_data.sent(strcmp('mGA',collection_data.id)),...
                           collection_data.sent(strcmp('kSplit',collection_data.id)), ...
                           'Tail', 'right');
fprintf(1, 'Alternative Hypothesis, mGA UAVs sent more broadcast than kSplit UAVs= %d, p-value=%0.5e\n', h, p);
%fprintf(1, 'Mean mGA= %.2f, kSplit=%0.2f\n', );

[h, p, ci, stats] = ttest2(collection_data.received(strcmp('mGA',collection_data.id)),...
                           collection_data.received(strcmp('kSplit',collection_data.id)), ...
                           'Tail', 'right');
fprintf(1, 'Alternative Hypothesis, mGA UAVs received more data than kSplit UAVs = %d, p-value=%0.5e\n', h, p);

