% Setup from nothing a measurement rack for the Ashoori Dill
%---------------------
clear all;
close all;
instrreset;

%% CONSTANTS

%Addresses
LOCKIN_GPIB(1) = 8; %number lockins from lowest to ground to highest
LOCKIN_GPIB(2) = 12;
LOCKIN_GPIB(3) = 14;
HPDMM_GPIB = 20;
DAC_COM = 'COM3';

%Rack parameters
MAGNET_YES = 0;

%% load empty smdata shell (where all instruments and channels go)
global smdata;
global smscan;
load smdata_empty;


%% Add Instruments to rack

% load dummy instrument
smloadinst('test') 
% add dummy channels
smaddchannel('test', 'CH1', 'dummy');
smaddchannel('test', 'CH2', 'count');

%--
%% add Lockins

for i = 1:length(LOCKIN_GPIB)
    currLock = ['Lockin' num2str(i)];
    currLockShort = ['L' num2str(i) '_'];
    currLockGPIB = LOCKIN_GPIB(i);
    try
        inst = smloadinst('SR830', [], 'agilent', 7, currLockGPIB); % SR830 on NI GPIB card 0, address 23.
        smopen(inst); %open GPIB communication to lockin
        smdata.inst(inst).name = currLock;
        %add lockin channels (Ex: X VREF OUT1 OUT2 IN1 IN2)
        smaddchannel(currLock, 'X', [currLockShort 'X'], [-Inf, Inf, Inf, 1]);
        smaddchannel(currLock, 'VREF', [currLockShort 'V'], [-Inf, Inf, Inf, 1]);
        smaddchannel(currLock, 'IN1', [currLockShort 'In1'], [-Inf, Inf, Inf, 1]);
        smaddchannel(currLock, 'DATA1', [currLockShort 'Data1'], [-Inf, Inf, Inf, 1]);
        smaddchannel(currLock, 'FREQ', [currLockShort 'F'], [-Inf, Inf, Inf, 1]);
    catch
        fprintf('*ERROR* problem with connecting to Lockin')
    end
end

%% HP
try
    inst = smloadinst('HP34401A', [], 'agilent', 7, HPDMM_GPIB); % SR830 on NI GPIB card 0, address 23.
    %open GPIB communication to lockin
    smopen(inst);
    smaddchannel('HP34401A', 'VAL', 'DMM', [-Inf, Inf, Inf, 1]);
    smaddchannel('HP34401A', 'DATA', 'DMM_Data', [-Inf, Inf, Inf, 1]);
catch
    fprintf('*ERROR* problem with connecting to HP34401A')
end

%% add DAC
try
    inst = smloadinst('DecaDAC',[],{},DAC_COM); 
    %open serial connection to DAC
    smopen(inst);
    smdata.inst(inst).name = 'DAC';
    %set DAC ranges to match switches:
    set(smdata.inst(inst).data.inst,'BaudRate',9600);
    smdata.inst(inst).data.update = [1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000];
    smdata.inst(inst).data.trigmode = 0;
    %add lockin channels
    smaddchannel('DAC', 'CH0', 'd_V0', [-1, 1, 0.5, 1]);
    smaddchannel('DAC', 'RAMP0', 'd_rV0', [-1, 1, 0.5, 1]);
catch
    fprintf('*ERROR* problem with connecting to DecaDAC')
end

%% add Magnet Powersupply
if MAGNET_YES
    try
        inst = smloadinst('IPS 120-10', [], 'agilent', 7, 25); % SR830 on agilent GPIB card 7, address 25.
        %open GPIB communication to lockin
        smopen(inst);
        smdata.inst(inst).name = 'Magnet';

        %add lockin channels
        smaddchannel('Magnet', 'FIELD', 'B', [-13.5, 13.5, 0.005, 1]);

    catch
        fprintf('*ERROR* problem with connecting to Lockin')
    end
end

% useful commands for inspecting configuration (not required)
smprintinst
smprintchannels

%cd to current directory
% cd C:\Users\JDSY-TOSHIBA\Dropbox\ProximalGateGraphene\data\20120715-Florida\20120717-FL\G406-10_NewJersey\transport

smgui_small;
