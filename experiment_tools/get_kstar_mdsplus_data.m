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
  
  tree = 'kstar';
  
  setenv('MDSPLUS_DIR', '/usr/local/mdsplus');
  MDSPLUS=getenv('MDSPLUS_DIR');
  addpath(genpath(MDSPLUS))
  
  status = mdsconnect('172.17.250.21:8005');
  connectioncheck(status, 'Connected', 'Could not connect');
  
  status = mdsopen(tree,shot);
  connectioncheck(status, 'Tree opened', 'Could not open tree');
  
  signals_data = [];  
  for iarg = 1:length(varargin)
    
    signal_name = varargin{iarg};
    disp(['Fetching ' signal_name]);
    
    y = mdsvalue(['\' signal_name]);
    t = mdsvalue(['DIM_OF(\' signal_name ')']); 
    
    signals_data = setfield(signals_data, signal_name, 'y', y);
    signals_data = setfield(signals_data, signal_name, 't', t);
       
  end
  
  status = mdsclose;
  connectioncheck(status, 'Tree closed', 'Could not close tree');
   
  status = mdsdisconnect;
  connectioncheck(status, 'Disconnected', 'Could not disconnect');
  
  
  function connectioncheck(status, msgtrue, msgfalse)
    if status > 0
      disp(msgtrue)
    else
      warning(msgfalse)
    end
  end  
end

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  