classdef CellCompositeState < mlfourd.ImagingState
	%% CellCompositeState   
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.FilenameState, mlpatterns.State, mlfourd.DoubleState.

	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $,
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: CellCompositeState.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	 
	properties (Dependent)
        cellComposite
        mgh
        niftic
        niftid
        numericalNiftid
    end

	methods %% GET  
        function f = get.cellComposite(this)
            f = this.concreteObj_;
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
            this.contexth_.changeState( ...
                mlfourd.NIfTIdState.load(this.concreteObj_, this.contexth_));
            f = this.contexth_.niftid;
        end
    end 
    
    methods (Static)
        function this = load(varargin)
            this = mlfourd.CellCompositeState(varargin{:});
        end
    end
    
    methods 
        function this = CellCompositeState(obj, h)
            if (~isa(obj, 'mlfourd.ImagingComponent'))
                try
                    obj = mlfourd.ImagingComponent.load(obj);
                catch ME
                    handexcept(ME, 'mlfourd:castingError', ...
                        'CellCompositeState.load does not support objects of type %s', class(obj));
                end
            end
            this.concreteObj_ = obj;
            this.contexth_ = h;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

