


%recover

global smdata; 
global smscan;

if 1==1
  clear all;
  load('C:\Special_Measure_2011\Measurement Setups\Probe Station\probestationrack.mat');
  %smdata = smbackup;
end
instrreset;
%Open communications for all instruments
k2400adr = 13;
k2700adr = 16;
sr830adr = 9;

sr830ind = 2;
k2400ind = 3;
k2700ind = 4;
dacind = 5;

smdata.inst(sr830ind).data.inst = gpib('ni', 0, sr830adr);
smdata.inst(k2400ind).data.inst = gpib('ni', 0, k2400adr);
smdata.inst(k2700ind).data.inst = gpib('ni', 0, k2700adr);
smdata.inst(dacind).data.inst = serial('COM5');

fopen(smdata.inst(sr830ind).data.inst);
fopen(smdata.inst(k2400ind).data.inst);
fopen(smdata.inst(k2700ind).data.inst);
fopen(smdata.inst(dacind).data.inst);

if 1==1
%initialize the Keithley 2400 as a voltage source
fprintf(smdata.inst(k2400ind).data.inst,'*RST');
fprintf(smdata.inst(k2400ind).data.inst,':sour:func volt');
fprintf(smdata.inst(k2400ind).data.inst,':outp on');
fprintf(smdata.inst(k2400ind).data.inst,':sens:curr:prot 1e-3');
end

if 1==0
%initialize Keithley 2400 as a current source for reading T
fprintf(smdata.inst(3).data.inst,'*RST');
fprintf(smdata.inst(3).data.inst,':sour:func curr');
fprintf(smdata.inst(3).data.inst,':sens:func "volt"');
fprintf(smdata.inst(3).data.inst,':outp on');
fprintf(smdata.inst(3).data.inst,':sour:curr 1e-5')
end

%LoadSensorCal;
%smdata.inst(k2400indT).data.inst = smdata.inst(k2400ind).data.inst;

smgui;