% The FFT operates on a single vector without regard to the actual
% (physical) sampling rate. Uses the FFT and sampling rate to obtain the
% FFT in true frequency space.

% Ref: https://www.mathworks.com/help/matlab/ref/fft.html

% INPUTS:
% x - signal vector for fft
% ts - sample time used in sampling x [seconds],
% plotit - flag to make a plot of the results


% EXAMPLE:
% % Create signal
% ts = 0.0001;
% t = 0:ts:2;
% w1 = 30;
% w2 = 8;
% y = 3*sin(w1*2*pi*t) + 2*sin(w2*2*pi*t);  % signal
% [Y, mag_Y, f] = fft_time(y, ts, 1);


function [fft_x, mag_fft_x, f] = fft_time(x, ts, plotit)
  
if ~exist('plotit', 'var'), plotit = 0; end
  
L = length(x);
Fs = 1/ts;  % sampling frequency

 % verify that there are an even number of samples 
if rem(L,2) ~= 0 
  x(end) = [];
  L = L-1; 
end 

fft_x2 = fft(x)/L;                    % 2-sided spectrum
fft_x = fft_x2(1:L/2+1);
fft_x(2:end-1) = 2*fft_x(2:end-1);    % 1-sided spectrum 

mag_fft_x = abs(fft_x);

f = Fs*(0:(L/2))/L;  % frequency basis for 1-sided spectra

if plotit
  figure
  plot(f, mag_fft_x)
  ylabel('Amplitude')
  xlabel('Frequency [Hz]')
  
  [~,imax] = max(fft_x);
  xmax = f(imax) * 3;
  xlim([0 xmax])
  
end
end











