classdef LegacyTool < handle & mlfourd.ImagingState2
    %% line1
    %  line2
    %  
    %  Created 08-Dec-2021 21:31:47 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods (Static)
        function this = create(contexth, imgobj, varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      imgobj (various): provides numerical imaging data.  
            %  Returns:
            %      this (mlfourd.ImagingState2)
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'contexth', @(x) isa(x, 'mlfourd.ImagingContext2'))
            addRequired(ip, 'imgobj',  @(x) ~isempty(x))
            parse(ip, contexth, imgobj, varargin{:})
            ipr = ip.Results;

            assert(~isdeployed);

            switch class(ipr.imgobj)
                case {'mlfourd.ImagingContext', 'mlfourd.ImagingFormatContext'}
                    ipr.imgobj.save();
                    this = mlfourd.ImagingContext2(ipr.imgobj.fqfilename);
                otherwise
                    error('mlfourd:TypeError', stackstr())
            end
        end
    end

    %% PROTECTED

    methods (Access = private)        
        function this = LegacyTool()
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
