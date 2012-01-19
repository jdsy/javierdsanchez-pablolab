function Tcurr = GetTsensor(Vcurr)
%fn = 'Lakeshore Sensor 55123 Calibration Export.txt';
%fid = fopen(fn);
%DD = fscanf(fid,'%E',[2,inf])';
%T = DD(:,1); 
%V = DD(:,2);
%fclose(fid);
global Tsens;
global Vsens;

Tcurr = interp1(Vsens,Tsens,Vcurr);
end
%figure(1);
%plot(T,V);