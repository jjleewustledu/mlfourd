classdef ImagingContext < handle
	%% IMAGINGCONTEXT provides the context for a state design pattern, 
    %  wrapping filesystem I/O and NIfTIInterfaces.   Cf. properties mgh, nifti, imcomponent, stateTypeClass
    %  See also:  mlfourd.ImagingState, mlpatterns.State

	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingContext.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: ImagingContext.m 2627 2013-09-16 06:18:10Z jjlee $ 

    
	properties (Dependent)
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp
        fqxfm
        
        mgh
        nifti
        imcomponent
        stateTypeclass
    end
    
	methods %% GET/SET
        function f = get.filename(this)
            f = this.state_.filename;
        end
        function f = get.filepath(this)
            f = this.state_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.state_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.state_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.state_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.state_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.state_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.state_.fqfp;
        end
        function f = get.fqxfm(this)
            f = [this.fqfileprefix mlfsl.FlirtVisitor.XFM_SUFFIX];
        end
        function f = get.mgh(this)
            f = this.state_.mgh;
        end
        function f = get.nifti(this)
            f = this.state_.nifti;
        end
        function f = get.imcomponent(this)
            f = this.state_.imcomponent;
        end
        function set.filename(this, f)
            this.state_.filename = f;
        end
        function set.filepath(this, f)
            this.state_.filepath = f;
        end        
        function set.fileprefix(this, f)
            this.state_.fileprefix = f;
        end        
        function set.filesuffix(this, f)
            this.state_.filesuffix = f;
        end        
        function set.fqfilename(this, f)
            this.state_.fqfilename = f;
        end        
        function set.fqfileprefix(this, f)
            this.state_.fqfileprefix = f;
        end        
        function set.fqfn(this, f)
            this.state_.fqfn = f;
        end        
        function set.fqfp(this, f)
            this.state_.fqfp = f;
        end
        function set.fqxfm(this, f)
            [pth,fp] = filepartsx(f, mlfsl.FlirtVisitor.XFM_SUFFIX);
            this.state_.fqfileprefix = fullfile(pth, fp);
        end
        function set.mgh(this, f)
            this.state_.mgh = f;
        end
        function set.nifti(this, f)
            this.state_.nifti = f;
        end        
        function set.imcomponent(this, f)
            this.state_.imcomponent = f;
        end
        
        function c = get.stateTypeclass(this)
            c = class(this.state_);
        end        
    end 

    methods (Static)
        function this = load(obj)
            %% LOAD
            %  Usage:  this = ImagingContedxt.load(object)
            %                                    ^ fileprefix, filename, NIfTI, ImagingComponent
            
            this = mlfourd.ImagingContext(obj);
        end
    end
    
	methods 
        function     save(this) 
            this.state_.save;
        end
        function     saveas(this,fileprefix)
            this.state_.saveas(fileprefix);
        end
        function     changeState(this, s)
            %% CHANGESTATE should be accessed by ImagingState subclasses or debuggers
            %  Usage:  this.changeState(imagingStateObject)
            
            assert(isa(s, 'mlfourd.ImagingState'));
            this.state_ = s;
        end
        function f = char(this)
            f = this.fqfilename;
        end
        function c = clone(this)
            c = mlfourd.ImagingContext(this);
        end
        function     forceState(this, stype)
            %% FORCESTATE
            %  Usage:  this.forceState(name_of_stateTypeclass)
            %                          ^ subclasses of ImagingState, as string
            
            assert(ischar(stype));
            stype = lower(stype);
            import mlfourd.*;
            if (lstrfind(stype, 'location'))
                this.state_ = ImagingLocation.load(this.fqfilename, this);
            end
            if (lstrfind(stype, 'mgh'))
                this.state_ = MGHState.load(this.fqfilename, this);
            end
            if (lstrfind(stype, 'nifti'))
                this.state_ = NIfTIState.load(this.nifti, this);
            end
            if (lstrfind(stype, 'component'))
                this.state_ = ImagingComponentState.load(this.imcomponent, this);
            end
        end
    end
    
    methods (Access = 'protected')
        function this = ImagingContext(obj)
            import mlfourd.*;
            switch (class(obj))
                case 'char'
                    if (lstrfind(obj, '.mgz') || lstrfind(obj, '.mgh')) %%% KLUDGE
                        this.state_ = MGHState.load(obj, this); 
                        return
                    end
                    this.state_ = ImagingLocation.load(obj, this);
                case 'mlsurfer.MGH'
                    this.state_ = MGHState.load(obj, this);
                case 'mlfourd.ImagingContext'
                    this.state_ = obj.state_;
                case {'mlfourd.NIfTI' 'mlfourd.BlurredNIfTI' 'mlfourd.NiiBrowser'}
                        this.state_ = NIfTIState.load(obj, this); 
                otherwise
                    if (isa(obj, 'mlfourd.ImagingComponent'))
                        this.state_ = ImagingComponentState.load(obj, this); return; end
                    error('mlfourd:unsupportedTypeclass', 'class(ImagingContext.ctor.obj)->%s', class(obj));
            end            
        end
    end
    
    properties (Access = 'private')
        state_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

