classdef ManifoldTool < handle & mlfourd.ImagingState2
    %% line1
    %  line2
    %  
    %  Created 10-Dec-2021 23:08:32 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods
        
        %% cast then return copy(imaging format object)
        
        function ifc = cifti(this)
            error('mlfourd:NotImplementedError', 'ImagingTool.cifti()')
        end

        %%

        function this = ManifoldTool(varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      imagingFormat (IImagingFormat): provides numerical imaging data.  
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'contexth', @(x) isa(x, 'mlfourd.ImagingContext2'))
            addRequired(ip, 'imagingFormat',  @(x) isa(x, 'mlfourd.IImagingFormat'))
            parse(ip, contexth, imagingFormat, varargin{:})
            ipr = ip.Results;

            this = this@mlfourd.ImagingState2(ipr.contexth, ipr.imagingFormat, varargin{:});
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
