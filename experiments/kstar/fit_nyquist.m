% Fits a nyquist plot to KSTAR experimental data
% and obtains the transfer function estimate

clear all; clc; close all;

% ========
% SETTINGS
% ========
plotit = 1;

% ====================================
% LOAD DATA, FIND MINI-XP TIME WINDOWS
% ====================================
load('21081analysis.mat')
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

% =====================================
% FIND ULTIMATE AND STEADY-STATE GAINS
% =====================================
sections = [1:3 5:6];  % section 4 has bad data
nsections = length(sections);
for isection = 1:nsections
  
  section = sections(isection);    
  iwindow = istart(section):iend(section);
  
  u = uraw(iwindow);
  y = yraw(iwindow);
  t = ytraw(iwindow);  
  yfilt = sgolayfilt(y,3,21);
  
  % ultimate gain
  [Gu, wu] = find_ultimate_gain(u, yfilt, t);
  
  % estimate Kp, tau and the lower and upper bounds
  [D, ta, ta2, ta2_lb, ta2_ub, ta2sigma, signKp] = ...
    measure_timeseries_params2(u, yfilt, t);
  
  [Kp, tau] = fopdt_fit_eqns(Gu, ta, ta2, signKp);
  [Kp_lb, tau_lb] = fopdt_fit_eqns(Gu, ta, ta2_lb, signKp);  
  [Kp_ub, tau_ub] = fopdt_fit_eqns(Gu, ta, ta2_ub, signKp);
     
  % save to struct
  fits.Gu(isection)     = Gu;
  fits.wu(isection)     = wu;
  fits.fu(isection)     = wu / (2*pi);
  fits.D(isection)      = D;
  fits.Kp(isection)     = Kp;
  fits.Kp_lb(isection)  = Kp_lb;
  fits.Kp_ub(isection)  = Kp_ub;
  fits.tau(isection)    = tau;
  fits.tau_lb(isection) = tau_lb;
  fits.tau_ub(isection) = tau_ub;
  fits.ta(isection) = ta;
  fits.ta2(isection) = ta2;
  fits.ta2_lb(isection) = ta2_lb;
  fits.ta2_ub(isection) = ta2_ub;
  fits.ta2sigma(isection) = ta2sigma;
  
end  

%%
% ======================
% Fit transfer function
% ======================
clc
iuse = ~isnan(fits.Kp);

p = 0.8;
Kp0 = signKp * pmedian( fits.Kp(iuse), p);
tau0 = pmedian( fits.tau(iuse), p);
D0 = pmedian( fits.D(iuse), p);

G0 = make_G( Kp0, tau0, D0);

gains_meas = [fits.Gu fits.Kp(iuse)];
f_meas = [fits.fu   zeros(size(fits.Kp(iuse)))];

% assign weights on Kp related to 
dkp = abs( fits.Kp(iuse) - fits.Kp_lb(iuse));
Kp_wts = 0.2 * (min(dkp) ./ dkp) .^ (1/4);

fit_wts = [3 3 3 1 1  Kp_wts];

[Kp_fit, tau_fit, D_fit] = fit_transfer_fun2(Kp0, tau0, D0, gains_meas, f_meas, fit_wts);
Gfit = make_G(Kp_fit, tau_fit, D_fit);

format shorte
disp(['Kp: ' num2str(Kp_fit)])
disp(['tau: ' num2str(tau_fit)])
disp(['D: ' num2str(D_fit)])
format short

%%
figure
hold on

% nyquist(G0, 'r')
nyquist(Gfit, 'b')

% plot ultimate gains
scatter( real(fits.Gu), imag(fits.Gu), 'b', 'filled')

% plot ssgains and error bars
xneg = fits.Kp_ub - fits.Kp;
xpos = fits.Kp_lb - fits.Kp;
i = isnan(fits.Kp_ub);
xneg(i) = -1.5*xpos(i);
y = ((1:nsections) - nsections/2) * 1e-10;
errorbar( fits.Kp, y, xneg, xpos, 'horizontal', 'o', 'color', 'r', ...
  'markerfacecolor', 'b')


xlabel('Real')
ylabel('Imag')
grid on
axis equal
axis([-0.3528    0.0378   -0.1350    0.1313] * 1e-7)
set(gcf, 'position', [276 334 879 644])






































