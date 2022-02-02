classdef MGHInfo < handle & mlfourd.AbstractNIfTIInfo
	%% MGHINFO  

	%  $Revision$
 	%  was created 24-Jul-2018 11:31:16 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
    
    properties (Constant) 
        FILETYPE      = 'MGZ'
        FILETYPE_EXT  = '.mgz'
        MGH_EXT       = '.mgz';
        SUPPORTED_EXT = {'.mgh' '.mgz' '.nii' '.nii.gz' '.ge' '.gelx' '.lx' '.ximg' '.IMA' '.dcm' '.afni' '.bshort' '.bfloat' '.sdt'} 
        % '.img' is SPM format to mri_convert
    end
    
	methods 		  
        function fqfn = fqfileprefix_mgz(this)
            fqfn = strcat(this.fqfileprefix, this.MGH_EXT);
        end
        function s = load_untouch_nii(this)
            %% ctor must have converted .mgz to .nii.gz using mri_convert.
            %  superclass method make_nii calls niftiread, which calls load_untouch_nii.
            %  Returns:
            %      s: struct of NIfTI data expected by mlniftitools.
            
            s = mlniftitools.load_untouch_nii(strcat(this.fqfileprefix, '.nii.gz'));
        end  

 		function this = MGHInfo(varargin)
 			%% MGHINFO calls mri_convert, then mlniftitools.load_untouch_header_only
 			%  @param filename is required.

 			this = this@mlfourd.AbstractNIfTIInfo(varargin{:});
            
            fqfileprefix_mgz = strcat(this.fqfileprefix, '.mgz');
            if ~isfile(fqfileprefix_mgz)
                return
            end            
            mlbash(sprintf('mri_convert %s %s', fqfileprefix_mgz, strcat(this.fqfileprefix, this.defaultFilesuffix))); 
            this.filesuffix = this.defaultFilesuffix; % hereafter, behave exactly as NIfTIInfo
            
%             [this.hdr_,this.ext_,this.filetype_,this.machine_] = this.load_untouch_header_only;
%             this.hdr_ = this.adjustHdr(this.hdr_);
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

