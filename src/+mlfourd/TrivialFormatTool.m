classdef TrivialFormatTool < handle & mlfourd.ImagingFormatState2
    %% TRIVIALIMAGINGFORMAT is a trivially concrete subclass of ImagingFormatState2 intended for testing, debugging,  
    %  and exploration.
    %  
    %  Created 05-Dec-2021 20:57:34 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.    

    methods

        %% implementations of IImagingFormat

        function tf = isempty(~)
            tf = true;
        end
        function len = length(~)
            len = 0;
        end
        function n = ndims(~)
            n = 2; % ndims([]) == 2
        end
        function n = numel(~)
            n =  0;
        end
        function s = size(~, varargin)
            s = [0 0];
        end

        %%
        
        function this = TrivialFormatTool(contexth, varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingFormatContexts of the state design pattern.
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'contexth', @(x) isa(x, 'mlfourd.ImagingFormatContext2'))
            parse(ip, contexth, varargin{:})
            ipr = ip.Results;
            
            this = this@mlfourd.ImagingFormatState2(ipr.contexth, [], varargin{:});
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
