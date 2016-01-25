classdef (Abstract) ImagingState < mlfourd.NIfTIIO
	%% IMAGINGSTATE is the parent class for all internal states used by ImagingContext in a state design pattern.
    %  See also:  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.CellCompositeState, mlfourd.FilenameState, mlpatterns.State, mlfourd.DoubleState.

	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingState.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: ImagingState.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	 
	properties (Abstract)
        cellComposite
        mgh
        niftic
        niftid
        numericalNiftid
    end
    
    properties (Dependent)
        filename
        filepath
        fileprefix
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp
        noclobber
    end
    
    methods %% GET
        function f = get.filename(this)
            f = this.concreteObj_.filename;
        end
        function f = get.filepath(this)
            f = this.concreteObj_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.concreteObj_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.concreteObj_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.concreteObj_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.concreteObj_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.concreteObj_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.concreteObj_.fqfp;
        end
        function f = get.noclobber(this)
            f = this.concreteObj_.noclobber;
        end
        
        function this = set.filename(this, f)
            this.concreteObj_.filename = f;
        end  
        function this = set.filepath(this, f)
            this.concreteObj_.filepath = f;
        end  
        function this = set.fileprefix(this, f)
            this.concreteObj_.fileprefix = f;
        end        
        function this = set.filesuffix(this, f)
            this.concreteObj_.filesuffix = f;
        end        
        function this = set.fqfilename(this, f)
            this.concreteObj_.fqfilename = f;
        end        
        function this = set.fqfileprefix(this, f)
            this.concreteObj_.fqfileprefix = f;
        end        
        function this = set.fqfn(this, f)
            this.concreteObj_.fqfilename = f;
        end        
        function this = set.fqfp(this, f)
            this.concreteObj_.fqfileprefix = f;
        end     
        function this = set.noclobber(this, f)
            this.concreteObj_.noclobber = f;
        end
    end    
        
    methods (Static)
        function obj = dedecorateNIfTId(obj)
            if (isa(obj, 'mlfourd.INIfTId'))
                while (isa(obj, 'mlfourd.INIfTIdecorator'))
                    obj = obj.component;
                end
                return
            end
        end
    end
    
    methods
        function a = atlas(this, varargin)
            %% ATLAS
            %  @param [varargin] are passed to NIfTIcState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NIfTIcState(this.concreteObj_, this.contexth_));
            a = this.contexth_.atlas(varargin{:});
        end
        function a = binarized(this, varargin)
            %% BINARIZED
            %  @param [varargin] are passed to NumericalNIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            a = this.contexth_.binarized(varargin{:});
        end
        function a = blurred(this, varargin)
            %% BLURRED
            %  @param [varargin] are passed to NumericalNIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            a = this.contexth_.blurred(varargin{:});
        end
        function a = masked(this, varargin)
            %% MASKED
            %  @param [varargin] are passed to NumericalNIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            a = this.contexth_.masked(varargin{:});
        end
        function a = maskedByZ(this, varargin)
            %% MASKEDBYZ
            %  @param [varargin] are passed to NumericalNIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            a = this.contexth_.maskedByZ(varargin{:});
        end
        function c    = char(this)
            c = char(this.concreteObj_);
        end
        function        disp(this)
            disp(this.concreteObj_);
        end
        function d    = double(this)
            d = double(this.concreteObj_);
        end
        function        save(this)
            if (~strcmp(this.contexth_.stateTypeclass, 'mlfourd.FilenameState'))
                this.concreteObj_.save;
                this.contexth_.changeState( ...
                    mlfourd.FilenameState(this.concreteObj_, this.contexth_));
            end
        end
        function this = saveas(this, f)
            this.concreteObj_ = this.concreteObj_.saveas(f);
        end
        function a = thresh(this, varargin)
            %% THRESH
            %  @param [varargin] are passed to NumericalNIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            a = this.contexth_.thresh(varargin{:});
        end
        function a = threshp(this, varargin)
            %% THRESHP
            %  @param [varargin] are passed to NumericalNIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            a = this.contexth_.threshp(varargin{:});
        end
        function a = timeSummed(this, varargin)
            %% TIMESUMMED
            %  @param [varargin] are passed to NumericalNIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            a = this.contexth_.timeSummed(varargin{:});
        end
        function a = uthresh(this, varargin)
            %% UTHRESH
            %  @param [varargin] are passed to NumericalNIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            a = this.contexth_.uthresh(varargin{:});
        end
        function a = uthreshp(this, varargin)
            %% UTHRESHP
            %  @param [varargin] are passed to NumericalNIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            a = this.contexth_.uthreshp(varargin{:});
        end
        function a = volumeSummed(this, varargin)
            %% VOLUMESUMMED
            %  @param [varargin] are passed to NumericalNIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                NumericalNIfTIdState(this.concreteObj_, this.contexth_));
            a = this.contexth_.volumeSummed(varargin{:});
        end
        function        view(this, varargin)
            %% VIEW
            %  @param [varargin] are passed to NIfTIdState after a state-change
            
            import mlfourd.*;
            this.contexth_.changeState( ...
                FilenameState(this.concreteObj_, this.contexth_));
            this.contexth_.view(varargin{:});
        end
    end
    
    methods (Hidden)
        function this = changeState(this, s)
            this.contexth_.changeState(s);
        end
    end
    
    %% PROTECTED
    
    properties (Access = protected)
        contexth_
        concreteObj_
    end
    
    methods (Access = protected)
        function this = ImagingState % prevents direct instantiation
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

