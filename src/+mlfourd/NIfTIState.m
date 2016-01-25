classdef NIfTIState < mlfourd.ImagingState
    %% NIFTISTATE 
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.CellCompositeState, mlfourd.ImagingLocation, mlpatterns.State, mlfourd.DoubleState.
    
    %  $Revision: 2627 $
    %  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $
    %  by $Author: jjlee $,
    %  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $
    %  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/NIfTIState.m $,
    %  developed on Matlab 8.1.0.604 (R2013a)
    %  $Id: NIfTIState.m 2627 2013-09-16 06:18:10Z jjlee $

	properties (Dependent)
        cellComposite
        mgh
        niftic
        niftid
        numericalNiftid
    end

	methods %% GET
        function f = get.cellComposite(this)            
            this.contexth_.changeState( ...
                mlfourd.CellCompositeState(this.concreteObj_, this.contexth_));
            f = this.contexth_.cellComposite;
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
        function f = get.niftid(this)            
            this.contexth_.changeState( ...
                mlfourd.NIfTIdState(this.concreteObj_, this.contexth_));
            f = this.contexth_.niftid;
        end
        function g = get.numericalNiftid(this)
            this.contexth_.changeState( ...
                mlfourd.NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            g = this.contexth_.numericalNiftid;
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
            this.concreteObj_ = obj;
            this.contexth_ = h;
        end
    end
    
    %  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
end

