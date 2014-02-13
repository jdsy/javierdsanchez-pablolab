% 1K Setup Instrument Initialization
%---------------------

%Clear out Matlab
clear all;
close all;
instrreset;

%GPIB addresses
GPIB_BOARD = 'ni'
BOARD_NUM = 0;
LockInA_GPIB=15;
LockInB_GPIB=8;
% Source_GPIB=15;
DMM_GPIB=16;
% Temp_GPIB=12;
% Magnet_GPIB=1;
% NA_GPIB=17;

% load empty smdata shell (where all instruments and channels go)
global smdata;
global smscan;
load smdata_empty;

%% Add instruments to rack
%------------

% load dummy instrument
smloadinst('test');
smloadinst('time');

% add dummy channels
%smaddchannel('test', 'CH1', 'dummy');
smaddchannel('test', 'CH2', 'count');

smaddchannel('time','toc','toc');
smaddchannel('time','tNow','timeNow');
%------------
%% add LockInA
try
    ind = smloadinst('SR830', [], 'ni', 0, LockInA_GPIB);
        
    %setup GPIB communication parameters
%     set(smdata.inst(ind).data.inst,'inputbuffersize',2^16); %assigns 65kb to the read buffer to enable it to take a full buffer of data with one request
%     set(smdata.inst(ind).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
%     set(smdata.inst(ind).data.inst,'timeout',40);    %increases timeout time to allow for large data transfers
    
    %open GPIB communication
    smopen(ind); 

    smdata.inst(ind).name = 'LockIn_A';
    
    %add channels
    smaddchannel('LockIn_A', 'X', 'X_A', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_A', 'Y', 'Y_A', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_A', 'X', 'G', [-Inf, Inf, Inf, 3.8740e-4]);
%     smaddchannel('LockIn_A', 'OUT1', 'Vs_A', [-10, 10, .5, 1]);
%     smaddchannel('LockIn_A', 'IN1', 'In1_A', [-Inf, Inf, Inf, 1]);
%     smaddchannel('LockIn_A', 'IN2', 'In2_A', [-Inf, Inf, Inf, 1]);
%     smaddchannel('LockIn_A', 'IN3', 'In3_A', [-Inf, Inf, Inf, 1]);
%     smaddchannel('LockIn_A', 'IN4', 'In4_A', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_A', 'FREQ', 'Freq_A', [0, 102000, 10, 1]);
    smaddchannel('LockIn_A', 'VREF', 'Vref_A', [0.004, 5, 0.5, 1]);
    
catch err
    fprintf(['*ERROR* problem with connecting to LockIn_A\n' err.identifier ': ' err.message '\n'])
end

%% add LockInB
try
    ind = smloadinst('SR830', [], 'ni', 0, LockInB_GPIB);
        
    %setup GPIB communication parameters
%     set(smdata.inst(ind).data.inst,'inputbuffersize',2^16); %assigns 65kb to the read buffer to enable it to take a full buffer of data with one request
%     set(smdata.inst(ind).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
%     set(smdata.inst(ind).data.inst,'timeout',40);    %increases timeout time to allow for large data transfers
    
    %open GPIB communication
    smopen(ind); 

    smdata.inst(ind).name = 'LockIn_B';
    
    %add channels
    smaddchannel('LockIn_B', 'X', 'X_B', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_B', 'Y', 'Y_B', [-Inf, Inf, Inf, 1]);
%     smaddchannel('LockIn_A', 'OUT1', 'Vs_A', [-10, 10, .5, 1]);
%     smaddchannel('LockIn_A', 'IN1', 'In1_A', [-Inf, Inf, Inf, 1]);
%     smaddchannel('LockIn_A', 'IN2', 'In2_A', [-Inf, Inf, Inf, 1]);
%     smaddchannel('LockIn_A', 'IN3', 'In3_A', [-Inf, Inf, Inf, 1]);
%     smaddchannel('LockIn_A', 'IN4', 'In4_A', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_B', 'FREQ', 'Freq_B', [0, 102000, 10, 1]);
    smaddchannel('LockIn_B', 'VREF', 'Vref_B', [0.004, 5, 0.5, 1]);
    
catch err
    fprintf(['*ERROR* problem with connecting to LockIn_B\n' err.identifier ': ' err.message '\n'])
end


% 
% %% add Keithley 2400
% try
%     ind  = smloadinst('K2400', [], GPIB_BOARD, BOARD_NUM, Source_GPIB);
%        
%     %setup GPIB communication parameters
%     set(smdata.inst(ind).data.inst,'inputbuffersize',2^18); %assigns 262kb to the read buffer to enable it to take a full buffer of data with one request
%     set(smdata.inst(ind).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
%     set(smdata.inst(ind).data.inst,'eosmode','read&write');  %end of string character is used in both read and write operations
%     
%     %open GPIB communication
%     smopen(ind);
% 
%     smdata.inst(ind).name = 'Source';
%     
%     %add channels
%     smaddchannel('Source','V','Vbg',[-210 210 3 1]);
%     smaddchannel('Source','I','Ibg',[-Inf Inf 0.1 1]);
%     smaddchannel('Source','V','Vionic',[-10 10 1 1]);
%     
%     %set instrument parameters
%     %fprintf(smdata.inst(ind).data.inst,'*rst'); %resets the Keithley
%     
%     fprintf(smdata.inst(ind).data.inst,'sense:current:protection 1e-6'); %sets a current limit protector to 1uA
%     fprintf(smdata.inst(ind).data.inst,':sense:current:range 1e-6');    %sets the sense current limit to 1uA
%     fprintf(smdata.inst(ind).data.inst,'source:delay 0.0'); %sets delay to 0
%     fprintf(smdata.inst(ind).data.inst,':source:voltage:range 100');  %sets the voltage range to 100V
%     %fprintf(smdata.inst(ind).data.inst,':source:voltage:range:auto 1');    %sets the voltage range to auto
%     fprintf(smdata.inst(ind).data.inst,':rout:term rear');  %enables the rear terminal
%     fprintf(smdata.inst(ind).data.inst,':output on');   %turns the output on
%     
% catch err
%     fprintf(['*ERROR* problem with connecting to the Source\n' err.identifier ': ' err.message '\n'])
% end

%% add Keithley 2700
try
    ind  = smloadinst('K2700', [], GPIB_BOARD, BOARD_NUM, DMM_GPIB);
    
    %setup GPIB communication parameters
    set(smdata.inst(ind).data.inst,'inputbuffersize',2^18); %assigns 262kb to the read buffer to enable it to take a full buffer of data with one request
    set(smdata.inst(ind).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
    set(smdata.inst(ind).data.inst,'eosmode','read&write');
    set(smdata.inst(ind).data.inst,'timeout',30);    %increases timeout time to allow for large data transfers
    
    %open GPIB communication
    smopen(ind);

    smdata.inst(ind).name = 'DMM';
    
    %add channels
    smaddchannel('DMM','V','Vdmm',[-Inf Inf Inf 1]);
    smaddchannel('DMM','V','Isd',[-Inf Inf Inf -1e4]);
    
    %set instrument parameters
    fprintf(smdata.inst(ind).data.inst,'*rst'); %resets the Keithley
    
    fprintf(smdata.inst(ind).data.inst,'initiate:continuous on;:abort'); %turns on continuous readings
    fprintf(smdata.inst(ind).data.inst,':voltage:nplcycles 1'); %sets the cycle time to the Keithley's medium (1s)
    fprintf(smdata.inst(ind).data.inst,'sense:voltage:dc:average:state off'); %turns off averaging
    fprintf(smdata.inst(ind).data.inst,':sense:voltage:range:auto 1');    %sets the voltage range to auto
    %fprintf(smdata.inst(ind).data.inst,':sense:voltage:dc:range .1');    %sets the voltage range 100mV (the min)
    
catch err
    fprintf(['*ERROR* problem with connecting to the DMM\n' err.identifier ': ' err.message '\n'])
end

%% add DAC
try
    ind = smloadinst('DecaDAC', [], 'serial', 'COM2');
    
    %setup GPIB communication parameters
      set(smdata.inst(ind).data.inst,'BaudRate',9600);
      set(smdata.inst(ind).data.inst,'timeout',20);  %increases timeout time
    
    %open GPIB communication
    smopen(ind);
    
    smdata.inst(ind).name = 'DAC';
    
    %add channels
    smaddchannel('DAC', 'CH0', 'BGVa', [-4.5 4.5 6 1]);
    smaddchannel('DAC', 'CH1', 'TGVa', [-3.5 3.5 6 1]);
    smaddchannel('DAC', 'CH2', 'BGVb', [-3 3 6 3.780]);
    smaddchannel('DAC', 'CH3', 'TGVb', [-6 5 6 1]);
    
    smaddchannel('DAC', 'CH5', 'Vbias', [-10 10 10 1000]);
    %smaddchannel('DAC', 'RAMP0', 'DAC0R', [-10 10 Inf 1]);
    
    %initialize the DAC
        %clear the buffer
            while smdata.inst(ind).data.inst.BytesAvailable > 0
                fscanf(smdata.inst(ind).data.inst);
                pause(0.3);
            end
        %reset any ramps
        for i=0:3
            stri = num2str(i);
            query(smdata.inst(ind).data.inst,['B0;M2;C' stri ';S0;']); 
            query(smdata.inst(ind).data.inst,['B0;M2;C' stri ';U65535;']);
            query(smdata.inst(ind).data.inst,['B0;M2;C' stri ';L0;']);
            dac_zero=32768; %measured bit where DAC is zero
            bit_str=sprintf(['B0;M2;C' stri ';D%.0f;'],dac_zero);
            query(smdata.inst(ind).data.inst,bit_str); %sets the DAC to zero
        end
    
catch err
    fprintf(['*ERROR* problem with connecting to the DAC\n' err.identifier ': ' err.message '\n'])
end

try
    ind = smloadinst('AMI430', [], 'serial', 'COM1');
    smopen(ind);
    
    smaddchannel('AMI430', 'B', 'Bfield', [-12 12 1 1]);
    
catch err
    fprintf(['*ERROR* problem with connecting to the AMI430 magnet\n' err.identifier ': ' err.message '\n'])
end
% 

%% % %add CryoMag
% try
%     ind = smloadinst('CMCS4', [], GPIB_BOARD, BOARD_NUM, Magnet_GPIB);
%     
%     %setup GPIB communication parameters
%     
%     %open GPIB communication
%     smopen(ind);
%     
%     %smdata.inst(ind).name = 'Magnet';
%     
%     %add channels
% %    smaddchannel('Magnet', 'B', 'B', [-1.5000 1.5000 0.1053 1]);
%     smaddchannel('Magnet', 'B', 'B', [-1.5000 1.5000 .1 1]);
% 
%     %set instrument parameters
%     fprintf(smdata.inst(ind).data.inst,'UNITS T');
%     fprintf(smdata.inst(ind).data.inst,'RANGE 0 20');   %Chooses the first range and sets its upper limit in A
%     fprintf(smdata.inst(ind).data.inst,'RATE 0 1.0526');    %chooses the first range and sets its rate in A/s
%     
% catch err
%     fprintf(['*ERROR* problem with connecting to the Magnet\n' err.identifier ': ' err.message '\n'])
% end
% 
% cd('Z:\group\Dichalcogenides');
% save configuration for future use
% save mysmdata smdata  

% useful commands for inspecting configuration (not required)
%smprintinst
%smprintchannels

% cd('C:\Users\Singapore\Documents\Javier\Measurements\2013-07-29_G70-11-13_G71-03-14\G71-03')
cd('C:\Users\Singapore\Documents\Javier\Measurements\2013-07-29_G70-11-13_G71-03-14\2013-08-04_G71-14_G71-03');
smgui
