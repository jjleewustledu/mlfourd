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
        
        function that = abs(this)
            that = this.usxfun(@abs);
        end
        function that = atan2(this, b)
            that = this.bsxfun(@atan2, b);
        end
        function that = rdivide(this, b)
            that = this.bsxfun(@rdivide, b);
        end
        function that = ldivide(this, b)
            that = this.bsxfun(@ldivide, b);
        end
        function that = hypot(this, b)
            that = this.bsxfun(@hypot, b);
        end
        function that = max(this, b)
            that = this.bsxfun(@max, b);
        end
        function that = min(this, b)
            that = this.bsxfun(@min, b);
        end
        function that = minus(this, b)
            that = this.bsxfun(@minus, b);
        end
        function that = mod(this, b)
            that = this.bsxfun(@mod, b);
        end
        function that = mpower(this, b)
            that = this.bsxfun(@mpower, b);
        end
        function that = mldivide(this, b)
            that = this.bsxfun(@mldivide, b);
        end
        function that = mrdivide(this, b)
            that = this.bsxfun(@mrdivide, b);           
        end
        function that = mtimes(this, b)
            that = this.bsxfun(@mtimes, b);
        end
        function that = plus(this, b)
            that = this.bsxfun(@plus, b);
        end
        function that = power(this, b)
            that = this.bsxfun(@power, b);
        end
        function that = rem(this, b)
            that = this.bsxfun(@rem, b);
        end
        function that = sum(this, varargin)            
            that = copy(this);            
            that.innerContext_ = mlfourd.ImagingFormatContext( ...
                this.innerContext_, 'img', sum(this.innerContext_.img, varargin{:}));
            that.innerContext_.addLog( ...
                sprintf('NumericalTool:  sum %s %s', this.fileprefix, mat2str(varargin{:}))); 
        end
        function that = times(this, b)
            that = this.bsxfun(@times, b);
        end
        function that = ctranspose(this)
            that = this.usxfun(@ctranspose);
        end
        function that = transpose(this)
            that = this.usxfun(@transpose);
        end
        function that = uminus(this)
            that = this.usxfun(@uminus);
        end
        
        function that = eq(this, b)
            that = this.bsxfun(@eq, b);
        end
        function that = ne(this, b)
            that = this.bsxfun(@ne, b);
        end
        function that = lt(this, b)
            that = this.bsxfun(@lt, b);
        end
        function that = le(this, b)
            that = this.bsxfun(@le, b);
        end
        function that = gt(this, b)
            that = this.bsxfun(@gt, b);
        end
        function that = ge(this, b)
            that = this.bsxfun(@ge, b);
        end
        function that = and(this, b)
            that = this.bsxfun(@and, b);
        end
        function that = or(this, b)
            that = this.bsxfun(@or, b);
        end
        function that = xor(this, b)
            that = this.bsxfun(@xor, b);
        end
        function that = not(this)
            that = this.usxfun(@not);
        end            
        
        function c    = char(this)
            c = this.innerContext_.char;
        end
        function d    = double(this)
            d = double(this.innerContext_.img);
        end
        function s    = mat2str(this, varargin)
            s = mat2str(this.innerContext_.img, varargin{:});
        end
        function that = ones(this, varargin)
            that = copy(this);
            that.innerContext_ = mlfourd.ImagingFormatContext( ...
                this.innerContext_, 'img', ones(this.innerContext_.size, varargin{:}));
            that.innerContext_.addLog( ...
                sprintf('NumericalTool:  ones %s', this.fileprefix)); 
        end
        function r    = rank(this)
            r = this.innerContext_.rank;
        end
        function that = scrubNanInf(this)
            that = copy(this);
            img_ = this.innerContext_.img;
            img_(isnan(img_)) = 0;
            img_(~isfinite(img_)) = 0;
            that.innerContext_ = mlfourd.ImagingFormatContext( ...
                this.innerContext_, 'img', img_);
            that.innerContext_.addLog( ...
                sprintf('NumericalTool:  scrubNanInf %s', this.fileprefix)); 
        end
        function s    = single(this)
            s = single(this.innerContext_.img);
        end
        function s    = size(this, varargin)
            s = size(this.innerContext_.img, varargin{:});
        end
        function that = zeros(this, varargin)
            that = copy(this);
            that.innerContext_ = mlfourd.ImagingFormatContext( ...
                this.innerContext_, 'img', zeros(this.innerContext_.size, varargin{:}));
            that.innerContext_.addLog( ...
                sprintf('NumericalTool:  zeros %s', this.fileprefix)); 
        end
                
        %% implementations of mlpatterns.HandleDipNumerical
        
        function that = dipiqr(this)
            that = this.usxfun(@dipiqr);
        end
        function that = dipisfinite(this)
            that = this.usxfun(@dipisfinite);
        end
        function that = dipisinf(this)
            that = this.usxfun(@dipisinf);
        end
        function that = dipisnan(this)
            that = this.usxfun(@dipisnan);
        end
        function that = dipisreal(this)
            that = this.usxfun(@dipisreal);
        end
        function that = diplogprod(this)
            that = this.usxfun(@diplogprod);
        end
        function that = dipmad(this)
            that = this.usxfun(@dipmad);
        end        
        function that = dipmax(this)
            that = this.usxfun(@dipmax);
        end        
        function that = dipmean(this)
            that = this.usxfun(@dipmean);
        end        
        function that = dipmedian(this)
            that = this.usxfun(@dipmedian);
        end        
        function that = dipmin(this)
            that = this.usxfun(@dipmin);
        end   
        function that = dipmode(this)
            that = this.usxfun(@dipmode);
        end
        function that = dipprctile(this, b)
            that = this.bsxfun(@dipprctile, b);
        end
        function that = dipprod(this)
            that = this.usxfun(@dipprod);
        end        
        function that = dipquantile(this, b)
            that = this.bsxfun(@dipquantile, b);
        end
        function that = dipstd(this)
            that = this.usxfun(@dipstd);
        end                
        function that = dipsum(this)
            that = this.usxfun(@dipsum);
        end 
        function that = diptrimmean(this, b)
            that = this.bsxfun(@diptrimmean, b);
        end
                
        %% 
        
        function that = usxfun(this, funh)
            %% USXFUN
            %  @param funh  is a function_handle.
            %  @return that is a modified copy of this.
            %  @throws MATLAB
            
            that = copy(this);
            that.innerContext_ = mlfourd.ImagingFormatContext( ...
                this.innerContext_, 'img', double(funh(this.innerContext_.img)));
            that.innerContext_.addLog( ...
                sprintf('NumericalTool:  %s %s', func2str(funh), this.fileprefix));
        end
        function that = bsxfun(this, funh, b)
            %% BSXFUN overloads bsxfun for INIfTI
            %  @param funh  is a function_handle.
            %  @param b     is an ImagingFormatContext
            %  @return that is a modified copy of this.
            %  @throws MATLAB:bsxfun:nonnumericOperands
            
            assert(isa(b, 'mlfourd.ImagingFormatContext'));
            that = copy(this);
            that.innerContext_ = mlfourd.ImagingFormatContext( ...
                this.innerContext_, 'img', double(bsxfun(funh, this.innerContext_.img, b.img)));
            that.innerContext_.addLog( ...
                sprintf('NumericalTool:  %s %s %s', func2str(funh), this.fileprefix, b.fileprefix));
        end
        
        function this = NumericalTool(h, varargin)
            this = this@mlfourd.AbstractImagingTool(h, varargin{:});
            this.innerContext_ = mlfourd.ImagingFormatContext(varargin{:});
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
