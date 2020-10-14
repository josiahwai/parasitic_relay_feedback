ccc
load('KSTARMSPEC23070DATA.mat')
ts = mean(diff(t_ACTUATOR_MSPEC));

figure
plot(t_ACTUATOR_MSPEC, ACTUATOR_MSPEC)

fft_time(ACTUATOR_MSPEC, ts, 1);
title('ACTUATOR MSPEC')


%%
uraw = ACTUATOR_MSPEC;
utraw = t_ACTUATOR_MSPEC;
yraw = MEASUREMENT_MSPEC;
ytraw = t_MEASUREMENT_MSPEC;

% ========
% SETTINGS
% ========
plotit = 1;

% ====================================
% LOAD DATA, FIND MINI-XP TIME WINDOWS
% ====================================
clearvars -except yraw ytraw uraw utraw plotit

% find the time windows for each mini-xp
t = utraw;
ts = mean(diff(ytraw));

i = find( abs(uraw) < 10);
j1 = find( ~ismember(i-1,i));
j0 = find( ~ismember(i+1,i));

istart = i(j0(1:end-1));
iend = i(j1(2:end));

tstart = t(istart);
tend = t(iend);

% plot time windows
if plotit
  figure
  ax(1) = subplot(211);
  hold on
  plot(ytraw, yraw)
  ylabel('y')
  ax(2) = subplot(212);
  hold on
  plot(utraw, uraw)
  ylabel('u')

  for k = 1:length(tstart)
    iwindow = istart(k):iend(k);
    umax = 1.05*max(uraw(iwindow));
    umin = 1.05*min(uraw(iwindow));
                
    xbox = [tstart(k) tstart(k) tend(k) tend(k) tstart(k)];
    ybox = [umin umax umax umin umin];
    
    plot(xbox, ybox, 'g', 'linewidth', 2);      
    ylim([umin umax] * 1.3)
  end
  
  linkaxes(ax, 'x')
end

%%
for k = 1:length(tstart)
  iwindow = istart(k):iend(k);
  
  fft_time(uraw(iwindow), ts, plotit);

  
end
















