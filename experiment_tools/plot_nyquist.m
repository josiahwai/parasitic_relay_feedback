clear all; clc; close all;

% ========
% SETTINGS
% ========
% shot = 21801;
shot =  23070; 
t0 = [4 6]; % [2 3 4 6 7];       % timeslice to use for nyquist plot
tf = [4.9 6.9]; % [3 4 5 7 8];
numfreqs = 4;
figdir = '/Users/jwai/Desktop/relay_feedback/experiment_tools/figs/';

% ==========
% LOAD DATA
% ==========
fn = ['signals' num2str(shot)];
load(fn);
struct_to_ws(signals);
u_all = DESMSOFF.y;
y_all = DESMSERR.y;
t_all = DESMSOFF.t;
ts = mean(diff(t_all));

% ===================
% FIND NYQUIST POINTS
% ===================
gains_meas = {};
nregions = length(t0);
for iregion = 1:nregions
  
  iwindow = find( t_all > t0(iregion) & t_all < tf(iregion));
  
  u = u_all(iwindow);
  y = y_all(iwindow);
  t = t_all(iwindow);
  
  [U,Au,~] = fft_time(u, ts);
  [Y,Ay,f] = fft_time(y, ts);
  
  [~,imax] = max(Ay);
  
  [~,i_use] = findpeaks(Au,'SortStr', 'descend', 'NPeaks', numfreqs, ...
      'minpeakdist', imax / 3); %10/mean(diff(f)));    
  f_use = f(i_use);
  
  figure
  sgtitle(['TIME: ' num2str(t0(iregion)) '-' num2str(tf(iregion))]);  
  ax(1) = subplot(211);
  grid on
  hold on
  plot(f,Au);
  scatter(f_use, Au(i_use), 'o')
  xlim([0 500])
  
  ax(2) = subplot(212);
  grid on
  hold on
  plot(f,Ay);
  scatter(f_use, Ay(i_use), 'o')
  xlim([0 500])
  linkaxes(ax,'x');
  
    
  gains_meas{iregion} = Y(i_use) ./ U(i_use);
end




fn = [figdir 'nyquist.fig'];
savefig(gcf, fn);



























