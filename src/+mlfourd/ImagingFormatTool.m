classdef ImagingFormatTool < handle & matlab.mixin.Copyable & mlfourd.AbstractImagingTool
	%% IMAGINGFORMATTOOL and mlfourd.ImagingContext form a hierarchical state design pattern. 

	%  $Revision$
 	%  was created 10-Aug-2018 02:14:04 by jjlee,
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
        
        %% SET/GET
        
        function        set.filename(this, fn)
            this.innerImaging_.filename = fn;
        end
        function fn   = get.filename(this)
            fn = this.innerImaging_.filename;
        end
        function        set.filepath(this, pth)
            this.innerImaging_.filepath = pth;
        end
        function pth  = get.filepath(this)
            pth = this.innerImaging_.filepath;
        end
        function        set.fileprefix(this, fp)
            this.innerImaging_.fileprefix = fp;
        end
        function fp   = get.fileprefix(this)
            fp = this.innerImaging_.fileprefix;
        end
        function        set.filesuffix(this, fs)
            this.innerImaging_.filesuffix = fs;
        end
        function fs   = get.filesuffix(this)
            fs = this.innerImaging_.filesuffix;
        end        
        function        set.fqfilename(this, fqfn)
            this.innerImaging_.fqfilename = fqfn;
        end
        function fqfn = get.fqfilename(this)
            fqfn = this.innerImaging_.fqfilename;
        end
        function        set.fqfileprefix(this, fqfp)
            this.innerImaging_.fqfileprefix = fqfp;
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = this.innerImaging_.fqfileprefix;
        end
        function        set.fqfn(this, f)
            this.fqfilename = f;
        end
        function f    = get.fqfn(this)
            f = this.fqfilename;
        end
        function        set.fqfp(this, f)
            this.fqfileprefix = f;
        end
        function f    = get.fqfp(this)
            f = this.fqfileprefix;
        end        
        function        set.noclobber(this, nc)
            this.innerImaging_.noclobber = nc;
        end            
        function g    = get.noclobber(this)
            g = this.innerImaging_.noclobber;
        end    
        
        function g    = get.imagingInfo(this)
            g = this.innerImaging_.imagingInfo;
        end
        function g    = get.imgrec(this)
            g = this.innerImaging_.imgrec;
        end 
        function g    = get.innerTypeclass(this)
            g = this.innerImaging_.innerTypeclass;
        end  
        function g    = get.logger(this)
            if (isempty(this.innerImaging_))
                g = []; 
                return
            end
            g = this.innerImaging_.logger;
        end   
        function        set.viewer(this, s)
            this.innerImaging_.viewer = s;
        end   
        function g    = get.viewer(this)
            g = this.innerImaging_.viewer;
        end           
                
        %% cast then return this.innerImaging_ which is ImagingFormatContext
        
        function ifc  = fourdfp(this)
            this.innerImaging_.filesuffix = '.4dfp.hdr';
            %this.innerImaging_ = this.innerImaging_.mutateInnerImagingFormatByFilesuffix;
            ifc = this.innerImaging_;
        end
        function ifc  = mgz(this)
            this.innerImaging_.filesuffix = '.mgz';
            %this.innerImaging_ = this.innerImaging_.mutateInnerImagingFormatByFilesuffix;
            ifc = this.innerImaging_;
        end
        function ifc  = nifti(this)
            this.innerImaging_.filesuffix = '.nii.gz';
            %this.innerImaging_ = this.innerImaging_.mutateInnerImagingFormatByFilesuffix;
            ifc = this.innerImaging_;
        end
        
        %% delegate to ImagingFormatTool
        
        function        addImgrec(this, varargin)
            this.innerImaging_.getInnerNIfTI.addImgrec(varargin{:}); % imgrec is a handle logger
        end
        function        addLog(this, varargin)
            this.innerImaging_.addLog(varargin{:});
        end
        function c    = char(this)
            c = this.innerImaging_.char;
        end
        function d    = double(this)
            d = double(this.innerImaging_.img);
        end
        function        freeview(this, varargin)
            this.innerImaging_.freeview(varargin{:});
        end
        function        fsleyes(this, varargin)
            this.innerImaging_.fsleyes(varargin{:});
        end
        function        fslview(this, varargin)
            this.innerImaging_.fslview(varargin{:});
        end
        function        hist(this, varargin)
            this.innerImaging_.hist(varargin{:});
        end
        function tf   = isempty(this)
            tf = isempty(this.innerImaging_.img);
        end
        function l    = length(~)
            l = 1;
        end
        function l    = logical(this)
            l = logical(this.innerImaging_.img);
        end
        function this = makeSimilar(this, varargin)
            %% MAKESIMILAR provides a legacy interface
            
            ip = inputParser;
            addParameter(ip, 'img',  this.innerImaging_.img, @isnumeric);
            addParameter(ip, 'fileprefix', this.fileprefix, @ischar);
            addParameter(ip, 'descrip', [class(this) '.madeSimilar'], @ischar);
            parse(ip, varargin{:});    

            this.innerImaging_ = mlfourd.ImagingFormatContext( ...
                this.innerImaging_, ...
                'img', ip.Results.img,  ...
                'fileprefix', ip.Results.fileprefix, 'descrip', ip.Results.descrip);
            this.innerImaging_.addLog( ...
                sprintf('MaskingTool:  %s', ip.Results.descrip));
        end
        function s    = mat2str(this, varargin)
            s = mat2str(this.innerImaging_.img, varargin{:});
        end
        function n    = ndims(this)
            n = this.innerImaging_.ndims;
        end
        function r    = rank(this)
            r = this.ndims;
        end
        function        save(this)
            this.innerImaging_.save;
        end
        function this = saveas(this, f)
            this.innerImaging_ = this.innerImaging_.saveas(f);
        end
        function s    = single(this)
            s = single(this.innerImaging_.img);
        end
        function s    = size(this, varargin)
            s = size(this.innerImaging_.img, varargin{:});
        end
        function tf =   sizeEq(this, varargin)
            inSize   = varargin{:}.nifti.size;
            thisSize = this.concreteObj_.size;
            tf = all(thisSize(1:3) == inSize(1:3));
        end
        function tf =   sizeGt(this, varargin)
            inSize   = varargin{:}.nifti.size;
            thisSize = this.concreteObj_.size;
            tf = prod(thisSize(1:3)) > prod(inSize(1:3));
        end
        function tf =   sizeLt(this, varargin)
            inSize   = varargin{:}.nifti.size;
            thisSize = this.concreteObj_.size;
            tf = prod(thisSize(1:3)) < prod(inSize(1:3));
        end
        function        updateInnerImaging(this, u)
            assert(isa(u, 'mlfourd.ImagingFormatContext'));
            this.innerImaging_ = u;
        end
        function        view(this, varargin)
            this.innerImaging_.view(varargin{:});
        end   
        
        %%
        
        function this = ImagingFormatTool(h, varargin)
            this = this@mlfourd.AbstractImagingTool(h);            
            this.innerImaging_ = mlfourd.ImagingFormatContext(varargin{:});
            assert(~isempty(this.innerImaging_), 'mlfourd:ValueError', 'ImagingFormatTool.ctor');
        end
    end     
    
    %% PROTECTED
    
    properties (Access = protected)
        innerImaging_
    end
    
    methods (Access = protected)
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
            that.innerImaging_ = copy(this.innerImaging_);
        end
        function iimg = getInnerImaging(this)
            iimg = this.innerImaging_;
            assert(~isempty(iimg));
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

