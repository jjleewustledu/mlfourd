classdef MGHState < mlfourd.ImagingState 
	%% MGHSTATE   
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState,
    %             mlfourd.ImagingComponentState, mlfourd.FilenameState, mlpatterns.State, mlfourd.DoubleState.
    %  TODO:   setting filenames should not change state to FilenameState.

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
    
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
            f = this.concreteState_;
        end
        function f = get.nifti(this)
            this.contextH_.changeState( ...
                mlfourd.NIfTIState.load(this.concreteState_, this.contextH_));
            f = this.contextH_.nifti;
        end
        function f = get.niftid(this)
            this.contextH_.changeState( ...
                mlfourd.NIfTIdState.load(this.concreteState_, this.contextH_));
            f = this.contextH_.niftid;
        end
    end 
    
    methods (Static)
        function this = load(varargin)
            this = mlfourd.MGHState(varargin{:});
        end
    end

    %% PROTECTED
    
    methods (Access = 'protected')
        function this = MGHState(obj, h)
            if (~isa(obj, 'mlsurfer.MGH'))
                try
                    obj = mlsurfer.MGH.load(obj);
                catch ME
                    handexcept(ME.identifier, 'mlfourd:castingError', ...
                        'mlfourd.MGHState.load does not support objects of type %s', class(obj));
                end
            end
            this.concreteState_ = obj; 
            this.contextH_ = h;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

