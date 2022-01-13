classdef LegacyImagingFormatContext < handle & mlfourd.LegacyTool
    %% line1
    %  line2
    %  
    %  Created 09-Dec-2021 00:44:54 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods
        function this = LegacyImagingFormatContext(varargin)
            %% LEGACYIMAGINGFORMATCONTEXT 
            %  Args:
            %      arg1 (its_class): Description of arg1.
            
            this = this@mlfourd.LegacyTool(varargin{:})
            
            ip = inputParser;
            addParameter(ip, "arg1", [], @(x) false)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
