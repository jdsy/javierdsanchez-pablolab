% Setup from nothing a measurement rack for the Ashoori Dill

clear all;
close all;
instrreset;

%% CONSTANTS

%Addresses
LOCKIN_GPIB(1) = 14; %number lockins from lowest to ground to highest
LOCKIN_GPIB(2) = 15;
% LOCKIN_GPIB(3) = 14;
K2400_GPIB = 24;
HPDMM_GPIB = 7;
LS325_GPIB = 12;
% NIDAC
PZT_GPIB = 10;
SC_COM = 'COM4';
% MONO_COM = 'COM?';
Chopper_COM = 'COM5';


%% load empty smdata shell (where all instruments and channels go)

global smdata;
global smscan;
load smdata_empty;


%% Add Instruments to rack

% load dummy instrument
smloadinst('test');
smloadinst('time');

% add dummy channels
%smaddchannel('test', 'CH1', 'dummy');
smaddchannel('test', 'CH2', 'count');
smaddchannel('time','time','Time');

%% add SR830 Lockins

for i = 1:length(LOCKIN_GPIB)
    currLock = ['Lockin' num2str(i)];
    currLockShort = ['L' num2str(i) '_'];
    currLockGPIB = LOCKIN_GPIB(i);
    try
        inst = smloadinst('SR830', [], 'ni', 0, currLockGPIB); % SR830 on NI GPIB card 0, address 14.
        smdata.inst(inst).name = currLock;
        
        %setup GPIB communication parameters
        set(smdata.inst(inst).data.inst,'inputbuffersize',2^16); %assigns 65kb to the read buffer to enable it to take a full buffer of data with one request
        set(smdata.inst(inst).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
        set(smdata.inst(inst).data.inst,'timeout',40);    %increases timeout time to allow for large data transfers
    
        %open GPIB communication
        smopen(inst); 

        %add channels
        smaddchannel(currLock, 'X', [currLockShort 'X'], [-Inf, Inf, Inf, 1]);
        smaddchannel(currLock, 'R', [currLockShort 'R'], [-Inf, Inf, Inf, 1]);
        smaddchannel(currLock, 'VREF', [currLockShort 'V'], [0, 5, 1, 1]);
        if i==1
        smaddchannel(currLock, 'OUT1', 'Vlg', [-10, 10, 10, 1]);
        smaddchannel(currLock, 'OUT2', 'Vrg', [-10, 10, 10, 1]);
        smaddchannel(currLock, 'OUT3', 'Vbg', [-90, 90, 10, .05]);
        smaddchannel(currLock, 'OUT3', 'VPx', [-50, 50, Inf, .6/20.5]); %calibrated using 001_PN_diode_spatial_0Vsd_0Vbg_700nm_50uW.mat in WSe2-PN6
        smaddchannel(currLock, 'OUT4', 'VPy', [-50, 50, Inf, .6/20.5]);
        smaddchannel(currLock, 'IN1', 'Ref', [-Inf, Inf, Inf, 1]);
        end
        %smaddchannel(currLock, 'DATA1', [currLockShort 'Data1'], [-Inf, Inf, Inf, 1]);
        %smaddchannel(currLock, 'FREQ', [currLockShort 'F'], [-Inf, Inf, Inf, 1]);
        
        %set instrument parameters
        %fprintf(smdata.inst(inst).data.inst,'*rst'); %resets the lockin

        fprintf(smdata.inst(inst).data.inst,'slvl .004'); %sets the output amplitude to the lockin's lowest value (4mV)
        fprintf(smdata.inst(inst).data.inst,'freq 365.2');    %sets the lockin source frequency
        fprintf(smdata.inst(inst).data.inst,'ilin 0');   %turns both line filters off
        fprintf(smdata.inst(inst).data.inst,'isrc 1');   %sets the input to A-B
        fprintf(smdata.inst(inst).data.inst,'icpl 0');   %sets the input coupling to AC
        fprintf(smdata.inst(inst).data.inst,'ignd 0');   %sets the ground to float
        fprintf(smdata.inst(inst).data.inst,'oflt 7');   %sets the time constant to 300ms
        fprintf(smdata.inst(inst).data.inst,'ofsl 3');   %sets roll off to 24dB
        fprintf(smdata.inst(inst).data.inst,'sens 23');   %sets the sensitivity to 100mV

        %fprintf(smdata.inst(inst).data.inst,'srat 9');   %sets the sample rate to 32Hz
        %fprintf(smdata.inst(inst).data.inst,'send 0');   %sets the scan end to 1 shot instead of loop
        %fprintf(smdata.inst(inst).data.inst,'rest');     %resets the buffer 
        %fprintf(smdata.inst(inst).data.inst,'tstr 1');   %turns on the trigger
    
    catch err
        fprintf('*ERROR* problem with connecting to the SR830')
    end
end

%% add Keithley 2400 Source

try
    inst = smloadinst('K2400', [], 'ni', 0, K2400_GPIB); % K2400 on NI GPIB card 0, address 24.
    smdata.inst(inst).name = 'Source';
    
    %setup GPIB communication parameters
    set(smdata.inst(inst).data.inst,'inputbuffersize',2^18); %assigns 262kb to the read buffer to enable it to take a full buffer of data with one request
    set(smdata.inst(inst).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
    set(smdata.inst(inst).data.inst,'eosmode','read&write');  %end of string character is used in both read and write operations
    
    %open GPIB communication
    smopen(inst); 
    
    %add channels
    smaddchannel('Source','V','Vsd',[-5 5 .5 1]);
    smaddchannel('Source','V','VbgK',[-210 210 1 1]);
    smaddchannel('Source','I','Iketh',[-Inf Inf 0.1 1]);
    %smaddchannel('Source','V','Vionic',[-10 10 1 1]);
    
    %set instrument parameters
    %fprintf(smdata.inst(inst).data.inst,'*rst'); %resets the Keithley
    
    fprintf(smdata.inst(inst).data.inst,'sense:current:protection 50e-6'); %sets a current limit protector to 1uA
    fprintf(smdata.inst(inst).data.inst,':sense:current:range 50e-6');    %sets the sense current limit to 1uA
    fprintf(smdata.inst(inst).data.inst,'source:delay 0.0'); %sets delay to 0
    fprintf(smdata.inst(inst).data.inst,':source:voltage:range 100');  %sets the voltage range to 100V
    %fprintf(smdata.inst(inst).data.inst,':source:voltage:range:auto 1');    %sets the voltage range to auto
    fprintf(smdata.inst(inst).data.inst,':rout:term rear');  %enables the rear terminal
    fprintf(smdata.inst(inst).data.inst,':output on');   %turns the output on

catch err
    fprintf('*ERROR* problem with connecting to the Keithley 2400 Source')
end

%% HP 34401A DMM

try
    inst = smloadinst('HP34401A', [], 'ni', 0, HPDMM_GPIB); % HP34401 on NI GPIB card 0, address 7.
    smdata.inst(inst).name = 'DMM';
       
    %setup GPIB communication parameters
    set(smdata.inst(inst).data.inst,'inputbuffersize',2^18); %assigns 262kb to the read buffer to enable it to take a full buffer of data with one request
    set(smdata.inst(inst).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
    set(smdata.inst(inst).data.inst,'eosmode','read&write');
    set(smdata.inst(inst).data.inst,'timeout',30);    %increases timeout time to allow for large data transfers
    
    %open GPIB communication
    smopen(inst);
    
    %add channels
    smaddchannel('DMM', 'VAL', 'Vdmm', [-Inf, Inf, Inf, 1]);
    smaddchannel('DMM', 'VAL', 'Isd', [-Inf, Inf, Inf, -1e6]);
    
    %set instrument parameters
%     fprintf(smdata.inst(inst).data.inst,'*rst'); %resets the DMM

    fprintf(smdata.inst(inst).data.inst,'sense:voltage:dc:nplcycles min'); %min instead of 1 sets the cycle time to the DMM's minimum (.02s)
%     %fprintf(smdata.inst(inst).data.inst,':sense:voltage:dc:range .1');    %sets the voltage range 100mV (the min)
    
catch err
    fprintf('*ERROR* problem with connecting to the HP34401A DMM')
end

%% add LS 325 Temperature Controller

try
    inst = smloadinst('LS325', [], 'ni', 0, LS325_GPIB);
    smdata.inst(inst).name = 'Temp';
    
    %setup GPIB communication parameters
    
    %open GPIB communication
    smopen(inst);
    
    %add channels
    smaddchannel('Temp', 'A', 'T', [-Inf, Inf, Inf, 1]);
    smaddchannel('Temp', '1', 'Tset', [0, 350, Inf, 1]);
    smaddchannel('Temp', 'PWR1', 'Hpwr', [0, 3, Inf, 1]); %power range=0~3
    
    %set instrument parameters
    %fprintf(smdata.inst(inst).data.inst,'*rst');  %resets the temperature controller
    
catch err
    fprintf('*ERROR* problem with connecting to the Temperature Controller')
end

%% add Fianium FemtoPower 1060 Super Continuum Laser

try
    inst = smloadinst('FianiumSC1060', [], 'serial', SC_COM);
    smdata.inst(inst).name = 'SC';
    
    %setup COM communication parameters
    set(smdata.inst(inst).data.inst,'Baudrate',19200);
    set(smdata.inst(inst).data.inst,'Terminator','CR');
    
    %open COM communication
    smopen(inst);
    
    %add channels
    smaddchannel('SC', 'Q', 'SCq', [0, 2800, Inf, 1]);
    smaddchannel('SC', 'P700', 'P700', [0, 1000, Inf, 1]);
    
    %set instrument parameters
    
catch err
    fprintf('*ERROR* problem with connecting to the Super Continuum Laser')
end

%% add Thor M2000 Optical Chopper

try
    inst = smloadinst('ThorM2000', [], 'serial', Chopper_COM);
    smdata.inst(inst).name = 'Chopper';
    
    %setup COM communication parameters
    set(smdata.inst(inst).data.inst,'Baudrate',115200);
    set(smdata.inst(inst).data.inst,'Terminator','CR');
    
    %open COM communication
    smopen(inst);
    
    %add channels
    smaddchannel('Chopper', 'freq', 'OC_f', [0, 1010, Inf, 1]);
    smaddchannel('Chopper', 'phase', 'OC_ph', [0, 360, Inf, 1]);
    smaddchannel('Chopper', 'enable', 'OC_enbl', [0, 1, Inf, 1]);
    
    %set instrument parameters
    
%     %load device outside of special measure
%     Chopper=serial(Chopper_COM);
%     set(Chopper,'Baudrate',115200);
%     set(Chopper,'Terminator','CR');
%     fopen(Chopper);
    
catch err
    fprintf('*ERROR* problem with connecting to the Optical Chopper')
end

%% add PI E-516 Piezo Controller

try
    inst = smloadinst('PIe516', [], 'ni', 0, PZT_GPIB);
    smdata.inst(inst).name = 'Pzt';
    
    %setup GPIB communication parameters
    
    %open GPIB communication
    smopen(inst);
    
    %add channels
    smaddchannel('Pzt', 'X', 'pztX', [0, 100, Inf, 1]);
    smaddchannel('Pzt', 'Y', 'pztY', [0, 100, Inf, 1]);
    
    %set instrument parameters
    fprintf(smdata.inst(inst).data.inst,'*rst');  %resets the piezo controller
    
catch err
    fprintf('*ERROR* problem with connecting to the Piezo Controller')
end

%% add NI DAC

try
%     inst = smloadinst('NIDAC',[],{},DAC_COM);
%     smdata.inst(inst).name = 'DAC';
%     
%     %open serial connection
%     smopen(inst);
%     
%     %setup DAQ communication parameters
%     
%     %add channels
%     smaddchannel('DAC', 'ao0', 'ao0', [-10, 10, 1, 1]);
%     smaddchannel('DAC', 'ao1', 'ao1', [-10, 10, 1, 1]);
%     smaddchannel('DAC', 'ai0', 'ai0', [-Inf, Inf, Inf, 1]);
%     smaddchannel('DAC', 'ai16', 'ai16', [-Inf, Inf, Inf, 1]);
%     
%     %set instrument parameters
    
    %load device outside of special measure
    DAC=daq.createSession('ni');
    DAC.addAnalogOutputChannel('dev1','ao0','Voltage');
    DAC.addAnalogInputChannel('dev1','ai16','Voltage');
    
catch err
    fprintf('*ERROR* problem with connecting to the NI DAC')
end

%% useful commands for inspecting configuration (not required)
smprintinst
smprintchannels

%cd to current directory
% cd C:\Users\JDSY-TOSHIBA\Dropbox\ProximalGateGraphene\data\20120715-Florida\20120717-FL\G406-10_NewJersey\transport

smgui_small;

clear HPDMM_GPIB LOCKIN_GPIB K2400_GPIB LS325_GPIB PZT_GPIB Chopper_COM SC_COM err currLock currLockGPIB currLockShort i inst

