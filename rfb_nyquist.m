clear; clc; close all;

% ========
% SETTINGS
% ========
Kp = 1;
tau = .1;
D = .01;
NoisePower = 0.000000001;
NumOfFreqs = 5;   % number of harmonic peaks to include in fitting
Tsim = 10;

% ========
% SIMULATE
% ========
G_true = make_G(Kp, tau, D);   % transfer function model
sim('RFB_parasitic_method',Tsim)
clearvars -except u y G_true NumOfFreqs NoisePower

% =========
% ANALYSIS
% =========
t = u.time;
ts = mean(diff(t));  % sample time
udata = u.data;
ydata = sgolayfilt(y.data,3,101);

% Find relay feedback gains
[gains_rfb, f_rfb, ipks, f, Y, U, Ay, Au] = find_rfb_gains(udata, ydata, ts, NumOfFreqs); 

% Fit to a FOPDT model
[Kp_fit, tau_fit, D_fit] = fit_transfer_fun( gains_rfb, f_rfb);
G_fit = make_G( Kp_fit, tau_fit, D_fit);


% ===============
% DISPLAY RESULTS
% ===============
disp('Fit params Kp, tau, D:')
disp([Kp_fit tau_fit D_fit])

plotshit













