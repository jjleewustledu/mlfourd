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
                'datatype', iform.datatype, ...
                'ext', iform.ext, ...
                'filetype', iform.filetype, ...
                'N', iform.N , ...
                'untouch', [], ...
                'hdr', hdr_);
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

        function save(this)
            %% SAVE 

            this.assertNonemptyImg();
            this.ensureNoclobber();
            ensuredir(this.filepath);

            warning('off', 'MATLAB:structOnObject');
            try
                fqfn_nii = strcat(this.fqfileprefix, '.nii.gz');
                fqfn_mgz = strcat(this.fqfileprefix, '.mgz');
                this.save_nii();
                cmd = sprintf('mri_convert %s %s', fqfn_nii, fqfn_mgz);
                mlbash(cmd);
                this.addLog(cmd);
                this.saveLogger();
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError', ...
                    'MghTool.save could not save %s', this.fqfilename);
            end
            warning('on', 'MATLAB:structOnObject');
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
