classdef NumericalNIfTIc < mlfourd.NumericalNIfTId
	%% NUMERICALNIFTIC  

	%  $Revision$
 	%  was created 16-Jan-2016 12:27:16
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	 
    methods (Static)        
        function this = load(varargin)
            import mlfourd.*;
            this = NumericalNIfTId(NIfTIc.load(varargin{:}));
        end
    end

	methods 
        function this = usxfun(this, funh)
            %% USXFUN is bsxfun with only a function handle as argument.
            %  @param funh  is a function_handle.
            %  @return this is modified.
            %  @throws MATLAB:bsxfun:nonnumericOperands

            copy = this.component.makeEmpty; % Composite
            iter = this.component.createIterator;
            while (iter.hasNext)
                cache = iter.next; % INIfTI                
                cache = cache.makeSimilar('img', funh(cache.img), ...
                                          'descrip', sprintf('NumericalNIfTId.usxfun %s %s', ...
                                                             func2str(funh), cache.fileprefix));
                copy  = copy.add(cache);                
            end
            this.component_ = copy;            
        end
        function this = bsxfun(this, funh, b)
            %% BSXFUN overloads bsxfun for INIfTI
            %  @param funh is a function_handle.
            %  @param b    is a scalar or INIfTI object.
            %  @return c   is a NumericalNIfTId object.
            %  @throws MATLAB:bsxfun:nonnumericOperands
            
            copy = this.component.makeEmpty; % Composite
            iter = this.component.createIterator;
            while (iter.hasNext)
                cache = iter.next; % INIfTI
                if (isa(b, 'mlfourd.INIfTI'))
                    cache = cache.makeSimilar('img', bsxfun(funh, cache.component.img, b.img), ...
                                              'descrip', sprintf('NumericalNIfTId.bsxfun %s %s %s', ...
                                                                 func2str(funh), cache.fileprefix, b.fileprefix));
                else
                    cache = cache.makeSimilar('img', bsxfun(funh, this.component.img, b), ...
                                              'descrip', sprintf('NumericalNIfTId.bsxfun %s %s %g', ...
                                                                 func2str(funh), this.fileprefix, b));
                end                                
                copy  = copy.add(cache);                
            end
            this.component_ = copy; 
        end
		  
 		function this = NumericalNIfTIc(varargin)
 			this = this@mlfourd.NumericalNIfTId(varargin{:});
            this = this.append_descrip('decorated by NumericalNIfTIc');
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

