% Test fit equations
% Ref: Cheng-Ching Yu, Autotuning of PID Controllers
close all
try u = u.Data; catch, end
clearvars -except u yfilt t gains_meas f_meas

Ku = 1/gains_meas(2);
wu = 2*pi*f_meas(2);
[D, a, h, wu, fu, Tu, ta, ta2] = measure_timeseries_params(u, yfilt, t);


% plot(t,u)
% plot(t,yfilt)

syms x
% =========
% EQUATIONS
% =========

% eqn 3.15
tau315 = tan(pi - D*wu) / wu;

% eqn 3.16 - requires a-priori knowledge of Kp
Kp = 1.5e-5;
tau316 = abs( sqrt( (Kp*Ku)^2 - 1) / wu);

% eqn 3.21, eqn4.8 - true fopdt, stable
eqn48 = x == pi / ( wu * log( 2*exp(D/x) - 1));   % 
tau48 = double(vpasolve(eqn48, x));

% eqn 4.9
Kp49 = a / (h  * (1 - exp(-D/tau48)));       

% eqn 4.14 - same as 4.8, but for unstable
eqn414 = x == -pi / ( wu * log( 2*exp( -D/x) - 1));    % eqn 4.14
tau414 = double(vpasolve(eqn414, x));

Kp415 =  a / h  * ( exp(D/tau414) - 1);             % eqn 4.15


% approximated fopdt
eqn418 = 2*exp(-ta2/x) - exp(-ta/x) == 1;   % eqn 4.18
tau418 = double(vpasolve(eqn418, x, [0 0.2]));

D418 = (pi - atan(tau418 * wu)) / wu;
Kp418 = sqrt(1 + (tau418 * wu)^2) / abs(Ku);


% BEST EQUATIONS - D from timeseries, tau418, Kp418
disp(['Tau: ' num2str(tau418)])
disp(['D: '   num2str(D)])
disp(['Kp: '  num2str(Kp418)])

































