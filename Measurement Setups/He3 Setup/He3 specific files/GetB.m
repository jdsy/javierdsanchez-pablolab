function B = GetB
%Get Mag field
%Hadar, 12/2010
%Hadar: I think it does not read the field correctly...
MagContind = 7;

global smdata;
[Bout] = query(smdata.inst(MagContind).data.inst,'IOUT?');
% B = str2num(Bout); % no longer a string?
B = str2num(Bout)

end