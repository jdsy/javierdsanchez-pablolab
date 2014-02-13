%% Converts the current scan to a buffer scan

%Instructions

% First setup scan - note you always have 2 loops, even if you want a 1d
% scan.

% Loop 1 = fast loop.  Put a DAC RAMP CHANNEL here.
% Set DAC step time = -1 * step time
%     -1 tells special measure that this is a ramp sweep. It will send
%     command to DAC to ramp to a value and won't communicate anymore.

% Loop 2 - here is where you measure the Lockin Buffer
% Record - Lock in buffer channel (either 'DATA1' or 'DATA2')
%  note you have to input a setchan.  So use dummy with 1 datapoint if you
%  want a 1d scan.

% set Save Loop = 2 so that you save only after the scan is done.

%last, run the following two commands to add necessary configfn to scan.

%setup config fn
smscan.configfn.fn = @smarampconfig_DECADACdmmSR830;
smscan.configfn.args = {'trig'};


%if you want to not use a buffer anymore
% either 
%  a) open an old non buffer scan
%  b) type: 
%  clear smscan
%  global smscan
%  
%  and then make the next scan in smgui as normal
