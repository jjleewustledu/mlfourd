classdef PETNIfTIdState < mlfourd.ImagingState
	%% PETNIFTIDSTATE  

	%  $Revision$
 	%  was created 28-Jan-2017 21:05:05
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.1.0.441655 (R2016b) for MACI64.
 	

	properties (Dependent)
        cellComposite
        fourdfp
        mgh
        niftic
        niftid
        numericalNiftid
        petNiftid
 	end 

	methods %% GET
        function g = get.cellComposite(this)
            this.contexth_.changeState( ...
                mlfourd.CellCompositeState(this.concreteObj_, this.contexth_));
            g = this.contexth_.cellComposite;
        end
        function f = get.fourdfp(this)
            this.contexth_.changeState( ...
                mlfourd.FourdfpState(this.concreteObj_, this.contexth_));
            f = this.contexth_.fourdfp;
        end
        function g = get.mgh(this)
            this.contexth_.changeState( ...
                mlfourd.MGHState(this.concreteObj_, this.contexth_));
            g = this.contexth_.mgh;
        end
        function g = get.niftic(this)
            this.contexth_.changeState( ...
                mlfourd.NIfTIcState(this.concreteObj_, this.contexth_));
            g = this.contexth_.niftic;
        end   
        function g = get.niftid(this)
            g = this.dedecorateNIfTId(this.concreteObj_);
        end   
        function g = get.numericalNiftid(this)            
            this.contexth_.changeState( ...
                mlfourd.NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            g = this.contexth_.numericalNiftid;
        end
        function g = get.petNiftid(this)
            g = this.concreteObj_;
        end     
    end

	methods 
        function     addLog(this, varargin)
            this.concreteObj_.addLog(varargin{:});
        end
        
 		function this = PETNIfTIdState(obj, h)
            if (~isa(obj, 'mlfourd.PETNIfTIdState'))
                try
                    obj = mlpet.PETNIfTId(mlfourd.NIfTId(obj));
                catch ME
                    handexcept(ME, 'mlfourd:castingError', ...
                        'PETNIfTIdState.ctor does not support objects of type %s', class(obj));
                end
            end
            this.concreteObj_ = obj;
            this.contexth_ = h;
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end
