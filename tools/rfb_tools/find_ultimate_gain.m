% Find the ultimate frequency and gain for a relay feedback timeseries

function [Gu, wu] = find_ultimate_gain(u, y, t, plotit)

if ~exist('plotit', 'var'), plotit = 0; end

ts = mean(diff(t));

% FFT transform
[Y,Ay]   = nfft(y, ts);
[U,Au,f] = nfft(u, ts);

% find ultimate frequency
isearch = find(f > 0.05);   % ignore the zero hz peak
[~,k] = max(Au(isearch));   % find ultimate frequency from u
ipk_u = isearch(k);
ff_u = f(ipk_u);

fwindow = 0.05*ff_u;  % find ultimate frequency from y
isearch =  find( abs(f-ff_u) < fwindow);
[~,k] = max(Ay(isearch));
ipk_y = isearch(k);
ff_y = f(ipk_y);
  
wu = (ff_u + ff_y) * pi; % averaged ultimate angular frequency  
Gu = Y(ipk_y) / U(ipk_u); % ultimate gain
  

if plotit
  subplot(211)
  hold on
  plot(f,Ay)
  xlim([0 100])
  scatter(f(ipk_y), Ay(ipk_y), 'r')
  
  subplot(212)
  hold on
  plot(f,Au)
  xlim([0 100])
  scatter(f(ipk_u), Au(ipk_u), 'r')
end


















