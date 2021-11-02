classdef BrainNet2 < handle
	%% BRAINNET2 is a lightweight implementation of BrainNet by 
    %  Xia M, Wang J, He Y (2013) BrainNet Viewer: A Network Visualization Tool for Human Brain Connectomics. 
    %  PLoS ONE 8: e68910.

	%  $Revision$
 	%  was created 18-May-2021 14:27:03 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.10.0.1602886 (R2021a) for MACI64.  Copyright 2021 John Joowon Lee.
 	
	properties
 		argoutCache
        
        % options
        layout
        global % objectMaterial, markLeftAndRight
    end
    
	methods		  
 		function this = BrainNet2(varargin)
 			%% BRAINNET2
 			%  @param .
            
            
        end
        
        function call()
        end
    end 
    
    %% PRIVATE
    
    methods (Access = private)
        function varargout = BrainNet_(varargin)
            gui_Singleton = 1;
            gui_State = struct('gui_Name',       mfilename, ...
                'gui_Singleton',  gui_Singleton, ...
                'gui_OpeningFcn', @BrainNet_OpeningFcn, ...
                'gui_OutputFcn',  @BrainNet_OutputFcn, ...
                'gui_LayoutFcn',  [] , ...
                'gui_Callback',   []);
            if nargin && ischar(varargin{1})
                gui_State.gui_Callback = str2func(varargin{1});
            end

            if nargout
                [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
            else
                gui_mainfcn(gui_State, varargin{:});
            end
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

