% Fit a FOPDT transfer function using weighted nonlinear least squares
% Eventually, should upgrade to include other model types beyond FOPDT

function [Kp_fit, tau_fit, D_fit] = fit_transfer_fun(u, y, ts, gains_measured, f_measured)

% ==============================================
% Obtain a starting guess for the fit parameters
% ==============================================

% read delay D from timeseries
y_thresh = .05 * mean(abs(y));
u_thresh = .05 * mean(abs(u));
iu0 = find( abs(u) > u_thresh, 1);
iy0 = find( abs(y) > y_thresh, 1);
D0 = ts * (iy0 - iu0);

% Read Kp and ultimate gain and frequency 
Kp0 = gains_measured(1);
Ku = gains_measured(3);
wu = 2*pi*f_measured(3);

% eqn 3.16
tau0 = sqrt( (Kp0*Ku)^2 - 1) / wu;

param0 = abs([Kp0 tau0 D0]');
% ===========================================
% Perform weighted least squares optimization
% ===========================================

lb = [-inf -inf 0]; % time delay must be positive

params_hat = lsqnonlin(@weighted_fopdt_err, param0, ...
  lb, [], [], f_measured, gains_measured);

[Kp_fit, tau_fit, D_fit] = unpack(params_hat);


% Error function for weighted lsqonlin
function err = weighted_fopdt_err(params, f_measured, gains_measured)

nf = length(f_measured);

% ADJUST THESE FOR WEIGHTED FITTING
fit_wts = ones(nf, 1);                   % equal weighting
% fit_wts = [10; 1; 10; ones(nf-3,1)];   % high weighting on steady-state, fundamental freqs
% fit_wts = [1; 10; 10; ones(nf-3,1)];   % high weighting on fundamental freq and 0.5x fundamental

[Kp, tau, D] = unpack(params);
w = f_measured*pi*2i;
gains_fit = ( Kp ./ ( 1 + tau .* w)) .* exp( -D.*w); 
err = fit_wts .* (gains_fit - gains_measured);

err = [real(err) imag(err)];

end
end











