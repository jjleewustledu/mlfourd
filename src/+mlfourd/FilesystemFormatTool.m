classdef FilesystemFormatTool < handle & mlfourd.ImagingFormatState2
    %% FILESYSTEMFORMATTOOL supports filesystem information for most mlfourd objects that work with imaging data.  
    %  It provides lightweight functionality for determining the size of filesystem data.  In combinations with other
    %  mlfourd objects, FilesystemFormatTool should be the principal source of filesystem information.
    %  
    %  Created 07-Dec-2021 22:22:28 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods

        %% implementations of IImagingFormat

        function tf = isempty(this)
            tf = ~isfile(this.fqfilename);
        end
        function len = length(this)
            len = size(this, ndims(this));
        end
        function n = ndims(this)
            n = length(size(this));
        end
        function n = numel(this)
            n = prod(size(this)); %#ok<PSIZE> 
        end
        function sz = size(this, varargin)
            %% @todo refactor to call factory method imagingInfo().

            ip = inputParser;
            addOptional(ip, 'index', [], @isnumeric);
            parse(ip, varargin{:});
            ipr = ip.Results;

            if ~isempty(this.size_cache_)
                sz = this.size_cache_;
                if ~isempty(ipr.index)
                    sz = sz(ipr.index);
                end
                return
            end
            if ~isfile(this.fqfn)
                sz = [];
                return
            end
            if contains(this.filesuffix, mlfourd.FourdfpInfo.SUPPORTED_EXT)
                try
                    imgi = mlfourd.FourdfpInfo(this.fqfilename);
                    sz = imgi.Dimensions;
                catch ME
                    handwarning(ME);
                    try
                        [~,r] = mlbash(sprintf('fslhd %s', this.fqfn));
                        re = regexp(r, '\S+\s+dim1\s+(?<d1>\d+)\s*dim2\s+(?<d2>\d+)\s*dim3\s+(?<d3>\d+)\s*dim4\s+(?<d4>\d+)\s*\S+', 'names');
                        sz = cellfun(@str2double, struct2cell(re))';
                        sz = sz(sz > 1);                        
                    catch ME
                        handwarning(ME);
                        sz = [];
                    end
                end
                this.size_cache_ = sz;
                if ~isempty(ipr.index)
                    sz = sz(ipr.index);
                end
                return
            end  
            if contains(this.filesuffix, mlfourd.NIfTIInfo.SUPPORTED_EXT)
                try
                    imgi = mlfourd.NIfTIInfo(this.fqfilename);
                    imgi.load_info();
                    sz = imgi.ImageSize;             
                catch ME
                    handwarning(ME);
                    try
                        [~,r] = mlbash(sprintf('fslhd %s', this.fqfn));
                        re = regexp(r, '\S+\s*dim0\s+(?<d0>\d+)\s*dim1\s+(?<d1>\d+)\s*dim2\s+(?<d2>\d+)\s*dim3\s+(?<d3>\d+)\s*dim4\s+(?<d4>\d+)\s*\S+', 'names');
                        sz = cellfun(@str2double, struct2cell(re))';
                        ndims = sz(1);
                        sz = sz(2:ndims+1);
                    catch ME
                        handwarning(ME);
                        sz = [];
                    end
                end
                this.size_cache_ = sz;
                if ~isempty(ipr.index)
                    sz = sz(ipr.index);
                end
                return
            end
            if contains(this.filesuffix, mlfourd.MGHInfo.SUPPORTED_EXT)
                try
                    imgi = mlfourd.MGHInfo(this.fqfilename);
                    sz = imgi.ImageSize;          
                catch ME
                    handwarning(ME);
                    sz = [];
                end
                this.size_cache_ = sz;
                if ~isempty(ipr.index)
                    sz = sz(ipr.index);
                end
                return
            end
            error("mlfourd:NotImplementedError", "FilesystemTool.size()")
        end

        %%

        function this = FilesystemFormatTool(contexth, fn, varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingFormatContexts of the state design pattern.
            %      fn (text): imaging filename.
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'contexth', @(x) isa(x, 'mlfourd.ImagingFormatContext2'))
            addRequired(ip, 'fn', @istext)
            parse(ip, contexth, fn, varargin{:})
            ipr = ip.Results;

            filesystem = mlio.HandleFilesystem.createFromString(ipr.fn);
            this = this@mlfourd.ImagingFormatState2(ipr.contexth, [], 'filesystem', filesystem, varargin{:});
        end
    end

    %% PRIVATE

    properties (Access = private)
        size_cache_
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
