
global smdata; 
global smscan;

%recover
if 1==1
    clear all;
    global smdata; 
    global smscan;
    % load('Z:\group\measurements\leonardo\Bi_layer_device\BN_01_11_11_BN14\He3_measurements\pn1\ScansDC\Buffer_Rack.mat');  %rack v5 has corrections to DAC
    load('Y:\group\measurements\leonardo\Bi_layer_device\BN_02_23A\MatLab_scans\Rack_Leonardo_2011_04_27.mat');  %rack v5 has corrections to DAC

end
instrreset;


%Open communications for all instruments
k2400adr = 14;          % Addressing
k2700adr = 16;
sr830adr = 8;
sr830badr = 9;
Tcontadr = 12;
MagContadr = 1;

sr830ind = 2;            % Indexing
k2400ind = 3;
k2700ind = 4;
dacind = 5;
sr830bind = 6;
Tcontind = 7;
MagContind = 8;

smdata.inst(sr830ind).data.inst = gpib('ni', 0, sr830adr);
smdata.inst(k2400ind).data.inst = gpib('ni', 0, k2400adr);
smdata.inst(k2700ind).data.inst = gpib('ni', 0, k2700adr);
smdata.inst(dacind).data.inst = serial('COM1');
smdata.inst(sr830bind).data.inst = gpib('ni', 0, sr830badr);
smdata.inst(Tcontind).data.inst = gpib('ni', 0, Tcontadr);
smdata.inst(MagContind).data.inst = gpib('ni', 0, MagContadr);

fopen(smdata.inst(sr830ind).data.inst);
fopen(smdata.inst(k2400ind).data.inst);
fopen(smdata.inst(k2700ind).data.inst);
fopen(smdata.inst(dacind).data.inst);
fopen(smdata.inst(sr830bind).data.inst);
fopen(smdata.inst(Tcontind).data.inst);
fopen(smdata.inst(MagContind).data.inst);

if 1==1
%properly intialize DAC according to front switches
    i = sminstlookup('DecaDAC');
    %MAKE SURE TO SET FOLLOWING OT MATCH FRONT PANEL!!
    smdata.inst(i).data.rng = [-10 10;-10 10;-10 10;0 10;-10 0;-10 0;-10 0;-10 0;-10 0;-10 0;-10 10;-10 10];
    smdata.inst(i).data.update = [1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000];
    smdata.inst(i).data.trigmode = 0;
    %%datadim
    smdata.inst(i).datadim = zeros([24,1])
end

if 1==1
    %initialize the Keithley 2400 as a voltage source
    fprintf(smdata.inst(k2400ind).data.inst,'*RST');
    fprintf(smdata.inst(k2400ind).data.inst,':sour:func volt');
    fprintf(smdata.inst(k2400ind).data.inst,':outp on');
    fprintf(smdata.inst(k2400ind).data.inst,':sens:curr:prot 1e-6');
end

if 1==0
    %initialize Keithley 2400 as a current source
    fprintf(smdata.inst(k2400ind).data.inst,'*RST');
    fprintf(smdata.inst(k2400ind).data.inst,':sour:func curr');
    fprintf(smdata.inst(k2400ind).data.inst,':sens:func "volt"');
    fprintf(smdata.inst(k2400ind).data.inst,':outp on');
    fprintf(smdata.inst(k2400ind).data.inst,':sour:curr 0');
end

%initialize the magnet
if 1==0
    fprintf(smdata.inst(MagContind).data.inst,'UNITS T');
    fprintf(smdata.inst(MagContind).data.inst,'RANGE 0 39.46');
    fprintf(smdata.inst(MagContind).data.inst,'RATE 0 0.02');   % rate 4.6mT/s
    fprintf(smdata.inst(MagContind).data.inst,'PSHTR ON');
end
cd('Y:\group\measurements\leonardo\Bi_layer_device\BN_02_23A\Bi_Layer_2_3');
smgui;