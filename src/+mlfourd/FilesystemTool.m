classdef FilesystemTool < handle & mlfourd.ImagingState2
	%% FILESYSTEMTOOL uses minimal memory resources by avoiding loading imaging numerical data.
    %
 	%  Created 10-Aug-2018 04:41:41 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%  Developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.

	methods

        %% implementations of IImaging

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

            if ~isfile(this.fqfn)
                sz = [];
                return
            end
            if contains(this.filesuffix, mlfourd.FourdfpInfo.SUPPORTED_EXT)
                try
                    [~,r] = mlbash(sprintf('fslhd %s', this.fqfn));
                    re = regexp(r, '\S+\s+dim1\s+(?<d1>\d+)\s*dim2\s+(?<d2>\d+)\s*dim3\s+(?<d3>\d+)\s*dim4\s+(?<d4>\d+)\s*\S+', 'names');
                    sz = cellfun(@str2double, struct2cell(re))';
                    sz = sz(sz > 1);
                    if ~isempty(ipr.index)
                        sz = sz(ipr.index);
                    end
                catch ME
                    handwarning(ME);
                    sz = [];
                end
                return
            end
            if contains(this.filesuffix, mlfourd.NIfTIInfo.SUPPORTED_EXT)
                try
                    [~,r] = mlbash(sprintf('fslhd %s', this.fqfn));
                    re = regexp(r, '\S+\s*dim0\s+(?<d0>\d+)\s*dim1\s+(?<d1>\d+)\s*dim2\s+(?<d2>\d+)\s*dim3\s+(?<d3>\d+)\s*dim4\s+(?<d4>\d+)\s*\S+', 'names');
                    sz = cellfun(@str2double, struct2cell(re))';
                    ndims = sz(1);
                    len_sz = length(sz);
                    if ndims+1 > len_sz
                        sz = sz(2:len_sz);
                    else
                        sz = sz(2:ndims+1);
                    end
                    if ~isempty(ipr.index)
                        sz = sz(ipr.index);
                    end                
                catch ME
                    handwarning(ME);
                    sz = [];
                end
                return
            end  
            if contains(this.filesuffix, mlfourd.MGHInfo.SUPPORTED_EXT)
                try
                    imgi = mlfourd.MGHInfo(this.fqfilename);
                    sz = imgi.ImageSize;
                    if ~isempty(ipr.index)
                        sz = sz(ipr.index);
                    end                
                catch ME
                    handwarning(ME);
                    sz = [];
                end
                return
            end
            warning("mlfourd:NotImplementedError", "FilesystemTool.size()")
            sz = [];
        end

        %%

        function [s,r] = view(this, varargin)
            viewer = this.imagingFormat_.viewer;
            [s,r] = viewer.aview(this.fqfilename, varargin{:});
        end
		
        function this = FilesystemTool(contexth, imagingFormat, varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      imagingFormat (IImagingFormat): provides a filename for imaging data on the filesystem.  
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.  

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'contexth', @(x) isa(x, 'mlfourd.ImagingContext2'))
            addRequired(ip, 'imagingFormat',  @(x) istext(x) || isa(x, 'mlfourd.IImagingFormat'))
            parse(ip, contexth, imagingFormat, varargin{:})
            ipr = ip.Results;
            if ipr.contexth.compatibility
                ipr.imagingFormat = mlfourd.ImagingFormatContext(ipr.imagingFormat, varargin{:});
            else
                if istext(ipr.imagingFormat) && ~isfile(ipr.imagingFormat)
                    for ext = {'.nii.gz' '.nii' '.4dfp.hdr' '.mgz' '.mgh'}
                        if isfile(strcat(ipr.imagingFormat, ext{1}))
                            ipr.imagingFormat = strcat(ipr.imagingFormat, ext{1});
                            break
                        end
                    end
                end
                ipr.imagingFormat = mlfourd.ImagingFormatContext2(ipr.imagingFormat, varargin{:});
            end
            ipr.imagingFormat.selectFilesystemFormatTool();
            this = this@mlfourd.ImagingState2(ipr.contexth, ipr.imagingFormat, varargin{:});
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

