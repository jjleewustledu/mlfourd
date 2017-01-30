classdef DoubleState < mlfourd.ImagingState
	%% DOUBLESTATE  
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.CellCompositeState, mlfourd.FilenameState, mlpatterns.State.
    %  TODO:      setting filenames should not change state to FilenameState.

	%  $Revision$
 	%  was created 31-Dec-2015 02:08:43
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64. 	

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
        function f = get.cellComposite(this)
            this.contexth_.changeState( ...
                mlfourd.CellCompositeState(this.concreteObj_, this.contexth_));
            f = this.contexth_.composite;
        end
        function f = get.fourdfp(this)
            this.contexth_.changeState( ...
                mlfourd.FourdfpState(this.concreteObj_, this.contexth_));
            f = this.contexth_.fourdfp;
        end
        function f = get.mgh(this)
            this.contexth_.changeState( ...
                mlfourd.MGHState(this.concreteObj_, this.contexth_));
            f = this.contexth_.mgh;
        end
        function f = get.niftic(this)
            this.contexth_.changeState( ...
                mlfourd.NIfTIcState(this.concreteObj_, this.contexth_));
            f = this.contexth_.niftic;
        end
        function g = get.niftid(this)
            this.contexth_.changeState( ...
                mlfourd.NIfTIdState(this.concreteObj_, this.contexth_));
            g = this.contexth_.niftid;
        end
        function g = get.numericalNiftid(this)
            this.contexth_.changeState( ...
                mlfourd.NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            g = this.contexth_.numericalNiftid;
        end
        function f = get.petNiftid(this)
            this.contexth_.changeState( ...
                mlfourd.PETNIfTIdState(this.concreteObj_, this.contexth_));
            f = this.contexth_.petNiftid;
        end
    end 
     
    methods 
 		function this = DoubleState(obj, h)
            try
                obj = double(obj);
            catch ME
                handexcept(ME, 'mlfourd:castingError', ...
                    'DoubleState.load does not support objects of type %s', class(obj));
            end
            this.concreteObj_ = obj;
            this.contexth_ = h;
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

