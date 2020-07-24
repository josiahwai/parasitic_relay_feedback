close all

% model parameters
Kp = 1;
tau = 5;
D = 5;
model_params = [Kp tau D];
G_true = make_G(Kp, tau, D);   % transfer function model

% relay parameters
h = 1;
alpha = 0.2;
bias = 0.5;
hysteresis = 0.04;
relay_params = [h alpha bias hysteresis];

% simulation parameters
noise_power = 1e-10;
NumOfFreqs = 5;

warning('off','all')

% ===========================
% INCREASING NOISE SIMULATION
% ===========================
noise_power_list = noise_power; %logspace(-9, -6.5, 20);

for k = 1:length(noise_power_list)
  k
  noise_power = noise_power_list(k);
  e(k) = rfb_nyquist_loop( model_params, NumOfFreqs); 
end


%%
% plot results
figure

ax(1) = subplot(321);
hold on
plot( [e.noise_ratio], [e.Kp_err]*100)
scatter( [e.noise_ratio], [e.Kp_err]*100)
xlabel('Noise Ratio ')
ylabel('Kp err [%]')
title('Kp err [%]')

ax(2) = subplot(322);
hold on
plot( [e.noise_ratio], [e.tau_err]*100)
scatter( [e.noise_ratio], [e.tau_err]*100)
xlabel('Noise Ratio ')
ylabel('tau err [%]')
title('tau err [%]')

ax(3) = subplot(323);
hold on
plot( [e.noise_ratio], [e.D_err]*100)
scatter( [e.noise_ratio], [e.D_err]*100)
xlabel('Noise Ratio ')
ylabel('D err [%]')
title('D err [%]')

ax(4) = subplot(324);
hold on
plot( [e.noise_ratio], [e.gains_meas_err]*100)
xlabel('Noise Ratio ')
ylabel('Gains meas err [%]')
title('Gains meas err [%]')

ax(5) = subplot(325);
hold on
plot( [e.noise_ratio], [e.gains_fit_err]'*100)
xlabel('Noise Ratio ')
ylabel('Gains fit err [%]')
title('Gains fit err [%]')

sgtitle(['Kp = ' num2str(Kp) ', tau = ' num2str(tau) ', D = ' num2str(D)], 'fontweight', 'bold')


linkaxes(ax)
ylim([-10 120])
% xlim([0 0.3])






