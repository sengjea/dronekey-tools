function y=sync_tables(sync_table,ber_table, makeplot)
    sync_model =  fitlm(sync_table.timestamp, sync_table.gps_sow, 'linear');
    y = predict(sync_model, ber_table.timestamp);
    if makeplot
        figure
        hold on
        scatter(sync_table.gps_sow, sync_table.timestamp);
        plot(y, ber_table.timestamp, '-r');
    end
end