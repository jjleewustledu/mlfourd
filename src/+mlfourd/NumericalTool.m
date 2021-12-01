classdef NumericalTool < handle & mlfourd.ImagingFormatTool & mlpatterns.HandleNumerical & mlpatterns.HandleDipNumerical
	%% NUMERICALTOOL extends INIfTI implementations with bsxfun and other numerical functionality.
    
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
        function acos(this)
            this.usxfun(@acos);
        end
        function acosh(this)
            this.usxfun(@acosh);
        end
        function asin(this)
            this.usxfun(@asin);
        end
        function asinh(this)
            this.usxfun(@asinh);
        end
        function atan(this, b)
            this.bsxfun(@atan, b);
        end
        function atan2(this, b)
            this.bsxfun(@atan2, b);
        end
        function atanh(this)
            this.usxfun(@atanh);
        end
        function cos(this)
            this.usxfun(@cos);
        end
        function cosh(this)
            this.usxfun(@cosh);
        end        
        function dice(this, b, varargin)
            this.bsxfun(@dice_, b);            
            function d = dice_(img1, img2)
                if ~isempty(varargin)
                    msk = logical(varargin{:});
                    img1 = img1(msk);
                    img2 = img2(msk);
                end
                img1(isnan(img1)) = 0;
                img2(isnan(img2)) = 0;
                d = dice(logical(img1), logical(img2));
            end
        end
        function exp(this)
            this.usxfun(@exp);
        end
        function flip(this, b)
            this.bsxfun(@flip, b);
