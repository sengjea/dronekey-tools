% x(:,1) = packet_length, x(:,2) = rssi 

prr_model_function = @(x) (1-qfunc(sqrt(2*(10.^(x(:,1)/10 - (-94/10)))))).^(400);
x = [-10:-1:-100].';
figure
hold on
plot(x, prr_model_function(x));