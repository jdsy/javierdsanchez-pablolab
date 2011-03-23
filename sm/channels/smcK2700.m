function val = smcK2700(ic, val, rate)

%skeletal driver for Keithley 2700 and 2000

global smdata;

switch ic(3); %Operation: 0 for read, 1 for write

    case 0 %just read voltage for now
        val = query(smdata.inst(ic(1)).data.inst, 'DATA?', '%s\n', '%f');
                  
    case 1 %write operation;  
        error('The DMM does not support write operations');
        
    otherwise
        error('Operation not supported');
end

