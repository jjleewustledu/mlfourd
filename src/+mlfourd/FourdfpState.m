classdef FourdfpState < mlfourd.ImagingState
	%% FOURDFPSTATE  
    %  @deprecated

	%  $Revision$
 	%  was created 08-Jun-2016 23:19:47
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.341360 (R2016a) for MACI64.
 	
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
        
        %% state changes
        
        function f  = fourdfp(this)
            f = this.concreteObj_;
        end
        function f  = mgh(this)
            this = this.nifti_4dfp_n(this.fqfileprefix);
            this.contexth_.changeState( ...
                mlfourd.MGHState(this.fqfilename, this.contexth_));
            f = this.contexth_.mgh;
        end
        function f  = niftid(this)
            this = this.nifti_4dfp_n(this.fqfileprefix);
            this.contexth_.changeState( ...
                mlfourd.NIfTIdState(this.fqfilename, this.contexth_));
            f = this.contexth_.niftid;
        end
        function g  = numericalNiftid(this)
            this = this.nifti_4dfp_n(this.fqfileprefix);
            this.contexth_.changeState( ...
                mlfourd.NumericalNIfTIdState(this.fqfilename, this.contexth_));
            g = this.contexth_.numericalNiftid;
        end
        
        %%
        
        function        addImgrec(this, varargin)
            this.concreteObj_.addImgrec(varargin{:});
        end
        function        addLog(this, varargin)
            this.concreteObj_.addLog(varargin{:});
        end
        function this = nifti_4dfp_n(this, varargin)
            try
                fv = mlfourdfp.FourdfpVisitor;
                fv.nifti_4dfp_n(varargin{:});
                this.filesuffix = '.nii.gz';
            catch ME
                handexcept(ME);
            end
        end
        function this = nifti_4dfp_4(this, varargin)
            try
                fv = mlfourdfp.FourdfpVisitor;
                fv.nifti_4dfp_4(varargin{:});
                this.filesuffix = '.4dfp.hdr';
            catch ME
                handexcept(ME);
            end
        end
        function        view(this, varargin)
            this.concreteObj_.viewer = this.viewer;
            this.concreteObj_.view([this.fqfilename varargin{:}]);
        end 
        
 		function this = FourdfpState(obj, h)
            if (~isa(obj, 'mlfourdfp.Fourdfp'))
                try
                    import mlfourdfp.*;
                    if (ischar(obj))
                        [pth,fp,x] = myfileparts(obj);
                        assert(strcmp(x, '.4dfp.hdr'));
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

