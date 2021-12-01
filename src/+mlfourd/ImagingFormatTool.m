classdef ImagingFormatTool < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable & mlfourd.AbstractImagingTool
	%% IMAGINGFORMATTOOL and ImagingContext2 form a hierarchical state design pattern. 

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
            this.imagingFormat_.filename = fn;
        end
        function fn   = get.filename(this)
            fn = this.imagingFormat_.filename;
        end
        function        set.filepath(this, pth)
            this.imagingFormat_.filepath = pth;
        end
        function pth  = get.filepath(this)
            pth = this.imagingFormat_.filepath;
        end
        function        set.fileprefix(this, fp)
            this.imagingFormat_.fileprefix = fp;
        end
        function fp   = get.fileprefix(this)
            fp = this.imagingFormat_.fileprefix;
        end
        function        set.filesuffix(this, fs)
            this.imagingFormat_.filesuffix = fs;
        end
        function fs   = get.filesuffix(this)
            fs = this.imagingFormat_.filesuffix;
        end        
        function        set.fqfilename(this, fqfn)
            this.imagingFormat_.fqfilename = fqfn;
        end
        function fqfn = get.fqfilename(this)
            fqfn = this.imagingFormat_.fqfilename;
        end
        function        set.fqfileprefix(this, fqfp)
            this.imagingFormat_.fqfileprefix = fqfp;
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = this.imagingFormat_.fqfileprefix;
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
            this.imagingFormat_.noclobber = nc;
        end            
        function g    = get.noclobber(this)
            g = this.imagingFormat_.noclobber;
        end    
        
        function g    = get.imagingInfo(this)
            g = this.imagingFormat_.imagingInfo;
        end
        function g    = get.imgrec(this)
            if ~isprop(this.imagingFormat_, 'imgrec')
                g = [];
                return
            end
            g = this.imagingFormat_.imgrec;
                
        end 
        function g    = get.innerTypeclass(this)
            g = this.imagingFormat_.innerTypeclass;
        end  
        function g    = get.logger(this)
            if (isempty(this.imagingFormat_))
                g = []; 
                return
            end
            g = this.imagingFormat_.logger;
        end   
        function        set.viewer(this, s)
            this.imagingFormat_.viewer = s;
        end   
        function g    = get.viewer(this)
            g = this.imagingFormat_.viewer;
        end           
                
        %% cast then return this.imagingFormat_ which is ImagingFormatContext
        
        function ifc  = fourdfp(this)
            ifc = copy(this.imagingFormat_);
            ifc.filesuffix = '.4dfp.hdr';
            ifc = ifc.mutateInnerImagingFormatByFilesuffix;
        end
        function ifc  = mgz(this)
            ifc = copy(this.imagingFormat_);            
            ifc.filesuffix = '.mgz';
            ifc = ifc.mutateInnerImagingFormatByFilesuffix;
        end
        function ifc  = nifti(this)
            ifc = copy(this.imagingFormat_);
            ifc.filesuffix = '.nii.gz';
            ifc = ifc.mutateInnerImagingFormatByFilesuffix;
        end
        
        %% delegate to ImagingFormatTool
        
        function        addImgrec(this, varargin)
            this.imagingFormat_.getInnerImagingFormat.addImgrec(varargin{:}); % imgrec is a handle logger
        end
        function        addLog(this, varargin)
            this.imagingFormat_.addLog(varargin{:});
        end
        function        addLogNoEcho(this, varargin)
            this.imagingFormat_.addLogNoEcho(varargin{:});
        end
        function c    = char(this)
            c = this.imagingFormat_.char;
        end
        function d    = double(this)
            d = double(this.imagingFormat_.img);
        end
        function        ensureDouble(this)
            this.imagingFormat_.ensureDouble;
        end
        function        ensureSingle(this)
            this.imagingFormat_.ensureSingle;
        end
        function        export(this, varargin)
            this.addLog('mlfourd.ImagingFormatTool.export %s', this.fqfilename)
            this.imagingFormat_.export(varargin{:});            
        end
        function        freeview(this, varargin)
            this.imagingFormat_.freeview(varargin{:});
        end
        function        fsleyes(this, varargin)
            this.imagingFormat_.fsleyes(varargin{:});
        end
        function        fslview(this, varargin)
            this.imagingFormat_.fslview(varargin{:});
        end
        function        hist(this, varargin)
            this.imagingFormat_.hist(varargin{:});
        end        
        function h    = histogram(this, varargin)
            msk = this.imagingFormat_.img ~= 0;
            h = histogram(this.imagingFormat_.img(msk), varargin{:});
        end
        function [h,h1] = imagesc(this, varargin)
            figure
            this.imagingFormat_.img(logical(eye(size(this.imagingFormat_.img, 1)))) = nan;
            max_img = dipmax(this.imagingFormat_.img);
            h = imagesc(this.imagingFormat_.img, varargin{:});
            colormap('jet')
            h1 = colorbar('FontSize', 20);
            caxis([-max_img max_img])
            set(get(h1,'label'),'string', 'functional connectivity', 'FontSize', 28)
            axis('off')
            title(this.imagingFormat_.fileprefix, 'FontSize', 24, 'Interpreter', 'none')
        end
        function tf   = isempty(this)
            tf = isempty(this.imagingFormat_.img);
        end
        function l    = length(~)
            l = 1;
        end
        function l    = logical(this)
            l = logical(this.imagingFormat_.img);
        end
        function that = makeSimilar(this, varargin)
            %% MAKESIMILAR provides a legacy interface
            
            ip = inputParser;
            addParameter(ip, 'img',  this.imagingFormat_.img, @isnumeric);
            addParameter(ip, 'fileprefix', this.fileprefix, @ischar);
            addParameter(ip, 'descrip', [class(this) '.madeSimilar'], @ischar);
            parse(ip, varargin{:});    

            that = copy(this);
            that.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, ...
                'img', ip.Results.img,  ...
                'fileprefix', ip.Results.fileprefix, 'descrip', ip.Results.descrip);
            that.imagingFormat_.addLog( ...
                sprintf('MaskingTool:  %s', ip.Results.descrip));
        end
        function s    = mat2str(this, varargin)
            s = mat2str(this.imagingFormat_.img, varargin{:});
        end
        function n    = ndims(this)
            n = this.imagingFormat_.ndims;
        end
        function n    = numel(this)
            n = this.imagingFormat_.numel;
        end
        function p    = pointCloud(this)
            img = this.imagingFormat_.img;            
            idx = find(img);
            [X,Y,Z] = ind2sub(size(img), idx);             
            C(:,1) = X; % C are ints cast as double
            C(:,2) = Y;
            C(:,3) = Z;
            p = pointCloud(C, 'Intensity', img(idx));
        end
        function r    = rank(this)
            r = this.ndims;
        end
        function        save(this)
            this.addLog('mlfourd.ImagingFormatTool.save %s', this.fqfilename)
            this.imagingFormat_.save;
        end
        function this = saveas(this, f)
            this.imagingFormat_ = this.imagingFormat_.saveas(f);
        end
        function s    = single(this)
            s = single(this.imagingFormat_.img);
        end
        function s    = size(this, varargin)
            s = size(this.imagingFormat_.img, varargin{:});
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
            this.imagingFormat_ = u;
        end
        function        view(this, varargin)
            this.imagingFormat_.view(varargin{:});
        end   
        
        %%
        
        function this = ImagingFormatTool(h, varargin)
            this = this@mlfourd.AbstractImagingTool(h);            
            this.imagingFormat_ = mlfourd.ImagingFormatContext(varargin{:});
        end
    end     
    
    %% PROTECTED
    
    properties (Access = protected)
        imagingFormat_
    end
    
    methods (Access = protected)
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
            that.imagingFormat_ = copy(this.imagingFormat_);
        end
        function iimg = getInnerImaging(this)
            iimg = this.imagingFormat_;
            assert(~isempty(iimg));
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

