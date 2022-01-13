classdef SurfaceTool
    %% line1 
    %  setenv('SUBJECTS_DIR', pwd)
    %  recon-all -subject sub-S58163_ses-surfer-v7.2.0 -i $scans/79-T1/DICOM/1.3.12.2.1107.5.2.38.51010.30000019052315311761100000001-79-100-wwrsds.dcm -T2 $scans/23-T2/DICOM/1.3.12.2.1107.5.2.38.51010.30000019052315311761100000001-23-100-8i13il.dcm -T2pial -all
    %  gtmseg --s sub-S58163_ses-surfer-v7.2.0
    %  
    %  Created 27-Dec-2021 13:27:19 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods
        function this = SurfaceTool(varargin)
            %% SURFACETOOL 
            %  Args:
            %      arg1 (its_class): Description of arg1.
            
            ip = inputParser;
            addParameter(ip, "arg1", [], @(x) false)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
