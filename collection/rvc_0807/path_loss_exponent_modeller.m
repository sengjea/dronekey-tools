function rx_power_model=path_loss_exponent_modeller(distance_values, dbm_values, grouping_values, Pt_, freq_, plot_, log_file)
dist0_ = min(distance_values);
if 1
    mod_distance_values = log10(distance_values);   
    rx_power_function = @(c,x) -10 * c(2) * x(:,1) + c(1);
else
    mod_distance_values = distance_values;
    rx_power_function = @(c,x) c(1) -  10 * c(2) * log10(x(:,1)./dist0_);
end
mod_dist0_ = min(mod_distance_values);

rx_power_model =  fitnlm(mod_distance_values, dbm_values, rx_power_function, [-90 6]);

rx_power_model_xvalues = transpose(linspace(mod_dist0_,max(mod_distance_values)));
rx_power_model_yvalues = predict(rx_power_model, rx_power_model_xvalues);
Pr0_dbm  = predict(rx_power_model, mod_dist0_);
Pr0_ = 10.^(Pr0_dbm./10);
lambda_ = 299792458/freq_;
L_ = (Pt_ / Pr0_) * (lambda_ /(4 * pi * dist0_))^2;

%% PLot Figure
    if plot_
        figure;
        hold on;
        scatter(mod_distance_values, dbm_values, [], grouping_values, '.');
        
        plot(rx_power_model_xvalues, rx_power_model_yvalues,'-r');
        plot(rx_power_model_xvalues, rx_power_model_yvalues + 2 * rx_power_model.RMSE,'-y');
        plot(rx_power_model_xvalues, rx_power_model_yvalues - 2 * rx_power_model.RMSE,'-y');
        title('Log distance vs RSSI');
        xlabel('Log distance (log(m))');
        ylabel('RSSI values (dBm)');
    end
%% Logging Function
if log_file
    fprintf(log_file, 'Time: %s\n', datestr(now,'yyyy/mm/dd HH:MM:SS'));
    fprintf(log_file, 'path_loss_function = %s\n',func2str(rx_power_function));
    fprintf(log_file, 'where c(1) = %.5e, c(2) = %.5e\n', ...
        rx_power_model.Coefficients.Estimate(1), rx_power_model.Coefficients.Estimate(2));
    fprintf(log_file, 'rsquares = %.5e\n', rx_power_model.Rsquared.Adjusted);
    fprintf(log_file, '#--------NS2 Parameters---------\n');
    fprintf(log_file, 'Propagation/Shadowing set std_db_ %.5e\n', rx_power_model.RMSE);
    fprintf(log_file, 'Propagation/Shadowing set dist0_ %.5e\n', dist0_);
    fprintf(log_file, 'Propagation/Shadowing set pathlossExp_ %.5e\n', rx_power_model.Coefficients.Estimate(2));
    fprintf(log_file, 'Phy/WirelessPhy set Pt_ %.5e\n', Pt_);
    fprintf(log_file, 'Phy/WirelessPhy set freq_ %.5e\n', freq_);
    fprintf(log_file, 'Phy/WirelessPhy set L_ %.5e\n', L_);
    fprintf(log_file, '#--------------------------------------\n');
end
end