
%This is an initialization program for the Special Measure program for the probe station measurement setup.
% It will clear all old variables and instruments in MatLab, open new connections to the instruments,
% and set all their values to their default and safe settings.  

clear all; %clears all variables in MatLab

%Open Special Measure data files
global smdata; 
global smscan;
load('C:\Special_Measure_2011\Measurement Setups\Probe Station\probestationrack.mat');
%smdata = smbackup;
  
instrreset; %clears all old instrument connections

%Open communications for all instruments

%GPIB addresses
k2400adr = 13;
k2700adr = 16;
sr830adr = 9;

sr830ind = sminstlookup('SR830');
k2400ind = sminstlookup('K2400');
k2700ind = sminstlookup('K2700');
dacind = sminstlookup('DecaDAC');

%Load all the instruments
smdata.inst(sr830ind).data.inst = gpib('ni', 0, sr830adr);
smdata.inst(k2400ind).data.inst = gpib('ni', 0, k2400adr);
smdata.inst(k2700ind).data.inst = gpib('ni', 0, k2700adr);
smdata.inst(dacind).data.inst = serial('COM5');

%Open all the instruments
fopen(smdata.inst(sr830ind).data.inst);
fopen(smdata.inst(k2400ind).data.inst);
fopen(smdata.inst(k2700ind).data.inst);
fopen(smdata.inst(dacind).data.inst);

if 1==1
    %initialize the SR830 as a lockin
    fprintf(smdata.inst(sr830ind).data.inst,'*rst'); %resets
    fprintf(smdata.inst(sr830ind).data.inst,'freq 107.77'); %sets the frequency to 107.77 Hz
    fprintf(smdata.inst(sr830ind).data.inst,'slvl .004'); %sets the amplitude to .004 V
    fprintf(smdata.inst(sr830ind).data.inst,'isrc 1'); %sets the input to A-B
    fprintf(smdata.inst(sr830ind).data.inst,'ignd 1'); %sets the input to ground
    fprintf(smdata.inst(sr830ind).data.inst,'sens 20'); %sets the sensitivity to 10 mV
    fprintf(smdata.inst(sr830ind).data.inst,'oflt 7'); %sets the time constant to 30 ms
    fprintf(smdata.inst(sr830ind).data.inst,'ofsl 3'); %sets the roll off to 24 dB
end

if 1==1
    %initialize the Keithley 2400 as a voltage source
    fprintf(smdata.inst(k2400ind).data.inst,'*RST'); %resets
    fprintf(smdata.inst(k2400ind).data.inst,'source:delay 0.0'); %sets delay to 0
    fprintf(smdata.inst(k2400ind).data.inst,':outp on'); %turns on output
    fprintf(smdata.inst(k2400ind).data.inst,':sens:curr:prot 1e-4'); %sets overload current to 1e-4 A
end

if 1==1
    %initialize the Keithley 2700 as a DMM
    fprintf(smdata.inst(k2700ind).data.inst,'*rst'); %resets
    fprintf(smdata.inst(k2700ind).data.inst,'initiate:continuous on;:abort'); %turns on continuous readings
    fprintf(smdata.inst(k2700ind).data.inst,':voltage:nplcycles .01'); %sets cycle time to fastest
    fprintf(smdata.inst(k2700ind).data.inst,'sense:voltage:dc:average:state off'); %turns off averaging
end
        
if 1==1
    %initialize the DecaDAC as a DAC voltage source
    DACzero=32768; %measured bit where DAC is zero
    bit_str=sprintf('B0;M2;C0;D%.0f;',DACzero);
    query(smdata.inst(dacind).data.inst,bit_str); %sets DAC to zero
    %reset any ramps
    query(smdata.inst(dacind).data.inst, 'B0;M2;C0;S0;'); 
    query(smdata.inst(dacind).data.inst, 'B0;M2;C0;U65535;');
    query(smdata.inst(dacind).data.inst, 'B0;M2;C0;L0;');
end
    

smgui;
close (gcf); %This is a stupid work around to get smgui to display correctly.  
smgui;
cd('C:\Documents and Settings\ohm\My Documents\MATLAB');