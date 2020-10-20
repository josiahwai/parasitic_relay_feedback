clear all; clc; close all;
load('ROOT')
% =================
% RELAY SETTINGS
% =================
shot = 23070;
t_relay_start = 0;
tend = 12;
d = 1;
alpha = [0.3 0 0 0 0];
nparasites = nnz(alpha);
output_bias_frac = 0;
input_bias = 0;
hysteresis = 2e-4;
maxrmp = 1.5;

%%
relay_params = [t_relay_start maxrmp d output_bias_frac input_bias hysteresis nparasites alpha];

load(['signals' num2str(shot)]);
t = double(signals.DESMSERR.t);
y = double(signals.DESMSERR.y);
y(t<0) = [];
t(t<0) = [];
ts = mean(diff(signals.DESMSERR.t));
DESMSERR = [t y];

% ========
% SIMULATE
% ========
simdir = [ROOT '/experiment_tools/pcs_sim/simulink/'];
current_dir = pwd;
cd(simdir);
sim([simdir 'parasitic_relay.slx'], tend);
cd(current_dir);

%%
% PLOT
figure
ax(1) = subplot(211);
hold on
grid on
plot(u.Time, u.Data/2)
ylim([-1 1] * maxrmp);

ax(2) = subplot(212);
hold on
grid on
plot(y.Time, y.Data)
yline(hysteresis ,'r');
yline(-hysteresis, 'r');
linkaxes(ax,'x')
xlim([8.1 8.5])
































