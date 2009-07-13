function data = smrun(scan, filename)
% data = smrun(scan, filename)
%
% scan: struct with the following fields:
%   disp: struct array with display information with  fields:  
%     channel: (index to saved channels)
%     dim: plot dimension (1 or 2)
%     loop: in what loop to display. defaults to one slower than 
%           acquisition. (somewhat rough)
% saveloop: loop in which to save data (default: second fastest)
% trafofn: list of global transformations.
% configfn: function struct with elements fn and args.
%            confignfn.fn(scan, configfn.args{:}) is called before all
%            other operations.
% loops: struct array with one element for each dimension, fields given
%        below. The last entry is for the fastest, innermost loop
%   fields of loops:
%   rng, 
%   npoints (empty means take rng as a vector, otherwise rng defines limits)
%   ramptime: min ramp time from point to point for each setchannel, 
%           currently converted to ramp rate assuming the same ramp rate 
%           at each point. If negative, the channel is only initialized at
%           the first point of the loop, and ramptime replaced by the 
%           slowest negative ramp time.
%           At the moment, this determines both the sample and the ramp
%           rate, i.e. the readout occurs as soon as a ramp finishes.
%           Ramptime can be a vector with an entry for each setchannel or
%           a single number for all channels. 
%   setchan
%   trafofn (cell array of function handles. Default: independent variable of this loop)
%   getchan
%   prefn (struct array with fields fn, args. Default empty)
%   postfn (default empty, currently a cell array of function handles)
%   datafn
%   procfn: struct array with fields fn and dim, one element for each
%           getchannel. dim replaces datadim, fn is a struct array with
%           fields fn and args.
%   trigfn: executed only after programming ramps for autochannels.

global smdata;


if isfield(scan, 'configfn')
    for i = 1:length(scan.configfn)
        scan = scan.configfn(i).fn(scan, scan.configfn(i).args{:});
    end
end

scandef = scan.loops(end:-1:1);
% swap order of loops (convention changed after code was written)
% loops are specified fastest first, but indexed slowest first internally

disp = scan.disp;

nloops = length(scandef);
nsetchan = zeros(1, nloops);
ngetchan = zeros(1, nloops);


if ~isfield(scandef, 'npoints')
    [scandef.npoints] = deal([]);
end

if ~isfield(scandef, 'trafofn')
    [scandef.trafofn] = deal({});
end

if ~isfield(scandef, 'ramptime')
     [scandef.ramptime] = deal([]);
end

if ~isfield(scan, 'saveloop')
    scan.saveloop = 2;
end


if ~isfield(scan, 'trafofn')
    scan.trafofn = {};
end


%if nargin < 2
%    filename = 'data';
%end

if nargin >= 2
    if isempty(filename);
        filename = 'data';
    end
    filename = sprintf('sm_%s.mat', filename);

    str = '';
    while exist(filename, 'file') && ~strcmp(str, 'yes')
        fprintf('File %s exists. Overwrite? (yes/no)', filename);
        while 1
            str = input('', 's');
            switch str
                case 'yes'
                    break;
                case 'no'
                    filename = sprintf('sm_%s.mat', input('Enter new name:', 's'));
                    break
            end
        end
    end
end


    
for i = 1:nloops
    if isempty(scandef(i).npoints)        
        scandef(i).npoints = length(scandef(i).rng);
    elseif isempty(scandef(i).rng)        
        scandef(i).rng = 1:scandef(i).npoints;
    else
        scandef(i).rng = linspace(scandef(i).rng(1), scandef(i).rng(end), ...
            scandef(i).npoints);
    end

    % default for ramp?
    
    scandef(i).setchan = smchanlookup(scandef(i).setchan);
    scandef(i).getchan = smchanlookup(scandef(i).getchan);
    nsetchan(i) = length(scandef(i).setchan);
    ngetchan(i) = length(scandef(i).getchan);

    if isempty(scandef(i).ramptime)
        scandef(i).ramptime = nan(nsetchan(i), 1);
    elseif length(scandef(i).ramptime) == 1 
        scandef(i).ramptime = repmat(scandef(i).ramptime, size(scandef(i).setchan));
    end

    k = nloops-i+1; %use user convention: slowest loops first    
    if isempty(scandef(i).trafofn)
        scandef(i).trafofn = {};
       [scandef(i).trafofn{1:nsetchan(i)}] = deal(@(x, y) x(k));
    else
        for j = 1:nsetchan(i)
            if isempty(scandef(i).trafofn{j})
                scandef(i).trafofn{j} = @(x, y) x(k);
            end
        end
    end
