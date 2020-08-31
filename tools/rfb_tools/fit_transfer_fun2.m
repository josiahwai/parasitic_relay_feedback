function [Kp_fit, tau_fit, D_fit] = fit_transfer_fun2(Kp0, tau0, D0, gains_measured, f_measured, fit_wts)

if ~exist('fit_wts', 'var'), fit_wts = ones(size(f_measured)); end

% ===========================================
% Perform weighted least squares optimization
% ===========================================
param0 = [Kp0 tau0 D0];
lb = [-inf -inf 0];  % delay must be positive for a causal system

opts = optimset('display', 'off');
opts.TolFun = 1e-12;

params_hat = lsqnonlin(@weighted_fopdt_err, param0, ...
  lb, [], opts, f_measured, gains_measured);

[Kp_fit, tau_fit, D_fit] = unpack(params_hat);


% Error function for weighted lsqonlin
function err = weighted_fopdt_err(params, f_measured, gains_measured)

[Kp, tau, D] = unpack(params);
w = f_measured*pi*2i;
gains_fit = ( Kp ./ ( 1 + tau .* w)) .* exp( -D.*w); 
err = fit_wts .* (gains_fit - gains_measured);

err = [real(err) imag(err)];

end
end






