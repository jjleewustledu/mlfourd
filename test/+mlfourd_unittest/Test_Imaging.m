classdef Test_Imaging < matlab.unittest.TestCase
    %% TEST_IMAGING supports ImagingContext2 & ImagingFormatContext2
    %  
    %  Created 15-Dec-2021 13:28:36 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_unittest.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.

    properties
        compatibility = false
        do_view = false
        pwd0
        T1001 = 'T1001'
        T1001_ic_4dfp % anatDir
        T1001_ic_nii % anatDir
    end

    properties (Dependent)
        anatDir % CCIR_00559_00754/derivatives/sub-S41723/anat
        anatDir2 % CCIR_01211/sourcedata/sub-S108293/anat
        dataDir % mlfourd/data
        dataDir2 % mlfourdfp/data
        fdg_fqfn_4dfp % CCIR_00559_00754/sourcedata/sub-S58163/pet
        fdg_ic_fqfn_nii % CCIR_00559_00754/sourcedata/sub-S58163/pet
        fdg_nifti_4dfp_fqfn_nii % CCIR_00559_00754/sourcedata/sub-S58163/pet
        large_4dfp % CCIR_00559_00754/derivatives/sub-S58163/pet
        large_nii % CCIR_00559_00754/derivatives/sub-S58163/pet
        mriDir % CCIR_00559_00754/derivatives/sub-S41723/mri
        T1001_fqfn_4dfp % anatDir
        T1001_fqfn_nii % anatDir
        TmpDir        
    end

    methods 

        %% GET

        function g = get.anatDir(~)
            g = fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00559_00754', 'derivatives', 'sub-S41723', 'anat', '');
        end
        function g = get.anatDir2(~)
            g = fullfile(getenv('SINGULARITY_HOME'), 'CCIR_01211', 'sourcedata', 'sub-S108293', 'anat', '');
        end
        function g = get.dataDir(~)
            g = fullfile(getenv('HOME'), 'MATLAB-Drive', 'mlfourd', 'data', '');
        end
        function g = get.dataDir2(~)
            g = fullfile(getenv('HOME'), 'MATLAB-Drive', 'mlfourdfp', 'data', '');
        end
        function g = get.fdg_fqfn_4dfp(~)
            g = fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00559_00754', 'sourcedata', 'sub-S58163', 'pet', ...
                'fdgdt20190523132832_222.4dfp.hdr');
        end
        function g = get.fdg_ic_fqfn_nii(~)
            g = fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00559_00754', 'sourcedata', 'sub-S58163', 'pet', ...
                'fdgdt20190523132832_222_ImagingContext2.nii.gz');
        end
        function g = get.fdg_nifti_4dfp_fqfn_nii(~)
            g = fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00559_00754', 'sourcedata', 'sub-S58163', 'pet', ...
                'fdgdt20190523132832_222_nifti_4dfp.nii.gz');
        end
        function g = get.large_4dfp(~)
            g = fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00559_00754', 'derivatives', 'sub-S58163', 'pet', ...
                'oodt20190523123738_on_T1001.4dfp.hdr');
        end
        function g = get.large_nii(~)
            g = fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00559_00754', 'derivatives', 'sub-S58163', 'pet', ...
                'oodt20190523123738_on_T1001.nii.gz');
        end 
        function g = get.mriDir(~)
            g = fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00559_00754', 'derivatives', 'sub-S41723', 'mri', '');
        end
        function g = get.T1001_fqfn_4dfp(this)
            g = fullfile(this.anatDir, 'T1001.4dfp.hdr');
        end
        function g = get.T1001_fqfn_nii(this)
            g = fullfile(this.anatDir, 'T1001.nii.gz');
        end
        function g = get.TmpDir(~)
            g = fullfile(getenv('HOME'), 'Tmp', '');
        end

        %%

        function cleanT1(~, ext)
            deleteExisting(strcat('T1_test', ext))
        end
        function setupT1(~, ext)
            switch ext
                case '.4dfp.hdr'
                    if ~isfile('T1_test.4dfp.hdr')
                        mlbash('mri_convert T1.mgz T1_test.nii.gz');
                        gunzip('T1_test.nii.gz');
                        mlbash('nifti_4dfp -4 T1_test.nii T1_test.4dfp.hdr');
                        gzip('T1_test.nii');
                        deleteExisting('T1_test.nii');
                    end
                case '.hdr'
                    if ~isfile('T1_test.hdr')
                        mlbash('mri_convert T1.mgz T1_test --out_type analyze');
                        movefile('T1_test001.hdr', 'T1_test.hdr');
                        movefile('T1_test001.img', 'T1_test.img');
                        deleteExisting('T1_test001.mat');
                    end
                case '.mgz'
                    if ~isfile('T1_test.mgz')
                        copyfile('T1.mgz', 'T1_test.mgz', 'f');
                    end
                case '.nii.gz'
                    if ~isfile('T1_test.nii.gz')
                        mlbash('mri_convert T1.mgz T1_test.nii.gz');
                    end
            end
        end
    end

	properties (Access = protected)
    end

    methods (Access = protected)
        function cleanTestMethod(this)
            popd(this.pwd0);
        end
        function setupImagingTest(this)
            import mlfourd.*
            this.pwd0 = pushd(this.TmpDir);

            if ~isfile(basename(this.fdg_ic_fqfn_nii))
                copyfile(this.fdg_ic_fqfn_nii);
            end
            if ~isfile(basename(this.fdg_nifti_4dfp_fqfn_nii))
                copyfile(this.fdg_nifti_4dfp_fqfn_nii);
            end
            if ~isfile_4dfp(mybasename(this.fdg_fqfn_4dfp))
                copyfile([myfileprefix(this.fdg_fqfn_4dfp) '.4dfp.*']);
            end
            if ~isfile([this.T1001 '.nii.gz'])
                copyfile(fullfile(this.anatDir, [this.T1001 '.nii.gz']));
            end
            if ~isfile_4dfp(this.T1001)
                copyfile(fullfile(this.anatDir, [this.T1001 '.4dfp.*']));
            end
            if ~isfile('T1.mgz')
                copyfile(fullfile(this.mriDir, 'T1.mgz'));
            end
            if ~isfile('T1.nii.gz')
                mlbash('mri_convert T1.mgz T1.nii.gz')
            end
            if ~isfile('brain.mgz')
                copyfile(fullfile(this.mriDir, 'brain.mgz'));
            end
            if ~isfile('brain.nii.gz')
                mlbash('mri_convert brain.mgz brain.nii.gz')
            end
            this.T1001_ic_nii = ImagingContext2([this.T1001 '.nii.gz'], 'compatibility', this.compatibility);
            this.T1001_ic_4dfp = ImagingContext2([this.T1001 '.4dfp.hdr'], 'compatibility', this.compatibility);
        end
    end

    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
