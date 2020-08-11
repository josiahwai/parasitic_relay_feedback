clear all; clc; close all;
addpath([pwd '/tools'])
addpath([pwd '/sensitivity_analysis'])
addpath([pwd '/noise_power_estimation'])

% ========
% SETTINGS
% ========
NumOfFreqs = 5;   % number of harmonic peaks to include in fitting
Tsim = 2;

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
alpha = [0 0 0 0 0];
nparasites = nnz(alpha);
output_bias_frac = 0.1;
input_bias = 1e-6;
hysteresis = 2e-6;

relay_params = [d output_bias_frac input_bias hysteresis nparasites alpha];


% ========
% SIMULATE
% ========
G_true = make_G(Kp, tau, D);   % transfer function model
sim('RFB_parasitic_method',Tsim)

% =========
% ANALYSIS
% =========
t = u.time;
n = length(t);
ts = mean(diff(t));  % sample time
Fs = 1/ts; 
udata = u.data(1:n);
yfilt = sgolayfilt(y.data(1:n),3,101);
yclean = yclean.data(1:n);
noise = noise.data(1:n);

% noise-to-signal power spectrum ratio and amplitude ratio
psd_noise = periodogram(noise, [], n, Fs);
psd_y = periodogram(yclean, [], n, Fs);

noise_ratio1 = mean(psd_noise) / mean(psd_y);
noise_ratio2 = mean(abs(noise)) / mean(abs(yclean));

% Find relay feedback gains
[gains_meas, f_meas, f, ipks, Y, Ay, ipks_y, U, Au, ipks_u] = find_rfb_gains ...
  (udata, yfilt, ts, NumOfFreqs, nparasites); 

% Fit to a FOPDT model
[Kp_fit, tau_fit, D_fit] = fit_transfer_fun(udata, yfilt, ts, gains_meas, f_meas);
G_fit = make_G( Kp_fit, tau_fit, D_fit);


% ===============
% DISPLAY RESULTS
% ===============
disp('Fit params Kp, tau, D:')
format long
disp([Kp_fit tau_fit D_fit])

plotshit







































