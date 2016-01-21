classdef NumericalNIfTId < mlfourd.NIfTIdecoratorProperties & mlpatterns.Numerical & mlpatterns.DipNumerical 
	%% NUMERICALNIFTID extends NIfTId implementations with bsxfun and other numerical functionality.
    
	%  $Revision$
 	%  was created 10-Jan-2016 13:16:45
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
        
    methods (Static)        
        function this = load(varargin)
            import mlfourd.*;
            this = NumericalNIfTId(NIfTId.load(varargin{:}));
        end
    end
    
    methods
        function this = usxfun(this, funh)
            %% USXFUN
            %  @param funh  is a function_handle.
            %  @return this is modified.
            %  @throws MATLAB
                         
            this = this.makeSimilar('img', funh(this.component.img), ...
                                    'descrip', sprintf('NumericalNIfTId.usxfun %s %s', ...
                                                       func2str(funh), this.fileprefix));
        end
        function this = bsxfun(this, funh, b)
            %% BSXFUN overloads bsxfun for INIfTI
            %  @param funh is a function_handle.
            %  @param b    is a INIfTI object or numerical.
            %  @return this is modified.
            %  @throws MATLAB:bsxfun:nonnumericOperands
            
            if (isa(b, 'mlfourd.INIfTI'))
                this = this.makeSimilar('img', bsxfun(funh, this.component.img, b.img), ...
                                        'descrip', sprintf('NumericalNIfTId.bsxfun %s %s %s', ...
                                                           func2str(funh), this.fileprefix, b.fileprefix));
            else
                this = this.makeSimilar('img', bsxfun(funh, this.component.img, b), ...
                                        'descrip', sprintf('NumericalNIfTId.bsxfun %s %s %s', ...
                                                           func2str(funh), this.fileprefix, mat2str(b)));
            end
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
            if (isa(b, 'mlfourd.INIfTI'))
                this = this.makeSimilar('img', mldivide(this.component.img, b.img), ...
                                        'descrip', sprintf('NumericalNIfTId.mldivide %s %s', ...
                                                           this.fileprefix, b.fileprefix));
            else
                this = this.makeSimilar('img', mldivide(this.component.img, b), ...
                                        'descrip', sprintf('NumericalNIfTId.mldivide %s %s', ...
                                                           this.fileprefix, mat2str(b)));
            end
        end
        function this = mrdivide(this, b)     
            if (isa(b, 'mlfourd.INIfTI'))
                this = this.makeSimilar('img', mrdivide(this.component.img, b.img), ...
                                        'descrip', sprintf('NumericalNIfTId.mrdivide %s %s', ...
                                                           this.fileprefix, b.fileprefix));
            else
                this = this.makeSimilar('img', mrdivide(this.component.img, b), ...
                                        'descrip', sprintf('NumericalNIfTId.mrdivide %s %s', ...
                                                           this.fileprefix, mat2str(b)));
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
            this = this.makeSimilar('img', sum(this.component.img, varargin{:}), ...
                                    'descrip', sprintf('NumericalNIfTId.sum %s %s', ...
                                                       this.fileprefix, mat2str(varargin{:})));  
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
        
        %% Using NIfTIdecorators
        
        function this = blurred(this, varargin)
            import mlfourd.*;
            b = BlurringNIfTId(this.component);
            b = b.blurred(varargin{:});
            this = NumericalNIfTId(b.component);
        end
        function this = masked(this, varargin)
            import mlfourd.*;
            m = MaskingNIfTId(this.component);
            m = m.masked(varargin{:});
            this = NumericalNIfTId(m.component);
        end
        function this = timeSummed(this)
            import mlfourd.*;
            d = DynamicNIfTId(this.component);
            d = d.timeSummed;
            %d.img = squeeze(d.img);
            this = NumericalNIfTId(d.component);
        end
        function this = volumeSummed(this)
            import mlfourd.*;
            d = DynamicNIfTId(this.component);
            d = d.volumeSummed;
            %d.img = squeeze(d.img);
            this = NumericalNIfTId(d.component);
        end
                
        %% Ctor
        
        function this = NumericalNIfTId(varargin)
            this = this@mlfourd.NIfTIdecoratorProperties(varargin{:});
            if (nargin == 1 && isa(varargin{1}, 'mlfourd.NumericalNIfTId'))
                this = this.component;
                return
            end
            this = this.append_descrip('decorated by NumericalNIfTId');
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
