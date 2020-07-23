
% model parameters
Kp = 1;
tau = .1;
D = .002;
model_params = [Kp tau D];
G_true = make_G(Kp, tau, D);   % transfer function model

% relay parameters
h = 1;
alpha = 0.2;
bias = 0.5;
hysteresis = 0.04;
relay_params = [h alpha bias hysteresis];

% simulation parameters
noise_power = 1e-10;
NumOfFreqs = 5;

e = rfb_nyquist_loop( model_params, NumOfFreqs); 



