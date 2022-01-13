classdef (Abstract) IImagingFormat < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable & mlio.IOInterface
    %% IIMAGINGFORMAT specifies parts of a class hierarchy implemented by ImagingFormatContext, ImagingFormatContext2,
    %  and ImagingFormatState2.
    %  
    %  Created 05-Dec-2021 15:57:44 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    properties (Abstract)        
        filesystem
        img
        logger
    end

    methods (Abstract)
        isempty(this)
        length(this)
        ndims(this)
        numel(this)
        size(this)

        addLog(this)
        char(this)
        double(this)
        logical(this)
        save(this)
        single(this)
        string(this)
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
