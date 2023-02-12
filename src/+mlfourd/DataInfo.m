classdef DataInfo < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable & mlio.IOInterface
    %% DATAINFO manages metadata and header information for imaging. 
    %  
    %  Created 07-Oct-2022 21:26:21 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.13.0.2049777 (R2022b) for MACI64.  Copyright 2022 John J. Lee.
    
    methods
        function this = DataInfo(varargin)
            %% CIFTIINFO 
            %  Args:
 			%      filesystem_ (text|mlio.HandleFilesystem):  
            %          If text, ImagingInfo creates isolated filesystem_ information.
            %          If mlio.HandleFilesystem, ImagingInfo will reference the handle for filesystem_ information,
            %          allowing for external modification for synchronization.
            %          For aufbau, the file need not exist on the filesystem.
            %      json_metadata (struct): read from filesystem by ImagingInfo hierarchy.
            %      json_metadata_filesuffix (text): for reading from filesystem by ImagingInfo hierarchy.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addOptional( ip, 'filesystem', mlio.HandleFilesystem(), @(x) istext(x) || isa(x, 'mlio.HandleFilesystem'));
            addParameter(ip, 'json_metadata', [])
            addParameter(ip, 'json_metadata_filesuffix', '.json', @istext)
            parse(ip, varargin{:});
            ipr = ip.Results;
            if istext(ipr.filesystem)
                this.filesystem_ = mlio.HandleFilesystem.createFromString(ipr.filesystem);
            end
            if isa(ipr.filesystem, 'mlio.HandleFilesystem')
                this.filesystem_ = ipr.filesystem;
            end
            this.json_metadata_ = ipr.json_metadata;
            this.json_metadata_filesuffix_ = ipr.json_metadata_filesuffix;
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
