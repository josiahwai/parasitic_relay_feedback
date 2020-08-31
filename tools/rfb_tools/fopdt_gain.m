
function gain = fopdt_gain(freq, Kp, tau, D) 
  w = freq*pi*2i;
  gain = ( Kp ./ ( 1 + tau .* w)) .* exp( -D.*w); % fopdt model
end