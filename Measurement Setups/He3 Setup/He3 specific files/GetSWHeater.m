function SW = GetSWHeater

global smdata;
MagContind = 8; 

SW = query(smdata.inst(MagContind).data.inst, sprintf('PSHTR?')); 

end