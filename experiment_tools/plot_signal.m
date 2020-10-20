clear all; clc; close all;

% ========
% SETTINGS
% ========
plotit = 1;
saveit = 1;
shot = 23070;
load_data_from_mdsplus = 0;

signal_names = {'DESMSOFF', 'DESMSERR'};
savedir = '/Users/jwai/Desktop/relay_feedback/experiment_tools/data/';

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
struct_to_ws(signals);

%%
% =============
% PLOT AND SAVE
% =============
i = find(DESMSOFF.t > t0 & DESMSOFF.t < tf);


if plotit
  figure
  axa(1) = subplot(221);
  hold on
  grid on
  plot(DESMSOFF.t(i), DESMSOFF.y(i))
  f = 0.5* max(DESMSOFF.y) / median( findpeaks( DESMSERR.y, 'sortstr', ...
    'descend', 'Npeaks', 10, 'Minpeakdistance', 200)) ;
  plot(DESMSERR.t(i), DESMSERR.y(i) * f)
  legend('DESMSOFF', 'DESMSERR')
  
  axa(2) = subplot(223);
  hold on
  grid on
  plot(DESMSERR.t(i), DESMSERR.y(i), 'r')
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
  xlim([0 600])
end


[~, ~, ~, ~, ~, ~, signKp] = measure_timeseries_params(DESMSOFF.y, DESMSERR.y, DESMSERR.t);
disp(['Inferred signKp: ' num2str(signKp)])

if saveit
  fn = ['signals' num2str(shot)];
  save([savedir fn], 'signals')
end
