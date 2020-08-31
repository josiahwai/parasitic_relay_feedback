% Ref: Cheng-Ching Yu, Autotuning of PID Controllers

function [Kp, tau] = fopdt_fit_eqns(Gu, ta, ta2, signKp)

wu = pi / ta; 
Ku = 1 / Gu;

% approximated fopdt eqns from eqn 4.18 of Ref
eqn418 = @(x) 2*exp(-ta2./x) - exp(-ta./x) - 1; 
try
  bounds = [sqrt(eps) 10];
  tau = fzero( eqn418, bounds);
  Kp = signKp * sqrt(1 + (tau * wu)^2) / abs(Ku);
catch
  tau = nan;
  Kp = nan;
end





