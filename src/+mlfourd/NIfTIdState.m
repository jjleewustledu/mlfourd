classdef NIfTIdState < mlfourd.ImagingState
	%% NIFTIDSTATE has-an mlfourd.ImagingComponentState 
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.MGHState, 
    %             mlfourd.ImagingComponentState, mlfourd.ImagingLocation, mlpatterns.State

	%  $Revision$
 	%  was created 21-Oct-2015 00:44:09
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
	properties (Dependent)
        filename
        filepath
        fileprefix
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp
        
        mgh
        niftid	
        nifti	
        imcomponent	 
 	end 

	methods % GET/SET
        function f = get.filename(this)
            f = this.niftid_.filename;
        end
        function f = get.filepath(this)
            f = this.niftid_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.niftid_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.niftid_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.niftid_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.niftid_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.niftid_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.niftid_.fqfp;
        end    
        function f = get.mgh(this)            
            this.contextHandle_.changeState( ...
                mlfourd.MGHState.load(this.fqfilename, this.contextHandle_));
            f = this.contextHandle_.mgh;
        end  
        function f = get.niftid(this)
            f = this.niftid_;
            f = mlfourd.NIfTId(f);
        end
        function f = get.nifti(this)            
            this.contextHandle_.changeState( ...
                mlfourd.NIfTIState.load(this.fqfilename, this.contextHandle_));
            f = this.contextHandle_.nifti;
        end
        function f = get.imcomponent(this)            
            this.contextHandle_.changeState( ...
                mlfourd.ImagingComponentState.load(this.fqfilename, this.contextHandle_));
            f = this.contextHandle_.imcomponent;
        end        
        
        function this = set.filename(this, f)
            this.niftid_.filename = f;
        end        
        function this = set.filepath(this, f)
            this.niftid_.filepath = f;
        end
        function this = set.fileprefix(this, f)
            this.niftid_.fileprefix = f;
        end        
        function this = set.filesuffix(this, f)
            this.niftid_.filesuffix = f;
        end        
        function this = set.fqfilename(this, f)
            this.niftid_.fqfilename = f;
        end        
        function this = set.fqfileprefix(this, f)
            this.niftid_.fqfileprefix = f;
        end        
        function this = set.fqfn(this, f)
            this.fqfilename = f;
        end        
        function this = set.fqfp(this, f)
            this.fqfileprefix = f;
        end     
        function this = set.mgh(this, f)
            assert(isa(f, 'mlsurfer.MGH'));
            this.contextHandle_.changeState( ...
                mlfourd.MGHState.load(f, this.contextHandle_));
        end
        function this = set.niftid(this, f)
            assert(isa(f, 'mlfourd.INIfTI'));
            this.contextHandle_.changeState( ...
                mlfourd.NIfTIdState.load(f, this.contextHandle_));
        end
        function this = set.nifti(this, f)
            assert(isa(f, 'mlfourd.NIfTIInterface'));
            this.contextHandle_.changeState( ...
                mlfourd.NIfTIState.load(f, this.contextHandle_));
        end
        function this = set.imcomponent(this, f)
            assert(isa(f, 'mlfourd.ImagingComponent'));
            this.contextHandle_.changeState( ...
                mlfourd.ImagingComponentState.load(f, this.contextHandle_));
        end
    end 
    
	methods (Static)
        function this = load(obj, h)            
            import mlfourd.*;
            if (~isa(obj, 'mlfourd.INIfTI'))
                try
                    obj = NIfTId(obj);
                catch ME
                    error(ME.identifier, ...
                          'mlfourd.NIfTIdState.load does not support objects of type %s', class(obj));
                end
            end
            if (lstrfind(class(obj), 'mlfourd.NIfTIdecorator'))
                obj = obj.component;
            end
            this = NIfTIdState;
            this.niftid_ = obj;
            this.contextHandle_ = h;
        end
    end 
    
	methods
        function this = save(this)
            this.niftid_.save;
        end
        function this = saveas(this, f)
            this.niftid_ = this.niftid_.saveas(f);
        end
 	end 

    %% PROTECTED
    
    methods (Access = 'protected')
        function this = NIfTIdState
        end
    end
    
    %% PRIVATE
    
	properties (Access = 'private')
        niftid_
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

