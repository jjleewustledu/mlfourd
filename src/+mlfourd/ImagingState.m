classdef (Abstract) ImagingState < mlio.IOInterface
	%% IMAGINGSTATE is the parent class for all internal states used by ImagingContext in a state design pattern.
    %  See also:  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.ImagingComponentState, mlfourd.FilenameState, mlpatterns.State, mlfourd.DoubleState.

	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingState.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: ImagingState.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	 
	properties (Abstract)
        composite
        mgh
        nifti
        niftid
    end
    
    methods (Abstract)
%        g    = get(this, locs)
%        l    = length(this)
%        this = remove(this, locs)
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
    end
    
    methods %% GET
        function f = get.filename(this)
            f = this.concreteState_.filename;
        end
        function f = get.filepath(this)
            f = this.concreteState_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.concreteState_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.concreteState_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.concreteState_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.concreteState_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.concreteState_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.concreteState_.fqfp;
        end
        
        function this = set.filename(this, f)
            this.concreteState_.filename = f;
        end  
        function this = set.filepath(this, f)
            this.concreteState_.filepath = f;
        end  
        function this = set.fileprefix(this, f)
            this.concreteState_.fileprefix = f;
        end        
        function this = set.filesuffix(this, f)
            this.concreteState_.filesuffix = f;
        end        
        function this = set.fqfilename(this, f)
            this.concreteState_.fqfilename = f;
        end        
        function this = set.fqfileprefix(this, f)
            this.concreteState_.fqfileprefix = f;
        end        
        function this = set.fqfn(this, f)
            this.concreteState_.fqfilename = f;
        end        
        function this = set.fqfp(this, f)
            this.concreteState_.fqfileprefix = f;
        end
    end    
    
    methods
        function this = add(this, varargin)            
            this.contextH_.changeState( ...
                mlfourd.ImagingComponentState.load(this.concreteState_, this.contextH_));
            cmps = this.contextH_.composite;
            this.concreteState_ = cmps.add(varargin{:});
        end
        function c    = char(this)
            c = char(this.concreteState_);
        end
        function        disp(this)
            disp(this.concreteState_);
        end
        function d    = double(this)
            d = double(this.concreteState_);
        end
        function        save(this)
            if (~strcmp(this.contextH_.stateTypeclass, 'mlfourd.FilenameState'))
                this.concreteState_.save;
                this.contextH_.changeState( ...
                    mlfourd.FilenameState(this.concreteState_, this.contextH_));
            end
        end
        function this = saveas(this, f)
            this.concreteState_ = this.concreteState_.saveas(f);
        end
        function        view(this)
            this.concreteState_.freeview;
        end
    end
    
    methods (Hidden)
        function this = changeState(this, s)
            this.contextH_.changeState(s);
        end
    end
    
    %% PROTECTED
    
    properties (Access = protected)
        contextH_
        concreteState_
    end
    
    methods (Access = protected)
        function this = ImagingState % prevents direct instantiation
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

