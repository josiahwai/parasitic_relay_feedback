clear all; clc; close all;

% ========
% SETTINGS
% ========
shot = 23070; 
load_data_from_mdsplus = 0;
saveit = 1;
data_dir = '/Users/jwai/Desktop/relay_feedback/experiment_tools/data/';
fig_dir = '/Users/jwai/Desktop/relay_feedback/experiment_tools/figs/';

signal_names = {'DESMSOFF', 'DESMSERR', 'SYSIPS1A', 'SYSIPS2A', 'SYSIPS3A'};
%%
% =========
% LOAD DATA
% =========
if load_data_from_mdsplus
  signals = get_kstar_mdsplus_data(shot, signal_names{:});
else
  load(['signals' num2str(shot)]);
end
%%
% =============
% PLOT AND SAVE
% =============
figure
sgtitle(num2str(shot))

nsignals = length(signal_names);
ncols = 2;
nrows = ceil(nsignals/ncols);
fields = fieldnames(signals);

for i = 1:nsignals
  try
    y = getfield(signals, fields{i}, 'y');
    t = getfield(signals, fields{i}, 't');
    
    ax(i) = subplot(nrows, ncols, i);
    plot(t,y)
    title(fields{i})
  catch
  end
end
linkaxes(ax, 'x')


if saveit
  data_fn = [data_dir 'signals' num2str(shot)];
  fig_fn = [fig_dir num2str(shot)];
  
  save(data_fn, 'signals')
  savefig(gcf, fig_fn)
end
























