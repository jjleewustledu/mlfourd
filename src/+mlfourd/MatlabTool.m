classdef MatlabTool < handle & mlfourd.ImagingTool
    %% MATLABTOOL is a minimal concrete subclass of ImagingTool which supports native Matlab numerical maths.
    %  N.B.:  numeq and numneq evaluate numerical imaging data of MatlabTool.
    %         eq,== and neq,~= evaluate whether handles for MatlabTool are the same.
    %
    %  Created 05-Dec-2021 21:15:53 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.

    methods
        
        %% implementations of mlpatterns.Numerical
        
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
        function expm(this)
            this.usxfun(@expm);
        end
        function flip(this, b)
            this.bsxfun(@flip, b);
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
        function logm(this)
            this.usxfun(@logm);
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
        function sqrt(this)
            this.usxfun(@sqrt);
        end
        function sqrtm(this)
            this.usxfun(@sqrtm);
        end
        function sum(this, varargin)
            this.imagingFormat_.img = sum(this.imagingFormat_.img, varargin{:});
            if isempty(varargin)
                tag = '';
            else
                tag = ['_' strrep(cell2str(varargin), ' ', '_')];
            end
            this.imagingFormat_.fileprefix = strcat(this.imagingFormat_.fileprefix, '_sum', tag);
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.sum: %s %s', this.fileprefix, mat2str(varargin{:}))); 
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
        
        function numeq(this, b)
            this.lbsxfun(@eq, b);
        end
        function numneq(this, b)
            this.lbsxfun(@neq, b);
        end
        function numlt(this, b)
            %% synonymous with lt()

            this.lbsxfun(@lt, b);
        end
        function numle(this, b)
            %% synonymous with le()

            this.lbsxfun(@le, b);
        end
        function numgt(this, b)
            %% synonymous with gt()

            this.lbsxfun(@gt, b);
        end
        function numge(this, b)
            %% synonymous with ge()

            this.lbsxfun(@ge, b);
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
        function isreal(this)
            this.usxfun(@isreal)
        end
        function not(this)
            this.lusxfun(@not);
        end 
        function or(this, b)
            this.lbsxfun(@or, b);
        end
        function xor(this, b)
            this.lbsxfun(@xor, b);
        end
        
        function false(this, varargin)
            this.imagingFormat_.img = false(this.imagingFormat_.size, varargin{:});
            this.imagingFormat_.fileprefix = strcat(this.imagingFormat_.fileprefix, '_false');
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.false: %s', this.fileprefix)); 
        end
        function find(this, varargin)
            this.imagingFormat_.img = find(this.imagingFormat_.img, varargin{:});
            this.imagingFormat_.fileprefix = strcat(this.imagingFormat_.fileprefix, '_find');
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.find: %s', this.fileprefix)); 
        end
        function nan(this, varargin)
            this.imagingFormat_.img = mlfourd.ImagingFormatContext2( ...
                nan(this.imagingFormat_.size, varargin{:}), ...
                'filesystem', this.filesystem, ...
                'logger', this.logger);
            this.imagingFormat_.fileprefix = strcat(this.imagingFormat_.fileprefix, '_nan');
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.nan: %s', this.fileprefix)); 
        end
        function ones(this, varargin)
            this.imagingFormat_.img = ones(this.imagingFormat_.size, varargin{:});
            this.imagingFormat_.fileprefix = strcat(this.imagingFormat_.fileprefix, '_ones');
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.ones: %s', this.fileprefix)); 
        end
        function reshape(this, varargin)
            this.imagingFormat_.img = reshape(this.imagingFormat_.img, varargin{:});
            this.imagingFormat_.fileprefix = strcat(this.imagingFormat_.fileprefix, '_reshape');
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.reshape: %s', mat2str(size(this.imagingFormat_.img)))); 
        end
        function scrubNanInf(this)
            img_ = this.imagingFormat_.img;
            img_(isnan(img_)) = 0;
            img_(~isfinite(img_)) = 0;
            this.imagingFormat_.img = img_;
            this.imagingFormat_.fileprefix = strcat(this.imagingFormat_.fileprefix, '_scrubNanInf');
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.scrubNanInf: %s', this.fileprefix)); 
        end
        function true(this, varargin)
            this.imagingFormat_.img = true(this.imagingFormat_.size, varargin{:});
            this.imagingFormat_.fileprefix = strcat(this.imagingFormat_.fileprefix, '_true');
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.true: %s', this.fileprefix)); 
        end
        function zeros(this, varargin)
            this.imagingFormat_.img = zeros(this.imagingFormat_.size, varargin{:});
            this.imagingFormat_.fileprefix = strcat(this.imagingFormat_.fileprefix, '_zeros');
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.zero:s %s', this.fileprefix)); 
        end
                
        %% implementations of mlpatterns.DipNumerical
        
        function d = dipiqr(this)
            this.usxfun(@dipiqr);
            d = this.imagingFormat_.img;
        end
        function d = dipisfinite(this)
            this.usxfun(@dipisfinite);
            d = this.imagingFormat_.img;
            d = logical(d);
        end
        function d = dipisinf(this)
            this.usxfun(@dipisinf);
            d = this.imagingFormat_.img;
            d = logical(d);
        end
        function d = dipisnan(this)
            this.usxfun(@dipisnan);
            d = this.imagingFormat_.img;
            d = logical(d);
        end
        function d = dipisreal(this)
            this.usxfun(@dipisreal);
            d = this.imagingFormat_.img;
            d = logical(d);
        end
        function d = diplogprod(this)
            this.usxfun(@diplogprod);
            d = this.imagingFormat_.img;
        end
        function d = dipmad(this)
            this.usxfun(@dipmad);
            d = this.imagingFormat_.img;
        end        
        function d = dipmax(this)
            this.usxfun(@dipmax);
            d = this.imagingFormat_.img;
        end        
        function d = dipmean(this)
            this.usxfun(@dipmean);
            d = this.imagingFormat_.img;
        end        
        function d = dipmedian(this)
            this.usxfun(@dipmedian);
            d = this.imagingFormat_.img;
        end        
        function d = dipmin(this)
            this.usxfun(@dipmin);
            d = this.imagingFormat_.img;
        end   
        function d = dipmode(this)
            this.usxfun(@dipmode);
            d = this.imagingFormat_.img;
        end
        function d = dipprctile(this, b)
            this.bsxfun(@dipprctile, b);
            d = this.imagingFormat_.img;
        end
        function d = dipprod(this)
            this.usxfun(@dipprod);
            d = this.imagingFormat_.img;
        end        
        function d = dipquantile(this, b)
            this.bsxfun(@dipquantile, b);
            d = this.imagingFormat_.img;
        end
        function d = dipstd(this)
            this.usxfun(@dipstd);
            d = this.imagingFormat_.img;
        end                
        function d = dipsum(this)
            this.usxfun(@dipsum);
            d = this.imagingFormat_.img;
        end 
        function d = diptrimmean(this, b)
            this.bsxfun(@diptrimmean, b);
            d = this.imagingFormat_.img;
        end

        %%
        
        function s = bstr(~, b)
            if isa(b, 'mlfourd.ImagingContext2')
                s = b.fileprefix;
                return
            end
            if isa(b, 'mlfourd.ImagingFormatContext2')
                s = b.fileprefix;
                return
            end
            if isa(b, 'mlfourd.IImagingFormat')
                s = strrep(num2str(b), '.', 'p');
                return
            end
            if isscalar(b)
                s = strrep(num2str(b), '.', 'p');
                return
            end
            if isnumeric(b)
                s = strrep(mat2str(size(b)), ' ', '_');
                s = ['size_' s(2:end-1)];
                return
            end
            s = 'obj';
        end
        function cast(this, varargin)
            %% CAST overloads cast for INIfTI
            %  Syntax:
            %      B = cast(A,newclass)
            %      B = cast(A,'like',p)
            
            ip = inputParser;
            addRequired(ip, 'mode', @istext)
            addOptional(ip, 'number', [], @isnumeric)
            parse(ip, varargin{:});
            ipr = ip.Results;

            if ~strcmp(ipr.mode, 'like')                
                this.imagingFormat_.img = cast(this.imagingFormat_.img, ipr.mode);
                fp = this.imagingFormat_.fileprefix;
                this.imagingFormat_.addLog( ...
                    sprintf('MatlabTool.cast:  %s cast %s', fp, ipr.mode));
                this.imagingFormat_.fileprefix = [fp '_cast_' ipr.mode];
                return
            end

            if isa(ipr.number, 'mlfourd.ImagingContext2')
                b = ipr.number.imagingFormat();
                b = b.img;
            end
            if isa(ipr.number, 'mlfourd.ImagingFormatContext2')
                b = b.img;
            end

            this.imagingFormat_.img = cast(this.imagingFormat_.img, 'like', double(b));
            fp = this.imagingFormat_.fileprefix;
            cl = class(this.imagingFormat_.img);
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.cast:  %s cast %s', fp, cl));
            this.imagingFormat_.fileprefix = [fp '_cast_' cl];
        end
        function funm(this, funh, varargin)
            %% FUNM overloads funm for INIfTI
            %  Syntax:
            %      F = funm(A,fun)
            %      F = funm(A,fun,options)
            %      F = funm(A,fun,options,p1,2,...)

            this.imagingFormat_.img = funm(double(this.imagingFormat_.img), funh, varargin{:});
            fp = this.imagingFormat_.fileprefix;
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.funm:  %s(%s)', func2str(funh), fp));
            this.imagingFormat_.fileprefix = [fp '_fnum_' func2str(funh)];
        end
        function lusxfun(this, funh)
            %% LUSXFUN
            %  @param funh  is a function_handle.
            %  @return this is modified.
            %  @throws MATLAB
            
            this.usxfun(funh)
            this.imagingFormat_.img = logical(this.imagingFormat_.img);
        end
        function lbsxfun(this, funh, b)
            %% LBSXFUN overloads bsxfun for INIfTI
            %  @param funh  is a function_handle.
            %  @param b     is numeric, ImagingState2, ImagingFormatContext2 or acceptable arg to
            %               ImagingFormatContext2.ctor.
            %  @return this is modified.
            %  @throws MATLAB:bsxfun:nonnumericOperands
            
            this.bsxfun(funh, b)
            this.imagingFormat_.img = logical(this.imagingFormat_.img);
        end
        function usxfun(this, funh)
            %% USXFUN
            %  @param funh  is a function_handle.
            %  @return this is modified.
            %  @throws MATLAB
            
            this.imagingFormat_.img = double(funh(this.imagingFormat_.img));
            fp = this.imagingFormat_.fileprefix;
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.usxfun:  %s(%s)', func2str(funh), fp));
            this.imagingFormat_.fileprefix = [fp '_' func2str(funh)];
        end
        function bsxfun(this, funh, b)
            %% BSXFUN overloads bsxfun for INIfTI
            %  @param funh  is a function_handle.
            %  @param b     is numeric, ImagingState2, ImagingFormatContext2 or acceptable arg to
            %               ImagingFormatContext2.ctor.
            %  @return this is modified.
            %  @throws MATLAB:bsxfun:nonnumericOperands
            
            if isa(b, 'mlfourd.ImagingContext2')
                b.selectMatlabTool();
                b_ = b.imagingFormat();
                b = b_.img;
            end
            if isa(b, 'mlfourd.ImagingFormatContext2')
                b = b.img;
            end

            this.imagingFormat_.img = double(bsxfun(funh, double(this.imagingFormat_.img), double(b)));
            fp = this.imagingFormat_.fileprefix;
            this.imagingFormat_.addLog( ...
                sprintf('MatlabTool.bsxfun:  %s(%s, %s)', func2str(funh), fp, this.bstr(b)));
            this.imagingFormat_.fileprefix = [fp '_' func2str(funh) '_' this.bstr(b)];
        end
        
        function this = MatlabTool(contexth, imagingFormat, varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      imagingFormat (IImagingFormat): provides numerical imaging data.  
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.            

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'contexth', @(x) isa(x, 'mlfourd.ImagingContext2'))
            addRequired(ip, 'imagingFormat',  @(x) isnumeric(x) || islogical(x) || isa(x, 'mlfourd.IImagingFormat'))
            parse(ip, contexth, imagingFormat, varargin{:})
            ipr = ip.Results;
            if isnumeric(ipr.imagingFormat) || islogical(ipr.imagingFormat)
                ipr.imagingFormat = mlfourd.ImagingFormatContext2(ipr.imagingFormat, varargin{:});
            end
            ipr.imagingFormat.selectMatlabFormatTool();
            this = this@mlfourd.ImagingTool(ipr.contexth, ipr.imagingFormat, varargin{:});
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
