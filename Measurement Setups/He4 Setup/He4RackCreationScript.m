%JDSY 01-24-2011
%He4 Rack creation script
%This file creates a new "Rack" to work with the He4 system
%A rack is a matlab structure that contains all the info about the
%instruments connected to the computer
%%% This file can be used as a reference to make racks for other setups
%%% it is very easy to modify.

global smdata;
smdata = [];
smdata.inst = [];
smdata.channels = [];
smdata.configch = [];
smdata.configfn = {};
smdata.chanvals = [];
% smdata.inst(i).data = [];
% smdata.inst(i).datadim = [];
% smdata.inst(i).cntrlfn = [];
% smdata.inst(i).type = [];
% smdata.inst(i).device = [];
% smdata.inst(i).name = [];
% smdata.inst(i).channels= [];

%test instrument
i=1
smdata.inst(i).data = [];
%note on data dim.  First coloumn is first dim, 2nd coloumn is 2nd dim,
%etc.
smdata.inst(i).datadim = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
smdata.inst(i).cntrlfn = @smctest;
smdata.inst(i).type = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
smdata.inst(i).device = 'test';
smdata.inst(i).name = [];
smdata.inst(i).channels= strvcat('CH1','CH2','CH3','CH4','CH5','CH6','CH7','CH8','CH9','CHA','CHB','CHC','CHD','CHE','CHF');

%Lower Lockin 
i=i+1
%%%Lockin specific data
smdata.inst(i).data.inst = []; %load gpib instrument here
smdata.inst(i).data.sampint = 0.0156;
smdata.inst(i).data.currsamp = 680;
%%Lockin datadim -> dimension of each of the 16 channels for the lockin
%%(most are scalar i.e. 0)
smdata.inst(i).datadim = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 680 680]';
%%Lockin control function -> instrument driver
smdata.inst(i).cntrlfn = @smcSR830;
%%type determines whether is a ramping channel or not (1 is ramping
%%channel)
smdata.inst(i).type = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
%name of the device type
smdata.inst(i).device = 'SR830';
%name of the specific device
smdata.inst(i).name = 'LowerLockin';
%channel list
smdata.inst(i).channels = strvcat('X','Y','R','THETA','FREQ','VREF','IN1','IN2','IN3','IN4','OUT1','OUT2','OUT3','OUT4','DATA1','DATA2','SENS','TAU','SYNC');

%K2400
i=i+1
%%%data
smdata.inst(i).data.inst = []; %load gpib instrument here
%%datadim
smdata.inst(i).datadim = [0 0]';
%%Control function
smdata.inst(i).cntrlfn = @smcK2400
%%dimension of channels
smdata.inst(i).type = [0 0]';
%name of the device type
smdata.inst(i).device = 'K2400';
%name of the specific device
smdata.inst(i).name = 'K2400V';
%channel list
smdata.inst(i).channels = strvcat('V','I');

%K2700 DMM
i=i+1
%%%data
smdata.inst(i).data.inst = []; %load gpib instrument here
%%datadim
smdata.inst(i).datadim = [0]';
%%Control function
smdata.inst(i).cntrlfn = @smcK2700
%%dimension of channels
smdata.inst(i).type = [0]';
%name of the device type
smdata.inst(i).device = 'K2700';
%name of the specific device
smdata.inst(i).name = 'DMM';
%channel list
smdata.inst(i).channels = strvcat('V');

%DecaDAC
i=i+1
%%%data
smdata.inst(i).data.inst = []; %load serial object here
%range is important, it must match the range on the front of the DAC
%switches
smdata.inst(i).data.rng = [-10 10;-10 0;-10 0;-10 0;-10 0;-10 0;-10 0;-10 0;-10 0;-10 0;-10 10;-10 10];
smdata.inst(i).data.update = [1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000];
smdata.inst(i).data.trigmode = 0;
%%datadim
smdata.inst(i).datadim = zeros([24,1])
%%Control function
smdata.inst(i).cntrlfn = @smcDecaDAC4
%%dimension of channels
smdata.inst(i).type = [0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;1];
%name of the device type
smdata.inst(i).device = 'DecaDAC';
%name of the specific device
smdata.inst(i).name = [];
%channel list
smdata.inst(i).channels = strvcat('CHAN A0','RAMP A0','CHAN A1','RAMP A1','CHAN A2','RAMP A2','CHAN A3','RAMP A3','CHAN B0','RAMP B0','CHAN B1','RAMP B1','CHAN B2','RAMP B2','CHAN B3','RAMP B3','CHAN C0','RAMP C0','CHAN C1','RAMP C1','CHAN C2','RAMP C2','CHAN C3','RAMP C3');


