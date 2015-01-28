classdef DirTools < mlfourd.DirToolComponent
    %% DIRTOOLS is the composite of mlfourd.DirTool, both of which form a composite design pattern with mlfourd.DirToolComponent
    
    properties
        itsPath
        itsListing
    end
    
    methods
        function pth = get.itsPath(this)
            pth = cellfun(@(t) t.itsPath, this.dirTools_, 'UniformOutput', false);
        end
        function list = get.itsListing(this)            
            ca = cellfun(@(t) t.itsListing, this.dirTools_, 'UniformOutput', false);
            list = struct([]);
            for c = 1:length(ca)
                sa = ca{c};
                for s = 1:length(sa)
                    list = [list sa(s)]; %#ok<AGROW>
                end
            end
        end
        
        %% return concatenated struct-arrays
        function sarr = files2sa(this, idx)
            sarr = arrayfun(@(t) t.files2sa, this.dirTools_, 'UniformOutput', false);
            if (exist('idx','var'))
                sarr = sarr(idx); end
        end
        function sarr = directories2sa(this, idx)
            sarr = arrayfun(@(t) t.directories2sa, this.dirTools_, 'UniformOutput', false);
            if (exist('idx','var'))
                sarr = sarr(idx); end
        end
        function sarr = invisibleFiles2sa(this, idx)
            sarr = arrayfun(@(t) t.invisibleFiles2sa, this.dirTools_, 'UniformOutput', false);
            if (exist('idx','var'))
                sarr = sarr(idx); end
        end
        function sarr = invisibleDirectories2sa(this, idx)  
            sarr = arrayfun(@(t) t.invisibleDirectories2sa, this.dirTools_, 'UniformOutput', false);
            if (exist('idx','var'))
                sarr = sarr(idx); end      
        end
        
        %% return concatenated cell-arrays
        function pp = paths(this, idx)
            pp = cellfun(@(t) t.paths, this.dirTools_, 'UniformOutput', false);
            pp = [pp{:}];
            if (exist('idx','var'))
                pp = pp{idx}; end
        end
        function ff = fqfns(this, idx)
            ff = cellfun(@(t) t.fqfns, this.dirTools_, 'UniformOutput', false);
            ff = [ff{:}];
            if (exist('idx','var'))
                ff = ff{idx}; end
        end
        function ff = fns(this, idx)
            ff = cellfun(@(t) t.fns, this.dirTools_, 'UniformOutput', false);
            ff = [ff{:}];
            if (exist('idx','var'))
                ff = ff{idx}; end
        end
        function ff = fqdns(this, idx)
            ff = cellfun(@(t) t.fqdns, this.dirTools_, 'UniformOutput', false);
            ff = [ff{:}];
            if (exist('idx','var'))
                ff = ff{idx}; end
        end
        function ff = dns(this, idx)
            ff = cellfun(@(t) t.dns, this.dirTools_, 'UniformOutput', false);
            ff = [ff{:}];
            if (exist('idx','var'))
                ff = ff{idx}; end
        end
        function len = length(this)
            len = 0;
            for t = 1:length(this.dirTools_)
                len = len + length(this.dirTools_{t});
            end
        end
        
        function this = DirTools(varargin)
            args = ensureCell(varargin);
            this.dirTools_ = cell(size(args));
            for v = 1:length(args)
                this.dirTools_{v} = mlfourd.DirTool(args{v}); end
        end
    end    
    
    %% PRIVATE
    
    properties (Access = 'private')
        dirTools_
    end
    
    methods (Access = 'private')
        function pth = commonPath(this)
            sorted = this.sortLengths(this.fqdns);
            for s = 1:length(sorted)-1
                idx = strfind(sorted{s+1}, sorted{s});
                if (0 == idx)
                    pth = ''; return; end
                if (1 == idx)
                    pth = sorted{s+1}(1); return; end
                sorted{s+1} = sorted{s+1}(1:idx);
            end
            pth = sorted{length(sorted)};
        end
        function ca = sortLengths(~, ca0)
            ca = cell(size(ca0));
            calens = cellfun(@length, ca0);
            for c = 1:length(calens)
                ca{calens{c}} = ca0{c};
            end
        end
    end
end

