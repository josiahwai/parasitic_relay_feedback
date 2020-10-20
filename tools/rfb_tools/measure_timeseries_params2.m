% Extract some parameters measurable from the relay feedback timeseries
%
% INPUTS: u - vector of control inputs, y - vector of measured outputs, t -
%         times associated with u and y
%
% OUTPUTS: all outputs are averaged over the # of relay cycles with biases
% removed
%
%   D - dead time for a FOPDT model measured by diff in time between
%       relay switching and the time at which y(t) peaks and reverses
%   a - peak amplitudes of y
%   h - relay amplitude from u
%   wu - ultimate frequency (radians)
%   fu - ultimate frequency (Hz)
%   Tu - ultimate period
%   ta - the time it takes y to travel from -a to +a (and vice versa)
%   ta2 - the time it takes y to travel from -a to 0 (or +a to 0)
%   ta2_lb - 90% confidence interval lower bound on ta2 estimate
%   ta2_ub -            "            uppper           "
%   signKp - the sign of the steady state gain parameter, Kp. 
%            
%
% Restrictions: algorithm was written for a single relay and has not been
% tested for more complicated systems such as the parasitic relay
%
% Author: Josiah Wai, 8/2020
% Modified 10/2020, interpolate the ta2 value

function [D, ta, ta2, ta2_lb, ta2_ub, ta2sigma, signKp, a, h, wu, fu, Tu] = ...
  measure_timeseries_params2(u, y, t, plotit)


if ~exist('plotit','var'), plotit = 0; end

ts = mean(diff(t)); % sample time

y = y - mean(y);

iup = find( diff(u) > 0.1*max(u));   % indices where relay switched up
idown = find( diff(u) < 0.1*min(u)); %            "                 down
iswitches = sort([iup; idown]);

nperiod = round(median(diff(iswitches))*2);
Tu = nperiod * ts;
fu = 1/Tu;
wu = 2*pi*fu;

[pks, ipks_y] = findpeaks(abs(y), 'minpeakheight', max(y)/2, 'minpeakdistance', nperiod/3);
a = mean(pks);

% when y(t) reaches its peak, u(t) switched slightly in the past (delay = D
% seconds ago). Therefore if u(t) and y(t) have the same sign at the
% peaks in y, Kp is negative. 
signKp = -mode( sign( u(ipks_y) .* y(ipks_y)));

h = ( max(u) - min(u)) / 2;

for i = 1:length(ipks_y)
  ipk_y = ipks_y(i);
  k = find(iswitches < ipk_y, 1, 'last');
  delays(i) = ts * (ipk_y - iswitches(k));
end
D = mean(rmoutliers(delays));

% ==================
% Measure ta and ta2
% ==================

if plotit
  figure
  hold on
  yyaxis left
  plot(t,u)
  yyaxis right
  plot(t,y)
  xlim([t(1) t(1)+ts*nperiod*8])
end



% Search settings
nclean_switches = 2;       % min # of clean switches on either side of the current
t_minthresh = 0.5 * Tu/2;  % min time between switching to be considered 'clean'
t_maxthresh = 2 * Tu/2;  % max ...

ndelay = round(D/ts);
ta_list = [];
ta2_list = [];

for i = nclean_switches + 1: (length(iswitches) - nclean_switches - 1)
  
  
  inearby_switches = iswitches(i + (-nclean_switches:nclean_switches));
  switch_times = diff(inearby_switches) * ts;
  clean = all( switch_times > t_minthresh & switch_times < t_maxthresh);
  
  if clean
    
    nwindow = floor( Tu / ts / 4);
    window = -nwindow:nwindow;
    isearch0 = iswitches(i) + ndelay + window;
    isearch1 = iswitches(i+1) + ndelay + window;   
          
%     [~,dum] = max( abs( y(isearch0)));
    [~,dum] = findpeaks( abs( y(isearch0)), 'npeaks', 1, 'sortstr', 'descend');
    ipk0 = isearch0(dum);
    pk0 = y(ipk0);
    
    % [~,dum] = max( abs( y(isearch1)));
    [~,dum] = findpeaks( abs( y(isearch1)), 'npeaks', 1, 'sortstr', 'descend');
    ipk1 = isearch1(dum);
    pk1 = y(ipk1);
    
    % half-rise time
    % mp = (pk1 + pk0) / 2;  % midpoint level to cross
    mp = 0;
    idx = ipk0:ipk1;
    z = y(idx) - mp;
    nhalfrise = find( z(1:end-1) .* z(2:end) < 0, 1);
    nhalfrise = nhalfrise - z(nhalfrise) / ( z(nhalfrise+1) - z(nhalfrise)) - 1;
                
    if ~isempty(nhalfrise)
      ta_list = [ta_list; ts * (ipk1 - ipk0)];  % rise time
      ta2_list = [ta2_list; nhalfrise * ts];    % half-rise time
      
      if plotit
        yyaxis right
        scatter( t(idx(1)) + ta2_list(end), mp, 'k', 'filled')
        scatter( t(ipk0), pk0, 'b', 'filled')
        scatter( t(ipk1), pk1, 'b', 'filled')
      end
    end
  end
end

[~,i1] = rmoutliers(ta_list);
[~,i2] = rmoutliers(ta2_list);

ta_list = ta_list( ~i1 & ~i2);
ta2_list = ta2_list( ~i1 & ~i2);
ta2sigma = std(ta2_list);

% calculate confidence interval bounds on the samples of ta and ta2 
% the most important factor is the ratio between ta and ta2, therefore we
% can fix ta and put the bounds on ta2. 
ta = pmean(ta_list, 0.8);
ta2 = pmean(ta2_list, 0.8);

ta_frac = ta2_list ./ ta_list;
[ta_frac_lb, ta_frac_ub] = Tconfidence_interval(ta_frac, 0.95);
ta2_lb = ta_frac_lb * ta;
ta2_ub = ta_frac_ub * ta;

ta2 = pmean(ta_frac, 0.8) * ta;

end





























