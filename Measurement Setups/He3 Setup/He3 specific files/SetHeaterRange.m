function SetHeaterRange(rng)
%Sets the heater range on the LakeShore
%Hadar, 11/2010

%rng: 0 = turn off heater, 1=2.5mW, 2 = 25 mV, 3 = 250 mW, 4 = 2.5 W, 5 = 25 W

Tcontind = 7;
global smdata;
scmd = sprintf('Range %d',rng);
fprintf(smdata.inst(Tcontind).data.inst,scmd);

end