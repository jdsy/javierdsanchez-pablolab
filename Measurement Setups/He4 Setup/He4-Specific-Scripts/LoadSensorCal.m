function LoadSensorCal
global Tsens;
global Vsens;

fn = 'Lakeshore Sensor 55123 Calibration Export.txt';
fid = fopen(fn);
DD = fscanf(fid,'%E',[2,inf])';
Tsens = DD(:,1); 
Vsens = DD(:,2);
fclose(fid);

end