end

npoints = [scandef.npoints];
totpoints = prod(npoints);

datadim = zeros(sum(ngetchan), 5); % size of data read each time
newdata = cell(1, max(ngetchan));
data = cell(1, sum(ngetchan));
ndim = zeros(1, sum(ngetchan)); % dimension of data read each time
dataloop = zeros(1, sum(ngetchan)); % loop in which each channel is read
disph = zeros(1, sum(ngetchan));
ramprate = cell(1, nloops);
tloop = zeros(1, nloops);
getch = vertcat(scandef.getchan);
% get data dimension and allocate data memory
for i = 1:nloops
    instchan = vertcat(smdata.channels(scandef(i).getchan).instchan);            
    for j = 1:ngetchan(i)
        ind = sum(ngetchan(1:i-1))+ j; % data channel index
        if isfield(scandef, 'procfn') && ~isempty(scandef(i).procfn(j).fn)
            dd = scandef(i).procfn(j).dim; % get dimension of proscessed data if procfn defined
        else
            dd = smdata.inst(instchan(j, 1)).datadim(instchan(j, 2), :);
        end
        
        ndim(ind) = sum(dd > 1);
        % # of non-singleton dimensions
        datadim(ind, 1:ndim(ind)) = dd(1:ndim(ind));          
        dim = [npoints(1:i), datadim(ind, 1:ndim(ind))];
        if length(dim) == 1
            dim(end+1) = 1;
        end
        data{ind} = nan(dim);
        dataloop(ind) = i;
    end
end
   
switch length(disp)
    case 1
        sbpl = [1 1];         
    case 2
        sbpl = [1 2];
   
    case {3, 4}
        sbpl = [2 2];
        
    case {5, 6}
        sbpl = [2 3];
        
    otherwise
        sbpl = [3 3];
        disp(10:end) = [];
end


if ~ishandle(1000);
    figure(1000)
    set(1000, 'pos', [10, 10, 800, 400]);
else
    figure(1000);
    clf;
end
set(1000, 'CurrentCharacter', char(0));

% default for disp loop
if ~isfield(disp, 'loop')
    for i = 1:length(disp)
        disp(i).loop = dataloop(disp(i).channel)-1;
    end
end

