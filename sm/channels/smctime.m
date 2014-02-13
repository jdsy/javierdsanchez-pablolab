function val = smctime(ic, val, rate)

%time driver

global smdata;

switch ic(3); %Operation: 0 for read, 1 for write

    case 0 %read
        switch ic(2)
            case 1 %toc
                val=toc;
            case 2
                val=now;
        end
        
                  
    case 1 %write operation;  
        error('Unfortunately, this program cannot control Time... yet');
        
    otherwise
        error('Operation not supported');
end

