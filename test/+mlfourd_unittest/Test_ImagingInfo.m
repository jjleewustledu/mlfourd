classdef Test_ImagingInfo < matlab.unittest.TestCase
	%% TEST_IMAGINGINFO 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImagingInfo)
 	%          >> result  = run(mlfourd_unittest.Test_ImagingInfo, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 24-Jul-2018 15:39:50 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
        pwd0
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
		function test_loadFdg(this)
 			import mlfourd.*;
            ref = mlpet.ReferenceFdgSumt;
            ref.copyfiles(this.TmpDir);
            finfo = mlfourd.FourdfpInfo( ...
                ref.dicomAsFourdfp, 'N', true, 'datatype', 4); % 0
            ref_ = ref.asStruct;
            fnii_ = finfo.load_nii;
            
            % reference
            this.verifyEqual(ref_.hdr.dime.dim, [3 344 344 127 1 1 1 1]);
            this.verifyEqual(ref_.hdr.dime.pixdim, [-1 2.086260080337524 2.086260080337524 2.031250000000000 0 0 0 0], 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.qform_code, 1);
            this.verifyEqual(ref_.hdr.hist.sform_code, 1);
            this.verifyEqual(ref_.hdr.hist.quatern_b, 0);
            this.verifyEqual(ref_.hdr.hist.quatern_c, 1);
            this.verifyEqual(ref_.hdr.hist.quatern_d, 0);
            this.verifyEqual(ref_.hdr.hist.qoffset_x, 3.583241271972656e+02, 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.qoffset_y, -3.564754333496094e+02, 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.qoffset_z, -1.200311584472656e+02, 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.srow_x, [-2.086260080337524 0 0 3.583241271972656e+02], 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.srow_y, [0 2.086260080337524 0 -3.564754333496094e+02], 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.srow_z, [0 0 2.031250000000000 -1.200311584472656e+02], 'RelTol', 1e-6);
         
            % note diff from fnii_
            this.verifyEqual(finfo.Filename, 'fdgv2ConvertedDefault_dcm2niix.4dfp.hdr');
            this.verifyEqual(finfo.Extents, int32(16384));
            this.verifyEqual(finfo.raw.dim, [4 344 344 127 1 1 1 1]);
            this.verifyEqual(finfo.raw.pixdim, [0 2.086260080337524 2.086260080337524 2.031250000000000 0 0 0 0], 'RelTol', 1e-6);
            this.verifyEqual(finfo.raw.qform_code, 0);
            this.verifyEqual(finfo.raw.sform_code, 1);
            this.verifyEqual(finfo.raw.srow_x, [-2.08626008033751 0 0 357.7936037778854], 'RelTol', 1e-6);
            this.verifyEqual(finfo.raw.srow_y, [0 2.0862600803375 0 -357.7936037778854], 'RelTol', 1e-6);
            this.verifyEqual(finfo.raw.srow_z, [0 0 2.0312500000000 -127.9687500000000], 'RelTol', 1e-6);
            this.verifyEqual(finfo.hdr.hist.originator, [357.793603777885 357.793603777885 127.96875], 'RelTol', 1e-6);
            
            this.verifyEqual(fnii_.hdr.dime.dim, [4 344 344 127 1 1 1 1]);
            this.verifyEqual(fnii_.hdr.dime.pixdim, [0 2.086260080337524 2.086260080337524 2.031250000000000 0 0 0 0], 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.qform_code, 0);
            this.verifyEqual(fnii_.hdr.hist.sform_code, 1);
            this.verifyEqual(fnii_.hdr.hist.quatern_b, 0);
            this.verifyEqual(fnii_.hdr.hist.quatern_c, 1);
            this.verifyEqual(fnii_.hdr.hist.quatern_d, 0);
            this.verifyEqual(fnii_.hdr.hist.qoffset_x, 357.793603777885, 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.qoffset_y, -357.793603777885, 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.qoffset_z, -127.96875, 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.srow_x, [-2.08626008033752 0 0 357.7936037778854], 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.srow_y, [0 2.08626008033752 0 -357.7936037778854], 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.srow_z, [0 0 2.03125 -127.96875], 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.originator, [357.7936037778854 357.7936037778854 127.96875], 'RelTol', 1e-6);
 		end
		function test_loadMprage(this)
 			import mlfourd.*;
            ref = mlfourd.ReferenceMprage;
            ref.copyfiles(this.TmpDir);
            finfo = mlfourd.FourdfpInfo( ...
                ref.dicomAsFourdfp, 'N', true, 'datatype', 4);
            ref_ = ref.asStruct;
            fnii_ = finfo.load_nii;
            
            % reference
            this.verifyEqual(ref_.hdr.dime.dim, [3 176 248 256 1 1 1 1]);
            this.verifyEqual(ref_.hdr.dime.pixdim, [1 0.999997019767761 1 1 2.40000009536743 0 0 0], 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.qform_code, 1);
            this.verifyEqual(ref_.hdr.hist.sform_code, 1);
            this.verifyEqual(ref_.hdr.hist.quatern_b, 0);
            this.verifyEqual(ref_.hdr.hist.quatern_c, -0.014834761619568, 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.quatern_d, 0);
            this.verifyEqual(ref_.hdr.hist.qoffset_x, -83.693443298339844, 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.qoffset_y, -81.353515625000000, 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.qoffset_z, -1.379176177978516e+02, 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.srow_x, [0.999557375907898 0 -0.029666258022189 -83.693443298339844], 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.srow_y, [0 1 0 -81.353515625000000], 'RelTol', 1e-6);
            this.verifyEqual(ref_.hdr.hist.srow_z, [0.029666183516383 0 0.999559879302979 -1.379176177978516e+02], 'RelTol', 1e-6);
            
            % note diff from fnii_
            this.verifyEqual(finfo.Filename, 't1_dcm2niix.4dfp.hdr');
            this.verifyEqual(finfo.Extents, int32(16384));
            this.verifyEqual(finfo.raw.dim, [4 176 248 256 1 1 1 1]);
            this.verifyEqual(finfo.raw.pixdim, [0 0.999997019767761 1 1 0 0 0 0], 'RelTol', 1e-6);
            this.verifyEqual(finfo.raw.qform_code, 0);
            this.verifyEqual(finfo.raw.sform_code, 1);
            
            this.verifyEqual(fnii_.hdr.dime.dim, [4 176 248 256 1 1 1 1]);
            this.verifyEqual(fnii_.hdr.dime.pixdim, [0 0.999997496604919 1 1 0 0 0 0], 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.qform_code, 0);
            this.verifyEqual(fnii_.hdr.hist.sform_code, 1);
            this.verifyEqual(fnii_.hdr.hist.quatern_b, 0);
            this.verifyEqual(fnii_.hdr.hist.quatern_c, 1);
            this.verifyEqual(fnii_.hdr.hist.quatern_d, 0);
            this.verifyEqual(fnii_.hdr.hist.qoffset_x, 87.499739229679108, 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.qoffset_y, -123.5);
            this.verifyEqual(fnii_.hdr.hist.qoffset_z, -127.5);
            this.verifyEqual(fnii_.hdr.hist.srow_x, [-0.999997019767761 0 0 87.4997392296791], 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.srow_y, [0 1 0 -123.5], 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.srow_z, [0 0 1 -127.5], 'RelTol', 1e-6);
            this.verifyEqual(fnii_.hdr.hist.originator, [87.4997392296791 123.5 127.5], 'RelTol', 1e-6);
 		end
		function test_loadSurfMprage(this)
 			import mlfourd.*;
            ref = mlfourd.ReferenceMprage;
            ref.copyfiles(this.TmpDir);
            minfo = mlfourd.MGHInfo( ...
                ref.surferAsMgz, 'N', true, 'datatype', 4);
            mnii_ = minfo.load_nii;
            
            % ref_ is identical to that in test_loadMprage            
            
            this.verifyEqual(minfo.Filename, '/Users/jjlee/Tmp/001.nii.gz');            
            this.verifyEqual(minfo.raw.dim, [3 176 248 256 1 1 1 1]);
            this.verifyEqual(minfo.raw.pixdim, [-1 0.999559879302979 1 0.999559879302979 2.400000095367432 1 1 1], 'RelTol', 1e-6);
            this.verifyEqual(minfo.raw.qform_code, 0);
            this.verifyEqual(minfo.raw.sform_code, 1);
            
            this.verifyEqual(mnii_.hdr.dime.dim, [3 176 248 256 1 1 1 1]);
            this.verifyEqual(mnii_.hdr.dime.pixdim, [-1 0.999559879302979 1 0.999559879302979 2.400000095367432 1 1 1], 'RelTol', 1e-6);
            this.verifyEqual(mnii_.hdr.hist.qform_code, 0);
            this.verifyEqual(mnii_.hdr.hist.sform_code, 1);
            this.verifyEqual(mnii_.hdr.hist.quatern_b, 1.07962474515944e-08, 'RelTol', 1e-6);
            this.verifyEqual(mnii_.hdr.hist.quatern_c,  0.999889969825745, 'RelTol', 1e-6);
            this.verifyEqual(mnii_.hdr.hist.quatern_d, -1.07962474515944e-08, 'RelTol', 1e-6);
            this.verifyEqual(mnii_.hdr.hist.qoffset_x, 91.2290878295898, 'RelTol', 1e-6);
            this.verifyEqual(mnii_.hdr.hist.qoffset_y, -81.3535232543945, 'RelTol', 1e-6);
            this.verifyEqual(mnii_.hdr.hist.qoffset_z, -132.726028442383, 'RelTol', 1e-6);
            this.verifyEqual(mnii_.hdr.hist.srow_x, [-0.999559879302979 0 -0.029666258022189 91.229095458984375], 'RelTol', 1e-6);
            this.verifyEqual(mnii_.hdr.hist.srow_y, [0 1 0 -81.353515625000000], 'RelTol', 1e-6);
            this.verifyEqual(mnii_.hdr.hist.srow_z, [-0.0296662449837 0 0.9995598793030 -132.7260437011719], 'RelTol', 1e-6);
            this.verifyEqual(mnii_.hdr.hist.originator, [84.73073504851 82.35351562500 133.78448490122  -13774 32760], 'RelTol', 1e-6);
 		end
	end

 	methods (TestClassSetup)
		function setupImagingInfo(this) %#ok<MANU>
 		end
	end

 	methods (TestMethodSetup)
		function setupImagingInfoTest(this)
 			import mlfourd.*;
 			this.testObj = ImagingInfo('notafile.nii.gz');
            this.pwd0 = pushd(this.TmpDir);
 			this.addTeardown(@this.cleanTestMethod);
 		end
    end
    
    %% PRIVATE

	properties (Access = private)
        refMpr_
        refFdgSumt_
    end
    
    methods (Access = private)
		function cleanTestMethod(this)
            popd(this.pwd0);
        end 
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

