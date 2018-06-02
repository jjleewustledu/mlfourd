classdef FourdfpState < mlfourd.ImagingState
	%% FOURDFPSTATE  

	%  $Revision$
 	%  was created 08-Jun-2016 23:19:47
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.341360 (R2016a) for MACI64.
 	

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
        function f  = get.cellComposite(this)
            this = this.nifti_4dfp_n;
            this.contexth_.changeState( ...
                mlfourd.CellCompositeState(this.fqfilename, this.contexth_));
            f = this.contexth_.cellComposite;
        end
        function f  = get.fourdfp(this)
            f = this.concreteObj_;
        end
        function f  = get.mgh(this)
            this = this.nifti_4dfp_n;
            this.contexth_.changeState( ...
                mlfourd.MGHState(this.fqfilename, this.contexth_));
            f = this.contexth_.mgh;
        end
        function f  = get.niftic(this)
            this = this.nifti_4dfp_n;
            this.contexth_.changeState( ...
                mlfourd.NIfTIcState(this.fqfilename, this.contexth_));
            f = this.contexth_.niftic;
        end
        function f  = get.niftid(this)
            this = this.nifti_4dfp_n;
            this.contexth_.changeState( ...
                mlfourd.NIfTIdState(this.fqfilename, this.contexth_));
            f = this.contexth_.niftid;
        end
        function g  = get.numericalNiftid(this)
            this = this.nifti_4dfp_n;
            this.contexth_.changeState( ...
                mlfourd.NumericalNIfTIdState(this.fqfilename, this.contexth_));
            g = this.contexth_.numericalNiftid;
        end
        function f  = get.petNiftid(this)
            this = this.nifti_4dfp_n;
            this.contexth_.changeState( ...
                mlfourd.PETNIfTIdState(this.concreteObj_, this.contexth_));
            f = this.contexth_.petNiftid;
        end  
    end
    
    methods (Static)
        function tf = isFourdfp(obj)
            tf = false;
            if (ischar(obj))
                [~,~,ext] = myfileparts(obj);
                if (lstrfind(ext, '.4dfp'))
                    tf = true;
                end  
            end          
        end
    end
    
	methods
        function        addLog(this, varargin)
            this.concreteObj_.addLog(varargin{:});
        end
        function this = nifti_4dfp_n(this, varargin)
            try
                fv = mlfourdfp.FourdfpVisitor;
                fv.nifti_4dfp_n(varargin{:});
                this.filesuffix = '.nii';
            catch ME
                handexcept(ME);
            end
        end
        function this = nifti_4dfp_ng(this, varargin)
            try
                fv = mlfourdfp.FourdfpVisitor;
                fv.nifti_4dfp_ng(varargin{:});
                this.filesuffix = '.nii.gz';
            catch ME
                handexcept(ME);
            end
        end
        function this = nifti_4dfp_4(this, varargin)
            try
                fv = mlfourdfp.FourdfpVisitor;
                fv.nifti_4dfp_4(varargin{:});
                this.filesuffix = '.4dfp.ifh';
            catch ME
                handexcept(ME);
            end
        end
        function        view(this, varargin)
            this.concreteObj_.viewer = this.viewer;
            this.concreteObj_.view(varargin{:});
        end 
        
 		function this = FourdfpState(obj, h)
            if (~isa(obj, 'mlfourdfp.Fourdfp'))
                try
                    import mlfourdfp.*;
                    if (ischar(obj))
                        [pth,fp,x] = myfileparts(obj);
                        assert(strcmp(x, '.4dfp.ifh'));
                        fqfp = fullfile(pth, fp);
                        this.nifti_4dfp_n(fqfp);
                        obj = mlfourd.NIfTId(fqfp);
                    end
                    obj = Fourdfp(obj);
                catch ME
                    handexcept(ME, 'mlfourdfp:castingError', ...
                        'mlfourd.FourdfpState does not support objects of type %s', class(obj));
                end
            end
            this.concreteObj_ = obj;
            this.contexth_ = h;
 		end
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

