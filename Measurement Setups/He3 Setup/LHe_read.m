%Read the He level meter
instrreset;
addr = 5;
LH = gpib('ni', 0, addr);
fopen(LH);
levels = []; tts = [];
fn = 'Z:\group\Topological Insulator\TI Matlab\SM_Scripts\LH_log_2011_02_17.mat';

waittime = 600; %seconds

for j = 1:1000
    valstr =  query(LH,'MEAS?');
    ind = findstr(valstr,'in');
    levelj = str2num(valstr(1:ind-1));
    tt = now;
    tts = [tts tt];
    levels = [levels levelj];
    save(fn,'levels','tts');
    pause(waittime);
    
end
fclose(LH);