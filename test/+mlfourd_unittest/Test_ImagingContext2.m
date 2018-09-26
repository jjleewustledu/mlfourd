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
        fslroi = 't1_dcm2niix_fslroi'
        fslroi_xmin  =  65
        fslroi_xsize =  44   % 66 remaining
        fslroi_xzoom =  0.25
        fslroi_ymin  =  82    
        fslroi_ysize =  83   % 82 remaining
        fslroi_yzoom =  1/3
        fslroi_zmin  =  0
        fslroi_zsize = -1    % 255 remaining
        fslroi_zzoom =  1
        pwd0
 		registry
        t1 = 't1_dcm2niix'
 		testObj
    end
    
    properties (Dependent)
        dataDir
        fslroi_zoom
        TmpDir
    end
    
    methods
        
        %% GET
    
        function g = get.dataDir(~)
            g = fullfile(getenv('HOME'), 'MATLAB-Drive', 'mlfourdfp', 'data', '');
        end
        function g = get.fslroi_zoom(this)
            g = [this.fslroi_xzoom this.fslroi_yzoom this.fslroi_zzoom];
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
        
        %% DynamicsTool
        
        function test_timeAveraged(this)
            img = ones(2,2,2,4);

            import mlfourd.*;            
            ic = ImagingContext2(img);            
            ic2 = ic.timeAveraged([2 3]);
            this.verifyEqual(double(ic2), ones(2,2,2));
            ic3 = ic.timeAveraged;
            this.verifyEqual(double(ic3), ones(2,2,2));
        end
        function test_timeContracted(this)
            img = ones(2,2,2,4);

            import mlfourd.*;            
            ic = ImagingContext2(img);            
            ic2 = ic.timeContracted([2 3]);
            this.verifyEqual(double(ic2), 2*ones(2,2,2));
            ic3 = ic.timeContracted;
            this.verifyEqual(double(ic3), 4*ones(2,2,2));
        end
        function test_volumeAveraged(this)
            img  = ones(2,2,2,4);
            mimg = zeros(2,2,2);
            mimg(1,1,1) = 1;

            import mlfourd.*;            
            ic = ImagingContext2(img);            
            ic2 = ic.volumeAveraged(mimg);
            this.verifyEqual(double(ic2), [1 1 1 1]);
            ic3 = ic.volumeAveraged;
            this.verifyEqual(double(ic3), [1 1 1 1]);
        end
        function test_volumeContracted(this)
            img  = ones(2,2,2,4);
            mimg = zeros(2,2,2);
            mimg(1,1,1) = 1;

            import mlfourd.*; %#ok<NSTIMP>
            ic = ImagingContext2(img);            
            ic2 = ic.volumeContracted(mimg);
            this.verifyEqual(double(ic2), [1 1 1 1]);
            ic3 = ic.volumeContracted;
            this.verifyEqual(double(ic3), [8 8 8 8]);
            
%             h = @improperMask;
%             this.verifyWarning(h(ic, mimg), 'mlfourd:failedToVerify');            
%             function improperMask(ic, mimg)
%                 ic.volumeContracted(2*mimg);
%             end
        end
        
        %% MaskingTool
        
        function test_binarized(this)
            img = zeros(2,2,2,2);
            img(1,1,1,1) = 999;
            img(2,2,2,2) = 999;
            
            import mlfourd.*;
            ic = ImagingContext2(img);
            ic = ic.binarized;
            this.verifyEqual(dipsum(double(ic)), 2);
        end
        function test_count(this)
            img = zeros(2,2,2,2);
            img(1,1,1,1) = 999;
            img(2,2,2,2) = 999;
            
            import mlfourd.*;
            ic = ImagingContext2(img);
            this.verifyEqual(ic.count, 2);
        end
        function test_masked(this)
            
        end
        function test_masked2d(this)
            img   = ones(2,2);            
            mimg2 = zeros(2,2);
            mimg2(1,1) = 1;            
            
            import mlfourd.*;
            ic = ImagingContext2(img);
            ic = ic.masked(mimg2);
            this.verifyEqual(dipsum(double(ic)), 1);
        end
        function test_masked3d(this)
            img   = ones(2,2,2);
            mimg2 = zeros(2,2);   mimg2(1,1) = 1;            
            mimg3 = zeros(2,2,2); mimg3(1,1,1) = 1;
            
            import mlfourd.*;
            ic  = ImagingContext2(img);
            ic2 = ic.masked(mimg2);
            this.verifyEqual(dipsum(double(ic2)), 2);
            ic3 = ic.masked(mimg3);
            this.verifyEqual(dipsum(double(ic3)), 1);            
        end
        function test_masked4d(this)
            img   = ones(2,2,2,2);
            mimg3 = zeros(2,2,2);   mimg3(1,1,1) = 1;
            mimg4 = zeros(2,2,2,2); mimg4(1,1,1,1) = 1;
            
            import mlfourd.*;
            ic  = ImagingContext2(img);
            ic3 = ic.masked(mimg3);
            this.verifyEqual(dipsum(double(ic3)), 2);
            ic4 = ic.masked(mimg4);
            this.verifyEqual(dipsum(double(ic4)), 1);
        end
        function test_maskedMaths(this)
            img   = ones(2,2,2,2);
            mimg3 = zeros(2,2,2); mimg3(1,1,1) = 1; mimg3(2,2,2) = 1;            
            
            import mlfourd.*;
            ic  = ImagingContext2(img);
            ic3 = ic.maskedMaths(mimg3, @sum);
            this.verifyEqual(dipsum(double(ic3)), 2);
        end
        function test_maskedByZ(this)
        end
        function test_thresh(this)
        end
        function test_threshp(this)
        end
        function test_uthresh(this)
        end
        function test_uthreshp(this)
        end
        function test_zoomed(this)
            this.createFslroi;            
            ic   = mlfourd.ImagingContext2([this.t1 '.nii.gz']);            
            icz  = mlfourd.ImagingContext2([this.fslroi '.nii.gz']);            
            
            zin  = ic.zoomed([0.25 2/3 1]);
%             zin.save;
%             zout = zin.zoomed([4 3/2 1]);
%             zout.save
%             ic.fsleyes(zin.fqfilename, zout.fqfilename);
%             delete(zin.fqfilename);
%             delete(zout.fqfilename);
        end
        function test_qsforms(this)            
            ic = mlfourd.ImagingContext2([this.t1 '.nii.gz']);
            ic.saveas([this.t1 '_test.nii.gz']);
            ic.fsleyes([this.t1 '_test.nii.gz']);
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
                copyfile(fullfile(this.dataDir, [this.fdg '.4dfp*']));
            end
            if (~lexist([this.fdg '.nii.gz']))
                copyfile(fullfile(this.dataDir, [this.fdg '.nii.gz']));
            end
            if (~lexist([this.t1 '.nii.gz']))
                copyfile(fullfile(this.dataDir, [this.t1 '.nii.gz']));
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
        function createFslroi(this)
            if (lexist(fullfile(this.TmpDir, this.fslroi), 'file'))
                return
            end
            mlbash(sprintf('fslroi %s %s %i %i %i %i %i %i', ...
                this.t1, this.fslroi, ...
                this.fslroi_xmin, this.fslroi_xsize, ...
                this.fslroi_ymin, this.fslroi_ysize, ...
                this.fslroi_zmin, this.fslroi_zsize));
        end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

