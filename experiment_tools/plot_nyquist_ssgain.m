% ========
% SETTINGS
% ========
shot = 21801;   % 23070;
t0 = [2 3 4 6 7];         % timeslice to use for nyquist plot
tf = [2.9 3.9 4.9 6.9 7.9];
figdir = '/Users/jwai/Desktop/relay_feedback/experiment_tools/figs/';

% ==========
% LOAD DATA
% ==========
load(['signals' num2str(shot)]);
struct_to_ws(signals);
u_all = DESMSOFF.y;
y_all = DESMSERR.y;
t_all = DESMSOFF.t;
ts = mean(diff(t_all));


% ============================
% FIND SSGAIN WITH 2 METHODS
% ============================
Kp_bias = [];
Kp_time = [];
nregions = length(t0);
for i = 1:nregions
  
  iwindow = find( t_all > t0(i) & t_all < tf(i));  
  u = u_all(iwindow);
  y = y_all(iwindow);
  t = t_all(iwindow);
  yfilt = sgolayfilt(y,3,21);
  
  % BIAS METHOD
  Kp_bias(i) = get_Kp_bias_method(u,yfilt);
  
  
  % TIME-RESPONSE METHOD 
  [Gu, wu] = find_ultimate_gain(u, yfilt, t);
  
  [D, ta, ta2, ta2_lb, ta2_ub, ta2sigma, signKp] = ...
    measure_timeseries_params(u, yfilt, t);
  
  [Kp_time(i), tau(i)] = fopdt_fit_eqns(Gu, ta, ta2, signKp);
  
  
end


% PLOT IT
openfig([figdir 'nyquist.fig']);
plot(real(Kp_bias), imag(Kp_bias), 'rx', 'linewidth', 4, 'markersize', 12)
plot(real(Kp_time), imag(Kp_time), 'bx', 'linewidth', 4, 'markersize', 12)
legend('Kp bias', 'Kp time')
yplotmax = max(abs([Kp_time Kp_bias]));
xlim([-1 1]*yplotmax*1.1)
axis equal

% ============================
% FUNCTION: GET KP BIAS METHOD
% ============================
function Kp = get_Kp_bias_method(u,y)
  nwindows = 10;
  n = length(u);
  istart = floor(0.2*n);
  dwindow = floor(istart)/nwindows;
  iwindow0 = istart:n-istart;

  for i = 1:nwindows
    yidx = iwindow0 + (i-1) * dwindow;
    uidx = iwindow0 - (i-1) * dwindow;
    Kp(i) = trapz( y( yidx)) / trapz( u( uidx));
  end

  Kp = mean(Kp);
end








