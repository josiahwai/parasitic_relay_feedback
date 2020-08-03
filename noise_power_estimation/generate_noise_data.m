clear all; clc; close all;

% ========
% SETTINGS
% ========
saveit = 1;
savedir = '/Users/jwai/Desktop/relay_feedback/noise_power_estimation/';

noise_power = 4e-17;
Tsim = 10;

% model parameters
Kp = 1.5e-5;  
tau = 0.03;  
D = .003;
model_params = [Kp tau D];

% relay parameters
h = 1;
alpha1 = 0.25;
alpha2 = 0;
bias_f = 0.2;
hysteresis = 3e-6;
relay_params = [h alpha1 alpha2 bias_f hysteresis];
use_2_parasites = boolean(alpha2); % flag to indicate to look for freqs from 2nd parasite

% ========
% SIMULATE
% ========
G_true = make_G(Kp, tau, D);   % transfer function model
sim('RFB_parasitic_method',Tsim)

if saveit
  t = u.time;
  u = u.data;  
  y_meas = y.data;
  y_clean = yclean.data;
  noise = noise.data;
  
  vars = {'t', 'u', 'y_meas', 'y_clean', 'noise'};
  for i = 1:length(vars)
    save([savedir vars{i}], vars{i});
  end
end
  
  
  
  
  
  
  
  
  
  
  
  