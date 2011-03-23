function val = smcK2400(ic, val, rate)
%Attempt by Hadar to write inst driver for Keithley 2400
%6/3/2010 JDSY - adding comments and checking things out
% question, is I curerntly measuring current or voltage?

%K2400 is a Sourcemeter.  Typically we use as voltage source for backgate

global smdata;

%ic(1) is instrument
%ic(2) is channel
%ic(3) is operation
%each instrument has a list of channels, retrieve desired one by index
strchan = smdata.inst(ic(1)).channels(ic(2));
if strchan == 'V'

    switch ic(3); %Operation: 0 for read, 1 for write

        case 0 %just read voltage for now
            %'case 0'
            KO = query(smdata.inst(ic(1)).data.inst, 'READ?', '%s\n', '%f,%f,%f,%f,%f');
            val = KO(1);

        case 1 %write operation;  %support only voltage right now
            %'case 1'
            cmd = ':SOUR:VOLT ';
            fprintf(smdata.inst(ic(1)).data.inst, sprintf('%s %f', cmd, val));

        otherwise
            error('Operation not supported');
    end
else
    if strchan == 'I'
        switch ic(3); %Operation: 0 for read, 1 for write

        case 0 %just read voltage for now  %JDSY - is this current or voltage?
            %'case 0'
            KO = query(smdata.inst(ic(1)).data.inst, 'READ?', '%s\n', '%f,%f,%f,%f,%f');
            val = KO(2);

        case 1 %write operation;  %support only voltage write now
            %'case 1'
            cmd = ':SOUR:VOLT ';
            fprintf(smdata.inst(ic(1)).data.inst, sprintf('%s %f', cmd, val));

        otherwise
            error('Operation not supported');
        end
    end
end
        
end

