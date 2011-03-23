function SetSetPoint_Rng(Tset)
%Encapsulate SetSetPoint and select range according to T
%Only for He3 heater
Tcontind = 7;
global smdata;
	                              
    if Tset < 10
        rng = 3;
    else if Tset < 30
            rng = 4;
        else
            rng = 5;
        end
    end
    
    SetSetPoint(1,rng,Tset);
end