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

            if matches(this.filesuffix, mlfourd.FourdfpInfo.SUPPORTED_EXT)
                imgi = mlfourd.FourdfpInfo(this.filesystem_);
                sz = imgi.Dimensions;
                sz = double(sz);
                if 1 == sz(4)
                    sz = sz(1:3);
                end
                return
            end
            if matches(this.filesuffix, mlfourd.NIfTIInfo.SUPPORTED_EXT)
                imgi = mlfourd.NIfTIInfo(this.filesystem_);
                sz = imgi.ImageSize;
                return
            end 
            if matches(this.filesuffix, mlfourd.MGHInfo.SUPPORTED_EXT)
                imgi = mlfourd.MGHInfo(this.fqfilename);
                sz = imgi.ImageSize;
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
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
