function T = GetT(abc)
%Get Temperature of a Sensor
%Hadar, 12/2010
Tcontind = 7;
global smdata;
scmd = sprintf('KRDG? %s',abc);
Tstr = query(smdata.inst(Tcontind).data.inst,scmd);
T = str2num(Tstr);
end