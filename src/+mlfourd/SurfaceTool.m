classdef SurfaceTool
    %  e.g.: 
    %  setenv('SUBJECTS_DIR', pwd)
    %  recon-all -subject sub-S58163_ses-surfer-v7.2.0 -i $scans/79-T1/DICOM/1.3.12.2.1107.5.2.38.51010.30000019052315311761100000001-79-100-wwrsds.dcm -T2 $scans/23-T2/DICOM/1.3.12.2.1107.5.2.38.51010.30000019052315311761100000001-23-100-8i13il.dcm -T2pial -all
    %  gtmseg --s sub-S58163_ses-surfer-v7.2.0
    %  
    %  Created 27-Dec-2021 13:27:19 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods (Static)
        function [s,r] = recon_all_subjects(varargin)
            %% RECON_ALL_SUBJECTS
            %  Args:
            %      subjects (cell): e.g., {'sub-123456', ...} in $SINGULARITY_HOME/CCIR_01211/sourcedata/
            %      project (text): e.g., CCIR_01211
            %      t1glob (text): within derivatives/sub-123456/anat/
            %      t2glob (text): within derivatives/sub-123456/anat/

            ip = inputParser;
            addRequired(ip, 'subjects', @iscell)
            addParameter(ip, 'project', 'CCIR_01211', @istext)
            addParameter(ip, 't1glob', '*_T1w_MPR_vNav_4e_RMS.nii.gz', @istext)
            addParameter(ip, 't2glob', '*_T2w_SPC_vNava.nii.gz', @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;

            subjectsDir0 = getenv('SUBJECTS_DIR');
            
            setenv('SUBJECTS_DIR', fullfile(getenv('SINGULARITY_HOME'), ipr.project, 'derivatives', ''));
            parfor si = 1:length(ipr.subjects)
                try
                    anatDir = fullfile(getenv('SINGULARITY_HOME'), ...
                        ipr.project, 'sourcedata', ipr.subjects{si}, 'anat', '');
                    t1file = glob(fullfile(anatDir, ipr.t1glob)); %#ok<*PFBNS> 
                    assert(isfile(t1file))
                    t2file = glob(fullfile(anatDir, ipr.t2glob));
                    assert(isfile(t2file))
                    mlfourd.SurfaceTool.recon_all( ...
                        strcat(ipr.subjects{si}, '_ses-surfer-v7.2.0'), 'i', t1file{end}, 'T2', t2file{end})
                catch ME
                    handwarning(ME)
                end
            end

            setenv('SUBJECTS_DIR', subjectsDir0);
        end
        function [s,r] = recon_all(varargin)
            % RECON_ALL
            % e.g.:
            % recon-all -subject sub-S58163_ses-surfer-v7.2.0 \\
            % -i $scans/79-T1/DICOM/1.3.12.2.1107.5.2.38.51010.30000019052315311761100000001-79-100-wwrsds.dcm \\
            % -T2 $scans/23-T2/DICOM/1.3.12.2.1107.5.2.38.51010.30000019052315311761100000001-23-100-8i13il.dcm \\
            % -T2pial -all

            ip = inputParser;
            addRequired(ip, 'subject', @(x) ~isfolder(x)) % recon-all will create folder
            addParameter(ip, 'i', @isfile)
            addParameter(ip, 'T2', @isfile)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            exe = sprintf(fullfile(getenv('FREESURFER_HOME'), 'bin', 'recon-all'));
            [~,r] = mlbash(sprintf('%s -version', exe));
            assert(contains(r, '7.2.0'))
            cmd = sprintf('%s -subject %s -i %s -T2 %s -T2pial -all', ...
                exe, ipr.subject, ipr.i, ipr.T2);
            [s,r] = mlbash(cmd)
        end
    end

    methods
        function this = SurfaceTool(varargin)
            %% SURFACETOOL 
            %  Args:
            %      arg1 (its_class): Description of arg1.
            
            ip = inputParser;
            addParameter(ip, "arg1", [], @(x) false)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
