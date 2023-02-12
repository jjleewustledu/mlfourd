classdef Temp < handle
    %% is for testing.
    %  Created 08-Oct-2022 18:19:01 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.13.0.2049777 (R2022b) for MACI64.  Copyright 2022 John J. Lee.
    
    properties
        imaging
    end

    methods
        function this = Temp(filename)
            this.imaging = mlfourd.ImagingContext2(filename);            
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
