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
        mgh
        niftic
        niftid
 	end

    methods %% GET
        function f = get.cellComposite(this)            
            this.contexth_.changeState( ...
                mlfourd.CellCompositeState.load(this.concreteObj_, this.contexth_));
            f = this.contexth_.composite;
        end
        function f = get.mgh(this)
            this.contexth_.changeState( ...
                mlfourd.MGHState.load(this.concreteObj_, this.contexth_));
            f = this.contexth_.mgh;
        end
        function f = get.niftic(this)            
            this.contexth_.changeState( ...
                mlfourd.NIfTIState.load(this.concreteObj_, this.contexth_));
            f = this.contexth_.niftic;
        end
        function f = get.niftid(this)
            f = this.concreteObj_;
        end  
    end 
     
    methods 
 		function this = DoubleState(obj, h)
            this.concreteObj_ = mlfourd.NIfTId(obj);
            this.contexth_ = h; 
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

