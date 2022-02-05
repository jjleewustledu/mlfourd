classdef MghTool < handle & mlfourd.ImagingFormatTool
    %% MGHTOOL behaves identically to NIfTIInfo until save() is called.  save() uses mri_convert
    %  to convert nii.gz to mgz.
    %  
    %  Created 12-Dec-2021 23:36:39 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods (Static)
        function this = createFromImagingFormat(iform)
            %% from any ImagingFormatTool create MghTool

            assert(isa(iform, 'mlfourd.ImagingFormatTool'))

            fs_ = iform.filesystem_;
            fs_.filesuffix = '.mgz';
            [hdr_,orig_] = mlfourd.MghTool.imagingFormatToHdr(iform);
            info_ = mlfourd.MGHInfo(fs_, ...
                'datatype', iform.datatype, ...
                'ext', iform.ext, ...
                'filetype', iform.filetype, ...
                'N', iform.N , ...
                'untouch', [], ...
                'hdr', hdr_, ...
                'orig', orig_);
            this = mlfourd.MghTool( ...
                iform.contexth_, iform.img, ...
                'imagingInfo', info_, ...
                'filesystem', fs_, ...
                'logger', iform.logger, ...
                'viewer', iform.viewer, ...
                'useCase', 2);
        end
    end

    properties (Dependent)
        fqfileprefix_mgz
    end

    methods

        %% GET

        function fqfn = get.fqfileprefix_mgz(this)
            fqfn = strcat(this.fqfileprefix, this.MGH_EXT);
        end
        
        %%

        function this = MghTool(varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      img (numeric): option provides numerical imaging data.  Default := [].
            %      imagingInfo (ImagingInfo): Default := [].
            %      filesystem (HandleFilesystem): Default := mlio.HandleFilesystem().
            %      logger (mlpipeline.ILogger): Default := log on filesystem | mlpipeline.Logger2(filesystem.fqfileprefix).
            %      viewer (IViewer): Default := mlfourd.Viewer().
            %      useCase (numeric): described above.  Default := 1.

            this = this@mlfourd.ImagingFormatTool(varargin{:});
        end

        function save(this)
            %% SAVE 

            this.assertNonemptyImg();
            this.ensureNoclobber();
            ensuredir(this.filepath);

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
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
