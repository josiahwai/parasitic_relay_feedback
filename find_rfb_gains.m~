% Given a time history of input u and measurement y, find the relay
% feedback gains at various frequencies. Filters the FFT of u and y 
% based on 3 criteria below to find a set of frequencies to evaluate at. 
%
% Returns: gains_rfb, f_rfb the gains and frequencies [Hz] and FFT parameters

function [gains_rfb, f_rfb, f, ipks, Y, Ay, ipks_y, U, Au, ipks_u] = ...
  find_rfb_gains(u_data, y_data, ts, nfreqs)

% FFT transform
[Y,Ay,f] = fft_time(y_data, ts);
[U,Au,f] = fft_time(u_data, ts);

% Find fundamental frequency and harmonics
isearch = find(f > 0.05);   % ignore the zero hz peak
[~,k] = max(Ay(isearch)); % find fundamental frequency from y
i1 = isearch(k);
ff_y = f(i1);

fwindow = 0.1*ff_y;  % find fundamental frequency from u
isearch =  find( abs(f-ff_y) < fwindow);  
[~,k] = max(Au(isearch));
i2 = isearch(k);
ff_u = f(i2);

i = round((i1+i2)/2);  % averaged fundamental freq
ff = f(i);                 

% Create list of harmonic frequencies
f_harmonics_y = (0.5*ff_y: 0.5*ff_y: nfreqs*ff_y/2)';
f_harmonics_u = (0.5*ff_u: 0.5*ff_u: nfreqs*ff_u/2)';

% search within fwindow Hz to find the peaks of each harmonic
% need 2 sets of indices since peak in Ay may be offset slightly from Au
ipks_y = [];
ipks_u = [];

for i = 1:nfreqs
  isearch = find( abs(f-f_harmonics_y(i)) < fwindow);  
  [~,k] = max( Ay( isearch));
  ipks_y(i) = isearch(k);
  
  isearch = find( abs(f-f_harmonics_u(i)) < fwindow);    
  [~,k] = max( Au( isearch));
  ipks_u(i) = isearch(k);
  
end


% Find gains
ipks = round((ipks_y + ipks_u) / 2);
f_rfb = f(ipks)';
gains_rfb = Y(ipks_y) ./ U(ipks_u);

% Add a point for the zero frequency (steady-state gain == Kp)
% The formula is: Kp = integral(y dt) / integral(u dt)
% However, time window for integration can affect Kp estimate significantly 
% Therefore, integrate over multiple time windows and average. 

n = length(u_data);
samples_per_pd = 10;   % sample Kp 10 times per period
nperiods = 10;         % average over 10 periods
period = 1 / f_rfb(1);   
dwindow = round( 0.5 * period / (samples_per_pd*ts)); 

istart = (dwindow * samples_per_pd * nperiods+1);
iwindow0 = istart:n-istart;

for i = 1:nperiods*samples_per_pd
  yidx = iwindow0 + (i-1) * dwindow;
  uidx = iwindow0 - (i-1) * dwindow;
  Kp(i) = trapz( y_data( yidx)) / trapz( u_data( uidx));
end

Kp = mean(Kp);

gains_rfb = [Kp; gains_rfb];
f_rfb = [0; f_rfb];




















