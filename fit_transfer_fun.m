% Fit a FOPDT transfer function using weighted nonlinear least squares
% Eventually, should upgrade to include other model types beyond FOPDT

function [Kp_fit, tau_fit, D_fit] = fit_transfer_fun(gains_measured, f_measured)


param0 = [1.2 0.08 0.005]'; % starting guess for Kp, D, tau

params_hat = lsqnonlin(@weighted_fopdt_err, param0, ...
  [], [], [], f_measured, gains_measured);

params_hat = real(params_hat);
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

end
end











