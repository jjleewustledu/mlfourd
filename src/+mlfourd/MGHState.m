classdef MGHState < mlfourd.ImagingState 
	%% MGHSTATE   
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState,
    %             mlfourd.CellCompositeState, mlfourd.FilenameState, mlpatterns.State, mlfourd.DoubleState.
    %  TODO:   setting filenames should not change state to FilenameState.

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
    
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
            f = this.concreteObj_;
        end
        function f = get.niftic(this)
            this.contexth_.changeState( ...
                mlfourd.NIfTIState(this.concreteObj_, this.contexth_));
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
        function this = MGHState(obj, h)
            if (~isa(obj, 'mlsurfer.MGH'))
                try
                    obj = mlsurfer.MGH(obj);
                catch ME
                    handexcept(ME.identifier, 'mlfourd:castingError', ...
                        'mlfourd.MGHState.load does not support objects of type %s', class(obj));
                end
            end
            this.concreteObj_ = obj; 
            this.contexth_ = h;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

