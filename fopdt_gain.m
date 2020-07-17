
function gain = fopdt_gain(freq)
  K = 1;
  T = 0.1;
  D = 0.01;
  
  w = freq*pi*2i;
  gain = (K/(1+T*w))*exp(-D*w); % fopdt model
end