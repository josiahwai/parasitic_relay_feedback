% EXAMPLE:
% signal_data = get_kstar_mdsplus_data(23070, 'DESMSOFF', 'DESMSERR');
% struct_to_ws(signal_data);
% figure
% subplot(211)
% plot(DESMSOFF.t, DESMSOFF.y)
% subplot(212)
% plot(DESMSERR.t, DESMSERR.y)


% =================
% LOAD MDSPLUS DATA
% =================
function signals_data = get_kstar_mdsplus_data(shot, varargin)
  
  setenv('MDSPLUS_DIR', '/usr/local/mdsplus');
  MDSPLUS=getenv('MDSPLUS_DIR');
  addpath(genpath(MDSPLUS))
  
  mdsconnect('172.17.250.21:8005');
  tree = 'kstar';
  mdsopen(tree,shot);
  
  signals_data = [];  
  for iarg = 1:length(varargin)
    
    signal_name = varargin{iarg};
    
    y = mdsvalue(['\' signal_name]);
    t = mdsvalue(['DIM_OF(\' signal_name ')']); 
    
    signals_data = setfield(signals_data, signal_name, 'y', y);
    signals_data = setfield(signals_data, signal_name, 't', t);
       
  end
  
  mdsclose;
  mdsdisconnect;
end

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  