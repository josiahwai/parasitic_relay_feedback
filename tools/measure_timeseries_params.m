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
%   ta - the time it takes to reach max amplitude, y(ta) = a, measured from
%        the most recent zero crossing of y
%   ta2 - the time it takes to reach half of max amplitude, y(ta2) = a/2,
%         measured from the most recent zero crossin of y
%
% Restrictions: algorithm was written for a single relay and has not been
% tested for more complicated systems such as the parasitic relay
%
% Author: Josiah Wai, 8/2020

function [D, a, h, wu, fu, Tu, ta, ta2] = measure_timeseries_params(u,y,t)

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

pks = findpeaks(abs(y), 'minpeakheight', max(y)/2, 'minpeakdistance', nperiod/3);
a = mean(pks);

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
  
% ============================
% METHOD 1: Measure ta and ta2
% ============================
[~,ipks_pos] = findpeaks(  y, 'minpeakheight', max(y) * 0.5, 'minpeakdistance', nperiod * 0.8);
[~,ipks_neg] = findpeaks( -y, 'minpeakheight', max(y) * 0.5, 'minpeakdistance', nperiod * 0.8);

% find the zero crossings after each peak
for i = 1: ( min( length(ipks_neg), length(ipks_pos)) - 1)
  
  isearch1 = ipks_neg(i):ipks_neg(i) + floor(nperiod/2);
  isearch2 = ipks_neg(i):ipks_neg(i) + floor(nperiod/2);
  
  izerocross1 = find( y(isearch1(1:end-1)) .* y(isearch1(2:end)) < 0, 1);
  izerocross2 = find( y(isearch2(1:end-1)) .* y(isearch2(2:end)) < 0, 1);

  ta2_list(i,1) = ts*izerocross1;
  ta2_list(i,2) = ts*izerocross2;
end

ta2_list = reshape(ta2_list, [], 1);

ta2 = mean(rmoutliers(ta2_list));  
ta = Tu/2;



% ============================
% METHOD 2: Measure ta and ta2
% ============================
% izerocrosses = find( y(1:end-1) .* y(2:end) < 0);
% 
% for i = 1:(length(izerocrosses)-1)  
%   izerocross = izerocrosses(i);
%   
%   isearch = floor(izerocross:izerocross+nperiod*0.6);
%   
%   % measure time to peak and time till half peak
%   [apk, delta_ia] = max(abs(y(isearch)));   
%   ta_list(i) = ts*delta_ia;
%   
%   delta_ia2 = find( abs(y(isearch)) >= apk/2, 1);
%   ta2_list(i) = ts*delta_ia2;
%   
% end
% 
% ta = mean(rmoutliers(ta_list));
% ta2 = mean(rmoutliers(ta2_list));


% figure
% hold on
% plot(t, u)
% plot(t, 1.2 * y * h / a)
% xlim( [t(1) t(1)+8*Tu])

end

 



























