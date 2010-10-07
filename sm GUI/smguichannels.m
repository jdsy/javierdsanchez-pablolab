function varargout = smguichannels(varargin)
% Runs special measure's GUI
% to fix: -- deselect plots after changing setchannels
%         -- selecting files/directories/run numbers
%         -- add notifications + smaux compatibility
    
   %  Create and then hide the GUI as it is being constructed.
   f = figure('Visible','on',...
       'Name','Configure Channels',...
       'NumberTitle','off',...
       'Position',[300,300,500,850],...
       'Toolbar','none',...
       'HandleVisibility','callback',...
       'Resize','off');
   movegui(f,'center')
   


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Construct the components.  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    %  Panel for Channels
    channelwidths = [40 75 100 75 50 50 50 50]; %widths of each column
    channelpanel = uipanel('Title','Channels',...
        'Units','pixels',...
        'Position',[260 50 sum(channelwidths)+5*(length(channelwidths)+2) 850]);

        channelnameheader_sth = uicontrol( ...
            'Style','Text',...
            'String','Name',...
            'Position',[10+sum(channelwidths(1:1)),805,channelwidths(2), 20]);
        channelinstheader_sth = uicontrol( ...
            'Style','Text',...
            'String','Instrument',...
            'Position',[15+sum(channelwidths(1:2)),805,channelwidths(3), 20]);
        channelchanheader_sth = uicontrol( ...
            'Style','Text',...
            'String','Channel',...
            'Position',[20+sum(channelwidths(1:3)),805,channelwidths(4), 20]);
        channelminheader_sth = uicontrol( ...
            'Style','Text',...
            'String','Min',...
            'Position',[25+sum(channelwidths(1:4)),805,channelwidths(5), 20]);
        channelmaxheader_sth = uicontrol( ...
            'Style','Text',...
            'String','Max',...
            'Position',[30+sum(channelwidths(1:5)),805,channelwidths(6), 20]);
        channelrampheader_sth = uicontrol( ...
            'Style','Text',...
            'String','Ramp',...
            'Position',[35+sum(channelwidths(1:6)),805,channelwidths(7), 20]);
        channelconvheader_sth = uicontrol( ...
            'Style','Text',...
            'String','Multiplier',...
            'Position',[40+sum(channelwidths(1:7)),805,channelwidths(8), 20]);
        channeladd_pbh = uicontrol( ...
            'String','Add Channel',...
            'Style','pushbutton',...
            'Position',[5 5 80 20],...
            'Callback',@channeladd_pbh_Callback);
        
        delchan_pbh = [];  % handles to delete channel pushbuttons
        channelname_eth = []; % handles to channelname edit boxes
        instname_pmh = []; % handles to inst name pupup menus
        instchan_pmh = []; % ...
        channelmin_eth = [];
        channelmax_eth = [];
        channelramprate_eth = [];
        channelconv_eth = [];
        
    % Pushbutton to open saved rack [matlab data file]
    openrack = uicontrol('Style','pushbutton','String','Open Rack',...
        'Position',[80 850 60 20],...
        'Callback',{@openrackpushbutton_Callback});
    % Pushbutton to save rack [matlab data file]
    saverack = uicontrol('Style','pushbutton','String','Save Rack',...
        'Position',[160 850 60 20],...
        'Callback',{@saverackpushbutton_Callback});

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Programming the GUI     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mInputArgs = varargin;  % Command line arguments when invoking the GUI
    mOutputArgs = {};       % Variable for storing output when GUI returns
    global smdata smscan smaux;

    
    if isstruct(smdata)
        smchanrefresh;
    end
    
    % refreshes the channel panel
    function smchanrefresh
        nchan = length(smdata.channels);
        workingsize=get(channelpanel,'Position');
        workingsize(4)=workingsize(4)-25;
        if ~isempty(delchan_pbh)
            delete([delchan_pbh channelname_eth instname_pmh instchan_pmh ...
                 channelmin_eth channelmax_eth channelramprate_eth ...
                 channelconv_eth]);           
        end
        delchan_pbh = [];
        channelname_eth = [];
        instname_pmh = [];
        instchan_pmh = [];
        channelmin_eth = [];
        channelmax_eth = [];
        channelramprate_eth = [];
        channelconv_eth = []; 
        
        channelyheight = 18; %in pixels
        channelyspacing = 22; %in pixels


        if ~isfield(smdata,'inst')
            smdata.inst(1).device = 'none';
            smdata.inst(1).name = ' ';
        end

        for i = 1:length(smdata.inst)
            instnames{i}=[smdata.inst(i).device,' ',smdata.inst(i).name];
        end
        for i = 1:nchan
            delchan_pbh(i) = uicontrol( ...
                'Style','pushbutton',...
                'String','Delete',...
                'Position',[5,workingsize(4)-channelyspacing*i-15,channelwidths(1),channelyheight],...
                'Visible','on',...
                'Callback',{@removechannel_Callback,i});
            channelname_eth(i) = uicontrol( ...
                'Style','edit',...
                'String',smdata.channels(i).name,...
                'Position',[10+sum(channelwidths(1:1)),workingsize(4)-channelyspacing*i-15,channelwidths(2), channelyheight],...
                'Visible','on',...
                'Callback',{@edtchannelname_Callback,i});
            instname_pmh(i) = uicontrol( ...
                'Style','popupmenu',...
                'String',['none' instnames],...
                'Value',smdata.channels(i).instchan(1)+1,...
                'Position',[15+sum(channelwidths(1:2)),workingsize(4)-channelyspacing*i-13,channelwidths(3), channelyheight],...
                'Callback',{@instname_pmh_Callback,i});
            instchan_pmh(i) = uicontrol( ...
                'Style','popupmenu',...
                'String',['none' cellstr(smdata.inst(smdata.channels(i).instchan(1)).channels)'],...
                'Value',smdata.channels(i).instchan(2)+1,...
                'Position',[20+sum(channelwidths(1:3)),workingsize(4)-channelyspacing*i-13,channelwidths(4), channelyheight],...
                'Callback',{@instchan_pmh_Callback,i});
            channelmin_eth(i) = uicontrol( ...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(1),...
                'Position',[25+sum(channelwidths(1:4)),workingsize(4)-channelyspacing*i-15,channelwidths(5), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelmin_eth_Callback,i});
            channelmax_eth(i) = uicontrol( ...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(2),...
                'Position',[30+sum(channelwidths(1:5)),workingsize(4)-channelyspacing*i-15,channelwidths(6), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelmax_eth_Callback,i});
            channelramprate_eth(i) = uicontrol( ...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(3),...
                'Position',[35+sum(channelwidths(1:6)),workingsize(4)-channelyspacing*i-15,channelwidths(7), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelramprate_eth_Callback,i});
            channelconv_eth(i) = uicontrol( ...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(4),...
                'Position',[40+sum(channelwidths(1:7)),workingsize(4)-channelyspacing*i-15,channelwidths(8), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelconv_eth_Callback,i});            
        end
    end

    function removechannel_Callback(hObject,eventdata,i)
        smdata.channels(i)=[];
        smchanrefresh;
        makeconstpanel;
        makelooppanels;
    end

    function channeladd_pbh_Callback(hObject,eventdata)
        if (~isstruct(smdata) || ~isfield(smdata,'inst'))
            errordlg('Please setup instruments before adding channels','Action not allowed');
        elseif isstruct(smdata)
            smdata.channels(end+1).instchan=[1 1];
            smdata.channels(end).rangeramp=[0 0 0 1];
            smdata.channels(end).name='New';
            smchanrefresh;
            makeconstpanel;
            makelooppanels;
        else
            smdata.channels(1).instchan=[1 1];
            smdata.channels(1).rangeramp=[0 0 0 1];
            smdata.channels(1).name='New';
            smchanrefresh;
            makeconstpanel;
            makelooppanels;            
        end
    end

    function edtchannelname_Callback(hObject,eventdata,i)
        smdata.channels(i).name=get(hObject,'String');
        makeconstpanel;
        makelooppanels;
    end

    function instname_pmh_Callback(hObject,eventdata,i)
        smdata.channels(i).instchan(1)=get(hObject,'Value')-1;
        smdata.channels(i).instchan(2)=1;
        set(instchan_pmh(i),'String',['none' cellstr(smdata.inst(smdata.channels(i).instchan(1)).channels)']);
        set(instchan_pmh(i),'Value',1);
    end

    function instchan_pmh_Callback(hObject,eventdata,i)
        smdata.channels(i).instchan(2)=get(hObject,'Value')-1;
    end

    function channelmin_eth_Callback(hObject,eventdata,i)
        val = str2double(get(hObject,'String'));
        if ~isnan(val)
            smdata.channels(i).rangeramp(1)= val;
            set(hObject,'String',smdata.channels(i).rangeramp(1));
        else
            errordlg('Please enter a real number or "inf"','Invalid Input Value');
            set(hObject,'String',smdata.channels(i).rangeramp(1));
        end
    end

    function channelmax_eth_Callback(hObject,eventdata,i)
        val = str2double(get(hObject,'String'));
        if ~isnan(val)
            smdata.channels(i).rangeramp(2)= val;
            set(hObject,'String',smdata.channels(i).rangeramp(2));
        else
            errordlg('Please enter a real number or "inf"','Invalid Input Value');
            set(hObject,'String',smdata.channels(i).rangeramp(2));
        end
    end

    function channelramprate_eth_Callback(hObject,eventdata,i)
        val = str2double(get(hObject,'String'));
        if ~isnan(val)
            smdata.channels(i).rangeramp(3)= val;
            set(hObject,'String',smdata.channels(i).rangeramp(3));
        else
            errordlg('Please enter a real number or "inf"','Invalid Input Value');
            set(hObject,'String',smdata.channels(i).rangeramp(3));
        end
    end

    function channelconv_eth_Callback(hObject,eventdata,i)
        val = str2double(get(hObject,'String'));
        if ~isnan(val)
            smdata.channels(i).rangeramp(4)= val;
            set(hObject,'String',smdata.channels(i).rangeramp(4));
        else
            errordlg('Please enter a real number or "inf"','Invalid Input Value');
            set(hObject,'String',smdata.channels(i).rangeramp(4));
        end
    end

    function openrackpushbutton_Callback(hObject,eventdata)
        [smdataFile,smdataPath] = uigetfile('*.mat','Select Rack File');
        S=load (fullfile(smdataPath,smdataFile));
        smdata=S.smdata;
        sminstrefresh;
        smchanrefresh;
        makeconstpanel;
    end

    function saverackpushbutton_Callback(hObject,eventdata)  
        [smdataFile,smdataPath] = uiputfile('*.mat','Save Rack As');
        save(fullfile(smdataPath,smdataFile),'smdata');
    end



    
    
end 