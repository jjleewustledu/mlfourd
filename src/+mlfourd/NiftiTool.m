classdef NiftiTool < handle & mlfourd.ImagingFormatTool
    %% NIFTITOOL
    %  
    %  Created 12-Dec-2021 20:59:01 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods (Static)
        function this = createFromImagingFormat(iform)
            %% from any ImagingFormatTool create NiftiTool

            assert(isa(iform, 'mlfourd.ImagingFormatTool'))
            
            fs_ = iform.filesystem_;
            fs_.filesuffix = '.nii.gz';
            [hdr_,orig_] = mlfourd.NiftiTool.imagingFormatToHdr(iform);
            info_ = mlfourd.NIfTIInfo(fs_, ...
                'datatype', iform.datatype, ...
                'ext', iform.ext, ...
                'filetype', iform.filetype, ...
                'N', iform.N, ...
                'untouch', [], ...
                'hdr', hdr_, ...
                'orig', orig_, ...
                'json_metadata', iform.json_metadata);
            this = mlfourd.NiftiTool( ...
                iform.contexth_, iform.img, ...
                'imagingInfo', info_, ...
                'filesystem', fs_, ...
                'logger', iform.logger, ...
                'viewer', iform.viewer, ...
                'useCase', 2);
        end
    end

    methods

        %%

        function this = NiftiTool(varargin)
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

            this.save_nii();
            this.save_json_metadata();
            this.saveLogger();
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
