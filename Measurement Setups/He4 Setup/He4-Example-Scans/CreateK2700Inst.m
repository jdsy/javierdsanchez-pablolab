ins = 5;
smdata.inst(ins).cntrlfn = @smcK2700;
smdata.inst(ins).device = 'K2700';
smdata.inst(ins).name = 'DMM';
smdata.inst(ins).channels = ['V'];
smdata.inst(ins).type = [0];
save Hsmdata smdata;