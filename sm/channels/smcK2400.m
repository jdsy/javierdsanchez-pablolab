function val = smcK2400(ic, val, rate)

%Driver for Keithley 2400
%Last update: Hadar 10-13-2010

global smdata;

strchan = smdata.inst(ic(1)).channels(ic(2),:);
if strchan == 'VSTEP'

    switch ic(3); %Operation: 0 for read, 1 for write

        case 0 %read
            %'case 0'
            KO = query(smdata.inst(ic(1)).data.inst, 'READ?', '%s\n', '%f,%f,%f,%f,%f');
            val = KO(1);

        case 1 %write operation; 
            %'case 1'
            cmd = ':SOUR:VOLT ';
            fprintf(smdata.inst(ic(1)).data.inst, sprintf('%s %f', cmd, val));

        otherwise
            error('Operation not supported');
    end
else
    if strchan == 'ISTEP'
        switch ic(3); %Operation: 0 for read, 1 for write

        case 0 %just read voltage for now
            %'case 0'
            KO = query(smdata.inst(ic(1)).data.inst, 'READ?', '%s\n', '%f,%f,%f,%f,%f');
            val = KO(2);

        case 1 %write operation;  
            %'case 1'
            cmd = ':SOUR:CURR ';
            fprintf(smdata.inst(ic(1)).data.inst, sprintf('%s %f', cmd, val));

        otherwise
            error('Operation not supported');
        end
    end
end
        
end

        end
    end
end
        
end

