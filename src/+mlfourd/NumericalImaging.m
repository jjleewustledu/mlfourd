classdef NumericalImaging < handle & mlfourd.ImagingFormatContext & mlpatterns.HandleNumerical & mlpatterns.HandleDipNumerical
	%% NUMERICALIMAGING  

	%  $Revision$
 	%  was created 12-Aug-2018 01:43:19 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	  
    properties (Dependent)
        component
    end
    
    methods (Static)
        function this = load(varargin) % legacy
            this = mlfourd.NumericalImaging(varargin{:});
        end
    end
    
    methods 
        
        %% GET
        
        function g = get.component(this) % legacy 
            g = this;
        end
        
        %% Overloaded Numerical
        
        function this = abs(this)
            this = this.usxfun(@abs);
        end
        function this = atan2(this, b)
            this = this.bsxfun(@atan2, b);
        end
        function this = rdivide(this, b)
            this = this.bsxfun(@rdivide, b);
        end
        function this = ldivide(this, b)
            this = this.bsxfun(@ldivide, b);
        end
        function this = hypot(this, b)
            this = this.bsxfun(@hypot, b);
        end
        function this = max(this, b)
            this = this.bsxfun(@max, b);
        end
        function this = min(this, b)
            this = this.bsxfun(@min, b);
        end
        function this = minus(this, b)
            this = this.bsxfun(@minus, b);
        end
        function this = mod(this, b)
            this = this.bsxfun(@mod, b);
        end
        function this = mpower(this, b)
            this = this.bsxfun(@mpower, b);
        end
        function this = mldivide(this, b)
            import mlfourd.*;
            if (isa(b, 'mlfourd.HandleINIfTI') || isa(b, 'mlfourd.INIfTI'))
                this = NumericalImaging(this, 'img', mldivide(this.component.img, b.img));
                this.addLog(sprintf('NumericalImaging.mldivide %s %s', this.fileprefix, b.fileprefix));
            else
                this = NumericalImaging(this, 'img', mldivide(this.component.img, b));
                this.addLog(sprintf('NumericalImaging.mldivide %s %s', this.fileprefix, mat2str(b)));
            end
        end
        function this = mrdivide(this, b)
            import mlfourd.*;
            if (isa(b, 'mlfourd.HandleINIfTI') || isa(b, 'mlfourd.INIfTI'))
                this = NumericalImaging(this, 'img', mrdivide(this.component.img, b.img));
                this.addLog(sprintf('NumericalImaging.mrdivide %s %s', this.fileprefix, b.fileprefix));
            else
                this = NumericalImaging(this, 'img', mrdivide(this.component.img, b));
                this.addLog(sprintf('NumericalImaging.mrdivide %s %s', this.fileprefix, mat2str(b)));
            end            
        end
        function this = mtimes(this, b)
            this = this.bsxfun(@mtimes, b);
        end
        function this = plus(this, b)
            this = this.bsxfun(@plus, b);
        end
        function this = power(this, b)
            this = this.bsxfun(@power, b);
        end
        function this = rem(this, b)
            this = this.bsxfun(@rem, b);
        end
        function this = sum(this, varargin)
            this = mlfourd.NumericalImaging(this, 'img', sum(this.component.img, varargin{:}));
            this.addLog(sprintf('NumericalImaging.sum %s %s', this.fileprefix, mat2str(varargin{:})));  
        end
        function this = times(this, b)
            this = this.bsxfun(@times, b);
        end
        function this = ctranspose(this)
            this = this.usxfun(@ctranspose);
        end
        function this = transpose(this)
            this = this.usxfun(@transpose);
        end
        function this = uminus(this)
            this = this.usxfun(@uminus);
        end
        
        function this = eq(this, b)
            this = this.bsxfun(@eq, b);
        end
        function this = ne(this, b)
            this = this.bsxfun(@ne, b);
        end
        function this = lt(this, b)
            this = this.bsxfun(@lt, b);
        end
        function this = le(this, b)
            this = this.bsxfun(@le, b);
        end
        function this = gt(this, b)
            this = this.bsxfun(@gt, b);
        end
        function this = ge(this, b)
            this = this.bsxfun(@ge, b);
        end
        function this = and(this, b)
            this = this.bsxfun(@and, b);
        end
        function this = or(this, b)
            this = this.bsxfun(@or, b);
        end
        function this = xor(this, b)
            this = this.bsxfun(@xor, b);
        end
        function this = not(this)
            this = this.usxfun(@not);
        end        
                
        %% Overloaded DipNumerical
        
        function x = dipiqr(this)
            this = this.usxfun(@dipiqr);
            x = this.img;
        end
        function x = dipisfinite(this)
            this = this.usxfun(@dipisfinite);
            x = this.img;
        end
        function x = dipisinf(this)
            this = this.usxfun(@dipisinf);
            x = this.img;
        end
        function x = dipisnan(this)
            this = this.usxfun(@dipisnan);
            x = this.img;
        end
        function x = dipisreal(this)
            this = this.usxfun(@dipisreal);
            x = this.img;
        end
        function x = diplogprod(this)
            this = this.usxfun(@diplogprod);
            x = this.img;
        end
        function x = dipmad(this)
            this = this.usxfun(@dipmad);
            x = this.img;
        end        
        function x = dipmax(this)
            this = this.usxfun(@dipmax);
            x = this.img;
        end        
        function x = dipmean(this)
            this = this.usxfun(@dipmean);
            x = this.img;
        end        
        function x = dipmedian(this)
            this = this.usxfun(@dipmedian);
            x = this.img;
        end        
        function x = dipmin(this)
            this = this.usxfun(@dipmin);
            x = this.img;
        end   
        function x = dipmode(this)
            this = this.usxfun(@dipmode);
            x = this.img;
        end
        function x = dipprctile(this, b)
            this = this.bsxfun(@dipprctile, b);
            x = this.img;
        end
        function x = dipprod(this)
            this = this.usxfun(@dipprod);
            x = this.img;
        end        
        function x = dipquantile(this, b)
            this = this.bsxfun(@dipquantile, b);
            x = this.img;
        end
        function x = dipstd(this)
            this = this.usxfun(@dipstd);
            x = this.img;
        end                
        function x = dipsum(this)
            this = this.usxfun(@dipsum);
            x = this.img;
        end 
        function x = diptrimmean(this, b)
            this = this.bsxfun(@diptrimmean, b);
            x = this.img;
        end
        
        %% *sxfun
		  
        function this = usxfun(this, funh)
            %% USXFUN
            %  @param funh  is a function_handle.
            %  @return this is modified.
            %  @throws MATLAB
                         
            this = mlfourd.NumericalImaging(this, 'img', double(funh(this.component.img)));
            this.addLog(sprintf('NumericalImaging.usxfun %s %s', func2str(funh), this.fileprefix));
        end
        function this = bsxfun(this, funh, b)
            %% BSXFUN overloads bsxfun for INIfTI
            %  @param funh is a function_handle.
            %  @param b    is a HandleINIfTI object or numerical.
            %  @return this is modified.
            %  @throws MATLAB:bsxfun:nonnumericOperands
            
            import mlfourd.*;
            if (isa(b, 'mlfourd.HandleINIfTI') || isa(b, 'mlfourd.INIfTI'))
                this = NumericalImaging(this, 'img', double(bsxfun(funh, this.component.img, b.img)));
                this.addLog(sprintf('NumericalImaging.bsxfun %s %s %s', func2str(funh), this.fileprefix, b.fileprefix));
            else
                this = NumericalImaging(this, 'img', double(bsxfun(funh, this.component.img, b)));
                this.addLog(sprintf('NumericalImaging.bsxfun %s %s %s', func2str(funh), this.fileprefix, mat2str(b)));
            end
        end
        
        %%
        
        function this = binarized(this, varargin)
            ic = this.numericalTool;
            ic = ic.binarized(varargin{:});
            this = ic.nifti;
        end
        function this = binarizeBlended(this, varargin)
            ic = this.numericalTool;
            ic = ic.binarizeBlended(varargin{:});
            this = ic.nifti;
        end
        function this = blurred(this, varargin)
            ic = this.numericalTool;
            ic = ic.blurred(varargin{:});
            this = ic.nifti;
        end
        function this = maskBlended(this, varargin)
            ic = this.numericalTool;
            ic = ic.maskBlended(varargin{:});
            this = ic.nifti;
        end
        function this = masked(this, varargin)
            ic = this.numericalTool;
            ic = ic.masked(varargin{:});
            this = ic.nifti;
        end
        function this = maskedByZ(this, varargin)
            ic = this.numericalTool;
            ic = ic.maskedByZ(varargin{:});
            this = ic.nifti;
        end
        function this = thresh(this, varargin)
            ic = this.numericalTool;
            ic = ic.thresh(varargin{:});
            this = ic.nifti;
        end
        function this = threshp(this, varargin)
            ic = this.numericalTool;
            ic = ic.threshp(varargin{:});
            this = ic.nifti;
        end
        function this = timeSummed(this)
            ic = this.numericalTool;
            ic = ic.timeSummed;
            this = ic.nifti;
        end
        function this = timeContracted(this, varargin)
            %% TIMECONTRACTED
            %  @param T is a closed interval for contracting times, [t0 tF]; defaults to all times.
            %  @return this contracted in time.
            
            ic = this.numericalTool;
            ic = ic.timeContracted(varargin{:});
            this = ic.nifti;
        end
        function this = uthresh(this, varargin)
            ic = this.numericalTool;
            ic = ic.uthresh(varargin{:});
            this = ic.nifti;
        end
        function this = uthreshp(this, varargin)
            ic = this.numericalTool;
            ic = ic.uthreshp(varargin{:});
            this = ic.nifti;
        end
        function this = volumeSummed(this)
            ic = this.numericalTool;
            ic = ic.volumeSummed;
            this = ic.nifti;
        end        
        function [this,msk] = volumeAveraged(this, varargin)   
            %% VOLUMEAVERAGED calls this.volumeContracted, then divides the data by the number of masked inclusions.
            %  @param per this.volumeContracted.
            %  @return this contracted and averaged by masked inclusions.
            
            ic = this.numericalTool;
            [ic,msk] = ic.volumeAveraged(varargin{:});
            this = ic.nifti;
            msk  = msk.nifti;
        end
        function [this,msk] = volumeContracted(this, varargin)
            %% VOLUMECONTRACTED
            %  @param mask is a mask for contracting volumes, mlfourd.ImagingContext or mlfourd.INIfTI; defaults to all volumes.
            %  @return this contracted in volumes.
            %  @return mask as mlfourd.NumericalNIfTId.
            
            ic = this.numericalTool;
            [ic,msk] = ic.volumeContracted(varargin{:});
            this = ic.nifti;
            msk  = msk.nifti;
        end
        function this = zoomed(this, varargin)
            ic = mlfourd.ImagingContext2(this);
            ic.selectNumericalTool;
            ic = ic.zoomed(varargin{:});
            this = ic.nifti;
        end
        
 		function this = NumericalImaging(varargin)
 			this = this@mlfourd.ImagingFormatContext(varargin{:});
 		end
    end 
    
    %% PRIVATE
    
    methods (Access = private)
        function ic = numericalTool(this)
            ic = mlfourd.ImagingContext2(this);
            ic.selectNumericalTool;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

