classdef NIfTIdState < mlfourd.ImagingState
	%% NIFTIDSTATE has-an mlfourd.CellCompositeState 
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.MGHState, 
    %             mlfourd.CellCompositeState, mlfourd.FilenameState, mlpatterns.State, mlfourd.DoubleState
    %  @deprecated

	%  $Revision$
 	%  was created 21-Oct-2015 00:44:09
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
	methods
        
        %% state changes
        
        function f = fourdfp(this)
            this.contexth_.changeState( ...
                mlfourd.FourdfpState(this.concreteObj_, this.contexth_));
            f = this.contexth_.fourdfp;
        end
        function g = mgh(this)
            this.contexth_.changeState( ...
                mlfourd.MGHState(this.concreteObj_, this.contexth_));
            g = this.contexth_.mgh;
        end
        function g = niftid(this)
            g = this.concreteObj_;
        end   
        function g = numericalNiftid(this)
            this.contexth_.changeState( ...
                mlfourd.NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            g = this.contexth_.numericalNiftid;
        end
        
        %%
        
        function        addImgrec(this, varargin)
            this.concreteObj_.addImgrec(varargin{:});
        end
        function        addLog(this, varargin)
            this.concreteObj_.addLog(varargin{:});
        end
        function lg =   getLog(this)
            lg = this.concreteObj_.logger;
        end
        function r =    rank(this)
            r = this.concreteObj_.rank;
        end
        function this = setNoclobber(this, s)
            this.concreteObj_.noclobber = logical(s);
        end
        function tf =   sizeEq(this, varargin)
            inSize = varargin{:}.niftid.size;
            thisSize = this.concreteObj_.size;
            tf = all(thisSize(1:3) == inSize(1:3));
        end
        function tf =   sizeGt(this, varargin)
            inSize = varargin{:}.niftid.size;
            thisSize = this.concreteObj_.size;
            tf = prod(thisSize(1:3)) > prod(inSize(1:3));
        end
        function tf =   sizeLt(this, varargin)
            inSize = varargin{:}.niftid.size;
            thisSize = this.concreteObj_.size;
            tf = prod(thisSize(1:3)) < prod(inSize(1:3));
        end
        function        view(this, varargin)
            this.concreteObj_.viewer = this.viewer;
            this.concreteObj_.view(varargin{:});
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

