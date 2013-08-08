
clear;
instrreset;
global smdata; 
global smscan;
%load SMDATA_DAC2;
%load DAC_Scan_v1;
%load scan_qpc2_iv;
%smdata.inst(1,5).data.rng = [0 9999];
%init instruments
k2400adr = 14;
k2700adr = 16;
sr830adr = 8;

smdata.inst(2).data.inst = gpib('ni', 0, sr830adr);
smdata.inst(3).data.inst = gpib('ni', 0, k2400adr);
smdata.inst(4).data.inst = gpib('ni', 0, k2700adr);
smdata.inst(5).data.inst = serial('COM5');

fopen(smdata.inst(2).data.inst);
fopen(smdata.inst(3).data.inst);
fopen(smdata.inst(4).data.inst);
fopen(smdata.inst(5).data.inst);


% fclose(smdata.inst(2).data.inst);
% fclose(smdata.inst(3).data.inst);
% fclose(smdata.inst(4).data.inst);
% fclose(smdata.inst(5).data.inst);
smgui;