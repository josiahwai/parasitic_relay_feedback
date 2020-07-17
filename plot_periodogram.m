function [P,f] = plot_periodogram(x, plotit)

if nargin == 1, plotit = 0; end

ts = 5e-5;
Fs = 1/ts;
nfft = length(x);
window = [];
% window = hamming(nfft);

[P,f] = periodogram(x, window, nfft, Fs);

if plotit
  figure
  plot(f,sqrt(P))
  
  ylabel('Amplitude')
  xlabel('Frequency [Hz]')
  
  [~,k] = max(P);
  xlim([0 1.3*f(k)])
end


