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
D = .01;
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
noise_power_list = linspace(0, 9e-15, 10);
hyst_prev = 3e-5;

for k = 4:4 % 1:length(noise_power_list)
  k
  noise_power = noise_power_list(k);  
    
  % starting guess
  hyst1 = hyst_prev * 1.1;
  relay_params = [h alpha bias hyst1];
  sim1 = rfb_nyquist_loop( model_params, NumOfFreqs, 0); 
  th1 = 180 + atan2d(imag(sim1.gains_meas(3)), real(sim1.gains_meas(3)));
  
  % Update guess
  hyst2 = hyst1*30/th1;
  relay_params = [h alpha bias hyst2]; 
  sim2 = rfb_nyquist_loop( model_params, NumOfFreqs, 0); 
  th2 = 180 + atan2d(imag(sim2.gains_meas(3)), real(sim2.gains_meas(3)));  
  
  % Update guess again
  hyst3 = hyst2 + (hyst2 - hyst1) / (th2 - th1) * (30 - th2);  
  relay_params = [h alpha bias hyst3];  
  sim3 = rfb_nyquist_loop( model_params, NumOfFreqs, 1);   
  th3 = 180 + atan2d(imag(sim3.gains_meas(3)), real(sim3.gains_meas(3)));
  
  
  hyst_prev = hyst3;
  hyst(k)  = hyst3;
  ymax(k) = max(sim3.yfilt);
  n1(k) = sim3.noise_ratio1;
  n2(k) = sim3.noise_ratio2;    
  gain_err(k) = norm(sim3.gains_meas_err);
end


figure
hold on
subplot(211)
plot(n2, hyst./ymax)
ylabel('Hysteresis / Ymax')
xlabel('Amplitude Noise Ratio')
title('"Optimal Hysteresis" -- Gain(ultimate freq) @ 30deg')

subplot(212)
plot(n2, gain_err)
ylabel('Gain Measurement Error chi^2')
xlabel('Amplitude Noise Ratio')

save([savedir 'noise_power_list'], 'noise_power_list')
save([savedir 'hyst'], 'hyst')











































