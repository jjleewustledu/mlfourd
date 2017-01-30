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
        fourdfp
        mgh
        niftic
        niftid
        numericalNiftid
        petNiftid
    end

	methods %% GET 
        function f = get.cellComposite(this)
            f = this.concreteObj_;
        end
        function f = get.fourdfp(this)
            this.contexth_.changeState( ...
                mlfourd.FourdfpState(this.concreteObj_.get(1), this.contexth_));
            f = this.contexth_.fourdfp;
        end
        function f = get.mgh(this)
            this.contexth_.changeState( ...
                mlfourd.MGHState(this.concreteObj_.get(1), this.contexth_));
            f = this.contexth_.mgh;
        end
        function f = get.niftic(this)  
            this.contexth_.changeState( ...
                mlfourd.NIfTIcState(this.concreteObj_, this.contexth_));
            f = this.contexth_.niftic;
        end
        function f = get.niftid(this)  
            import mlfourd.*;
            this.contexth_.changeState( ...
                NIfTIdState(NIfTId(this.concreteObj_.get(1)), this.contexth_));
            f = this.contexth_.niftid;
        end
        function g = get.numericalNiftid(this)
            this.contexth_.changeState( ...
                mlfourd.NumericalNIfTIdState(this.concreteObj_.get(1), this.contexth_));
            g = this.contexth_.numericalNiftid;
        end
        function f = get.petNiftid(this)
            this.contexth_.changeState( ...
                mlfourd.PETNIfTIdState(this.concreteObj_.get(1), this.contexth_));
            f = this.contexth_.petNiftid;
        end  
    end 
    
    methods 
        function this = CellCompositeState(obj, h)
            if (~isa(obj, 'mlpatterns.CellComposite'))
                if (~isa(obj, 'mlpatterns.Composite'))
                    obj = mlpatterns.CellComposite( ...
                        this.ensureCell(obj));
                end
                obj = this.composite2cellComposite(obj);
            end
            this.concreteObj_ = obj;
            this.contexth_ = h;
        end
    end
    
    %% PRIVATE
    
    methods (Static, Access = private)
        function obj = composite2cellComposite(obj)
            if (~isa(obj, 'mlpatterns.CellComposite'))
                assert(isa(obj, 'mlpatterns.Composite'));
                cc   = CellComposite;
                iter = obj.createIterator;
                while iter.hasNext
                    cc = cc.add(iter.next);
                end
                obj = cc;
            end
        end
        function obj  = ensureCell(obj)
            if (~iscell(obj))
                obj = cell(obj);
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

