function error_table=packet_error_analyser(recv_table, xmit_table, slices, transmission_delta)

slice_half = (slices(2) - slices(1))/2;
error_table = array2table(zeros(size(slices,2), 3), 'VariableNames', { 'prr', 'ber', 'gps_sow' });
iter = 1;
for slice=slices
    rx_window = recv_table.gps_sow >= slice - slice_half & ...
        recv_table.gps_sow < slice + slice_half;
    tx_window = xmit_table.gps_sow >= (slice - slice_half + transmission_delta) & ...
        xmit_table.gps_sow < (slice + slice_half + transmission_delta);
    
    if ismember('bits_error',recv_table.Properties.VariableNames) == 1
        good_packets_received = size(recv_table.dbm(rx_window & recv_table.bits_error == 0),1);
    else
        good_packets_received = size(recv_table.dbm(rx_window),1);
    end
    
    packets_transmitted = size(xmit_table.numtx(tx_window & xmit_table.status == 0), 1);
    error_table{iter,'prr'} = good_packets_received/packets_transmitted;
    
        if ismember('bits_error',recv_table.Properties.VariableNames) == 1
%         packet_size_range = recv_table.packet_length > packet_length_range(1) & ...
%             recv_table.packet_length < packet_length_range(2);
        total_bits_received = sum(recv_table.packet_length(rx_window ));
    
        bad_bits_received = sum(recv_table.bits_error(rx_window));
        error_table{iter,'ber'} = bad_bits_received/total_bits_received;
        end 
    error_table{iter,'gps_sow'} = slice;
    iter = iter + 1;
end
% mean_bits_received = mean(recv_table.packet_length(packet_size_range ));
%
% error_model_function = @(c,x) (1-qfunc(sqrt(2*(10.^(x(:,1)/10 - (c(1)/10)))))).^mean_bits_received;
% error_model =  fitnlm(error_table.avg_dbm, error_table.prr, error_model_function, [ -90 ]);
% error_model_xvalues = transpose(linspace(-100,-75));
% error_model_yvalues = predict(error_model, error_model_xvalues);
%
% figure;
% hold on;
% scatter(error_table.avg_dbm, error_table.prr, '+');
% %scatter(prr_table.avg_dbm, , '+');
% axis([-100 -75 0 1]);
% %set(gca,'YScale','log');
% plot(error_model_xvalues, error_model_yvalues,'-r');
% if log_file
%     fprintf(log_file, 'mean_bits_received = %.5e\n',mean_bits_received);
%     fprintf(log_file, 'error_model_function = %s\n',func2str(error_model_function));
%     fprintf(log_file, 'where c(1) = %.5e\n', error_model.Coefficients.Estimate(1));
%     fprintf(log_file, 'rsquares = %.5e\n', error_model.Rsquared.Adjusted);
% end
end