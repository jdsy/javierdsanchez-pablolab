%%General gate sweep setup for special measure
global runNumber
%%%%%%%%%%%%%CONFIG%%%%%%%%%%%%%%%%%%%%%%%
%% COMMONLY CHANGED
%runNumber = 10; %manually set run number here
measureStr ='Vi1_Im2_Vm3-4_Vbg';
sampleName = 'G40302';
scanType = 'bigVoltTest'; %'cal'
scanSpeed = 'slow';  %'slow'
iRotStr = 'i785'; %these are nominal
Btot = 0.0;
Bperp = 0.0;

V_BIAS = 100e-6; % 100uV
I_SENS = -1; %  -1e-6  KEEP NEGATIVE for ithaco

Temp = 300;

comments = 'this is great!';
%pins measured
VinPin     = '1'; %Where DAC voltage is connected
ImPin      = '2'; %Where current is being measured
VmLock2Pin = '';%additional lockin A-B
VmLock3Pin = ''; %additional lockin A-B
%After every set of 'savePoint' save the data
savePoint = 25;
%ramp down gate after sweeping?
rampDown = 1;

%% SWEEP PARAMETERS
if strcmp(scanSpeed,'fast');
    stepTime = 0.05; 
    waitTime = 0.01; 
    startWait = 1;
else strcmp(scanSpeed,'slow'); 
    stepTime = 0.1;  
    waitTime = 0.2; 
    startWait = 2;  
end

%measure or calibration sweep (calibration is for perp field matching)
if strcmp(scanType,'meas');
    range = [-0.025 0.085];
    stepsize = 0.3e-3;
elseif strcmp(scanType,'cal'); 
    range = [-0.5 0.5]
    stepsize = 1.66e-3;
elseif strcmp(scanType,'bigVoltTest'); 
    range = [1 5];
    stepsize = 0.05;
end
%calculate points from scanranges
npoints = round(abs((range(1) - range(2))/stepsize))+1;

%% Setup Pin naming and channels
%Construct channel names
VinName = ['Vin' VinPin];
ImName = ['Im' ImPin];
Lock2XName = ['Vm' VmLock2Pin];
Lock3XName = ['Vm' VmLock3Pin];
%Lookup generic channel names to rename
chanIDIm = smchanlookup('Im');
chanIDVmLock2 = smchanlookup('VmLock2');
chanIDVmLock3 = smchanlookup('VmLock3');
%Rename channels with the pin number - makes things easier when looking at data later
smdata.channels(chanIDIm).name = ImName; %Lockin measuring Ithaco
smdata.channels(chanIDVmLock2).name = Lock2XName;
smdata.channels(chanIDVmLock3).name = Lock3XName;

%% POWERPOINT & FIGURE PARAMETERS
ConductancePlot = true;
powerpointFile = 'asdf.ppt';

%% CHANNEL NAMES
GATE_CHAN = 'L2_V'; %normally 'Vg'
I_CHAN = 'Isd';


%%%%%%%%%%%%%END CONFIG%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check run number
runNumber = runNumQuery(runNumber);

%% Construct FILENAME
VinStr = [VinName '_'];
ImStr = [ImName '_'];
Lock2XStr = '';
Lock3XStr = '';
if ~isempty(VmLock2Pin) Lock2XStr = [Lock2XName '_']; end;
if ~isempty(VmLock3Pin) Lock3XStr = [Lock3XName '_']; end; 

measureStr = [VinStr  ImStr Lock2XStr  Lock3XStr 'Vbg'];
runStr = num2str(runNumber,'%03d');
scanType = scanType;
BtotStr = ['Bt' num2str(Btot,'%.5f') 'T'];
BperpStr = ['Bp' num2str(Bperp,'%.5f') 'T'] ;

runFilename = [runStr '_' measureStr '_' sampleName '_' scanType '_' iRotStr '_' BperpStr  '_' BtotStr];

%% Setup the scan
clear scanGate;
scanGate.name = runFilename;
scanGate.loops(1).setchan = {GATE_CHAN};
getchanStr = {ImName};
if ~strcmp('',VmLock2Pin) getchanStr = [getchanStr {Lock2XName}]; end %if pin is set add it to get chans
if ~strcmp('',VmLock3Pin) getchanStr = [getchanStr {Lock3XName}]; end %if pin is set add it to get chans
scanGate.loops(1).getchan = getchanStr;
scanGate.loops(1).rng = [range(1) range(2)];
scanGate.loops(1).npoints = npoints;
scanGate.loops(1).ramptime = stepTime;
scanGate.loops(1).waittime = waitTime;
scanGate.loops(1).startwait = startWait;
%set Im multiplier based on Ithaco
smdata.channels(chanIDIm).rangeramp(4) = I_SENS;

%Display everything that is measured
for i=1:size(getchanStr,2)
    scanGate.disp(i).loop = 1;
    scanGate.disp(i).channel = i;
    scanGate.disp(i).dim = 1;
end

scanGate.saveloop = [1 savePoint]; %save every 25th point to save time


scanGate.Bperp = Bperp;
scanGate.Btot = Btot;
scanGate.iRot = iRotStr;
scanGate.timestamp = datestr(now,31);
scanGate.scanType = scanType;
scanGate.runNumber = runNumber;
scanGate.comments = comments;
scanGate.Vbias = V_BIAS;
scanGate.Isens = I_SENS;

%% Setup ramp to zero function if wanted

if rampDown
    scanGate.escapefn.fn = @(x,y) smset(GATE_CHAN,0.004,1);
    %have to put an arguement
    scanGate.escapefn.args{1} = [];
end

%% Run scan

fprintf(['Starting scan:\n' runFilename '\n']);
tic
smscan = scanGate;
smrun(scanGate,['./' runFilename '.mat']);
systemsound('notify')
toc
runNumber = runNumber+1;

%change the channel names back to the generic ones
smdata.channels(chanIDIm).name = 'Im';
smdata.channels(chanIDVmLock2).name = 'VmLock2';
smdata.channels(chanIDVmLock3).name = 'VmLock3';

%% Create ASCII file version
[x y] = ldsm([runFilename '.mat']);
outData = [];
outData(:,1) = x';
outData(:,2) = y';
outfile = [runFilename '.dat'];
header={'#X','Y\n'};
fid = fopen(outfile, 'w');
if fid == -1; error('Cannot open file: %s', outfile); end
fprintf(fid, '%s\t', header{:});
fclose(fid);
dlmwrite(outfile,outData,'delimiter','\t','-append');
