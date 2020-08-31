clear; close all; clc

% ========
% SETTINGS
% ========
noise_power = 4e-16;
NumOfFreqs = 4;   % number of harmonic peaks to include in fitting
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
hysteresis = 1.2e-5;
relay_params = [h alpha bias hysteresis];

warning('off','all')

% ===========================
% INCREASING NOISE SIMULATION
% ===========================
% noise_power_list = noise_power; 
noise_power_list = linspace(1e-17, 1e-14, 10);

for k = 1:length(noise_power_list)
  
  
  k
  noise_power = noise_power_list(k);
  hysteresis = 4e9*noise_power + 1e-5;
  relay_params = [h alpha bias hysteresis];
  
  e(k) = rfb_nyquist_loop( model_params, NumOfFreqs); 
  e.noise_ratio2
end


%%
% plot results
figure
npl = noise_power_list;

ax(1) = subplot(321);
hold on
plot( npl, [e.Kp_err]*100)
scatter( npl, [e.Kp_err]*100)
xlabel('Noise Power ')
ylabel('Kp err [%]')
title('Kp err [%]')

ax(2) = subplot(322);
hold on
plot( npl, [e.tau_err]*100)
scatter( npl, [e.tau_err]*100)
xlabel('Noise Power ')
ylabel('tau err [%]')
title('tau err [%]')

ax(3) = subplot(323);
hold on
plot( npl, [e.D_err]*100)
scatter( npl, [e.D_err]*100)
xlabel('Noise Power ')
ylabel('D err [%]')
title('D err [%]')

ax(4) = subplot(324);
hold on
plot( npl, [e.gains_meas_err]*100)
xlabel('Noise Power ')
ylabel('Gains meas err [%]')
title('Gains meas err [%]')

ax(5) = subplot(325);
hold on
plot( npl, [e.gains_fit_err]'*100)
xlabel('Noise Power ')
ylabel('Gains fit err [%]')
title('Gains fit err [%]')


ax(6) = subplot(326);
hold on
plot(npl, [e.noise_ratio2]*100, 'b')
plot(npl, [e.noise_ratio1]*100, 'r')
legend('SNR_{amplitude}', 'SNR_{power}', 'location', 'southeast')


sgtitle(['Kp = ' num2str(Kp) ', tau = ' num2str(tau) ', D = ' num2str(D)], 'fontweight', 'bold')

linkaxes(ax)
ylim([-5 70])






