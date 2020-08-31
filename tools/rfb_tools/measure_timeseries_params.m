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

function [D, ta, ta2, ta2_lb, ta2_ub, ta2sigma, signKp, a, h, wu, fu, Tu] = ...
  measure_timeseries_params(u, y, t, plotit)

if ~exist('plotit','var'), plotit = 0; end

ts = mean(diff(t)); % sample time

u = u - mean(u);    % remove offsets
y = y - mean(y);

iup = find( diff(u) > 0.95*max(u));   % indices where relay switched up
idown = find( diff(u) < 0.95*min(u)); %            "                 down
iswitch = sort([iup; idown]);

nperiod = round(mean(diff(iswitch))*2);
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

% Measure delays: after each relay switch, find the time till peak y
nhalfpds = length(iswitch) - 1;
for ihalfpd = 1:nhalfpds
  
  i = iswitch(ihalfpd);
  isearch = floor(i-nperiod/20:i+nperiod/4);
  isearch = isearch(isearch > 0 & isearch < length(y));
  
  [~,dum] = max(abs(y(isearch)));
  ipk_y = isearch(dum);
  
  delays(ihalfpd) = t(ipk_y) - t(i);
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


iswitches = find( abs( diff(u)) > 0.99 * max(u));
ndelay = round(D/ts);
ta_list = [];
ta2_list = [];

for i = 2:( length( iswitches) - 2)
  
  % sensor noise can cause relay to switch too frequently
  % check that the surrounding switches are valid (far enough apart)
  iswitch0 = iswitches(i);
  iswitch1 = iswitches(i+1);
  iswitch2 = iswitches(i+2);
  
  if (2 * (iswitch1 - iswitch0) > 0.7 * nperiod) && (2 * (iswitch2 - iswitch1) > 0.7 * nperiod)
    
    isearch0 = (iswitch0 - 1 * ndelay):(iswitch0 + 2 * ndelay);
    isearch1 = (iswitch1 - 1 * ndelay):(iswitch1 + 2 * ndelay);
    
    [~,dum] = max( abs( y(isearch0)));
    ipk0 = isearch0(dum);
    pk0 = y(ipk0);
    
    [~,dum] = max( abs( y(isearch1)));
    ipk1 = isearch1(dum);
    pk1 = y(ipk1);
    
    % half-rise time
%     mp = (pk1 + pk0) / 2;  % midpoint level to cross
    mp = 0;
    idx = ipk0:ipk1;
    nhalfrise = find( ( y(idx(1:end-1)) - mp) .* ( y(idx(2:end)) - mp) < 0, 1);
    
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
ta = mean(ta_list);
ta2 = mean(ta2_list);

ta_frac = ta2_list ./ ta_list;
[ta_frac_lb, ta_frac_ub] = Tconfidence_interval(ta_frac, 0.95);
ta2_lb = ta_frac_lb * ta;
ta2_ub = ta_frac_ub * ta;






end





























