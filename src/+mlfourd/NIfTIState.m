classdef NIfTIState < mlfourd.ImagingState
    %% NIFTISTATE 
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.ImagingComponentState, mlfourd.ImagingLocation, mlpatterns.State, mlfourd.DoubleState.
    
    %  $Revision: 2627 $
    %  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $
    %  by $Author: jjlee $,
    %  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $
    %  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/NIfTIState.m $,
    %  developed on Matlab 8.1.0.604 (R2013a)
    %  $Id: NIfTIState.m 2627 2013-09-16 06:18:10Z jjlee $

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
            f = this.concreteState_;
        end
        function f = get.niftid(this)            
            this.contextH_.changeState( ...
                mlfourd.NIfTIdState.load(this.concreteState_, this.contextH_));
            f = this.contextH_.niftid;
        end
    end
    
    methods (Static)
        function this = load(varargin)
            this = mlfourd.NIfTIState(varargin{:});
        end
    end
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function this = NIfTIState(obj, h)
            if (~isa(obj, 'mlfourd.NIfTI'))
                try
                    obj = mlfourd.NIfTI(obj);
                catch ME
                    handexcept(ME, 'mlfourd:castingError', ...
                        'NIfTIState.ctor does not support objects of type %s', class(obj));
                end
            end
            this.concreteState_ = obj;
            this.contextH_ = h;
        end
    end
    
    %  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
end

