% 1K Setup Instrument Initialization
%---------------------

%Clear out Matlab
clear all;
close all;
instrreset;

%GPIB addresses
LockInA_GPIB=8;
LockInB_GPIB=11;
Source_GPIB=15;
DMM_GPIB=16;
Temp_GPIB=12;
Magnet_GPIB=1;
NA_GPIB=17;

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
smaddchannel('time','time','Time');

%------------
% add LockInA
try
    ind = smloadinst('SR830', [], 'agilent', 7, LockInA_GPIB);
        
    %setup GPIB communication parameters
    set(smdata.inst(ind).data.inst,'inputbuffersize',2^16); %assigns 65kb to the read buffer to enable it to take a full buffer of data with one request
    set(smdata.inst(ind).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
    set(smdata.inst(ind).data.inst,'timeout',40);    %increases timeout time to allow for large data transfers
    
    %open GPIB communication
    smopen(ind); 

    smdata.inst(ind).name = 'LockIn_A';
    
    %add channels
    smaddchannel('LockIn_A', 'X', 'X_A', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_A', 'Y', 'Y_A', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_A', 'OUT1', 'Vs_A', [-10, 10, .5, 1]);
    smaddchannel('LockIn_A', 'IN1', 'In1_A', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_A', 'IN2', 'In2_A', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_A', 'IN3', 'In3_A', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_A', 'IN4', 'In4_A', [-Inf, Inf, Inf, 1]);
    smaddchannel('LockIn_A', 'FREQ', 'Freq_A', [0, 102000, 10, 1]);
    smaddchannel('LockIn_A', 'VREF', 'Vli_A', [0, 5, 0.5, 1]);
    
    %set instrument parameters
    %fprintf(smdata.inst(ind).data.inst,'*rst'); %resets the lockin
    
    fprintf(smdata.inst(ind).data.inst,'slvl .004'); %sets the output amplitude to the lockin's lowest value (4mV)
    fprintf(smdata.inst(ind).data.inst,'freq 17.777');    %sets the lockin source frequency
    fprintf(smdata.inst(ind).data.inst,'ilin 0');   %turns both line filters off
    fprintf(smdata.inst(ind).data.inst,'isrc 1');   %sets the input to A-B
    fprintf(smdata.inst(ind).data.inst,'icpl 0');   %sets the input coupling to AC
    fprintf(smdata.inst(ind).data.inst,'ignd 0');   %sets the ground to float
    fprintf(smdata.inst(ind).data.inst,'oflt 9');   %sets the time constant to 300ms
    fprintf(smdata.inst(ind).data.inst,'ofsl 3');   %sets roll off to 24dB
    fprintf(smdata.inst(ind).data.inst,'sens 23');   %sets the sensitivity to 100mV
    
    %fprintf(smdata.inst(ind).data.inst,'srat 9');   %sets the sample rate to 32Hz
    %fprintf(smdata.inst(ind).data.inst,'send 0');   %sets the scan end to 1 shot instead of loop
    %fprintf(smdata.inst(ind).data.inst,'rest');     %resets the buffer 
    %fprintf(smdata.inst(ind).data.inst,'tstr 1');   %turns on the trigger
    
    
catch err
    fprintf(['*ERROR* problem with connecting to LockIn_A\n' err.identifier ': ' err.message '\n'])
end

% add LockInB
try
    ind = smloadinst('SR830', [], 'agilent', 7, LockInB_GPIB);
        
    %setup GPIB communication parameters
    set(smdata.inst(ind).data.inst,'inputbuffersize',2^16); %assigns 65kb to the read buffer to enable it to take a full buffer of data with one request
    set(smdata.inst(ind).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
    set(smdata.inst(ind).data.inst,'timeout',40);    %increases timeout time to allow for large data transfers
    
    %open GPIB communication
    smopen(ind); 

    smdata.inst(ind).name = 'LockIn_B';
    
    %add channels
    %smaddchannel('LockIn_B', 'X', 'X_B', [-Inf, Inf, Inf, 1]);
    %smaddchannel('LockIn_B', 'Y', 'Y_B', [-Inf, Inf, Inf, 1]);
    %smaddchannel('LockIn_B', 'OUT1', 'Vs_B', [-10, 10, .5, 1]);
    %smaddchannel('LockIn_B', 'IN1', 'Isd_B', [-Inf, Inf, Inf, -1e6]);
    %smaddchannel('LockIn_B', 'IN3', 'Vab_B', [-Inf, Inf, Inf, 1]);
    %smaddchannel('LockIn_B', 'FREQ', 'Freq_B', [0, 102000, 10, 1]);
    %smaddchannel('LockIn_B', 'VREF', 'Vli_B', [0, 5, 0.5, 1]);
    
    %set instrument parameters
    %fprintf(smdata.inst(ind).data.inst,'*rst'); %resets the lockin
    
    fprintf(smdata.inst(ind).data.inst,'slvl .004'); %sets the output amplitude to the lockin's lowest value (4mV)
    fprintf(smdata.inst(ind).data.inst,'freq 17.777');    %sets the lockin source frequency
    fprintf(smdata.inst(ind).data.inst,'ilin 0');   %turns both line filters off
    fprintf(smdata.inst(ind).data.inst,'isrc 1');   %sets the input to A-B
    fprintf(smdata.inst(ind).data.inst,'icpl 0');   %sets the input coupling to AC
    fprintf(smdata.inst(ind).data.inst,'ignd 0');   %sets the ground to float
    fprintf(smdata.inst(ind).data.inst,'oflt 9');   %sets the time constant to 300ms
    fprintf(smdata.inst(ind).data.inst,'ofsl 3');   %sets roll off to 24dB
    fprintf(smdata.inst(ind).data.inst,'sens 23');   %sets the sensitivity to 100mV
    
    %fprintf(smdata.inst(ind).data.inst,'srat 9');   %sets the sample rate to 32Hz
    %fprintf(smdata.inst(ind).data.inst,'send 0');   %sets the scan end to 1 shot instead of loop
    %fprintf(smdata.inst(ind).data.inst,'rest');     %resets the buffer 
    %fprintf(smdata.inst(ind).data.inst,'tstr 1');   %turns on the trigger
    
catch err
    fprintf(['*ERROR* problem with connecting to LockIn_B\n' err.identifier ': ' err.message '\n'])
end

% add Keithley 2400
try
    ind  = smloadinst('K2400', [], 'agilent', 7, Source_GPIB);
       
    %setup GPIB communication parameters
    set(smdata.inst(ind).data.inst,'inputbuffersize',2^18); %assigns 262kb to the read buffer to enable it to take a full buffer of data with one request
    set(smdata.inst(ind).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
    set(smdata.inst(ind).data.inst,'eosmode','read&write');  %end of string character is used in both read and write operations
    
    %open GPIB communication
    smopen(ind);

    smdata.inst(ind).name = 'Source';
    
    %add channels
    smaddchannel('Source','V','Vbg',[-210 210 3 1]);
    smaddchannel('Source','I','Ibg',[-Inf Inf 0.1 1]);
    smaddchannel('Source','V','Vionic',[-10 10 1 1]);
    
    %set instrument parameters
    %fprintf(smdata.inst(ind).data.inst,'*rst'); %resets the Keithley
    
    fprintf(smdata.inst(ind).data.inst,'sense:current:protection 1e-6'); %sets a current limit protector to 1uA
    fprintf(smdata.inst(ind).data.inst,':sense:current:range 1e-6');    %sets the sense current limit to 1uA
    fprintf(smdata.inst(ind).data.inst,'source:delay 0.0'); %sets delay to 0
    fprintf(smdata.inst(ind).data.inst,':source:voltage:range 100');  %sets the voltage range to 100V
    %fprintf(smdata.inst(ind).data.inst,':source:voltage:range:auto 1');    %sets the voltage range to auto
    fprintf(smdata.inst(ind).data.inst,':rout:term rear');  %enables the rear terminal
    fprintf(smdata.inst(ind).data.inst,':output on');   %turns the output on
    
catch err
    fprintf(['*ERROR* problem with connecting to the Source\n' err.identifier ': ' err.message '\n'])
end

% add Keithley 2700
try
    ind  = smloadinst('K2700', [], 'agilent', 7, DMM_GPIB);
    
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

% add DAC
try
    ind = smloadinst('BabyDAC', [], 'serial', 'COM1');
    
    %setup GPIB communication parameters
    set(smdata.inst(ind).data.inst,'inputbuffersize',2^10); %assigns 1kb to the read buffer
    set(smdata.inst(ind).data.inst,'outputbuffersize',2^10);  %assigns 1kb to the write buffer
    set(smdata.inst(ind).data.inst,'BaudRate',9600);
    set(smdata.inst(ind).data.inst,'timeout',30);  %increases timeout time
    
    %open GPIB communication
    smopen(ind);
    
    smdata.inst(ind).name = 'DAC';
    
    %add channels
    smaddchannel('DAC', 'CH0', 'DAC0', [-10 10 .1 1]);
    smaddchannel('DAC', 'CH1', 'DAC1', [-10 10 .1 1]);
    smaddchannel('DAC', 'CH2', 'DAC2', [-10 10 .1 1]);
    smaddchannel('DAC', 'CH3', 'DAC3', [-10 10 .1 1]);
    %smaddchannel('DAC', 'RAMP0', 'DAC0R', [-10 10 Inf 1]);
    
    %initialize the DAC
        %clear the buffer
            while smdata.inst(ind).data.inst.BytesAvailable > 0
                fscanf(smdata.inst(ind).data.inst);
                pause(0.3);
            end
        %reset any ramps
            query(smdata.inst(ind).data.inst,'B0;M2;C0;S0;'); 
            query(smdata.inst(ind).data.inst,'B0;M2;C0;U65535;');
            query(smdata.inst(ind).data.inst,'B0;M2;C0;L0;');
        dac_zero=32768; %measured bit where DAC is zero
        bit_str=sprintf('B0;M2;C0;D%.0f;',dac_zero);
        query(smdata.inst(ind).data.inst,bit_str); %sets the DAC to zero
    
catch err
    fprintf(['*ERROR* problem with connecting to the DAC\n' err.identifier ': ' err.message '\n'])
end

% add temperature controller
try
    ind = smloadinst('LS335', [], 'agilent', 7, Temp_GPIB);
    
    %setup GPIB communication parameters
    
    %open GPIB communication
    smopen(ind);
    
    smdata.inst(ind).name = 'Temp';
    
    %add channels
    smaddchannel('Temp', 'A', 'T', [-Inf, Inf, Inf, 1]);
    smaddchannel('Temp', '1', 'Tset', [0, 350, Inf, 1]);
    smaddchannel('Temp', 'PWR1', 'HeaterP', [0, 100, Inf, 1]); %PWR/Range=0~3
    
    %set instrument parameters
    %fprintf(smdata.inst(ind).data.inst,'*rst');  %resets the temperature controller
    
catch err
    fprintf(['*ERROR* problem with connecting to the Temperature Controller\n' err.identifier ': ' err.message '\n'])
end

% add Network Analyzer
try
    ind = smloadinst('AE5071C', [], 'agilent', 7, NA_GPIB);
    
    %setup GPIB communication parameters
    
    %open GPIB communication
    smopen(ind);
    
    %smdata.inst(ind).name = 'NA';
    
    %add channels
    %smaddchannel('NA', 'PWR', 'NAP', [-55 Inf Inf 1]);
    %smaddchannel('NA', 'PSTART', 'Pstart', [-55 Inf Inf 1]);
    %smaddchannel('NA', 'PSTOP', 'Pstop', [-55 Inf Inf 1]);
    %smaddchannel('NA', 'FREQ', 'NAF', [.1 8500 Inf 1e6]);
    %smaddchannel('NA', 'FSTART', 'Fstart', [.1 8500 Inf 1e6]);
    %smaddchannel('NA', 'FSTOP', 'Fstop', [.1 8500 Inf 1e6]);

    %set instrument parameters
    fprintf(smdata.inst(ind).data.inst, ':system:preset'); %presets the network analyzer
    fprintf(smdata.inst(ind).data.inst, ':source1:power -55'); %sets the output power to the network analyzer's lowest value (-55dBm)
    fprintf(smdata.inst(ind).data.inst, ':sense1:sweep:type linear');  %sets the sweep type to linear
    fprintf(smdata.inst(ind).data.inst, ':calc1:parameter:count 1'); %sets the max number of channels and traces; ch.1 :4 => 20001 points
    fprintf(smdata.inst(ind).data.inst, ':display:window1:spl D1');    %sets the LCD graph layout to display a single trace 
    fprintf(smdata.inst(ind).data.inst, ':calc1:parameter1:define S21');    %Defines a parameter S21 to measure
    fprintf(smdata.inst(ind).data.inst, ':calc1:parameter1:select');    %makes the S21 trace active
    fprintf(smdata.inst(ind).data.inst, ':display:window1:trace1:y:auto'); %auto scales y-axis

catch err
    fprintf(['*ERROR* problem with connecting to the Network Analyzer\n' err.identifier ': ' err.message '\n'])
end

% add CryoMag
try
    ind = smloadinst('CMCS4', [], 'agilent', 7, Magnet_GPIB);
    
    %setup GPIB communication parameters
    
    %open GPIB communication
    smopen(ind);
    
    %smdata.inst(ind).name = 'Magnet';
    
    %add channels
%    smaddchannel('Magnet', 'B', 'B', [-1.5000 1.5000 0.1053 1]);
    smaddchannel('Magnet', 'B', 'B', [-1.5000 1.5000 .1 1]);

    %set instrument parameters
    fprintf(smdata.inst(ind).data.inst,'UNITS T');
    fprintf(smdata.inst(ind).data.inst,'RANGE 0 20');   %Chooses the first range and sets its upper limit in A
    fprintf(smdata.inst(ind).data.inst,'RATE 0 1.0526');    %chooses the first range and sets its rate in A/s
    
catch err
    fprintf(['*ERROR* problem with connecting to the Magnet\n' err.identifier ': ' err.message '\n'])
end

cd('Z:\group\Dichalcogenides');
% save configuration for future use
% save mysmdata smdata  

% useful commands for inspecting configuration (not required)
%smprintinst
%smprintchannels

smgui
