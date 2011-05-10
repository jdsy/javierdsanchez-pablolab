
clear;
instrreset;
global smdata; 
load SMDATA_DAC3; %worked with DAC in script 4/7/10

%init instruments
k2400adr = 14;
k2700adr = 16;
sr830adr = 8;


Dacind = 5;

smdata.inst(2).data.inst = gpib('ni', 0, sr830adr);
smdata.inst(3).data.inst = gpib('ni', 0, k2400adr);
smdata.inst(4).data.inst = gpib('ni', 0, k2700adr);
%initialize DAC instrument
smdata.inst(Dacind).data.inst = serial('COM5');

fopen(smdata.inst(2).data.inst);
fopen(smdata.inst(3).data.inst);
fopen(smdata.inst(4).data.inst);
fopen(smdata.inst(Dacind).data.inst);

%smcDecaDAC4([Dacind 1 1],1.2);
%smcDecaDAC4([Dacind 1 0])
smgui;
%fclose(smdata.inst(2).data.inst);
%fclose(smdata.inst(3).data.inst);
%fclose(smdata.inst(4).data.inst);
%fclose(smdata.inst(Dacind).data.inst);
