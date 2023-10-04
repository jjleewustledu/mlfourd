classdef MGHInfo < handle & mlfourd.AbstractNIfTIInfo
	%% MGHINFO behaves identically to NIfTIInfo following instantiation.  Instantiation uses mri_convert
    %  to convert mgz to nii.gz.

	%  $Revision$
 	%  was created 24-Jul-2018 11:31:16 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
     	
    methods (Static)
        function e = defaultFilesuffix()
            e =  mlfourd.MGHInfo.FILETYPE_EXT;
        end
    end

    properties (Constant) 
        FILETYPE      = 'MGZ'
        FILETYPE_EXT  = '.mgz'
        MGH_EXT       = '.mgz';
        REORIENT2STD  = true;
        SUPPORTED_EXT = {'.mgh' '.mgz' '.nii' '.nii.gz' '.ge' '.gelx' '.lx' '.ximg' '.IMA' '.dcm' '.afni' '.bshort' '.bfloat' '.sdt'} 
        % '.img' is SPM format to mri_convert
    end

    properties (Dependent)
        fqfileprefix_mgz
        fqfileprefix_niigz
    end
    
	methods

        %% GET

        function fqfn = get.fqfileprefix_mgz(this)
            fqfn = strcat(this.fqfileprefix, this.MGH_EXT);
        end
        function fqfn = get.fqfileprefix_niigz(this)
            fqfn = strcat(this.fqfileprefix, mlfourd.NIfTIInfo.defaultFilesuffix);
        end

        %%

        function load_info(this)
            if isfile(this.fqfilename)
                this.info_ = niftiinfo(this.fqfilename); % Matlab's native
            end
        end

 		function this = MGHInfo(varargin)
 			%% MGHINFO provides points of entry for building info and hdr objects
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

            import mlfourd.NIfTIInfo.defaultFilesuffix % mgh|mgz -> nii.gz
 			this = this@mlfourd.AbstractNIfTIInfo(varargin{:});
            
            if isfile(this.fqfileprefix_mgz)
                if this.REORIENT2STD
                    tempname_niigz = strcat(tempname, defaultFilesuffix());
                    cmd = sprintf('mri_convert %s %s', this.fqfileprefix_mgz, tempname_niigz);
                    s = mlbash(cmd);
                    assert(0 == s, 'mlfourd:IOError', 'MGHInfo.ctor')
                    cmd = sprintf('fslreorient2std %s %s', tempname_niigz, this.fqfileprefix_niigz);
                    s = mlbash(cmd);
                    assert(0 == s, 'mlfourd:IOError', 'MGHInfo.ctor')
                    deleteExisting(tempname_niigz)

                    this.filesuffix = defaultFilesuffix(); % hereafter, behave exactly as NIfTIInfo
                    this.load_info();
                    return
                end

                cmd = sprintf('mri_convert %s %s', this.fqfileprefix_mgz, this.fqfileprefix_niigz);
                s = mlbash(cmd);
                assert(0 == s, 'mlfourd:IOError', 'MGHInfo.ctor')

                this.filesuffix = defaultFilesuffix(); % hereafter, behave exactly as NIfTIInfo
                this.load_info();
            end
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
end
