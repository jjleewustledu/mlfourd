classdef IImaging < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable & mlio.IOInterface
    %% IIMAGING specifies parts of a class hierarchy implemented by ImagingContext2 & ImagingState2.
    %  
    %  Created 07-Dec-2021 15:01:25 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.

    methods (Abstract)
        isempty(this)
        length(this)
        ndims(this)
        numel(this)
        %rank(this) % deprecated
        size(this)
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
