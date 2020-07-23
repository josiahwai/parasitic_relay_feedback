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
isearch = find(f > 0.5);  % ignore the zero hz peak

[~,i1] = max(Ay(isearch));  % find fundamental frequency from y
ff_guess = f(i1);

fwindow = 0.05*ff_guess;    % average it with fund freq from u
isearch =  find( abs(f-ff_guess) < fwindow);  
[~,k] = max(Au(isearch));
i2 = isearch(k);
i = round((i1+i2)/2);
ff = f(i);     % averaged fundamental freq


% Create list of harmonic frequencies
f_max = nfreqs*ff / 2;
f_harmonics = (0.5*ff: 0.5*ff: f_max)';


% search within fwindow Hz to find the peaks of each harmonic
% need 2 sets of indices since peak in Ay may be offset slightly from Au
fwindow = 0.05*ff; 
ipks_y = [];
ipks_u = [];

for i = 1:length(f_harmonics)
  isearch = find( abs(f-f_harmonics(i)) < fwindow);
  
  [~,k] = max( Ay( isearch));
  ipks_y(i) = isearch(k);
  
  [~,k] = max( Au( isearch));
  ipks_u(i) = isearch(k);
  
end


% Find gains
ipks = round((ipks_y + ipks_u) / 2);
f_rfb = f(ipks)';
gains_rfb = Y(ipks_y) ./ U(ipks_u);

% Add a point for the zero frequency (steady-state gains)
Kp = trapz(y_data) / trapz(u_data);
gains_rfb = [Kp; gains_rfb];
f_rfb = [0; f_rfb];




















