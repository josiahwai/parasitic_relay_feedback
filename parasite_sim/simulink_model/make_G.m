function G = make_G(Kp, tau, D)
  s = tf('s');
  G = (Kp / (1 + tau*s)) * exp(-D*s);
end
