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

            if matches(this.filesuffix, mlfourd.FourdfpInfo.SUPPORTED_EXT)
                info = analyze75info(this.fqfilename);
                sz = info.Dimensions;
                sz = double(sz);
                if 1 == sz(4)
                    sz = sz(1:3);
                end
                sz = sz(varargin{:});
                return
            end
            if matches(this.filesuffix, mlfourd.NIfTIInfo.SUPPORTED_EXT)
                info = niftiinfo(this.fqfilename);
                sz = info.ImageSize;
                sz = sz(varargin{:});
                return
            end    
            error("mlfourd:NotImplementedError", "FilesystemTool.size()")
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
                if istext(ipr.imagingFormat)
                    for ext = {'.nii.gz' '.nii' '.4dfp.hdr' '.mgz' '.mgh'}
                        if isfile(strcat(ipr.imagingFormat, ext{1}))
                            ipr.imagingFormat = strcat(ipr.imagingFormat, ext{1});
                            break
                        end
                    end
                    ipr.imagingFormat = mlfourd.ImagingFormatContext2(ipr.imagingFormat, varargin{:});
                end
            end
            ipr.imagingFormat.selectFilesystemFormatTool();
            this = this@mlfourd.ImagingState2(ipr.contexth, ipr.imagingFormat, varargin{:});
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

