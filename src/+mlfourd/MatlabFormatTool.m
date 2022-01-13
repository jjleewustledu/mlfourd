classdef MatlabFormatTool < handle & mlfourd.ImagingFormatTool
    %% MATLABFORMATTOOL is a concrete subclass of ImagingFormatTool intended for Matlab numerical analysis.
    %  
    %  Created 07-Dec-2021 21:58:26 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
        
    methods (Static)
        function this = createFromImagingFormat(iform)
            assert(isa(iform, 'mlfourd.ImagingFormatTool'))
            
            img_ = iform.img;
            hdr_ = iform.hdr;
            fs_ = iform.filesystem_;
            if isempty(fs_.filesuffix)
                fs_.filesuffix = '.mat';
            end
            info_ = mlfourd.ImagingInfo(fs_, ...
                        'datatype', iform.datatype, 'ext', iform.ext, 'filetype', iform.filetype, 'N', iform.N , 'untouch', false, 'hdr', hdr_);
            this = mlfourd.MatlabFormatTool( ...
                iform.contexth_, img_, ...
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
    end

    %% HIDDEN
    
    methods (Hidden)        
        function save__(this)
            % undifferentiated ImagingInfo does not have 4dfp, mgz or nifti information
            
            this.filesuffix = '.mat';
            save(this.fqfilename, 'this');
            this.addLog("save(" + this.fqfilename + ", 'this')");
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
