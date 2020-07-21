% Obtain transfer function for fopdt model from relay feedback experiment
% Ref: Cheng-Ching Yu, Autotuning of PID Controllers

[Py,f] = plot_periodogram(y.data, 0);
[Pu,f] = plot_periodogram(u.data, 0);

Ay = sqrt(Py);
Au = sqrt(Pu);

% Calculate gains
Au2 = Au;
thresh = min(maxk(Au2,20));  % use a threshold to ignore divs by zero
Au2(Au2 < thresh) = nan;
G = Ay ./ Au2;

% ultimate frequency and gain
[~,imax] = max(Ay);
wu = 2*pi*f(imax);
Ku = 1/G(imax);       

% read delay D from timeseries
y_thresh = .05 * mean(abs(y.data));
u_thresh = .05 * mean(abs(u.data));
iu0 = find( abs(u.data) > u_thresh, 1);
iy0 = find( abs(y.data) > y_thresh, 1);
tsample = 5e-5;  % sampling rate [s]
D = tsample * (iy0 - iu0);


% find Kp from timeseries (requires biased relay)
Kp = trapz(y.data) / trapz(u.data);


% eqn 3.15 of Ref
tau315 = tan(pi - D*wu) / wu;


% eqn 3.16
tau316 = sqrt( (Kp*Ku)^2 - 1) / wu;


% eqn 3.21 
syms t
eqn321 = t == pi / (wu * log( 2 * exp(D/t) - 1));
tau321 = double( vpasolve( eqn321, t));

fprintf('\n')
disp(['Kp: '     num2str(Kp)])
disp(['D: '      num2str(D)])
disp(['tau315: ' num2str(tau315)])
disp(['tau316: ' num2str(tau316)])
disp(['tau321: ' num2str(tau321)])




