%            this.imagingFormat_.fileprefix = sprintf('%s_flip%i', this.imagingFormat_.fileprefix, b);
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
        function jsdiv(this, b, varargin)
            this.bsxfun(@jsdiv_, b);
            function d = jsdiv_(img1, img2)                
                if ~isempty(varargin)
                    msk = logical(varargin{:});
                    img1 = img1(msk);
                    img2 = img2(msk);
                end
                img1(isnan(img1)) = eps;
                img1(img1 < eps) = eps;
                img1 = img1 / dipsum(img1);
                img2(isnan(img2)) = eps;
                img2(img2 < eps) = eps;
                img2 = img2 / dipsum(img2);                
                logImgQ = log2((img1 + img2)/2);
                d = 0.5 * ( ...
                    dipsum(img1 .* (log2(img1) - logImgQ)) + ...
                    dipsum(img2 .* (log2(img2) - logImgQ))); 
            end
        end
        function kldiv(this, b, varargin)
            this.bsxfun(@kldiv_, b);            
            function d = kldiv_(img1, img2)
                if ~isempty(varargin)
                    msk = logical(varargin{:});
                    img1 = img1(msk);
                    img2 = img2(msk);
                end
                img1(isnan(img1)) = eps;
                img1(img1 < eps) = eps;
                img1 = img1 / dipsum(img1);
                img2(isnan(img2)) = eps;
                img2(img2 < eps) = eps;
                img2 = img2 / dipsum(img2);
                d = dipsum(img1 .* (log2(img1) - log2(img2)));
            end
        end        
        function log(this)
            this.usxfun(@log);
        end
        function log10(this)
            this.usxfun(@log10);
        end
        function max(this, b)
            this.bsxfun(@max, b);
        end
        function min(this, b)
            this.bsxfun(@min, b);
        end
        function minus(this, varargin)
            if ~isempty(varargin)
                this.bsxfun(@minus, varargin{:});
            else
                this.uminus(varargin{:});
            end
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
        function sin(this)
            this.usxfun(@sin);
        end
        function sinh(this)
            this.usxfun(@sinh);
        end
        function sum(this, varargin)
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', sum(this.imagingFormat_.img, varargin{:}));
            if isempty(varargin)
                tag = '';
            else
                tag = ['_' strrep(cell2str(varargin), ' ', '_')];
            end
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_sum' tag];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  sum %s %s', this.fileprefix, mat2str(varargin{:}))); 
        end
        function tan(this)
            this.usxfun(@tan);
        end
        function tanh(this)
            this.usxfun(@tanh);
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
        function isequal(this, b)
            this.lbsxfun(@isequal, b);
        end 
        function isequaln(this, b)
            this.lbsxfun(@isequaln, b);
        end 
        function isfinite(this)
            this.lusxfun(@isfinite);
        end 
        function isinf(this)
            this.lusxfun(@isinf);
        end 
        function isnan(this)
            this.lusxfun(@isnan);
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
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', false(this.imagingFormat_.size, varargin{:}));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_false'];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  false %s', this.fileprefix)); 
        end
        function find(this, varargin)
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', find(this.imagingFormat_.img, varargin{:}));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_find'];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  find %s', this.fileprefix)); 
        end
        function nan(this, varargin)
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', nan(this.imagingFormat_.size, varargin{:}));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_nan'];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  nan %s', this.fileprefix)); 
        end
        function ones(this, varargin)
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', ones(this.imagingFormat_.size, varargin{:}));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_ones'];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  ones %s', this.fileprefix)); 
        end
        function reshape(this, varargin)
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', reshape(this.imagingFormat_.img, varargin{:}));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_reshape'];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  reshape %s', mat2str(size(this.imagingFormat_.img)))); 
        end
        function scrubNanInf(this)
            img_ = this.imagingFormat_.img;
            img_(isnan(img_)) = 0;
            img_(~isfinite(img_)) = 0;
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', img_);
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_scrubNanInf'];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  scrubNanInf %s', this.fileprefix)); 
        end
        function true(this, varargin)
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', true(this.imagingFormat_.size, varargin{:}));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_true'];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  true %s', this.fileprefix)); 
        end
        function zeros(this, varargin)
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', zeros(this.imagingFormat_.size, varargin{:}));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_zeros'];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  zeros %s', this.fileprefix)); 
        end
                
        %% implementations of mlpatterns.HandleDipNumerical
        
        function d = dipiqr(this)
            this.usxfun(@dipiqr);
            d = this.getInnerImaging.img;
        end
        function d = dipisfinite(this)
            this.usxfun(@dipisfinite);
            d = this.getInnerImaging.img;
            d = logical(d);
        end
        function d = dipisinf(this)
            this.usxfun(@dipisinf);
            d = this.getInnerImaging.img;
            d = logical(d);
        end
        function d = dipisnan(this)
            this.usxfun(@dipisnan);
            d = this.getInnerImaging.img;
            d = logical(d);
        end
        function d = dipisreal(this)
            this.usxfun(@dipisreal);
            d = this.getInnerImaging.img;
            d = logical(d);
        end
        function d = diplogprod(this)
            this.usxfun(@diplogprod);
            d = this.getInnerImaging.img;
        end
        function d = dipmad(this)
            this.usxfun(@dipmad);
            d = this.getInnerImaging.img;
        end        
        function d = dipmax(this)
            this.usxfun(@dipmax);
            d = this.getInnerImaging.img;
        end        
        function d = dipmean(this)
            this.usxfun(@dipmean);
            d = this.getInnerImaging.img;
        end        
        function d = dipmedian(this)
            this.usxfun(@dipmedian);
            d = this.getInnerImaging.img;
        end        
        function d = dipmin(this)
            this.usxfun(@dipmin);
            d = this.getInnerImaging.img;
        end   
        function d = dipmode(this)
            this.usxfun(@dipmode);
            d = this.getInnerImaging.img;
        end
        function d = dipprctile(this, b)
            this.bsxfun(@dipprctile, b);
            d = this.getInnerImaging.img;
        end
        function d = dipprod(this)
            this.usxfun(@dipprod);
            d = this.getInnerImaging.img;
        end        
        function d = dipquantile(this, b)
            this.bsxfun(@dipquantile, b);
            d = this.getInnerImaging.img;
        end
        function d = dipstd(this)
            this.usxfun(@dipstd);
            d = this.getInnerImaging.img;
        end                
        function d = dipsum(this)
            this.usxfun(@dipsum);
            d = this.getInnerImaging.img;
        end 
        function d = diptrimmean(this, b)
            this.bsxfun(@diptrimmean, b);
            d = this.getInnerImaging.img;
        end
                
        %% 
        
        function s = bstr(~, b)
            if isa(b, 'mlfourd.ImagingContext2')
                s = b.fileprefix;
                return
            end
            if isa(b, 'mlfourd.ImagingFormatContext')
                s = b.fileprefix;
                return
            end
            if isscalar(b)
                s = strrep(num2str(b), '.', 'p');
                return
            end
            if isnumeric(b)
                s = strrep(mat2str(size(b)), ' ', ',');
                s = ['size' s(2:end-1)];
                return
            end
            s = 'obj';
        end
        function lusxfun(this, funh)
            %% LUSXFUN
            %  @param funh  is a function_handle.
            %  @return this is modified.
            %  @throws MATLAB
            
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', logical(funh(this.imagingFormat_.img)));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_l' char(funh)];
            this.imagingFormat_.addLog( ...
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
                this.imagingFormat_ = ImagingFormatContext( ...
                    this.imagingFormat_, 'img', logical(bsxfun(funh, this.imagingFormat_.img, b)));
                this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_l' char(funh) '_' this.bstr(b)];
                this.imagingFormat_.addLog( ...
                    sprintf('NumericalTool:  l%s %s %s', func2str(funh), this.fileprefix, this.bstr(b)));
                return
            end
            if (isa(b, 'mlfourd.ImagingContext2'))
                b = b.nifti;
                this.imagingFormat_ = ImagingFormatContext( ...
                    this.imagingFormat_, 'img', logical(bsxfun(funh, this.imagingFormat_.img, b.img)));
                this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_l' char(funh) '_' this.bstr(b)];
                this.imagingFormat_.addLog( ...
                    sprintf('NumericalTool:  l%s %s %s', func2str(funh), this.fileprefix, b.fileprefix));
                return
            end
            b = ImagingFormatContext(b);
            this.imagingFormat_ = ImagingFormatContext( ...
                this.imagingFormat_, 'img', logical(bsxfun(funh, this.imagingFormat_.img, b.img)));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_l' char(funh) '_' this.bstr(b)];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  l%s %s %s', func2str(funh), this.fileprefix, b.fileprefix));
        end
        function usxfun(this, funh)
            %% USXFUN
            %  @param funh  is a function_handle.
            %  @return this is modified.
            %  @throws MATLAB
            
            this.imagingFormat_ = mlfourd.ImagingFormatContext( ...
                this.imagingFormat_, 'img', double(funh(this.imagingFormat_.img)));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_' char(funh)];
            this.imagingFormat_.addLog( ...
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
                this.imagingFormat_ = ImagingFormatContext( ...
                    this.imagingFormat_, 'img', double(bsxfun(funh, double(this.imagingFormat_.img), double(b))));
                this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_' char(funh) '_' this.bstr(b)];
                this.imagingFormat_.addLog( ...
                    sprintf('NumericalTool:  %s %s %s', func2str(funh), this.fileprefix, this.bstr(b)));
                return
            end
            if (isa(b, 'mlfourd.ImagingContext2'))
                b = b.nifti;
                this.imagingFormat_ = ImagingFormatContext( ...
                    this.imagingFormat_, 'img', double(bsxfun(funh, double(this.imagingFormat_.img), double(b.img))));
                this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_' char(funh) '_' this.bstr(b)];
                this.imagingFormat_.addLog( ...
                    sprintf('NumericalTool:  %s %s %s', func2str(funh), this.fileprefix, b.fileprefix));
                return
            end
            b = ImagingFormatContext(b);
            this.imagingFormat_ = ImagingFormatContext( ...
                this.imagingFormat_, 'img', double(bsxfun(funh, double(this.imagingFormat_.img), double(b.img))));
            this.imagingFormat_.fileprefix = [this.imagingFormat_.fileprefix '_' char(funh) '_' this.bstr(b)];
            this.imagingFormat_.addLog( ...
                sprintf('NumericalTool:  %s %s %s', func2str(funh), this.fileprefix, b.fileprefix));
        end
        
        function this = NumericalTool(h, varargin)
            this = this@mlfourd.ImagingFormatTool(h, varargin{:});
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
