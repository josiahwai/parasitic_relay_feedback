function D = measure_delay(u,y,t)

iup = find( diff(u) > 0.95*max(u));
idown = find( diff(u) < 0.95*min(u));
iswitch = sort([iup; idown]);
nperiod = round(mean(diff(iswitch))*2); 

delays = [];
for isample = 1:(length(iswitch)-1)
   
  i = iswitch(isample);
  isearch = floor(i-nperiod/20:i+nperiod/4);
  isearch = isearch(isearch > 0 & isearch < length(y));
  
  [~,dum] = max(abs(y(isearch)));
  ipk_y = isearch(dum);
  
  delays = [delays; t(ipk_y) - t(i)];  
end

D = mean(rmoutliers(delays));
  






























