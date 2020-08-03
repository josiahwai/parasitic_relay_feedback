% Noise power relationship in the simulink Band-Limited-White-Noise block: 
% noise_power = variance(noise) * ts
% 
% see https://www.mathworks.com/matlabcentral/answers/457180-relationship-between-noise-power-in-a-band-limited-white-noise-block-vs-variance-in-a-random-number

clc; clear all; close all;

load('y_meas')
load('u')
load('t')
ts = mean(diff(t));
use_2_parasites = 0;

% ================================
% CODE REUSE FROM find_rfb_gains.m 
% ================================

% FFT transform
[Y,Ay,f] = fft_time(y_meas, ts);

% Find fundamental frequency and harmonics
isearch = find(f > 0.05);   % ignore the zero hz peak
[~,i] = max(Ay(isearch));   % find fundamental frequency from y
i1 = isearch(i);
ff = f(i1);

% Create list of harmonic frequencies
if use_2_parasites
  mult = 0.25;
else
  mult = 0.5;
end
f_harmonics = (0: mult*ff: max(f))';


% ================================
% Estimate noise power by removing
%  the true signal (f_harmonics
% ================================
thresh = 0.05*ff;

for i = 1:length(f)
  if min( abs( f(i) - f_harmonics)) < thresh
    i_ignore(i) = true;
  else
    i_ignore(i) = false;
  end
end

Py = Ay.^2;
Pnoise = Py;
Pnoise(i_ignore) = [];

% Estimated noise statistics
est_noise_power = mean(Pnoise);
est_noise_stdev = sqrt( est_noise_power / ts);
est_amp_noise_ratio = est_noise_stdev / std(y_meas);
est_power_noise_ratio = est_amp_noise_ratio ^ 2;

% True noise statistics
load('noise')
load('y_clean')
psd_noise = periodogram(noise, [], length(noise), 1/ts);
psd_y = periodogram(y_clean, [], length(y_clean), 1/ts);

true_noise_power = var(noise) * ts;
true_noise_stdev = std(noise);
true_amp_noise_ratio = mean(abs(noise)) / mean(abs(y_clean));
true_power_noise_ratio = mean(psd_noise) / mean(psd_y);

% Display results
format shortG
disp('TRUE:') 
disp('[noise_power, std_deviation, amplitude_noise_ratio, power_noise_ratio]')
disp([true_noise_power true_noise_stdev true_amp_noise_ratio true_power_noise_ratio])
disp('ESTIMATED:')
disp([est_noise_power est_noise_stdev est_amp_noise_ratio est_power_noise_ratio])























































