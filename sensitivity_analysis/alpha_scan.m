% For different noise levels, simulates 3 times to find the hysteresis
% level that places the gain @ ultimate frequency 30deg from neg real axis
%
% Ref: eqns 9 and 10 from Scali, Cottaguiu, "Relay with hysteresis for 
%      monitoring and controller design"

clear; close all; clc

% ========
% SETTINGS
% ========
noise_power = 1.1e-17;
NumOfFreqs = 4;   % number of harmonic peaks to include in fitting
Tsim = 10;

% model parameters
Kp = 1.5e-5;  
tau = 0.03;  
D = .003;
model_params = [Kp tau D];
G_true = make_G(Kp, tau, D);   % transfer function model

% relay parameters
h = 1;
bias = 0.2;
hysteresis = 1.8e-6;

warning('off','all')

% ==========
% BIAS SCANS
% ==========
hysteresis_list = linspace(0,0.8,20);

for k = 1:length(alpha_list)
  k
  alpha = alpha_list(k);
  relay_params = [h alpha bias hysteresis];
  
  sim(k) = rfb_nyquist_loop( model_params, NumOfFreqs, 1); 
end

%%
figure

ax(1) = subplot(321);
hold on
plot( alpha_list, [sim.Kp_err]*100)
scatter( alpha_list, [sim.Kp_err]*100)
xlabel('alpha')
ylabel('Kp err [%]')
title('Kp err [%]')

ax(2) = subplot(322);
hold on
plot( alpha_list, [sim.tau_err]*100)
scatter( alpha_list, [sim.tau_err]*100)
xlabel('alpha')
ylabel('tau err [%]')
title('tau err [%]')

ax(3) = subplot(323);
hold on
plot( alpha_list, [sim.D_err]*100)
scatter( alpha_list, [sim.D_err]*100)
xlabel('alpha')
ylabel('D err [%]')
title('D err [%]')

ax(4) = subplot(324);
hold on
plot( alpha_list, [sim.gains_meas_err]*100)
xlabel('alpha')
ylabel('Gains meas err [%]')
title('Gains meas err [%]')

ax(5) = subplot(325);
hold on
plot( alpha_list, [sim.gains_fit_err]'*100)
xlabel('alpha')
ylabel('Gains fit err [%]')
title('Gains fit err [%]')

linkaxes(ax)
ylim([-3 30])
xlim([0 1])









































