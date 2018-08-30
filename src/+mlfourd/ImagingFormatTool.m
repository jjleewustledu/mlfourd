classdef ImagingFormatTool < handle & mlfourd.AbstractImagingTool
	%% IMAGINGFORMATTOOL and mlfourd.ImagingContext form a hierarchical state design pattern. 

	%  $Revision$
 	%  was created 10-Aug-2018 02:14:04 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
 		
 	end

	methods		
        
        %% get some ImagingFormatContext 
        
        function ifc = fourdfp(this)
            this.innerImaging_.filesuffix = '.4dfp.hdr';
            ifc = this.innerImaging_;
        end
        function ifc = mgz(this)
            this.innerImaging_.filesuffix = '.mgz';
            ifc = this.innerImaging_;
        end
        function ifc = nifti(this)
            this.innerImaging_.filesuffix = '.nii.gz';
            ifc = this.innerImaging_;
        end
        
        %%
        
        function this = ImagingFormatTool(h, varargin)
            this = this@mlfourd.AbstractImagingTool(h, varargin{:});
            this.innerImaging_ = mlfourd.ImagingFormatContext(varargin{:});
        end
  	end      
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

