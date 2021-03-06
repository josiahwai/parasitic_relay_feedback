% Pretty much the same thing as rfb_nyquist.m but as a function so that it
% can be run in a loop to do sensitivity analysis. 

% Returns: e - struct with normalized errors

function e = rfb_nyquist_loop( model_params, NumOfFreqs, plotit) 

if nargin == 2, plotit = 0; end
[Kp, tau, D] = unpack(model_params);
G_true = make_G(Kp, tau, D);   % transfer function model

% =========
% SIMULATE
% =========
Tsim = 10;
sim('RFB_parasitic_method',Tsim)

% =========
% ANALYSIS
% =========
t = u.time;
n = length(t);
ts = mean(diff(t));  % sample time
Fs = 1/ts;           % sample frequency
udata = u.data(1:n);
yfilt = sgolayfilt(y.data(1:n),3,101);
yclean = yclean.data(1:n);
noise = noise.data(1:n);

% noise-to-signal power spectrum ratio and amplitude ratio
psd_noise = periodogram(noise, [], n, Fs);
psd_y = periodogram(yclean, [], n, Fs);

noise_ratio1 = mean(psd_noise) / mean(psd_y);
noise_ratio2 = mean(abs(noise)) / mean(abs(yclean)); 

% Find relay feedback gains
[gains_meas, f_meas, f, ipks, Y, Ay, ipks_y, U, Au, ipks_u] = ...
  find_rfb_gains(udata, yfilt, ts, NumOfFreqs); 

% Fit to a FOPDT model
[Kp_fit, tau_fit, D_fit] = fit_transfer_fun(udata, yfilt, ts, gains_meas, f_meas);
G_fit = make_G( Kp_fit, tau_fit, D_fit);

if plotit, plotshit; end

% ===============
% MEASURE ERRORS
% ===============
gains_true = fopdt_gain( f_meas, Kp, tau, D);
gains_fit = fopdt_gain( f_meas, Kp_fit, tau_fit, D_fit);

e.Kp_err = abs( (Kp_fit - Kp) / Kp);
e.tau_err = abs( (tau_fit - tau) / tau);
e.D_err = abs( (D_fit - D) / D);

e.gains_fit_err = norm( abs((gains_true - gains_fit)) ./ abs(gains_true));
e.gains_meas_err = norm( abs((gains_true - gains_meas)) ./ abs(gains_true));

e.noise_ratio1 = noise_ratio1;
e.noise_ratio2 = noise_ratio2;

e.gains_meas = gains_meas;
e.f_meas = f_meas;
e.yfilt = yfilt;
e.noise = noise;

e.th = 180 + atan2d(imag(gains_meas(3)), real(gains_meas(3)));






