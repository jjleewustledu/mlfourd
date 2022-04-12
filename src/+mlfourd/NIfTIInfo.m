classdef NIfTIInfo < handle & mlfourd.AbstractNIfTIInfo 
	%% NIFTIINFO relies on Jimmy Shen's mlniftitools to obtain header information from NIfTI files.
    %  It emulates Matlab-native niftiinfo, while also using niftiinfo to obtain comparative information.

	%  $Revision$
 	%  was created 30-Apr-2018 16:39:09 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	     	
    methods (Static)
        function e = defaultFilesuffix()
            e =  mlfourd.NIfTIInfo.FILETYPE_EXT;
        end
    end

    properties (Constant)
        FILETYPE      = 'NIFTI_GZ'
        FILETYPE_EXT  = '.nii.gz'
        NIFTI_EXT     = '.nii.gz'
        SUPPORTED_EXT = {'.nii' '.nii.gz' '.hdr'}
    end
    
	methods 
        function load_info(this)
            if isfile(this.fqfilename)
                try
                    this.info_ = niftiinfo(this.fqfilename); % Matlab's native
                catch %ME
                    fprintf('IOWarning: mlfourd.NIfTIInfo.load_info.fqfilename->%s\n', this.fqfilename);
                    %handwarning(ME)
                end
            end
        end

 		function this = NIfTIInfo(varargin)
 			%% NIFTIINFO provides points of entry for building info and hdr objects
            %  Args:
 			%      filesystem_ (text|mlio.HandleFilesystem):  
            %          If text, ImagingInfo creates isolated filesystem_ information.
            %          If mlio.HandleFilesystem, ImagingInfo will reference the handle for filesystem_ information,
            %          allowing for external modification for synchronization.
            %          For aufbau, the file need not exist on the filesystem.
            %      datatype (scalar): sepcified by mlniftitools.
            %      ext (struct): sepcified by mlniftitools.
            %      filetype (scalar): sepcified by mlniftitools.
            %      N (logical): 
            %      separator (text): separates annotations
            %      untouch (logical): sepcified by mlniftitools.
            %      hdr (struct): sepcified by mlniftitools.
            %      original (struct): sepcified by mlniftitools.
            
            this = this@mlfourd.AbstractNIfTIInfo(varargin{:});

            %this.load_info();
 		end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

