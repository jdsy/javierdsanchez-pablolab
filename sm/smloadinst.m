function ind = smloadinst(file, ind, adaptor, varargin)
% ind = smloadinst(file, ind, adaptor, varargin)
% Add instrument from file generated by smsaveinst to rack at position ind.
% Ind defaults to end+1. Existing instruments are overwritten without
% warning.
% adaptor is the HW adaptor driver and defaults to 'ni';
% varargin are arguments to the instrument object constructor, e.g. gpib,
% visa or serial. If not defaults, the settings are taken from the file
% loaded. (Useful if file was created on the same system).

global smdata;

% if ~iscell(files)
%     files = {files};
% end
% 
% 
% for i = 1:length(files)

if nargin < 2 || isempty(ind)
    if isfield(smdata, 'inst')
        ind = length(smdata.inst)+1;
    else
        ind = 1;
    end
end

if isempty(strfind(file, 'sminst'))
    file = ['sminst_', file];
end

load(file);

if ~isempty(constructor)
    if nargin < 3 || isempty(adaptor) 
        switch func2str(constructor.fn)
            case {'gpib', 'visa-tcpip'}
                 adaptor = {'ni'};
            otherwise 
                adaptor = {};
        end
    elseif ~iscell(adaptor)
        adaptor = {adaptor};
    end
    if ~strcmp(adaptor, 'none')
        if nargin >= 4
            constructor.args = varargin;
        end
        
        if ~strcmp(adaptor, 'serial') % accommodate the fact that serial() does not need vendor info
            inst.data.inst = constructor.fn(adaptor{:}, constructor.args{:});
        else
            inst.data.inst = constructor.fn(constructor.args{:});
        end
        set(inst.data.inst, constructor.params, constructor.vals) ;
    end
end
smdata.inst(ind) = inst;

smcheckdata;
