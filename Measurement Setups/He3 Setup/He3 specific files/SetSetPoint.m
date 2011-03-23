function SetSetPoint(loop,rng,Tset)
%range: 0 = turn off heater, 1=2.5mW, 2 = 25 mV, 3 = 250 mW, 4 = 2.5 W, 5 = 25 W
%Hadar, 2/2011
Tcontind = 7;
global smdata;
	                              
scmd = sprintf('RANGE %d',rng);
response = query(smdata.inst(Tcontind).data.inst,scmd);
scmd = sprintf('SETP %d, %2.2f',loop,Tset);
response = query(smdata.inst(Tcontind).data.inst,scmd);
end