s.type = '()';
s2.type = '()';
for i = 1:length(disp)    
    subplot(sbpl(1), sbpl(2), i);
    dc = disp(i).channel; %index of channel to be displayed
    % modify if reducing data before plotting

    s.subs = num2cell(ones(1, dataloop(dc) + ndim(dc)));
    [s.subs{end-disp(i).dim+1:end}] = deal(':');
    %s.subs = [num2cell(ones(1, dataloop(scan.dispchan(i)) + ndim(scan.dispchan(i))-2)), ':', ':'];
    if dataloop(dc) + ndim(dc) > nloops 
        x = [1, datadim(dc, ndim(dc))];
        xlab = 'n';
    else
        x = scandef(dataloop(dc) + ndim(dc)).rng;        
        if ~isempty(scandef(dataloop(dc) + ndim(dc)).setchan)
            xlab = smdata.channels(scandef(dataloop(dc) + ndim(dc)).setchan(1)).name;
        else
            xlab = '';
        end
    end

    if disp(i).dim == 2        
        if dataloop(dc)+ndim(dc)-1  > nloops
            y = [1, datadim(dc, ndim(dc)-1)];
            ylab = 'n';
        else
            y = scandef(dataloop(dc)+ndim(dc)-1).rng;
            if ~isempty(scandef(dataloop(dc) + ndim(dc)-1).setchan)
                ylab = smdata.channels(scandef(dataloop(dc) + ndim(dc)-1).setchan(1)).name;
            else
                ylab = '';
            end
        end
        z = zeros(length(y), length(x));
        z(:, :) = subsref(data{dc}, s);
        disph(i) = imagesc(x, y, z);
        %disph(i) = imagesc(x, y, permute(subsref(data{dc}, s), [ndim(dc)+(-1:0), 1:ndim(dc)-2]));
        
        set(gca, 'ydir', 'normal');
        colorbar;
        title(smdata.channels(getch(dc)).name);
        xlabel(xlab);
        ylabel(ylab);
    else
        y = zeros(size(x));
        y(:) = subsref(data{dc}, s);
        disph(i) = plot(x, y);
        %permute(subsref(data{dc}, s), [ndim(dc), 1:ndim(dc)-1])
        xlim(sort(x([1, end])));
        xlabel(xlab);
        ylabel(smdata.channels(getch(dc)).name);
    end
end  

x = zeros(1, nloops);
val = zeros(1, max(nsetchan));
val2 = zeros(1, max(nsetchan));
%filename = sprintf('sm_%02d%02d%02d_%02d%02d')


configvals = cell2mat(smget(smdata.configch));
configch = {smdata.channels(smchanlookup(smdata.configch)).name};
configdata = fncall(smdata.configfn);

if nargin >= 2
    save(filename, 'configvals', 'configdata', 'scan', 'configch');
    str = [configch; num2cell(configvals)];
    logentry(filename);
    logadd(sprintf('%s=%.3g, ', str{:}));
end

tic;

count = ones(size(npoints)); % will cause all loops to be updated.

