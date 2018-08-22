classdef (Abstract) AbstractImagingTool < handle & matlab.mixin.Copyable
	%% ABSTRACTIMAGINGTOOL is the state and ImagingContext2 is the context forming a state design pattern for
    %  imaging tools.

	%  $Revision$
 	%  was created 10-Aug-2018 02:22:10 by jjlee,
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
    end
    
    methods 
        
        %% SET/GET
        
        function        set.filename(this, fn)
            this.innerContext_.filename = fn;
            this.selectImagingFormatTool;
        end
        function fn   = get.filename(this)
            fn = this.innerContext_.filename;
        end
        function        set.filepath(this, pth)
            this.innerContext_.filepath = pth;
        end
        function pth  = get.filepath(this)
            pth = this.innerContext_.filepath;
        end
        function        set.fileprefix(this, fp)
            this.innerContext_.fileprefix = fp;
        end
        function fp   = get.fileprefix(this)
            fp = this.innerContext_.fileprefix;
        end
        function        set.filesuffix(this, fs)
            this.innerContext_.filesuffix = fs;
            this.selectImagingFormatTool;
        end
        function fs   = get.filesuffix(this)
            fs = this.innerContext_.filesuffix;
        end        
        function        set.fqfilename(this, fqfn)
            this.innerContext_.fqfilename = fqfn;
            this.selectImagingFormatTool;
        end
        function fqfn = get.fqfilename(this)
            fqfn = this.innerContext_.fqfilename;
        end
        function        set.fqfileprefix(this, fqfp)
            this.innerContext_.fqfileprefix = fqfp;
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = this.innerContext_.fqfileprefix;
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
            this.innerContext_.noclobber = nc;
        end            
        function nc   = get.noclobber(this)
            nc = this.innerContext_.noclobber;
        end    
        
        %% get some ImagingFormatContext, directly accessing this.innerContext_ 
        
        function ifc = fourdfp(this)
            this.selectImagingFormatTool;
            this.innerContext_.filesuffix = '.4dfp.hdr';
            ifc = this.contexth_.fourdfp;
        end
        function ifc = mgz(this)
            this.selectImagingFormatTool;
            this.innerContext_.filesuffix = '.mgz';
            ifc = this.contexth_.mgz;
        end
        function ifc = nifti(this)
            this.selectImagingFormatTool;
            this.innerContext_.filesuffix = '.nii.gz';
            ifc = this.contexth_.nifti;
        end
        function niid = niftid(this)
            niid = mlfourd.NIfTId(this.nifti);
        end
        function niid = numericalNiftid(this)
            niid = mlfourd.NumericalNIfTId(this.niftid);
        end
        
        %% select states
        
        function selectBlurringTool(this)
            this.changeState( ...
                mlfourd.BlurringTool(this.contexth_, this.innerContext_));
        end
        function selectDynamicsTool(this)
            this.changeState( ...
                mlfourd.DynamicsTool(this.contexth_, this.innerContext_));
        end
        function selectFilesystemTool(this)
            this.changeState( ...
                mlfourd.FilesystemTool(this.contexth_, this.innerContext_));
        end
        function selectIsNumericTool(this)
            this.changeState( ...
                mlfourd.IsNumericTool(this.contexth_, this.innerContext_));
        end
        function selectImagingFormatTool(this)
            this.changeState( ...
                mlfourd.ImagingFormatTool(this.contexth_, this.innerContext_));
        end
        function selectMaskingTool(this)
            this.changeState( ...
                mlfourd.MaskingTool(this.contexth_, this.innerContext_));
        end
        function selectNumericalTool(this)
            this.changeState( ...
                mlfourd.NumericalTool(this.contexth_, this.innerContext_));
        end
        function selectRegistrationTool(this)
            this.changeState( ...
                mlfourdfp.RegistrationTool(this.contexth_, this.innerContext_));
        end
        
        %% mlpatterns.HandleNumerical        
        
        function that = abs(this)
            this.selectNumericalTool;
            that = this.contexth_.abs;            
        end
        function that = atan2(this, b)
            this.selectNumericalTool;
            that = this.contexth_.atan2(b);  
        end
        function that = bsxfun(this, pfun, b)
            this.selectNumericalTool;
            that = this.contexth_.bsxfun(pfun, b);  
        end
        function that = rdivide(this, b)
            this.selectNumericalTool;
            that = this.contexth_.rdivide(b);  
        end
        function that = ldivide(this, b)
            this.selectNumericalTool;
            that = this.contexth_.ldivide(b);  
        end
        function that = hypot(this, b)
            this.selectNumericalTool;
            that = this.contexth_.hypot(b);  
        end
        function that = max(this, b)
            this.selectNumericalTool;
            that = this.contexth_.max(b);  
        end
        function that = min(this, b)
            this.selectNumericalTool;
            that = this.contexth_.min(b);  
        end
        function that = minus(this, b)
            this.selectNumericalTool;
            that = this.contexth_.minus(b);  
        end
        function that = mod(this, b)
            this.selectNumericalTool;
            that = this.contexth_.mod(b);  
        end
        function that = plus(this, b)
            this.selectNumericalTool;
            that = this.contexth_.plus(b);  
        end
        function that = power(this, b)
            this.selectNumericalTool;
            that = this.contexth_.power(b);  
        end
        function that = rem(this, b)
            %% remainder after division
            
            this.selectNumericalTool;
            that = this.contexth_.rem(b);  
        end
        function that = times(this, b)
            this.selectNumericalTool;
            that = this.contexth_.times(b);  
        end
        function that = ctranspose(this)
            this.selectNumericalTool;
            that = this.contexth_.ctranspose;  
        end
        function that = transpose(this)
            this.selectNumericalTool;
            that = this.contexth_.transpose;  
        end
        function that = usxfun(this, pfun)
            this.selectNumericalTool;
            that = this.contexth_.usxfun(pfun);  
        end
        
        function that = eq(this, b)
            this.selectNumericalTool;
            that = this.contexth_.eq(b);  
        end
        function that = ne(this, b)
            this.selectNumericalTool;
            that = this.contexth_.ne(b);  
        end
        function that = lt(this, b)
            this.selectNumericalTool;
            that = this.contexth_.lt(b);  
        end
        function that = le(this, b)
            this.selectNumericalTool;
            that = this.contexth_.le(b);  
        end
        function that = gt(this, b)
            this.selectNumericalTool;
            that = this.contexth_.gt(b);  
        end
        function that = ge(this, b)
            this.selectNumericalTool;
            that = this.contexth_.ge(b);  
        end
        function that = and(this, b)
            this.selectNumericalTool;
            that = this.contexth_.and(b);  
        end
        function that = or(this, b)
            this.selectNumericalTool;
            that = this.contexth_.or(b);  
        end
        function that = xor(this, b)
            this.selectNumericalTool;
            that = this.contexth_.xor(b);  
        end
        function that = not(this)
            this.selectNumericalTool;
            that = this.contexth_.not;
        end
        
        function c    = char(this)
            c = this.innerContext_.char;
        end
        function d    = double(this)
            this.selectNumericalTool;
            d = this.contexth_.double;
        end
        function s    = mat2str(this, varargin)
            this.selectNumericalTool;
            s = this.contexth_.mat2str(varargin{:});
        end
        function that = ones(this, varargin)
            this.selectNumericalTool;
            that = this.contexth_.ones(varargin{:});
        end
        function r    = rank(this)
            this.selectNumericalTool;
            r = this.contexth_.rank;
        end
        function that = scrubNanInf(this)
            this.selectNumericalTool; 
            that = this.contexth_.scrubNanInf;           
        end
        function s    = single(this)
            this.selectNumericalTool;
            s = this.contexth_.single;
        end
        function s    = size(this, varargin)
            this.selectNumericalTool;
            s = this.contexth_.size(varargin{:});
        end
        function that = zeros(this, varargin)
            this.selectNumericalTool;
            that = this.contexth_.zeros(varargin{:});
        end
        
        %% mlpatterns.HandleDipNumerical      
        
