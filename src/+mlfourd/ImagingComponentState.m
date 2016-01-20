classdef ImagingComponentState < mlfourd.ImagingState
	%% IMAGINGCOMPONENTSTATE   
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.FilenameState, mlpatterns.State, mlfourd.DoubleState.
    %  TODO:      setting filenames should not change state to FilenameState.

	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingComponentState.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: ImagingComponentState.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	 
	properties (Dependent)
        composite
        mgh
        nifti
        niftid
    end

	methods %% GET  
        function f = get.composite(this)
            f = this.concreteState_;
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
            this.contextH_.changeState( ...
                mlfourd.NIfTIdState.load(this.concreteState_, this.contextH_));
            f = this.contextH_.niftid;
        end
    end 
    
    methods (Static)
        function this = load(varargin)
            this = mlfourd.ImagingComponentState(varargin{:});
        end
    end

    %% PROTECTED
    
    methods (Access = 'protected')
        function this = ImagingComponentState(obj, h)
            if (~isa(obj, 'mlfourd.ImagingComponent'))
                try
                    obj = mlfourd.ImagingComponent.load(obj);
                catch ME
                    handexcept(ME, 'mlfourd:castingError', ...
                        'ImagingComponentState.load does not support objects of type %s', class(obj));
                end
            end
            this.concreteState_ = obj;
            this.contextH_ = h;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

