% For different noise levels, simulates 3 times to find the hysteresis
% level that places the gain @ ultimate frequency 30deg from neg real axis
%
% Ref: eqns 9 and 10 from Scali, Cottaguiu, "Relay with hysteresis for 
%      monitoring and controller design"

clear; close all; clc

% ========
% SETTINGS
% ========
noise_power = 2e-17;
NumOfFreqs = 3;   % number of harmonic peaks to include in fitting
Tsim = 10;

% model parameters
Kp = 1.5e-5;  
tau = 0.03;  
D = .003;
model_params = [Kp tau D];
G_true = make_G(Kp, tau, D);   % transfer function model

% relay parameters
h = 1;
bias = 0.25;
alpha = 0.25;

warning('off','all')

% ==========
% BIAS SCANS
% ==========
h_list = [0 0.5 1 1.2 1.5 1.7 2 2.5 3] * 1e-6;

for k = 1:length(h_list)
  k
  hysteresis = h_list(k);
  relay_params = [h hysteresis bias hysteresis];
  
  sim(k) = rfb_nyquist_loop( model_params, NumOfFreqs, 1); 

  mean_noise(k) = mean(abs(sim(k).noise));
end

%%
figure
false_switching = [1 1 1 1 1 0 0 0 0];
hold on
stairs(h_list./mean_noise, false_switching, 'linewidth', 2)
scatter(h_list./mean_noise, false_switching, 'r')
ylim([-0.1 1.1])
xlabel('Hysteresis / Noise Amplitude')
ylabel('False Switching Present')
title('False Switching')

figure
subplot(311)
plot(h_list./mean_noise, [sim.th])
ylabel('Deg from negative real axis')

subplot(312)
plot(h_list./mean_noise, [sim.gains_fit_err]*100)
ylabel('Gain Errors [%]')
ylim([-5 40])

subplot(313)
plot(h_list./mean_noise, [sim.tau_err]*100)
xlabel('Hysteresis')
ylabel('tau Err [%]')
ylim([-5 40])





























