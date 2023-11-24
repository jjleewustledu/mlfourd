classdef MatlabFormatTool < handle & mlfourd.ImagingFormatTool
    %% MATLABFORMATTOOL is a concrete subclass of ImagingFormatTool intended for Matlab numerical analysis.
    %  
    %  Created 07-Dec-2021 21:58:26 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
        
    methods (Static)
        function this = createFromImagingFormat(iform)
            %% from any ImagingFormatTool create MatlabFormatTool

            assert(isa(iform, 'mlfourd.ImagingFormatTool'))
            
            fs_ = iform.filesystem_;
            if isempty(fs_.filesuffix)
                fs_.filesuffix = '.mat';
            end
            [hdr_,orig_] = mlfourd.MatlabFormatTool.imagingFormatToHdr(iform);
            info_ = mlfourd.ImagingInfo(fs_, ...
                'datatype', iform.datatype, ...
                'ext', iform.ext, ...
                'filetype', iform.filetype, ...
                'N', iform.N , ...
                'json_metadata', iform.json_metadata, ...
                'untouch', [], ...
                'hdr', hdr_, ...
                'original', orig_);
            this = mlfourd.MatlabFormatTool( ...
                iform.contexth_, iform.img, ...
                'imagingInfo', info_, ...
                'filesystem', fs_, ...
                'logger', iform.logger, ...
                'viewer', iform.viewer, ...
                'useCase', 3);
        end
    end

    methods

        %%

        function this = MatlabFormatTool(varargin)
            this = this@mlfourd.ImagingFormatTool(varargin{:});         
        end

        function save_mat(this, opts)
            % undifferentiated ImagingInfo does not have 4dfp, mgz or nifti information
            
            arguments
                this mlfourd.MatlabFormatTool
                opts.savelog logical = true;
            end

            if (this.noclobber && isfile(this.fqfilename))
                return
            end
            this.ensureNoclobber();
            this.assertNonemptyImg();
            ensuredir(this.filepath);            
            this.filesuffix = '.mat';
            save(this.fqfilename, 'this');
            if opts.savelog
                this.addLog("save(" + this.fqfilename + ", 'this')");
                this.saveLogger();
            end
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
