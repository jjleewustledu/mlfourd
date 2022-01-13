classdef NIfTIInfo < handle & mlfourd.AbstractNIfTIInfo 
	%% NIFTIINFO emulates Matlab function niftiinfo for use with Matlab versions prior to R2017b.  
    %  See also mlfourd.Analyze75Info, mlfourd.FourdfpInfo.  Requires Image Processing Toolbox function affine3d.

	%  $Revision$
 	%  was created 30-Apr-2018 16:39:09 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	     	
    properties (Constant)
        FILETYPE      = 'NIFTI_GZ'
        FILETYPE_EXT  = '.nii.gz'
        NIFTI_EXT     = '.nii.gz'
        SUPPORTED_EXT = {'.nii' '.nii.gz' '.hdr'}
    end
    
	methods 
 		function this = NIfTIInfo(varargin)
 			%% NIFTIINFO calls mlniftitools.load_untouch_header_only
 			%  @param filename is required.
            
            this = this@mlfourd.AbstractNIfTIInfo(varargin{:});            
            
            if (~isfile(this.fqfilename))
                return
            end
            
            [this.hdr_,this.ext_,this.filetype_,this.machine_] = this.load_untouch_header_only;
            this.hdr_ = this.adjustHdr(this.hdr_);
 		end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

