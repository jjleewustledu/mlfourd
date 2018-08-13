classdef Test_ImagingFormatContext < matlab.unittest.TestCase
	%% TEST_IMAGINGFORMATCONTEXT 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImagingFormatContext)
 	%          >> result  = run(mlfourd_unittest.Test_ImagingFormatContext, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 24-Jul-2018 01:23:51 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
        doview = false
        noDelete = false
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
        function test_ctor_noExtension(this)
            import mlfourd.*;
            niih = ImagingFormatContext(myfileprefix(this.ref.dicomAsNiigz));
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(niih.size, [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            this.verifyClass(niih.imagingInfo, 'mlfourdfp.FourdfpInfo');
            
            if (this.doview); niih.fsleyes; end
        end      
        function test_ctor_NIfTId(this)
 			import mlfourd.*;            
            niih = ImagingFormatContext(NIfTId(this.ref.dicomAsNiigz));
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(niih.size, [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            this.verifyClass(niih.imagingInfo, 'mlfourd.NIfTIInfo');
            
            if (this.doview); niih.fsleyes; end
        end  
        function test_mutateInnerImagingFormatByFilesuffix(this) 
 			import mlfourd.*;                    
            tmp = tempFqfilename(fullfile(pwd, 'test_mutateInnerImagingFormatByFilesuffix'));            
            niih_ = ImagingFormatContext(this.ref.dicomAsNiigz);   
            
            niih = niih_.saveas([tmp '.nii.gz']);
            this.verifyTrue(lexist(niih.fqfilename, 'file'));
            if (this.doview)
                mlbash(sprintf('fsleyes %s', niih.fqfilename)); 
            end
            this.deleteExisting([tmp '.nii.*']);
            
            tmp = tempFqfilename(fullfile(pwd, 'test_mutateInnerImagingFormatByFilesuffix')); % prevent overwriting tmp.nii.* 
            niih = niih_.saveas([tmp '.mgz']);
            this.verifyTrue(lexist(niih.fqfilename, 'file'));
            if (this.doview)
                mlbash(sprintf('fsleyes %s', niih.fqfilename)); 
            end
            this.deleteExisting([tmp '.mgz']);      
            
            niih = niih_.saveas([tmp '.4dfp.hdr']);
            this.verifyTrue(lexist_4dfp(niih.fqfilename, 'file'));
            if (this.doview)
                mlbash(sprintf('fsleyes %s', niih.fqfilename)); 
            end
            this.deleteExisting([tmp '.4dfp.*']);           
            
        end
        function test_ctor_t1niigz(this) 
 			import mlfourd.*;           
            niih = ImagingFormatContext(this.ref.dicomAsNiigz); 
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_ctor_t1niigz'));
            niih.saveas([tmp '.nii.gz']);
            this.verifyTrue(lexist([tmp '.nii.gz'], 'file'));
            this.deleteExisting([tmp '.nii.*']);
            if (this.doview); niih.fsleyes; end
        end
        function test_ctor_t14dfp(this)
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.dicomAsFourdfp, 'circshiftK', 0, 'N', true); % sagittal            
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
               
            tmp = tempFqfilename(fullfile(pwd, 'test_ctor_t14dfp'));
            niih.saveas([tmp '.4dfp.hdr']);
            this.verifyTrue(lexist_4dfp(tmp, 'file'));
            this.deleteExisting([tmp '.4dfp.*']);
            if (this.doview); niih.fsleyes; end 
        end
        function test_ctor_001mgz(this)
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.surferAsMgz); % sagittal            
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [248 256 176]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_ctor_001mgz'));
            niih.saveas([tmp '.mgz']);
            this.verifyTrue(lexist([tmp '.mgz'], 'file'));
            this.deleteExisting([tmp '.mgz']);
            if (this.doview); niih.freeview; end
        end
        function test_ctor_001niigz(this)
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.surferAsNiigz); % sagittal            
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [248 256 176]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_ctor_0014dfp(this) 
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.surferAsFourdfp, 'circshiftK', 0, 'N', true); % sagittal            
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_ctor_ana001(this) 
 			import mlfourd.*;
            niih = ImagingFormatContext('ana001.hdr', 'circshiftK', 0, 'N', false); % sagittal            
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.hdr');
            
            if (this.doview); niih.fsleyes; end            
        end
        function test_ctor_T1mgz(this)
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.T1AsMgz);
            this.verifyEqual(class(niih.img), 'uint8');
            this.verifyEqual(size(niih.img),  [256 256 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            
            if (this.doview); niih.freeview; end
        end
        function test_ctor_T1niigz(this)
 			import mlfourd.*;            
            niih = ImagingFormatContext(this.ref.T1AsNiigz);
            this.verifyEqual(class(niih.img), 'uint8');
            this.verifyEqual(size(niih.img),  [256 256 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_ctor_T14dfp(this) 
 			import mlfourd.*;            
            niih = ImagingFormatContext(this.ref.T1AsFourdfp, 'circshiftK', 0, 'N', true);
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [256 256 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            
            if (this.doview); niih.fsleyes; end
        end
        
        function test_fdg4dfp(this)
            %ref = mlfourd.ReferenceFdg;
            %ref.copyfiles(this.TmpDir);
        end
	end

 	methods (TestClassSetup)
		function setupNIfTIHeavy(this)
 			import mlfourd.*;
 			this.testObj_ = ImagingFormatContext([]);
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
        function deleteExisting(this, varargin)
            if (this.noDelete)
                return
            end
            deleteExisting(varargin{:});
        end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

