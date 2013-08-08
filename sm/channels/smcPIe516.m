function val = smcPIe516(ic, val, rate)
%Channels
%1 - 'X' Voltage output for channel A
%2 - 'Y' Voltage output for channel B

%Driver for Physik Instrumente E-516 Piezo Controller

global smdata;
inst = smdata.inst(ic(1)).data.inst;

switch ic(2) % Channels 

    case 1 %X
        switch ic(3) %get/set
            case 0 %get
                val = query(inst, sprintf('SVA? A'), '%s\n', '%f');
            case 1 %set
                fprintf(inst, sprintf('SVA A %f', val));
            otherwise
                error('Piezo Controller driver: Operation not supported');
        end
    case 2 %Y
        switch ic(3) %get/set
            case 0 %get
                val = query(inst, sprintf('SVA? B'), '%s\n', '%f');
            case 1 %set
                fprintf(inst, sprintf('SVA B %f', val));
            otherwise
                error('Piezo Controller driver: Operation not supported');
        end
    otherwise
        error('Piezo Controller  driver: Nonvalid Channel specified');
end

end