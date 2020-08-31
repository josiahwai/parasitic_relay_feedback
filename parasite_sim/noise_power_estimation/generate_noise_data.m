clear all; clc; close all;
load('ROOT')

% ========
% SETTINGS
% ========
saveit = 1;
savedir = [ROOT 'parasite_sim/noise_power_estimation/'];

Tsim = 10;

% model parameters
Kp = 1.5e-5;  
tau = 0.03;  
D = .003;
model_params = [Kp tau D];

% sensor noise
noise_power = 3e-17;  
noise_bias = 1e-6;

% relay parameters
d = 1;
alpha = [0.2 0.2 0 0 0];
nparasites = nnz(alpha);
output_bias_frac = 0.1;
input_bias = 1e-6;
hysteresis = 2e-6;

relay_params = [d output_bias_frac input_bias hysteresis nparasites alpha];

% ========
% SIMULATE
% ========
G_true = make_G(Kp, tau, D);   % transfer function model
simdir = [ROOT '/parasite_sim/simulink_model/']; 
current_dir = pwd;
cd(simdir);
sim([simdir 'RFB_parasitic_method.slx'], Tsim);
cd(current_dir);

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
  
  
  
  
  
  
  
  
  
  
  
  