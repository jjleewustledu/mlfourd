classdef FilesystemTool < handle & mlfourd.AbstractImagingTool
	%% FILESYSTEMTOOL  

	%  $Revision$
 	%  was created 10-Aug-2018 04:41:41 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
 		
 	end

	methods 
        
        %% get some ImagingFormatContext
        
        function ifc = fourdfp(this)
            ifc = this.ifcFromSuff('.4dfp.hdr');
        end
        function ifc = mgz(this)
            ifc = this.ifcFromSuff('.mgz');
        end
        function ifc = nifti(this)
            ifc = this.ifcFromSuff('.nii.gz');
        end
        function ifc = niftid(this)
            ifc = mlfourd.NIfTId(this.ifcFromSuff('.nii.gz'));
        end
        function ifc = numericalNiftid(this)
            ifc = mlfourd.NumericalNIfTId(this.ifcFromSuff('.nii.gz'));
        end
        
        %%
		  
 		function this = FilesystemTool(h, varargin)
            this = this@mlfourd.AbstractImagingTool(h, varargin{:});
            this.innerImaging_ = mlio.HandleConcreteIO(varargin{:});
            this.innerImaging_.fqfilename = varargin{1};
        end
    end 
    
    %% PRIVATE
    
    methods (Access = private)
        function ifc = ifcFromSuff(this, suff)
            ifc = mlfourd.ImagingFormatContext([this.fqfileprefix suff]);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

