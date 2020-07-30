% For different noise levels, simulates 3 times to find the hysteresis
% level that places the gain @ ultimate frequency 30deg from neg real axis
%
% Ref: eqns 9 and 10 from Scali, Cottaguiu, "Relay with hysteresis for 
%      monitoring and controller design"

clear; close all; clc

% ========
% SETTINGS
% ========
savedir = '/Users/jwai/Desktop/relay_feedback/sensitivity_analysis/';
NumOfFreqs = 4;   % number of harmonic peaks to include in fitting
Tsim = 10.0;

% model parameters
Kp = 1.5e-4;  
tau = 0.1;  
D = .003;
model_params = [Kp tau D];
G_true = make_G(Kp, tau, D);   % transfer function model

% relay parameters
h = 1;
alpha = 0.2;
bias = 0.2*h;

warning('off','all')

% ===========================
% INCREASING NOISE SIMULATION
% ===========================
% noise_power_list = 1e-15; 
noise_power_list = linspace(0, 9e-16, 10);
hyst_prev = 3e-6;

for k = 3:3 % length(noise_power_list)
  k
  noise_power = noise_power_list(k);  
  
  
  hyst1(k) = hyst_prev * 1.1;
  relay_params = [h alpha bias hyst1(k)];
  sim1(k) = rfb_nyquist_loop( model_params, NumOfFreqs, 0);
  th1(k) = 180 + atan2d(imag(sim1(k).gains_meas(3)), real(sim1(k).gains_meas(3)));
   
  hyst2(k) = mean( abs( sim1(k).noise)) * 4;
  relay_params = [h alpha bias hyst2(k)];  
  sim2(k) = rfb_nyquist_loop( model_params, NumOfFreqs, 1); 
  th2(k) = 180 + atan2d(imag(sim2(k).gains_meas(3)), real(sim2(k).gains_meas(3)));  
  
end


%%
figure
n2 = [sim2.noise_ratio2];

ax(1) = subplot(321);
hold on
plot( n2, [sim2.Kp_err]*100)
scatter( n2, [sim2.Kp_err]*100)
xlabel('Noise Amplitude Ratio')
ylabel('Kp err [%]')
title('Kp err [%]')

ax(2) = subplot(322);
hold on
plot( n2, [sim2.tau_err]*100)
scatter( n2, [sim2.tau_err]*100)
xlabel('Noise Amplitude Ratio')
ylabel('tau err [%]')
title('tau err [%]')

ax(3) = subplot(323);
hold on
plot( n2, [sim2.D_err]*100)
scatter( n2, [sim2.D_err]*100)
xlabel('Noise Amplitude Ratio')
ylabel('D err [%]')
title('D err [%]')

ax(4) = subplot(324);
hold on
plot( n2, [sim2.gains_meas_err]*100)
xlabel('Noise Amplitude Ratio')
ylabel('Gains meas err [%]')
title('Gains meas err [%]')

ax(5) = subplot(325);
hold on
plot( n2, [sim2.gains_fit_err]'*100)
xlabel('Noise Amplitude Ratio')
ylabel('Gains fit err [%]')
title('Gains fit err [%]')


sgtitle(['Kp = ' num2str(Kp) ', tau = ' num2str(tau) ', D = ' num2str(D)], 'fontweight', 'bold')

linkaxes(ax)
ylim([-3 15])
xlim([0 0.8])






































