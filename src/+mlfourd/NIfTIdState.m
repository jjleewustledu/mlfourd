classdef NIfTIdState < mlfourd.ImagingState
	%% NIFTIDSTATE has-an mlfourd.CellCompositeState 
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.MGHState, 
    %             mlfourd.CellCompositeState, mlfourd.FilenameState, mlpatterns.State, mlfourd.DoubleState

	%  $Revision$
 	%  was created 21-Oct-2015 00:44:09
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
	properties (Dependent)
        cellComposite
        mgh
        niftic
        niftid
        numericalNiftid
 	end 

	methods %% GET
        function g = get.cellComposite(this)
            this.contexth_.changeState( ...
                mlfourd.CellCompositeState(this.concreteObj_, this.contexth_));
            g = this.contexth_.cellComposite;
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
            g = this.concreteObj_;
        end   
        function g = get.numericalNiftid(this)
            this.contexth_.changeState( ...
                mlfourd.NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            g = this.contexth_.numericalNiftid;
        end
    end

    methods
        function        view(this, varargin)
            this.concreteObj_.freeview(varargin{:});
        end
        
        function this = NIfTIdState(obj, h)
            if (~isa(obj, 'mlfourd.NIfTId'))
                try
                    obj = mlfourd.NIfTId(this.dedecorateNIfTId(obj));
                catch ME
                    handexcept(ME, 'mlfourd:castingError', ...
                        'NIfTIdState.ctor does not support objects of type %s', class(obj));
                end
            end
            this.concreteObj_ = obj;
            this.contexth_ = h;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

