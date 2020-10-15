clear all; clc; close all;

% ========
% SETTINGS
% ========
plotit = 1;
saveit = 1;
shot = 23070;

signal_names = {'DESMSOFF', 'DESMSERR'};
savedir = '/Users/jwai/Desktop/relay_feedback/experiment_tools/data/';
load_data_from_mdsplus = 0;

t0 = 0;  % time window to use for plotting
tf = 12;

%%
% =========
% LOAD DATA
% =========
if load_data_from_mdsplus
  signals = get_kstar_mdsplus_data(shot, signal_names{:});
else
  fn = ['signals' num2str(shot)];
  load(fn);
end
struct_to_ws(signals)

%%
% =============
% PLOT AND SAVE
% =============
i = find(DESMSOFF.t > t0 & DESMSOFF.t < tf);

if plotit
  figure
  axa(1) = subplot(221);
  plot(DESMSOFF.t(i), DESMSOFF.y(i))
  legend('DESMSOFF')
  
  axa(2) = subplot(223);
  plot(DESMSERR.t(i), DESMSERR.y(i))
  legend('DESMSERR')
  linkaxes(axa,'x')      
  
  ts = mean(diff(DESMSOFF.t(i)));
  [~,mag,f] = fft_time(DESMSOFF.y(i), ts);
  axb(1) = subplot(222);
  plot(f, mag)
  legend('FFT DESMSOFF')
  
  [~,mag,f] = fft_time(DESMSERR.y(i), ts);
  axb(2) = subplot(224);
  plot(f, mag)
  legend('FFT DESMSERR')
  linkaxes(axb, 'x')  
end


figure
hold on
plot(DESMSOFF.t(i), DESMSOFF.y(i))
plot(DESMSERR.t(i), DESMSERR.y(i) * 2e6)
grid on


[~, ~, ~, ~, ~, ~, signKp] = measure_timeseries_params(DESMSOFF.y, DESMSERR.y, DESMSERR.t);

if saveit
  fn = ['signals' num2str(shot)];
  save([savedir fn], 'signals')
end
