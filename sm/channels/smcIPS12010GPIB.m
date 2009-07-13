function val = smcIPS12010GPIB(ico, val, rate)
% Driver for IPS12010 (GPIB version)
% settings for GPIB:
% usually board index is 0, address is 25
% can change Timeout to 1
% make sure to change the following
%               EOIMode = 'off'
%               EOSCharCode = 'CR'
%               EOSMode = 'read'

global smdata;
IPSaddress = 25; % for He4 station

if ico(3)==1
    rateperminute = rate*60;

    if abs(rateperminute) > .5; %.5 T /MIN
        error('Magnet ramp rate too high')
    end

end

%ico: vector with instruemnt(index to smdata.inst), channel number for that instrument, operation
% operation: 0 - read, 1 - set , 2 - unused usually
% rate overrides default

%Might need in setup:
%channel 1: FIELD

switch ico(2) % channel

    case 1
        switch ico(3)

            case 1
                % any way to delay trigger
                
                % put instrument in remote controlled mode
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'C3');
                fscanf(smdata.inst(ico(1)).data.inst);
                
                % set the rate
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['T' num2str(rateperminute)]);
                fscanf(smdata.inst(ico(1)).data.inst);
                
                % read the current field value
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'R7');
                currstring = fscanf(smdata.inst(ico(1)).data.inst);
                curr=str2double(currstring(2:end));
                
                % set the field target
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['J' num2str(val)]);
                fscanf(smdata.inst(ico(1)).data.inst);
                
                % go to target field
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'A1');
                fscanf(smdata.inst(ico(1)).data.inst);
                

                val = abs(val-curr)/abs(rate);
                
            case 0
                % read the current field value
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'X');
                state = fscanf(smdata.inst(ico(1)).data.inst);
                if state(9) == '2'
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'R18');
                else
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'R7');
                end
                val = fscanf(smdata.inst(ico(1)).data.inst, '%*c%f');
                
            otherwise
                error('Operation not supported');
        end
        
    case 2
        switch ico(3)
            case 1                
                % set the rate
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['T' num2str(rateperminute)]);
                fscanf(smdata.inst(ico(1)).data.inst);

                % read the current field value
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'R7');
                currstring = fscanf(smdata.inst(ico(1)).data.inst);
                curr=str2double(currstring(2:end));
                
                % set the field target
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['J' num2str(val)]);
                fscanf(smdata.inst(ico(1)).data.inst);
                                
                val = abs(val-curr)/abs(rate);

            case 0
                % read the current field value
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'R8');
                val = fscanf(smdata.inst(ico(1)).data.inst, '%*c%f');
                
            otherwise
                error('Operation not supported');
        end

end

