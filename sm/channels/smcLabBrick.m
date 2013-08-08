function val = smcLabBrick(ic, val, rate)
%function val = smcLabBrick(ic, val, rate)
% Control function for LabBricks from Vaunix.
% Only minimal functionality is supported.
% 1: freq, 2: power, 3: rf on/off
% 4: save settings
% 12: print a list of serial numbers (nb ; now only prints first serial.
% example: instrument 20 is a lab brick:
%  smcLabBrick([20 3 1],1) will turn on power


global smdata;

% Open the library if needed.
if ~libisloaded('hidapi')
  p=strrep(which('smcLabBrick'),'smcLabBrick.m','labbrick') ;  
  addpath(p);
  if ~lbLoadLibrary
      error('Unable to load hidapi');
  end
  rmpath(p);
  smdata.inst(ic(1)).data.devhandle=[];
end


lb_manufacturer = sscanf('0x041f','%x');
lb_product      = sscanf('0x1209','%x'); % Fixme; this only works with LSG-451

if ic(2) == 12 % Print serial of first device connected
   printFirstSerial(lb_manufacturer, lb_product);
   return;
end
    
    
% Open the device if needed.
h=libpointer();
try
  h=calllib('hidapi','hid_open',lb_manufacturer,lb_product,libpointer('uint16Ptr',[uint16(smdata.inst(ic(1)).data.serial) 0]));  
  if h.isNull
      error('Unable to open labbrick serial %s\n',smdata.inst(ic(1)).data.serial);
  end
  
  % Supported command info
  cmds(1).scale=1e3;
  cmds(1).size=4;
  cmds(1).name='Frequency';
  cmds(1).cmd=[4 132];
  cmds(1).offset=0;
  
  cmds(2).scale=-0.25;
  cmds(2).offset=-10;
  cmds(2).size=1;
  cmds(2).name='Power (dB)';
  cmds(2).cmd=[13 141];
  
  cmds(3).scale=1;
  cmds(3).offset=0;
  cmds(3).size=1;
  cmds(3).name='RF On';
  cmds(3).cmd=[10 138];
  
  if ic(3) == 1 % Set
      if ic(2) > length(cmds)
          error('Unknown channel %d\n', ic(2));
      end
      cmd=uint8(zeros(1,9));
      cmd(2)=cmds(ic(2)).cmd(ic(3)+1);
      cmd(3)=cmds(ic(2)).size;
      cmd = libpointer('uint8Ptr',cmd);
      p = cmd+3;      
      switch cmds(ic(2)).size
          case 4 % 32 bit int
              setdatatype(p,'uint32Ptr',1);
              p.value = round((cmds(ic(2)).offset + val) / cmds(ic(2)).scale);               
          case 1 % 8 bit int
              p.value(1) = round((cmds(ic(2)).offset + val) / cmds(ic(2)).scale); 
          otherwise
              error('Unsupported size');
      end      
      bytes = calllib('hidapi','hid_write',h,cmd,length(cmd.value));
      if bytes < 0; error('hidapi:hiderror','Error sending command get %s\n',cmds(ic(2)).name); end;
      clear p;
      clear cmd;
  else    % get
      if ic(2) > length(cmds)
          error('Unknown channel %d\n', ic(2));
      end  
      cmd=uint8([0 cmds(ic(2)).cmd(ic(3)+1) 0 0 0 0 0 0 0]);
      bytes = calllib('hidapi','hid_write',h,cmd,length(cmd));
      if bytes < 0; error('hidapi:hiderror','Error sending command get %s\n',cmds(ic(2)).name); end;
      for i=1:256  % May not be first response
        data = libpointer('uint8Ptr',zeros(1,8));
        bytes = calllib('hidapi','hid_read',h,data,8);
        if data.value(1) == cmd(2)
           break;
        end
      end  
      assert(data.val(2) == cmds(ic(2)).size);  % Check payload size.
      % Parse the payload
      switch data.val(2) 
          case 4  % 32 bit int.
              p=data+2;
              setdatatype(p,'uint32Ptr',1);
              val = double(p.value) * cmds(ic(2)).scale + cmds(ic(2)).offset;
              clear p;              
          case 1
              val = double(data.val(3)) * cmds(ic(2)).scale - cmds(ic(2)).offset;              
      end
      clear data;
  end
  
  calllib('hidapi','hid_close',h);  h=libpointer();
catch err
  if strcmp(err.identifier,'hidapi:hiderror')
      showHidError(h);
  end
  if ~h.isNull
     calllib('hidapi','hid_close',h);
  end
  rethrow(err);
end
return;
fscale=1e5;  % Frequency is set in 100khz increments.
funcs = {'Frequency','PowerLevel','RFOn'};
scales= [ 1e5, 0.25, 1];
switch ic(2)
    case {1,2,3}
       if ic(3)       
           lbfn(['Set' funcs{ic(2)}],dh,val/scales(ic(2)));           
       else
           val=lbfn(['Get' funcs{ic(2)}],dh)*scales(ic(2));
           % Work around a bug in the DLL
           if (ic(2) == 2)
               val=10-val;
           end
       end       
    case 11        
       fprintf('Warning: this device auto-closes\n');
    case 10
        lbfn('SaveSettings',dh);
    otherwise
        closeDevice(dh);
        error('Unknown channel');
end
closeDevice(dh);
end

function dh=openDevice(ic)
   global smdata;
   nd=lbfn('GetNumDevices');
   if nd == 0
       error('No labbrick attached');
   end
   devids=libpointer('uint32Ptr',zeros(nd+1,1));
   lbfn('GetDevInfo',devids);
   mydev=-1;
   if isfield(smdata.inst(ic(1)).data,'serial') && ~isempty(smdata.inst(ic(1)).data.serial)       
      for i=1:nd
         if lbfn('GetSerialNumber',devids.value(i)) == smdata.inst(ic(1)).data.serial
             mydev=i;             
             break;
         end
      end   
      if mydev == -1
        error('No device found matching serial number %d\n',smdata.inst(ic(1)).data.serial);
      end
   else
       mydev = 1;
       if nd > 1
           fprintf('Warning: More than one labbrick present and no serial number given\n');
           fprintf('Choosing first\n');
       end
   end
   dh=mydev;
   lbfn('InitDevice',dh);
end

function showHidError(h)
  if h.isNull
      fprintf('HIDERROR: Device is NULL\n');
  else
      str=calllib('hidapi','hid_error',h);
      for i=1:256
          setdatatype(str,'uint16Ptr',i);
          if(str.value(end) == 0)
            i
            setdatatype(str,'uint16Ptr',i-1);              
            str=char(str.value);
            break;
          end
      end
      fprintf('HIDERROR: %s\n',str);
      clear str;    
  end
end

function printFirstSerial(lb_manufacturer, lb_product)
  h=calllib('hidapi','hid_open',lb_manufacturer,lb_product,libpointer());
   if h.isNull
       error('No labbricks connected');
   end
   
   name=libpointer('uint16Ptr',zeros(1,128));
   calllib('hidapi','hid_get_manufacturer_string',h,name,length(get(name,'Value')));
   nmv=get(name,'Value');
   nmv=char(nmv(1:find(nmv == 0,1,'first')));
   calllib('hidapi','hid_get_product_string',h,name,length(get(name,'Value')));
   pnmv=get(name,'Value');
   pnmv=char(pnmv(1:find(pnmv == 0,1,'first')));
   calllib('hidapi','hid_get_serial_number_string',h,name,length(get(name,'Value')));
   snmv=get(name,'Value');
   snmv=char(snmv(1:find(snmv == 0,1,'first')));
   fprintf('First attached device is a %s from %s, serial "%s"\n',pnmv,nmv,snmv);
   calllib('hidapi','hid_close',h);
end