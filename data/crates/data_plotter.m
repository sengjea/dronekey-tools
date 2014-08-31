clear all; clc; close all;
!rm *.csv
!python log_parser.py mGA modified_ga_log_shadow/communication.log modified_ga_log_shadow/UAV*.tr
!python log_parser.py kSPlit ksplit_log_shadow/communication.log ksplit_log_shadow/UAV*.tr
prr_data = readtable('prr_data.csv'); 
collection_data = readtable('collection_data.csv'); 

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
for i=1:size(unique_ids)
    grouping = strcmp(unique_ids(i),prr_table.id);
    plot_table = prr_table(grouping, {'distance' 'prr'});
    plot_table = sortrows(plot_table,'distance');
    scatter(plot_table.distance, plot_table.prr);
end
legend(unique_ids);
title(sprintf('Plot of PRR vs Distance'));

f = figure;
set(f,'OuterPosition', [ 100 100 570 380 ]);
subplot(1,2,1)
boxplot(collection_data.sent, collection_data.id, 'labelorientation', 'inline');
title(sprintf('Comparison of Request Messages Sent'));
axis([0,3,0,50]);
subplot(1,2,2);
boxplot(collection_data.received, collection_data.id, 'labelorientation', 'inline');
title(sprintf('Comparison of Data Messages Received'));
axis([0,3,0,50]);


