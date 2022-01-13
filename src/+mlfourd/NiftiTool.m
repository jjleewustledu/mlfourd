classdef NiftiTool < handle & mlfourd.ImagingFormatTool
    %% line1
    %  line2
    %  
    %  Created 12-Dec-2021 20:59:01 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods (Static)
        function this = createFromImagingFormat(iform)
            assert(isa(iform, 'mlfourd.ImagingFormatTool'))
            
            if isa(iform, 'mlfourd.FourdfpTool')
                img_ = mlfourd.FourdfpInfo.exportFourdfpToNIfTI(iform.img);
                hdr_ = iform.hdr;
            else
                img_ = iform.img;
                hdr_ = iform.hdr;
            end
            fs_ = iform.filesystem_;
            fs_.filesuffix = '.nii.gz';
            info_ = mlfourd.NIfTIInfo(fs_, ...
                        'datatype', iform.datatype, 'ext', iform.ext, 'filetype', iform.filetype, 'N', iform.N , 'untouch', false, 'hdr', hdr_);
            this = mlfourd.NiftiTool( ...
                iform.contexth_, img_, ...
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
