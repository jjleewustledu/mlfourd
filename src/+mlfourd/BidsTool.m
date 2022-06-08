classdef BidsTool < handle & mlfourd.ImagingTool
    %% BIDSTOOL supports high-level states for imaging supporting the Brain Imaging Data Structure:
    %  https://bids.neuroimaging.io/
    %  
    %  Created 03-May-2022 18:35:40 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.12.0.1884302 (R2022a) for MACI64.  Copyright 2022 John J. Lee.
    
    methods
        function this = BidsTool(varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      imagingFormat (IImagingFormat): provides a filename for imaging data on the filesystem.  
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.  
            
            this = this@mlfourd.ImagingTool(varargin{:});            
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
