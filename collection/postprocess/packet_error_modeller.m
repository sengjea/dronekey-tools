function packet_error_modeller(recv_table, xmit_table, time_slices, transmission_delta, packet_length_range)
slice_half = (time_slices(2) - time_slices(1))/2;
prr_table = array2table(zeros(size(time_slices,2), 4), 'VariableNames', { 'gps_sow', 'prr', 'ber', 'avg_dbm' });
iter = 1;
for time_slice=time_slices
    rx_window = recv_table.gps_sow >= time_slice - slice_half & ...
        recv_table.gps_sow < time_slice + slice_half;
    tx_window = xmit_table.gps_sow >= (time_slice - slice_half + transmission_delta) & ...
        xmit_table.gps_sow < (time_slice + slice_half + transmission_delta);
    packet_size_range = recv_table.packet_length > packet_length_range(1) & ...
                            recv_table.packet_length < packet_length_range(2);
    
    good_packets_received = size(recv_table.bits_error(rx_window & recv_table.bits_error == 0),1);
    packets_transmitted = size(xmit_table.numtx(tx_window & xmit_table.status == 0), 1);
    
    total_bits_received = sum(recv_table.packet_length(rx_window & packet_size_range ));
    bad_bits_received = sum(recv_table.bits_error(rx_window & packet_size_range));
    
    prr_table{iter,'gps_sow'} = time_slice;
    prr_table{iter,'prr'} = good_packets_received/packets_transmitted;
    prr_table{iter,'ber'} = bad_bits_received/total_bits_received;
    prr_table{iter,'avg_dbm'} = mean(recv_table.dbm(rx_window));
    iter = iter + 1;
end
figure;
    hold on;
    scatter(prr_table.avg_dbm, prr_table.prr, [], prr_table.ber, '+');
    %scatter(prr_table.avg_dbm, , '+');
    axis([-100 -50 0 1.2]);
end