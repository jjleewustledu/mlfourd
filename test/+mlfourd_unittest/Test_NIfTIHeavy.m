classdef Test_NIfTIHeavy < matlab.unittest.TestCase
	%% TEST_NIFTIHEAVY 

	%  Usage:  >> results = run(mlfourd_unittest.Test_NIfTIHeavy)
 	%          >> result  = run(mlfourd_unittest.Test_NIfTIHeavy, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 24-Jul-2018 01:23:51 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
        doview = true
        pwd0
        ref
 		registry
 		testObj
    end
    
    properties (Dependent)
        dataroot
        TmpDir
    end

    methods
        
        %% GET/SET
        
        function g = get.dataroot(~)
            g = fullfile(getenv('HOME'), 'MATLAB-Drive', 'mlfourd', 'data', '');
        end
        function g = get.TmpDir(~)
            g = fullfile(getenv('HOME'), 'Tmp', '');
        end
    end
    
	methods (Test)
        function test_loadNoExtension(this)
            import mlfourd.*;
            niih = NIfTIHeavy(myfileprefix(this.ref.dicomAsNiigz));
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(niih.size, [248 256 176]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            this.verifyClass(niih.imagingInfo, 'mlfourdfp.FourdfpInfo');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_load_t1niigz(this) 
 			import mlfourd.*;           
            niih = NIfTIHeavy(this.ref.dicomAsNiigz); % sagittal            
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_load_t14dfp(this) % orientations ASR LPI differ from t1_dcm2niix.nii.gz, LPI LPI
 			import mlfourd.*;
            niih = NIfTIHeavy(this.ref.dicomAsFourdfp, 'circshiftK', 0, 'N', true); % sagittal            
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            
%             this.verifyEqual(niih.hdr.hk, refs.hdr.hk);
%             this.verifyEqual(niih.hdr.dime, refs.hdr.dime);
%             this.verifyEqual(niih.hdr.hist, refs.hdr.hist);
%             this.verifyEqual(niih.originalType, 'struct');
%             this.verifyEqual(niih.entropy, 0.143003055853027, 'RelTol', 1e-6);
%             this.verifyEqual(niih.filepath, this.TmpDir);
%             this.verifyEqual(niih.machine, 'ieee-le');   
               
            if (this.doview); niih.fsleyes; end 
        end
        function test_load_001mgz(this)
 			import mlfourd.*;
            niih = NIfTIHeavy(this.ref.surferAsMgz); % sagittal            
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [248 256 176]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            
            if (this.doview); niih.freeview; end
        end
        function test_load_001niigz(this)
 			import mlfourd.*;
            niih = NIfTIHeavy(this.ref.surferAsNiigz); % sagittal            
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [248 256 176]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_load_0014dfp(this) % orientations ASR LPI match 001.nii.gz
 			import mlfourd.*;
            niih = NIfTIHeavy(this.ref.surferAsFourdfp, 'circshiftK', 0, 'N', true); % sagittal            
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [248 256 176]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_load_ana001(this) % INCORRECT LABELS in fsleyes
 			import mlfourd.*;
            niih = NIfTIHeavy('ana001.hdr', 'circshiftK', 0, 'N', false); % sagittal            
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.hdr');
            
            if (this.doview); niih.fsleyes; end            
        end
        function test_load_T1mgz(this)
 			import mlfourd.*;
            niih = NIfTIHeavy(this.ref.T1AsMgz); % sagittal            
            this.verifyEqual(class(niih.img), 'uint8');
            this.verifyEqual(size(niih.img),  [256 256 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            
            if (this.doview); niih.freeview; end
        end
        function test_load_T1niigz(this)
 			import mlfourd.*;            
            niih = NIfTIHeavy(this.ref.T1AsNiigz); % sagittal            
            this.verifyEqual(class(niih.img), 'uint8');
            this.verifyEqual(size(niih.img),  [256 256 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_load_T14dfp(this) % orientations differ from T1.nii.gz
 			import mlfourd.*;            
            niih = NIfTIHeavy(this.ref.T1AsFourdfp, 'circshiftK', 0, 'N', true); % sagittal            
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [256 256 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            
            if (this.doview); niih.fsleyes; end
        end
	end

 	methods (TestClassSetup)
		function setupNIfTIHeavy(this)
 			import mlfourd.*;
 			this.testObj_ = NIfTIHeavy([]);
            this.ref = mlfourd.ReferenceMprage;
            this.ref.copyfiles(this.TmpDir);
 		end
	end

 	methods (TestMethodSetup)
		function setupNIfTIHeavyTest(this)
            this.pwd0 = pushd(this.TmpDir);
 			this.testObj = this.testObj_;
 			this.addTeardown(@this.cleanTestMethod);
 		end
    end
    
    %% PRIVATE

	properties (Access = private)
 		testObj_
 	end

	methods (Access = private)
		function cleanTestMethod(this)
            popd(this.pwd0);
 		end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

