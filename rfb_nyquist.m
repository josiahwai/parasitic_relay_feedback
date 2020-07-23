clear; clc; close all;

% ========
% SETTINGS
% ========
Kp = 1;
tau = .1;
D = .002;
NoisePower = 0;
NumOfFreqs = 5;   % number of harmonic peaks to include in fitting
Tsim = 10;

% ========
% SIMULATE
% ========
G_true = make_G(Kp, tau, D);   % transfer function model
sim('RFB_parasitic_method',Tsim)

noise_ratio = mean(abs(noise.data)) / mean(abs(yclean.data)); % noise amplitude ratio

% =========
% ANALYSIS
% =========
t = u.time;
n = length(t);
ts = mean(diff(t));  % sample time
udata = u.data(1:n);
ydata = sgolayfilt(y.data(1:n),3,101);

% Find relay feedback gains
[gains_rfb, f_rfb, f, ipks, Y, Ay, ipks_y, U, Au, ipks_u] = find_rfb_gains...
  (udata, ydata, ts, NumOfFreqs); 

% Fit to a FOPDT model
[Kp_fit, tau_fit, D_fit] = fit_transfer_fun(udata, ydata, ts, gains_rfb, f_rfb);
G_fit = make_G( Kp_fit, tau_fit, D_fit);


% ===============
% DISPLAY RESULTS
% ===============
disp('Fit params Kp, tau, D:')
disp([Kp_fit tau_fit D_fit])

plotshit