loops = 1:nloops;
for i = 1:totpoints    
    % update a loop if all subsequent loops are at first val
    if i > 1;
        loops = find(count > 1 , 1, 'last' ):nloops;
    end       
    
    for j = loops
        x(j) = scandef(j).rng(count(j));
    end

    xt = fliplr(x);
    for k = 1:length(scan.trafofn)
        xt = scan.trafofn{k}(xt);
    end

    for j = loops
        
        for k = 1:nsetchan(j)
            val(k) = scandef(j).trafofn{k}(xt, smdata.chanvals);
        end    

        autochan = scandef(j).ramptime < 0;
        scandef(j).ramptime(autochan) = min(scandef(j).ramptime(autochan));
        % this is a bit of a hack
        
        % alternative place to call prefn
        
        % set autochannels and program ramp only at first loop point
        if count(j) == 1 %
            if nsetchan(j) % stuff below pointless if no channels exist.
                smset(scandef(j).setchan, val(1:nsetchan(j)));
                % since only the entry for this loop is changed, this
                % procedure only makes sense if the loop is not mixed
                % with any faster loopm by the global transformations.
                % Should not be a major limitation.
                x2 = x;
                x2(j) = scandef(j).rng(end);
                x2 = fliplr(x2);
                for k = 1:length(scan.trafofn)
                    x2 = scan.trafofn{k}(x2);
                end

                for k = 1:nsetchan(j)
                    val2(k) = scandef(j).trafofn{k}(x2, smdata.chanvals);
                end

                % compute ramp rate for all steps.
                ramprate{j} = abs((val2(1:nsetchan(j))-val(1:nsetchan(j))))'...
                    ./(scandef(j).ramptime * (scandef(j).npoints-1));

                % program ramp
                if any(autochan)
                    smset(scandef(j).setchan(autochan), val2(autochan), ramprate{j}(autochan));
                end
            end
            tloop(j) = now;
        elseif ~all(autochan)
            smset(scandef(j).setchan(~autochan), val(~autochan), ...
                ramprate{j}(~autochan));            
        end
        
        % prolog functions
        if isfield(scandef, 'prefn')
            fncall(scandef(j).prefn, xt);
        end              
        
        pause((tloop(j) - now)*24*3600 + count(j) * max(abs(scandef(j).ramptime)));
        
        % trigger after waiting for first point.
        if count(j) == 1 && isfield(scandef, 'trigfn')
            fncall(scandef(j).trigfn);
        end

        if get(1000, 'CurrentCharacter') == char(27)
            if nargin >= 2
                save(filename, 'configvals', 'configdata', 'scan', 'configch', 'data')
            end
            set(1000, 'CurrentCharacter', char(0));
            return;
        end

    end
    % read loops if all subsequent loops are at max count, outer loops last
    loops = find(count < npoints, 1, 'last'):nloops;
    if isempty(loops)
        loops = 1:nloops;
    end
    for j = fliplr(loops)
        % could save a function call/data copy here - not a lot of code               
        newdata(1:ngetchan(j)) = smget(scandef(j).getchan);
       %transfer to data arrays
        ind = sum(ngetchan(1:j-1));
        for k = 1:ngetchan(j)
            s.subs = [num2cell(count(1:j)), repmat({':'}, 1, ndim(ind + k))];
            if isfield(scandef, 'procfn') 
                  for fn = scandef(j).procfn(k).fn                      
                      newdata{k} = fn.fn(newdata{k}, fn.args{:});                  
                  end
            end
            data{ind + k} = subsasgn(data{ind + k}, s, newdata{k}); 
        end
        
        % process data, 
     
        % display data. 
        for k = find([disp.loop] == nloops-j+1)
            dc = disp(k).channel;

            % last dim: :
            % previous: count or ones. Total number of indices
            % 
            nind = ndim(dc)+dataloop(dc)-disp(k).dim;
            s2.subs = [num2cell([count(1:min(j, nind)), ones(1, max(0, nind-j))]),...
                repmat({':'},1, disp(k).dim)];    
            
            if disp(k).dim == 2
                dim = size(data{dc});
                z = zeros(dim(end-1:end));
                z(:, :) = subsref(data{dc}, s2);
                set(disph(k), 'cdata', z);
            else                
                set(disph(k), 'ydata', subsref(data{dc}, s2));
            end
            drawnow;

        end

        if j == nloops-scan.saveloop+1 && nargin >= 2
            save(filename, '-append', 'data');
        end
               
        if isfield(scandef, 'postfn')
            fncall(scandef(j).postfn, xt);
        end

        if isfield(scandef, 'datafn')
            fncall(scandef(j).datafn, xt, data);
        end

        if get(1000, 'CurrentCharacter') == char(27)
            if nargin >= 2
                save(filename, 'configvals', 'configdata', 'scan', 'configch', 'data')
            end
            set(1000, 'CurrentCharacter', char(0));
            return;
        end
    
        %fprintf('Start %.3f  Set %.3f  Read: %.3f  Proc: %.3f\n', [t(1), diff(t)]);
    end
    %update counters
    count(loops(2:end)) = 1;
    count(loops(1)) =  count(loops(1)) + 1;

end

if nargin >= 2
    save(filename, 'configvals', 'configdata', 'scan', 'configch', 'data')
end
end

function res = fncall(fns, varargin) 

   
if nargout > 0
    res = cell(1, length(fns));
    if iscell(fns)
        for i = 1:length(fns)
            res{i} = fns{i}(varargin{:});
        end
    else
        for i = 1:length(fns)
            res{i} = fns(i).fn( varargin{:}, fns(i).args{:});
        end
    end
else
    if iscell(fns)
        for i = 1:length(fns)
            fns{i}(varargin{:});
        end
    else
        for i = 1:length(fns)
            fns(i).fn(varargin{:}, fns(i).args{:});
        end
    end
end
end