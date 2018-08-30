classdef NumericalTool < handle & mlfourd.AbstractImagingTool & mlpatterns.HandleNumerical & mlpatterns.HandleDipNumerical
	%% NUMERICALTOOL extends NIfTId implementations with bsxfun and other numerical functionality.
    
	%  $Revision$
 	%  was created 10-Jan-2016 13:16:45
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
        
    methods
        
        %% implementations of mlpatterns.HandleNumerical
        
        function abs(this)
            this.usxfun(@abs);
        end
        function atan2(this, b)
            this.bsxfun(@atan2, b);
        end
        function rdivide(this, b)
            this.bsxfun(@rdivide, b);
        end
        function ldivide(this, b)
            this.bsxfun(@ldivide, b);
        end
        function hypot(this, b)
            this.bsxfun(@hypot, b);
        end
        function max(this, b)
            this.bsxfun(@max, b);
        end
        function min(this, b)
            this.bsxfun(@min, b);
        end
        function minus(this, b)
            this.bsxfun(@minus, b);
        end
        function mod(this, b)
            this.bsxfun(@mod, b);
        end
        function mpower(this, b)
            this.bsxfun(@mpower, b);
        end
        function mldivide(this, b)
            this.bsxfun(@mldivide, b);
        end
        function mrdivide(this, b)
            this.bsxfun(@mrdivide, b);           
        end
        function mtimes(this, b)
            this.bsxfun(@mtimes, b);
        end
        function plus(this, b)
            this.bsxfun(@plus, b);
        end
        function power(this, b)
            this.bsxfun(@power, b);
        end
        function rem(this, b)
            this.bsxfun(@rem, b);
        end
        function sum(this, varargin)  
            this.innerImaging_ = mlfourd.ImagingFormatContext( ...
                this.innerImaging_, 'img', sum(this.innerImaging_.img, varargin{:}));
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  sum %s %s', this.fileprefix, mat2str(varargin{:}))); 
        end
        function times(this, b)
            this.bsxfun(@times, b);
        end
        function ctranspose(this)
            this.usxfun(@ctranspose);
        end
        function transpose(this)
            this.usxfun(@transpose);
        end
        function uminus(this)
            this.usxfun(@uminus);
        end
        
        function eq(this, b)
            this.lbsxfun(@eq, b);
        end
        function ne(this, b)
            this.lbsxfun(@ne, b);
        end
        function lt(this, b)
            this.lbsxfun(@lt, b);
        end
        function le(this, b)
            this.lbsxfun(@le, b);
        end
        function gt(this, b)
            this.lbsxfun(@gt, b);
        end
        function ge(this, b)
            this.lbsxfun(@ge, b);
        end
        function and(this, b)
            this.lbsxfun(@and, b);
        end
        function or(this, b)
            this.lbsxfun(@or, b);
        end
        function xor(this, b)
            this.lbsxfun(@xor, b);
        end
        function not(this)
            this.lusxfun(@not);
        end            
        
        function false(this, varargin)
            this.innerImaging_ = mlfourd.ImagingFormatContext( ...
                this.innerImaging_, 'img', false(this.innerImaging_.size, varargin{:}));
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  false %s', this.fileprefix)); 
        end
        function nan(this, varargin)
            this.innerImaging_ = mlfourd.ImagingFormatContext( ...
                this.innerImaging_, 'img', nan(this.innerImaging_.size, varargin{:}));
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  nan %s', this.fileprefix)); 
        end
        function ones(this, varargin)
            this.innerImaging_ = mlfourd.ImagingFormatContext( ...
                this.innerImaging_, 'img', ones(this.innerImaging_.size, varargin{:}));
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  ones %s', this.fileprefix)); 
        end
        function scrubNanInf(this)
            img_ = this.innerImaging_.img;
            img_(isnan(img_)) = 0;
            img_(~isfinite(img_)) = 0;
            this.innerImaging_ = mlfourd.ImagingFormatContext( ...
                this.innerImaging_, 'img', img_);
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  scrubNanInf %s', this.fileprefix)); 
        end
        function true(this, varargin)
            this.innerImaging_ = mlfourd.ImagingFormatContext( ...
                this.innerImaging_, 'img', true(this.innerImaging_.size, varargin{:}));
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  true %s', this.fileprefix)); 
        end
        function zeros(this, varargin)
            this.innerImaging_ = mlfourd.ImagingFormatContext( ...
                this.innerImaging_, 'img', zeros(this.innerImaging_.size, varargin{:}));
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  zeros %s', this.fileprefix)); 
        end
                
        %% implementations of mlpatterns.HandleDipNumerical
        
        function dipiqr(this)
            this.usxfun(@dipiqr);
        end
        function dipisfinite(this)
            this.usxfun(@dipisfinite);
        end
        function dipisinf(this)
            this.usxfun(@dipisinf);
        end
        function dipisnan(this)
            this.usxfun(@dipisnan);
        end
        function dipisreal(this)
            this.usxfun(@dipisreal);
        end
        function diplogprod(this)
            this.usxfun(@diplogprod);
        end
        function dipmad(this)
            this.usxfun(@dipmad);
        end        
        function dipmax(this)
            this.usxfun(@dipmax);
        end        
        function dipmean(this)
            this.usxfun(@dipmean);
        end        
        function dipmedian(this)
            this.usxfun(@dipmedian);
        end        
        function dipmin(this)
            this.usxfun(@dipmin);
        end   
        function dipmode(this)
            this.usxfun(@dipmode);
        end
        function dipprctile(this, b)
            this.bsxfun(@dipprctile, b);
        end
        function dipprod(this)
            this.usxfun(@dipprod);
        end        
        function dipquantile(this, b)
            this.bsxfun(@dipquantile, b);
        end
        function dipstd(this)
            this.usxfun(@dipstd);
        end                
        function dipsum(this)
            this.usxfun(@dipsum);
        end 
        function diptrimmean(this, b)
            this.bsxfun(@diptrimmean, b);
        end
                
        %% 
        
        function lusxfun(this, funh)
            %% LUSXFUN
            %  @param funh  is a function_handle.
            %  @return this is modified.
            %  @throws MATLAB
            
            this.innerImaging_ = mlfourd.ImagingFormatContext( ...
                this.innerImaging_, 'img', logical(funh(this.innerImaging_.img)));
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  %s %s', func2str(funh), this.fileprefix));
        end
        function lbsxfun(this, funh, b)
            %% LBSXFUN overloads bsxfun for INIfTI
            %  @param funh  is a function_handle.
            %  @param b     is logical, AbstractImagingTool, ImagingFormatContext or acceptable arg to
            %               ImagingFormatContext.ctor.
            %  @return this is modified.
            %  @throws MATLAB:bsxfun:nonnumericOperands
            
            import mlfourd.*;
            if (isnumeric(b))
                this.innerImaging_ = ImagingFormatContext( ...
                    this.innerImaging_, 'img', logical(bsxfun(funh, this.innerImaging_.img, b)));
                this.innerImaging_.addLog( ...
                    sprintf('NumericalTool:  %s %s %g', func2str(funh), this.fileprefix, b));
                return
            end
            if (isa(b, 'mlfourd.ImagingContext2'))
                b = b.nifti;
                this.innerImaging_ = ImagingFormatContext( ...
                    this.innerImaging_, 'img', logical(bsxfun(funh, this.innerImaging_.img, b.img)));
                this.innerImaging_.addLog( ...
                    sprintf('NumericalTool:  %s %s %s', func2str(funh), this.fileprefix, b.fileprefix));
                return
            end
            b = ImagingFormatContext(b);
            this.innerImaging_ = ImagingFormatContext( ...
                this.innerImaging_, 'img', logical(bsxfun(funh, this.innerImaging_.img, b.img)));
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  %s %s %s', func2str(funh), this.fileprefix, b.fileprefix));
        end
        function usxfun(this, funh)
            %% USXFUN
            %  @param funh  is a function_handle.
            %  @return this is modified.
            %  @throws MATLAB
            
            this.innerImaging_ = mlfourd.ImagingFormatContext( ...
                this.innerImaging_, 'img', double(funh(this.innerImaging_.img)));
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  %s %s', func2str(funh), this.fileprefix));
        end
        function bsxfun(this, funh, b)
            %% BSXFUN overloads bsxfun for INIfTI
            %  @param funh  is a function_handle.
            %  @param b     is numeric, AbstractImagingTool, ImagingFormatContext or acceptable arg to
            %               ImagingFormatContext.ctor.
            %  @return this is modified.
            %  @throws MATLAB:bsxfun:nonnumericOperands
            
            import mlfourd.*;
            if (isnumeric(b))
                this.innerImaging_ = ImagingFormatContext( ...
                    this.innerImaging_, 'img', double(bsxfun(funh, this.innerImaging_.img, b)));
                this.innerImaging_.addLog( ...
                    sprintf('NumericalTool:  %s %s %g', func2str(funh), this.fileprefix, b));
                return
            end
            if (isa(b, 'mlfourd.ImagingContext2'))
                b = b.nifti;
                this.innerImaging_ = ImagingFormatContext( ...
                    this.innerImaging_, 'img', double(bsxfun(funh, this.innerImaging_.img, b.img)));
                this.innerImaging_.addLog( ...
                    sprintf('NumericalTool:  %s %s %s', func2str(funh), this.fileprefix, b.fileprefix));
                return
            end
            b = ImagingFormatContext(b);
            this.innerImaging_ = ImagingFormatContext( ...
                this.innerImaging_, 'img', double(bsxfun(funh, this.innerImaging_.img, b.img)));
            this.innerImaging_.addLog( ...
                sprintf('NumericalTool:  %s %s %s', func2str(funh), this.fileprefix, b.fileprefix));
        end
        
        function this = NumericalTool(h, varargin)
            this = this@mlfourd.AbstractImagingTool(h, varargin{:});
            this.innerImaging_ = mlfourd.ImagingFormatContext(varargin{:});
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
