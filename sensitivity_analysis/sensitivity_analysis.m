clear; close all; clc

% ========
% SETTINGS
% ========
noise_power = 100e-16;
NumOfFreqs = 5;   % number of harmonic peaks to include in fitting
Tsim = 10.0;

% model parameters
Kp = 1.5e-4;  
tau = 0.1;  
D = .01;
model_params = [Kp tau D];
G_true = make_G(Kp, tau, D);   % transfer function model

% relay parameters
h = 1;
alpha = 0.2;
bias = 0.2*h;
hysteresis = 4.5e-5;
relay_params = [h alpha bias hysteresis];

warning('off','all')

% ===========================
% INCREASING NOISE SIMULATION
% ===========================
noise_power_list = noise_power; % logspace(-17, -14, 10); 

for k = 1:length(noise_power_list)
  
  noise_power = noise_power_list(k);
  e(k) = rfb_nyquist_loop( model_params, NumOfFreqs); 
end


%%
% plot results
figure

ax(1) = subplot(321);
hold on
plot( [e.noise_ratio2], [e.Kp_err]*100)
scatter( [e.noise_ratio2], [e.Kp_err]*100)
xlabel('Noise Ratio ')
ylabel('Kp err [%]')
title('Kp err [%]')

ax(2) = subplot(322);
hold on
plot( [e.noise_ratio2], [e.tau_err]*100)
scatter( [e.noise_ratio2], [e.tau_err]*100)
xlabel('Noise Ratio ')
ylabel('tau err [%]')
title('tau err [%]')

ax(3) = subplot(323);
hold on
plot( [e.noise_ratio2], [e.D_err]*100)
scatter( [e.noise_ratio2], [e.D_err]*100)
xlabel('Noise Ratio ')
ylabel('D err [%]')
title('D err [%]')

ax(4) = subplot(324);
hold on
plot( [e.noise_ratio2], [e.gains_meas_err]*100)
xlabel('Noise Ratio ')
ylabel('Gains meas err [%]')
title('Gains meas err [%]')

ax(5) = subplot(325);
hold on
plot( [e.noise_ratio2], [e.gains_fit_err]'*100)
xlabel('Noise Ratio ')
ylabel('Gains fit err [%]')
title('Gains fit err [%]')

sgtitle(['Kp = ' num2str(Kp) ', tau = ' num2str(tau) ', D = ' num2str(D)], 'fontweight', 'bold')

linkaxes(ax)






