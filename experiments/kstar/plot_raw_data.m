clear all; clc; close all;

% ========
% SETTINGS
% ========
load('21081analysis.mat')

% ==============
% PLOT RAW DATA
% ==============

vars = {yraw, uraw, hystraw, I_fixed_AMP, I_lower_AMP, I_lower_AMP_comb, ...
  I_lower_ANG, I_remain_AMP, I_remain_AMP_comb, I_remain_ANG, I_upper_AMP, ...
  I_upper_AMP_comb, I_upper_ANG, LM01, LM02, LM03, LM04, LMdiff, ...
  LMdiff_corrected, MID_ENABLE, PCLM01, PCLM02, PCLM03, PCLM04, TOP_ENABLE};

varnames = {'yraw', 'uraw', 'hystraw', 'I fixed AMP', 'I lower AMP', 'I lower AMP comb', ...
  'I lower ANG', 'I remain AMP', 'I remain AMP comb', 'I remain ANG', 'I upper AMP', ...
  'I upper AMP comb', 'I upper ANG', 'LM01', 'LM02', 'LM03', 'LM04', 'LMdiff', ...
  'LMdiff corrected', 'MID ENABLE', 'PCLM01', 'PCLM02', 'PCLM03', 'PCLM04', 'TOP ENABLE'};


t129872 = utraw;
t375802 = PCLM01t;
t600000 = LM01t;
n = length(vars);

figure
for i = 1:n
  
  switch length(vars{i})
    case 129872
      t = t129872;
    case 375802
      t = t375802;
    case 600000
      t = t600000;
  end
  
  ax(i) = subplot( ceil(n/4), 4, i);
  plot(t, vars{i})
  title(varnames{i})
  xlim([0 10])
  
end

set(gcf, 'Position', [92 48 1271 858])


















