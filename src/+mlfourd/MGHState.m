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
        fourdfp
        mgh
        niftic
        niftid
        numericalNiftid
        petNiftid
    end 
    
	methods %% GET
        function f = get.cellComposite(this)
            this.contexth_.changeState( ...
                mlfourd.CellCompositeState(this.concreteObj_, this.contexth_));
            f = this.contexth_.cellComposite;
        end
        function f = get.fourdfp(this)
            this.contexth_.changeState( ...
                mlfourd.FourdfpState(this.concreteObj_, this.contexth_));
            f = this.contexth_.fourdfp;
        end
        function f = get.mgh(this)
            f = this.concreteObj_;
        end
        function f = get.niftic(this)
            this.contexth_.changeState( ...
                mlfourd.NIfTIcState(this.concreteObj_, this.contexth_));
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
        function f = get.petNiftid(this)
            this.contexth_.changeState( ...
                mlfourd.PETNIfTIdState(this.concreteObj_, this.contexth_));
            f = this.contexth_.petNiftid;
        end
    end
    
    methods (Static)
        function niifn = mgh2nii(mghfn)
            fqfp  = mghfn(1:end-length(mlsurfer.MGH.MGH_EXT));
            niifn = [fqfp '.nii'];
            assert(lexist(mghfn, 'file'));
            mlfourd.MGHState.mri_convert(mghfn, niifn);
        end
        function f2 = mri_convert(f1, f2)
            assert(lexist(f1, 'file'), sprintf('MGH.mri_convert:  file not found:  %s', f1));
            if (~exist('f2', 'var'))
                [~,~,fsuffix] = myfileparts(f1);
                if (strcmp('.nii.gz', fsuffix) || strcmp('.nii', fsuffix))
                    f2 = filename( ...
                         fileprefix(f1, fsuffix), mlsurfer.MGH.MGH_EXT); 
                end
                if (strcmp('.mgz', fsuffix)    || strcmp('.mgh', fsuffix))
                    f2 = filename( ...
                         fileprefix(f1, fsuffix), mlfourd.NIfTI.FILETYPE_EXT); 
                end
            end
            mlbash(sprintf('mri_convert %s %s', f1, f2));
        end
        function mghfn = nii2mgh(niifn)
            fqfp  = niifn(1:end-length('.nii'));
            mghfn = [fqfp mlsurfer.MGH.MGH_EXT];
            assert(lexist(niifn, 'file'));
            mlfourd.MGHState.mri_convert(niifn, mghfn);
        end
    end
    
    methods
        function       addLog(this, varargin)
            this.concreteObj_.addLog(varargin{:});
        end
        function       view(this, varargin)
            this.concreteObj_.freeview(varargin{:});
        end
        
        function this = MGHState(obj, h)
            if (~isa(obj, 'mlsurfer.MGH'))
                try
                    import mlsurfer.* mlfourd.*;
                    if (ischar(obj))
                        [~,~,x] = fileparts(obj);
                        assert(strcmp(x, '.mgz') || strcmp(x, '.mgh'));
                        obj = NIfTId(MGHState.mgh2nii(obj));
                    end
                    obj = MGH(obj);
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

