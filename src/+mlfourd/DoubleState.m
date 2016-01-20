classdef DoubleState < mlfourd.ImagingState
	%% DOUBLESTATE  
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.ImagingComponentState, mlfourd.FilenameState, mlpatterns.State.
    %  TODO:      setting filenames should not change state to FilenameState.

	%  $Revision$
 	%  was created 31-Dec-2015 02:08:43
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64. 	

	properties (Dependent)
        composite
        mgh
        nifti
        niftid
 	end

    methods %% GET
        function f = get.composite(this)            
            this.contextH_.changeState( ...
                mlfourd.ImagingComponentState.load(this.concreteState_, this.contextH_));
            f = this.contextH_.composite;
        end
        function f = get.mgh(this)
            this.contextH_.changeState( ...
                mlfourd.MGHState.load(this.concreteState_, this.contextH_));
            f = this.contextH_.mgh;
        end
        function f = get.nifti(this)            
            this.contextH_.changeState( ...
                mlfourd.NIfTIState.load(this.concreteState_, this.contextH_));
            f = this.contextH_.nifti;
        end
        function f = get.niftid(this)
            f = this.concreteState_;
        end  
    end 
    
    methods (Static)
        function this = load(varargin)
            this = mlfourd.DoubleState(varargin{:});
        end
    end
        
    %% PROTECTED
    
    methods (Access = protected)
 		function this = DoubleState(obj, h)
            this.concreteState_ = mlfourd.NIfTId(obj);
            this.contextH_ = h; 
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

