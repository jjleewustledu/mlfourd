classdef (Sealed) FilesystemTool < handle & matlab.mixin.Copyable & mlfourd.AbstractImagingTool
	%% FILESYSTEMTOOL  

	%  $Revision$
 	%  was created 10-Aug-2018 04:41:41 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties (Dependent)
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp  
        noclobber
        
        imagingInfo
        imgrec
        innerTypeclass
        logger
        viewer
    end

	methods 
        
        %% GET
        
        function fn   = get.filename(this)
            fn = [this.fileprefix this.filesuffix];
        end
        function pth  = get.filepath(this)
            pth = this.filepath_;
        end
        function        set.filepath(this, s)
            assert(isfolder(s))
            this.filepath_ = s;
        end
        function fp   = get.fileprefix(this)
            fp = this.fileprefix_;
        end
        function        set.fileprefix(this, s)
            assert(ischar(s))
            this.fileprefix_ = s;
        end
        function fs   = get.filesuffix(this)
            fs = this.filesuffix_;
        end
        function        set.filesuffix(this, s)
            assert(ischar(s))
            this.filesuffix_ = s;
        end
        function fqfn = get.fqfilename(this)
            fqfn = [this.fqfileprefix this.filesuffix];
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = fullfile(this.filepath, this.fileprefix);
        end
        function f    = get.fqfn(this)
            f = this.fqfilename;
        end
        function f    = get.fqfp(this)
            f = this.fqfileprefix;
        end
        
        function g    = get.imagingInfo(this)
            g = [];
        end
        function g    = get.imgrec(this)
            g = [];
        end
        function g    = get.innerTypeclass(this)
            g = '';
        end
        function g    = get.logger(this)
            g = [];
        end
        function g    = get.viewer(this)
            g = '';
        end
        
        %% get some ImagingFormatContext
        
        function ifc = fourdfp(this)
            ifc = this.getInnerImaging('.4dfp.hdr');
            this.selectImagingFormatTool(this.contexth_);
        end
        function ifc = mgz(this)
            ifc = this.getInnerImaging('.mgz');
            this.selectImagingFormatTool(this.contexth_);
        end
        function ifc = nifti(this)
            ifc = this.getInnerImaging('.nii.gz');
            this.selectImagingFormatTool(this.contexth_);
        end
        function sz  = size(this, varargin)
            if (lstrfind(this.filesuffix, mlfourdfp.FourdfpInfo.SUPPORTED_EXT))
                sz = mlfourdfp.FourdfpVisitor.ifhMatrixSize(this.fqfileprefix);
                if (~isempty(varargin))
                    sz = sz(varargin{:});
                end
                return
            end
            if (lstrfind(this.filesuffix, mlfourd.NIfTIInfo.SUPPORTED_EXT))
                [~,r] = mlbash(sprintf('fslhd %s', this.fqfilename));
                re = regexp(r, ...
                    'dim1\s+(?<d1>\d+)\s+dim2\s+(?<d2>\d+)\s+dim3\s+(?<d3>\d+)\s+dim4\s+(?<d4>\d+)', 'names');
                sz = [str2double(re.d1) str2double(re.d2) str2double(re.d3) str2double(re.d4)];
                sz = sz(sz ~= 1);
                if (~isempty(varargin))
                    sz = sz(varargin{:});
                end
                return
            end    
            iimg = this.getInnerImaging;
            sz   = iimg.size(varargin{:});
        end
        
        %%
		  
 		function this = FilesystemTool(h, fqfn)
            this = this@mlfourd.AbstractImagingTool(h);
            [this.filepath_,this.fileprefix_,this.filesuffix_] = myfileparts(fqfn);
        end
    end 
    
    %% PROTECTED
    
    methods (Access = protected)     
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
        end   
        function iimg = getInnerImaging(this, varargin)
            ip = inputParser;
            addOptional(ip, 'suff', this.filesuffix, @ischar);
            parse(ip, varargin{:});
            
            import mlfourd.ImagingFormatContext;
            iimg = ImagingFormatContext([this.fqfileprefix ip.Results.suff]);
        end
    end
    
    properties (Access = protected)
        filepath_
        fileprefix_
        filesuffix_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

