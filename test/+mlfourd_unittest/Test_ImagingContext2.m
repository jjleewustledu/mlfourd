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
        do_legacy = true
        do_view = false
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
    
    methods (Static)        
        function hdr = adjustLegacyHdr(hdr, hdr2)            
            hdr.hk.regular = 'r';
            hdr.dime.dim(1) = 3; % hdr2 is more NIfTI compliant
            hdr.dime.pixdim(6:8) = [1 1 1];
            hdr.hist.descrip = hdr2.hist.descrip;
            hdr.hist.sform_code = 1;
            hdr.hist.qoffset_x = hdr2.hist.qoffset_x;
            hdr.hist.qoffset_y = hdr2.hist.qoffset_y;
            hdr.hist.qoffset_z = hdr2.hist.qoffset_z;
            hdr.extra = hdr2.extra;
        end
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
        function test_ctor_aufbau(this)
 			import mlfourd.*;
            fqfn = fullfile(this.TmpDir, sprintf('test_ctor_trivial_D%s.4dfp.hdr', datestr(now, 30)));
            
            ic = ImagingContext2(fqfn); % trivial ctor with fqfn not on filesystem
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.FilesystemTool');
            this.verifyEqual(ic.fqfilename, fqfn);
            this.verifyTrue(~lexist(fqfn, 'file'));
            
            ic.selectImagingFormatTool; % prepare for aufbau
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.ImagingFormatTool');    
            this.verifyEqual(ic.fqfilename, fqfn);
            this.verifyTrue(~lexist(fqfn, 'file'));
            
            % do aufbau
            ffp = ic.fourdfp;
            ffp.img = [1 2 3];
            ic.updateImagingFormatTool(ffp);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.ImagingFormatTool');    
            this.verifyEqual(ic.fqfilename, fqfn);
            this.verifyEqual(ic.fourdfp.img, single([1 2 3]));
        end
        function test_legacy_ImagingContext(this)
            if (~this.do_legacy); return; end
            import mlfourd.*;
            
            ic2 = ImagingContext2([this.t1 '.4dfp.hdr']);                      
            ic  = ImagingContext( [this.t1 '.4dfp.hdr']);
            hdr = this.adjustLegacyHdr(ic.fourdfp.hdr, ic2.fourdfp.hdr);
            this.verifyEqual(hdr,            ic2.fourdfp.hdr, 'RelTol', 1e-4);
            this.verifyEqual(ic.fourdfp.img, ic2.fourdfp.img);
            
            ic2_ic = ImagingContext2(ic);
            hdr_ = this.adjustLegacyHdr(ic2_ic.fourdfp.hdr, ic2.fourdfp.hdr);
            this.verifyEqual(hdr_,               ic2.fourdfp.hdr, 'RelTol', 1e-4);
            this.verifyEqual(ic2_ic.fourdfp.img, ic2.fourdfp.img);            
            
            ic_ic2 = ImagingContext( ic2);
            hdr__ = this.adjustLegacyHdr(ic_ic2.fourdfp.hdr, ic2.fourdfp.hdr);
            this.verifyEqual(hdr__,              ic2.fourdfp.hdr, 'RelTol', 1e-4);
            this.verifyEqual(ic_ic2.fourdfp.img, ic2.fourdfp.img);     
        end
        function test_legacy_niftid(this)
            if (~this.do_legacy); return; end
            import mlfourd.*;
            
            ifc = ImagingFormatContext([this.t1 '.4dfp.hdr']);                      
            ffp = mlfourdfp.Fourdfp(NIfTId( [this.t1 '.4dfp.hdr']));
            hdr = this.adjustLegacyHdr(ffp.hdr, ifc.hdr);
            this.verifyEqual(hdr,    ifc.hdr, 'RelTol', 1e-4);
            this.verifyEqual(ffp.img, ifc.img);
            
            ifc_niid = ImagingFormatContext(ffp);
            hdr_     = this.adjustLegacyHdr(ifc_niid.hdr, ifc.hdr);
            this.verifyEqual(hdr_,         ifc.hdr, 'RelTol', 1e-4);
            this.verifyEqual(ifc_niid.img, ifc.img);            
            
            niid_ifc = mlfourdfp.Fourdfp(NIfTId(ifc));
            hdr__    = this.adjustLegacyHdr(niid_ifc.hdr, ifc.hdr);
            this.verifyEqual(hdr__,        ifc.hdr, 'RelTol', 1e-4);
            this.verifyEqual(niid_ifc.img, ifc.img); 
        end
        function test_legacy_numericalNiftid(this)
            if (~this.do_legacy); return; end
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
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.BlurringTool'); % BlurringTool => ImagingFormatTool
        end
        function test_selectFilesystemTool(this)
            fqfn = this.testObj.fqfilename;
            deleteExisting(fqfn);
            this.testObj.selectFilesystemTool;
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.FilesystemTool');
            this.verifyEmpty(this.testObj.imagingInfo);
            this.verifyEmpty(this.testObj.logger);
            this.verifyTrue(lexist(fqfn, 'file')); % selecting FilesystemTool serializes data
            delete(fqfn);
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
            if (this.do_view)
                ic2.fsleyes; end
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
            ic  = ImagingContext2(img);  
            ic_ = ImagingContext2(img);            
            ic2 = ic.timeContracted([2 3]);
            this.verifyEqual(double(ic2), 2*ones(2,2,2));
            ic3 = ic_.timeContracted;
            this.verifyEqual(double(ic3), 4*ones(2,2,2));
        end
        function test_volumeAveraged(this)
            img  = ones(2,2,2,4);
            mimg = zeros(2,2,2);
            mimg(1,1,1) = 1;

            import mlfourd.*;            
            ic  = ImagingContext2(img);   
            ic_ = ImagingContext2(img);        
            ic2 = ic.volumeAveraged(mimg);
            this.verifyEqual(double(ic2), [1 1 1 1]);
            ic3 = ic_.volumeAveraged;
            this.verifyEqual(double(ic3), [1 1 1 1]);
        end
        function test_volumeContracted(this)
            img  = ones(2,2,2,4);
            mimg = zeros(2,2,2);
            mimg(1,1,1) = 1;

            import mlfourd.*; 
            ic  = ImagingContext2(img);  
            ic_ = ImagingContext2(img);
            ic2 = ic.volumeContracted(mimg);
            this.verifyEqual(double(ic2), [1 1 1 1]);
            ic3 = ic_.volumeContracted;
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
%            icz  = mlfourd.ImagingContext2([this.fslroi '.nii.gz']);            
            
            zin  = ic.zoomed(44, 88, 62, 124, 1, -1);
            zin.save;
            zout = zin.zoomed(-44, 176, -62, 248, 1, -1);
            zout.save
            if (this.do_view)
                ic.fsleyes(zin.fqfilename, zout.fqfilename); end
            deleteExisting(zin.fqfilename);
            deleteExisting(zout.fqfilename);
        end
        function test_qsforms(this)
            ic = mlfourd.ImagingContext2([this.t1 '.nii.gz']);
            ic.saveas([this.t1 '_test.nii.gz']);            
            if (this.do_view)
                ic.fsleyes([this.t1 '_test.nii.gz']); end
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
        function test_close(this)
            
        end
        
        function test_ifh(this)
            pwd0_ = pushd(this.TmpDir);
            
            this.assertTrue(lexist([this.t1 '.4dfp.hdr'], 'file'));
            testfp = sprintf('test_ifh');
            deleteExisting([testfp '*']);
            ic2 = mlfourd.ImagingContext2([this.t1 '.4dfp.hdr']);
            ic2.saveas([testfp '.4dfp.hdr']);
            ifh = mlfourdfp.IfhParser.load([testfp '.4dfp.ifh']);
            this.verifyEqual( ...            
                ic2.fourdfp.imagingInfo.ifh.nameOfDataFile, ...
                ifh.nameOfDataFile);
            
            popd(pwd0_);
        end
	end

 	methods (TestClassSetup)
		function setupImagingContext2(this)
 		end
	end

 	methods (TestMethodSetup)
		function setupImagingContext2Test(this)
 			import mlfourd.*;
 			this.testObj = ImagingContext2(1);
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

