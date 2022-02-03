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
                'orig', orig_);
            this = mlfourd.NiftiTool( ...
                iform.contexth_, iform.img, ...
                'imagingInfo', info_, ...
                'filesystem', fs_, ...
                'logger', iform.logger, ...
                'viewer', iform.viewer, ...
                'useCase', 2);
        end
        function info = createImagingInfo(fn, varargin)
            info = mlfourd.NIfTIInfo(fn, varargin{:});
        end
    end

    methods

        %%

        function this = NiftiTool(varargin)
            this = this@mlfourd.ImagingFormatTool(varargin{:});
        end
    end

    %% HIDDEN
    
    methods (Hidden)        
        function save__(this)
            assert(strcmp(this.filesuffix, '.nii') || ...
                   strcmp(this.filesuffix, '.nii.gz') || ...
                   strcmp(this.filesuffix, '.hdr'))
            this.save_nii;
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