%K2400 in temperature sensing mode
i=i+1
%%%data
smdata.inst(i).data.inst = []; %load gpib instrument here
%%datadim
smdata.inst(i).datadim = [0]';
%%Control function
smdata.inst(i).cntrlfn = @smcK2400T
%%dimension of channels
smdata.inst(i).type = [0]';
%name of the device type
smdata.inst(i).device = 'K2400';
%name of the specific device
smdata.inst(i).name = 'K2400T';
%channel list
smdata.inst(i).channels = strvcat('T');

%Magnet Controller
i=i+1
%%%data
smdata.inst(i).data.inst = []; %load gpib instrument here
%%datadim
smdata.inst(i).datadim = [0]';
%%Control function
smdata.inst(i).cntrlfn = @smcCryoMag
%%dimension of channels
smdata.inst(i).type = [1]';
%name of the device type
smdata.inst(i).device = 'MagnetController';
%name of the specific device
smdata.inst(i).name = 'MagnetController';
%channel list
smdata.inst(i).channels = strvcat('B');

%Upper Lockin
i=i+1
%%%Lockin specific data
smdata.inst(i).data.inst = []; %load gpib instrument here
smdata.inst(i).data.sampint = 0.0156;
smdata.inst(i).data.currsamp = 680;
%%Lockin datadim -> dimension of each of the 16 channels for the lockin
%%(most are scalar i.e. 0)
smdata.inst(i).datadim = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 680 680]';
%%Lockin control function -> instrument driver
smdata.inst(i).cntrlfn = @smcSR830;
%%type determines whether is a ramping channel or not (1 is ramping
%%channel)
smdata.inst(i).type = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
%name of the device type
smdata.inst(i).device = 'SR830';
%name of the specific device
smdata.inst(i).name = 'UpperLockin';
%channel list
smdata.inst(i).channels = strvcat('X','Y','R','THETA','FREQ','VREF','IN1','IN2','IN3','IN4','OUT1','OUT2','OUT3','OUT4','DATA1','DATA2','SENS','TAU','SYNC');



%%%%Add standard channels using 
%smaddchannel(inst, channel, name,rangeramp)
%rangeramp -> [Min Max RampRate Multiplier]
smaddchannel('LowerLockin','X','LockinX',[-Inf Inf Inf 1]);
smaddchannel('LowerLockin','V','LockinSineOut',[0 Inf Inf 1]);
smaddchannel('K2400V','V','BGV',[-Inf Inf 1 1]);
smaddchannel('K2400V','I','BGI',[-Inf Inf 0.1000 1]);
smaddchannel('DMM','V','DMM',[-Inf Inf Inf 1000]);
smaddchannel('test',1,'Gain',[-Inf Inf Inf 1]);
smaddchannel('test',2,'Iithaco',[-Inf Inf Inf 1]);
smaddchannel('DecaDAC','CHAN A0','DacV',[-10 10 1 1]);
smaddchannel('test',1,'dummy',[0 Inf Inf 1]);
smaddchannel('K2400T','T','T',[-Inf Inf Inf 1]);
smaddchannel('test',3,'I_bias',[0 0 0 1]);
smaddchannel('MagnetController','B','B',[-0.2000 0.2000 0.0184 1]); %range ramp values here are very important!  
smaddchannel('UpperLockin','X','LockinUpperX',[-Inf Inf Inf 1]);

save(['He4-Rack_' date],'smdata');
