classdef Test_ImagingContext2 < matlab.unittest.TestCase
	%% TEST_IMAGINGCONTEXT2 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImagingContext2)
 	%          >> result  = run(mlfourd_unittest.Test_ImagingContext2, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 10-Aug-2018 19:43:13 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
        fdg = 'fdgv1r1_sumt'
        pwd0
 		registry
 		testObj
    end
    
    properties (Dependent)
        dataDir
        TmpDir
    end
    
    methods
        
        %% GET
    
        function g = get.dataDir(~)
            g = fullfile(getenv('HOME'), 'MATLAB-Drive', 'mlfourdfp', 'data', '');
        end
        function g = get.TmpDir(~)
            g = fullfile(getenv('HOME'), 'Tmp', '');
        end
    end

	methods (Test)
		function test_ctor(this)
 			import mlfourd.*;
            fdg_ = ImagingFormatContext(fullfile(this.dataDir, [this.fdg '.4dfp.hdr']));
            
            ic  = ImagingContext2;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.ImagingFormatTool');
            ic2 = ImagingContext2(fdg_);
            this.verifyEqual(ic2.stateTypeclass, 'mlfourd.ImagingFormatTool');
            ic3 = ImagingContext2(ic2);
            this.verifyEqual(ic3.stateTypeclass, 'mlfourd.ImagingFormatTool');
            ic4 = ImagingContext2(ic3);
            this.verifyEqual(ic4.stateTypeclass, 'mlfourd.ImagingFormatTool');
        end
        function test_selectImagingTool(this)
            ic = mlfourd.ImagingContext2;       
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.ImagingFormatTool');   
            ic.selectImagingFormatTool;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.ImagingFormatTool');   
            ic.selectNumericalTool;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NumericalTool');   
            ic.selectBlurringTool;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.BlurringTool');              
            ic.selectImagingFormatTool;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.ImagingFormatTool');   
        end
        function test_fourdfp(this)
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.ImagingFormatTool');   
            this.verifyClass(this.testObj.fourdfp, 'mlfourd.ImagingFormatContext');
            this.verifyClass(this.testObj.fourdfp.imagingInfo, 'mlfourd.NIfTIInfo');
            this.verifyEqual(this.testObj.fourdfp.innerTypeclass, 'mlfourd.InnerNIfTI');
            this.verifyEqual(this.testObj.filesuffix, '.4dfp.hdr');
        end
        function test_nifti(this)
            this.verifyClass(this.testObj.nifti, 'mlfourd.ImagingFormatContext');
            this.verifyClass(this.testObj.nifti, 'mlfourd.ImagingFormatContext');
            this.verifyClass(this.testObj.nifti.imagingInfo, 'mlfourd.NIfTIInfo');
            this.verifyEqual(this.testObj.nifti.innerTypeclass, 'mlfourd.InnerNIfTI');
            this.verifyEqual(this.testObj.filesuffix, '.nii.gz');
        end
        
        %% mlpatterns.HandleNumerical
        
        function test_not(this)
            notTestObj = ~this.testObj;
            this.verifyClass(notTestObj, 'mlfourd.ImagingContext2');
            this.verifyEqual(this.testObj.nifti.img, 1);
            this.verifyEqual(notTestObj.nifti.img, false);
            this.verifyEqual(notTestObj.stateTypeclass, 'mlfourd.NumericalTool');
        end
        function test_plus(this)
            testobj = this.testObj + this.testObj;
            this.verifyClass(testobj, 'mlfourd.ImagingContext2');
            this.verifyEqual(this.testObj.nifti.img, 1);
            this.verifyEqual(testobj.nifti.img, 2);
            this.verifyEqual(testobj.stateTypeclass, 'mlfourd.NumericalTool');
        end
        function test_axpy(this)
            testobj = copy(this.testObj);
            testobj.fileprefix = 'test_axpy_testobj';
            product = testobj*2 + this.testObj;
            this.verifyEqual(product.nifti.img, 3);
            this.verifyEqual(testobj.nifti.img, 1);
            this.verifyEqual(testobj.stateTypeclass, 'mlfourd.NumericalTool');
        end
        function test_eq(this)
            ic2 = this.testObj == this.testObj;
            this.verifyClass(ic2, 'mlfourd.ImagingContext2');
            this.verifyTrue(ic2.nifti.img);
        end
        
        %% BlurringTool
        
        function test_blurred(this)
            import mlfourd.*;
            fdg_ = ImagingFormatContext(fullfile(this.dataDir, [this.fdg '.4dfp.hdr']));
            fdg_.img(:,:,:,2) = fdg_.img;
            
            ic2_ = ImagingContext2(fdg_);
            ic2  = ic2_.blurred([1 10 20]);
            ic2.fsleyes;
            this.verifyTrue(lstrfind(ic2.fileprefix, '_b200'));
        end
        
        %%
        
        function test_save(this)
            this.testObj.save;
            this.verifyTrue(lexist(this.testObj.fqfilename, 'file'));
            delete(this.testObj.fqfilename);
        end
        function test_saveas(this)
            this.testObj.saveas([this.testObj.fqfileprefix '_test_savesas']);
            this.verifyTrue(lexist(this.testObj.fqfilename, 'file'));
            delete(this.testObj.fqfilename);
        end
	end

 	methods (TestClassSetup)
		function setupImagingContext2(this)
 			import mlfourd.*;
 			this.testObj_ = ImagingContext2(1);
 		end
	end

 	methods (TestMethodSetup)
		function setupImagingContext2Test(this)
 			this.testObj = this.testObj_;
            this.pwd0 = pushd(this.TmpDir);
            if (~lexist_4dfp(this.fdg))
                copyfile(fullfile(this.dataDir, [this.fdg '.*']));
            end
 			this.addTeardown(@this.cleanTestMethod);
 		end
    end

	properties (Access = private)
 		testObj_
 	end

	methods (Access = private)
		function cleanTestMethod(this)
 		end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

