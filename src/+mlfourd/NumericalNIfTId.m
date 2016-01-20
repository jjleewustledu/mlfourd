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
                                        'descrip', sprintf('NumericalNIfTId.bsxfun %s %s %g', ...
                                                           func2str(funh), this.fileprefix, b));
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
        function this = plus(this, b)
            this = this.bsxfun(@plus, b);
        end
        function this = power(this, b)
            this = this.bsxfun(@power, b);
        end
        function this = rem(this, b)
            this = this.bsxfun(@rem, b);
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
        
        function this = dipiqr(this)
            this = this.usxfun(@dipiqr);
        end
        function this = dipisfinite(this)
            this = this.usxfun(@dipisfinite);
        end
        function this = dipisinf(this)
            this = this.usxfun(@dipisinf);
        end
        function this = dipisnan(this)
            this = this.usxfun(@dipisnan);
        end
        function this = dipisreal(this)
            this = this.usxfun(@dipisreal);
        end
        function this = diplogprod(this)
            this = this.usxfun(@diplogprod);
        end
        function this = dipmad(this)
            this = this.usxfun(@dipmad);
        end        
        function this = dipmax(this)
            this = this.usxfun(@dipmax);
        end        
        function this = dipmean(this)
            this = this.usxfun(@dipmean);
        end        
        function this = dipmedian(this)
            this = this.usxfun(@dipmedian);
        end        
        function this = dipmin(this)
            this = this.usxfun(@dipmin);
        end   
        function this = dipmode(this)
            this = this.usxfun(@dipmode);
        end
        function this = dipprctile(this, b)
            this = this.bsxfun(@dipprctile, b);
        end
        function this = dipprod(this)
            this = this.usxfun(@dipprod);
        end        
        function this = dipquantile(this, b)
            this = this.bsxfun(@dipquantile, b);
        end
        function this = dipstd(this)
            this = this.usxfun(@dipstd);
        end                
        function this = dipsum(this)
            this = this.usxfun(@dipsum);
        end 
        function this = diptrimmean(this, b)
            this = this.bsxfun(@diptrimmean, b);
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
