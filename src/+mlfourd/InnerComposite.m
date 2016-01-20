classdef InnerComposite 
	%% INNERCOMPOSITE adapts mlpattern.Composite interfaces for classes of mlfourd. 
    %  It is designed for efficiency over safety.

	%  $Revision$
 	%  was created 16-Jan-2016 17:59:46
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		composite
    end
    
    properties (Dependent) 
        length
    end
    
    methods %% GET
        function g = get.length(this)
            g = this.composite.length;
        end
    end

	methods		  
 		function this = InnerComposite(c)
            assert(isa(c, 'mlpatterns.Composite'));
            this.composite = c;
        end
        
        function this = setter(this, fldname, in)
            iter = this.composite.createIterator;
            while (iter.hasNext)
                
            end
            
            
            if (~(iscell(in) || isa(in, 'mlpatterns.CellComposite')))
                in = repmat({in}, 1, this.composite_.length);
            end
            for c = 1:this.composite_.length
                this.composite_{c}.(fldname) = in{c};
            end
        end
        function out = getter(this, fldname)
            out = cell(1, this.composite_.length);            
            for c = 1:this.composite_.length
                out{c} = this.composite_{c}.(fldname);
            end
        end
        function this = fevalComposite(this, funname, args)    
            if (exist('args','var')) 
                if (~iscell(args))
                    args = repmat({args}, 1, this.composite_.length);
                end
                for c = 1:this.composite_.length
                    this.composite_{c} = this.composite_{c}.(funname)(args{c});
                end
                return
            end
            for c = 1:this.composite_.length
                this.composite_{c} = this.composite_{c}.(funname);
            end
        end
        function out = fevalCompositeIn0(this, funname)
            out = cell(size(this.composite_));
            for c = 1:this.composite_.length
                out{c} = this.composite_{c}.(funname);
            end            
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

