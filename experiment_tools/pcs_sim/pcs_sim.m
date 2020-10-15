clear all; clc; close all;
load('ROOT')
% =================
% RELAY PARAMETERS
% =================
shot = 23070;
Tsim = 12;
d = 1;
alpha = [0.1 0.1 0.1 0.1 0.1];
nparasites = nnz(alpha);
output_bias_frac = 0;
input_bias = 0;
hysteresis = 3e-4;
relay_params = [d output_bias_frac input_bias hysteresis nparasites alpha];


% % load data
% DESMSERR = load(['err' num2str(shot) '.out']);
% t = DESMSERR(:,2);
% [t,i] = sort(t);
% y = DESMSERR(i,1);
% t_spaced = linspace(t(1), t(end), length(t))';
% y_spaced = interp1(t, y, t);
% DESMSERR = [t_spaced y_spaced];
% ts = mean(diff(t_spaced));

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
sim([simdir 'RFB_parasitic_method.slx'], Tsim);
cd(current_dir);

%%
% PLOT
figure
ax(1) = subplot(211);
hold on
grid on
plot(u.Time, -u.Data)

ax(2) = subplot(212);
hold on
grid on
plot(y.Time, y.Data)
yline(hysteresis ,'r');
yline(-hysteresis, 'r');
linkaxes(ax,'x')
% xlim([5.62 5.64])
