%         dipiqr(this)
%         dipisfinite(this)
%         dipisinf(this)
%         dipisnan(this)
%         dipisreal(this)
%         diplogprod(this)
%         dipmad(this)
%         dipmax(this)
%         dipmean(this)
%         dipmedian(this)
%         dipmin(this)
%         dipmode(this)
%         dipprctile(this)
%         dipprod(this)
%         dipquantile(this)
%         dipstd(this)
%         dipsum(this)
%         diptrimmean(this)
                
        %%
        
        function     freeview(this, varargin)
            this.selectImagingFormatTool;
            this.innerContext_.freeview(varargin{:});
        end
        function     fsleyes(this, varargin)
            this.selectImagingFormatTool;
            this.innerContext_.fsleyes(varargin{:});
        end
        function     fslview(this, varargin)
            this.selectImagingFormatTool;
            this.innerContext_.fslview(varargin{:});
        end
        function     hist(this, varargin)
            this.selectImagingFormatTool;
            this.innerContext_.hist(varargin{:});
        end
        function     save(this)
            this.selectImagingFormatTool;
            this.innerContext_.save;
        end
        function     saveas(this, f)
            this.selectImagingFormatTool;
            this.innerContext_.saveas(f);
            this.selectImagingFormatTool;
        end
        function     view(this, varargin)
            this.selectImagingFormatTool;
            this.innerContext_.view(varargin{:});
        end        
    end
    
    %% PROTECTED
    
    methods (Access = protected)         
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
            that.innerContext_ = copy(this.innerContext_);
        end
        
 		function this = AbstractImagingTool(h, varargin)
            assert(all(isvalid(h)));
            this.contexth_ = h;
 		end
    end 
    
    properties (Access = protected)
        contexth_
        innerContext_
    end

    %% HIDDEN
    
    methods (Hidden)
        function this = changeState(this, s)
            this.contexth_.changeState(s);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

