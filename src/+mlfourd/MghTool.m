classdef MghTool < handle & mlfourd.ImagingFormatTool
    %% line1
    %  line2
    %  
    %  Created 12-Dec-2021 23:36:39 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods (Static)
        function this = createFromImagingFormat(iform)
            assert(isa(iform, 'mlfourd.ImagingFormatTool'))

            if isa(iform, 'mlfourd.FourdfpTool')
                [img_,hdr_] = mlfourd.FourdfpInfo.exportFourdfpToFreesurferSpace(iform.img, iform.hdr);
            else
                img_ = iform.img;
                hdr_ = iform.hdr;
            end
            fs_ = iform.filesystem_;
            fs_.filesuffix = '.mgz';
            info_ = mlfourd.MGHInfo(fs_, ...
                'datatype', iform.datatype, 'ext', iform.ext, 'filetype', iform.filetype, 'N', iform.N , 'untouch', false, 'hdr', hdr_);
            this = mlfourd.MghTool( ...
                iform.contexth_, img_, ...
                'imagingInfo', info_, ...
                'filesystem', fs_, ...
                'logger', iform.logger, ...
                'viewer', iform.viewer, ...
                'useCase', 2);
        end
        function info = createImagingInfo(fn, varargin)
            import mlfourd.*;
            fn2 = [tempFqfilename(myfileparts(fn)) MGHInfo.defaultFilesuffix]; 
            mlbash(sprintf('mri_convert %s %s', fn, fn2)); 
            info = MGHInfo(fn2, varargin{:});
        end
    end

    methods
        
        %%

        function this = MghTool(varargin)
            this = this@mlfourd.ImagingFormatTool(varargin{:});
        end
    end

    %% HIDDEN
    
    methods (Hidden) 
        function save__(this)
            assert(strcmp(this.filesuffix, '.mgz') || ...
                   strcmp(this.filesuffix, '.mgh') || ...
                   strcmp(this.filesuffix, '.nii') || ...
                   strcmp(this.filesuffix, '.nii.gz'));
            try
                warning('off', 'MATLAB:structOnObject');
                fqfn = strcat(this.fqfileprefix, '.nii.gz');
                mlniftitools.save_nii(struct(this), fqfn);
                this.addLog("mlniftitools.save_nii(struct(this), " + fqfn + ")");
                cmd = sprintf('mri_convert %s %s', strcat(this.fqfileprefix, '.nii.gz'), strcat(this.fqfileprefix, '.mgz'));
                mlbash(cmd);
                this.addLog(cmd);
                warning('on', 'MATLAB:structOnObject');
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError', ...
                    'InnerNIfTI.save_mgz erred while attempting to save %s', this.fqfilename);
            end
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
