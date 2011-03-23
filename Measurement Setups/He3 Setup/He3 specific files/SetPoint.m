function SetPoint(loop,T)
%send a setpoint command to the LakeShore
%Hadar, 11/2010
Tcontind = 7;
global smdata;
scmd = sprintf('SETP %d, %2.2f',loop,T);
fprintf(smdata.inst(Tcontind).data.inst,scmd);

end