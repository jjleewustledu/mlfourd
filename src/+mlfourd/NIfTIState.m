classdef NIfTIState < mlfourd.ImagingState
    %% NIFTISTATE has-an mlfourd.ImagingComponentState
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.ImagingComponentState, mlfourd.ImagingLocation, mlpatterns.State
    
    %  $Revision: 2627 $
    %  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $
    %  by $Author: jjlee $,
    %  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $
    %  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/NIfTIState.m $,
    %  developed on Matlab 8.1.0.604 (R2013a)
    %  $Id: NIfTIState.m 2627 2013-09-16 06:18:10Z jjlee $

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
            f = this.imcomponentState_.filename;
        end
        function f = get.filepath(this)
            f = this.imcomponentState_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.imcomponentState_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.imcomponentState_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.imcomponentState_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.imcomponentState_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.imcomponentState_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.imcomponentState_.fqfp;
        end    
        function f = get.mgh(this)            
            this.contextHandle_.changeState( ...
                mlfourd.MGHState.load(this.fqfilename, this.contextHandle_));
            f = this.contextHandle_.mgh;
        end
        function f = get.niftid(this)            
            this.contextHandle_.changeState( ...
                mlfourd.NIfTIdState.load(this.fqfilename, this.contextHandle_));
            f = this.contextHandle_.niftid;
        end
        function f = get.nifti(this)
            f = this.imcomponentState_.imcomponent.cachedNext;
            f = mlfourd.NIfTI(f);
        end
        function f = get.imcomponent(this)            
            this.contextHandle_.changeState( ...
                mlfourd.ImagingComponentState.load(this.fqfilename, this.contextHandle_));
            f = this.contextHandle_.imcomponent;
        end        
        
        function this = set.filename(this, f)
            this.imcomponentState_.filename = f;
        end        
        function this = set.filepath(this, f)
            this.imcomponentState_.filepath = f;
        end
        function this = set.fileprefix(this, f)
            this.imcomponentState_.fileprefix = f;
        end        
        function this = set.filesuffix(this, f)
            this.imcomponentState_.filesuffix = f;
        end        
        function this = set.fqfilename(this, f)
            this.imcomponentState_.fqfilename = f;
        end        
        function this = set.fqfileprefix(this, f)
            this.imcomponentState_.fqfileprefix = f;
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
            if (~isa(obj, 'mlfourd.NIfTIInterface'))
                try
                    obj = NIfTI(obj);
                catch ME
                    error(ME.identifier, ...
                          'mlfourd.NIfTIState.load does not support objects of type %s', class(obj));
                end
            end
            this = NIfTIState;
            this.imcomponentState_ = ImagingComponentState.load(obj, h);
            this.contextHandle_ = h;
        end
    end 
    
	methods
        function this = save(this)
            this.imcomponentState_.save;
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(this.imcomponentState_.fqfilename, this.contextHandle_));
        end
        function this = saveas(this, f)
            this.imcomponentState_ = this.imcomponentState_.saveas(f);
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(this.imcomponentState_.fqfilename, this.contextHandle_));
        end
 	end 

    %% PROTECTED
    
    methods (Access = 'protected')
        function this = NIfTIState
        end
    end
    
    %% PRIVATE
    
	properties (Access = 'private')
        imcomponentState_
    end 
    
    %  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
end

