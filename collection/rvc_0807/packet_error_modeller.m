function packet_error_modeller(recv_table, xmit_table, slices, transmission_delta, packet_length_range)

slice_half = (slices(2) - slices(1))/2;
error_table = array2table(zeros(size(slices,2), 3), 'VariableNames', { 'prr', 'ber', 'avg_dbm' });
iter = 1;
for slice=slices
    rx_window = recv_table.gps_sow >= slice - slice_half & ...
        recv_table.gps_sow < slice + slice_half;
    tx_window = xmit_table.gps_sow >= (slice - slice_half + transmission_delta) & ...
        xmit_table.gps_sow < (slice + slice_half + transmission_delta);
    
    
    good_packets_received = size(recv_table.bits_error(rx_window & recv_table.bits_error == 0),1);
    packets_transmitted = size(xmit_table.numtx(tx_window & xmit_table.status == 0), 1);
    error_table{iter,'prr'} = good_packets_received/packets_transmitted;
    
    
    packet_size_range = recv_table.packet_length > packet_length_range(1) & ...
        recv_table.packet_length < packet_length_range(2);
    total_bits_received = sum(recv_table.packet_length(rx_window & packet_size_range ));
    
    bad_bits_received = sum(recv_table.bits_error(rx_window & packet_size_range));
    error_table{iter,'ber'} = bad_bits_received/total_bits_received;
    
    error_table{iter,'avg_dbm'} = mean(recv_table.dbm(rx_window));
    iter = iter + 1;
end
mean_bits_received = mean(recv_table.packet_length(packet_size_range ));
figure;
hold on;
scatter(error_table.avg_dbm, error_table.prr, '+');
%scatter(prr_table.avg_dbm, , '+');
axis([-100 -50 0 1]);
%set(gca,'YScale','log');
error_model_function = @(c,x) (1-qfunc(sqrt(2*(10.^(x(:,1)/10 - (c(1)/10)))))).^mean_bits_received;
error_model =  fitnlm(error_table.avg_dbm, error_table.prr, error_model_function, [ -90 ]);
error_model_xvalues = transpose(linspace(-100,-50));
error_model_yvalues = predict(error_model, error_model_xvalues);
plot(error_model_xvalues, error_model_yvalues,'-r');

end