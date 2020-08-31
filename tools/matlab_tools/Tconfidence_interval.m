% returns the confidence interval values for a vector of samples x and
% confidence interval CI. Uses the t-distribution, i.e., the mean and
% standard deviation are obtained from the samples and not known for the
% underlying distribuion. 
%
% Inputs: x - vector of samples
%         conf - desired level of confidence between 0 and 1 (ie, 0.95) 
%
% Outputs: lb - lower bound, ub - upper bound of confidence interval

function [lb, ub] = Tconfidence_interval(x, conf)

n = length(x);
dof = n - 1;  % degrees of freedom
alpha = 1 - conf;
p = 1 - alpha/2;      

tstar = icdf('T', p, dof);  % take the inverse of the t-distribution cdf

s = std(x);
xbar = mean(x);

lb = xbar - tstar * s / sqrt(n);
ub = xbar + tstar * s / sqrt(n);









