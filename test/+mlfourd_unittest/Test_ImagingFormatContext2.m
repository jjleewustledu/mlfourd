classdef Test_ImagingFormatContext2 < mlfourd_unittest.Test_Imaging
    %% TEST_IMAGINGFORMATCONTEXT2 exercises ImagingFormatContext2
    %  
    %  Created 15-Dec-2021 13:24:56 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_unittest.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    properties
        testObj
        testTrivial
    end

    properties (Dependent)
    end
    
    methods (Test)
        function test_afun(this)
            import mlfourd.*
            this.assumeEqual(1,1);
            this.verifyEqual(1,1);
            this.assertEqual(1,1);

            this.verifyEqual(pwd, this.TmpDir)
        end
        function test_MatlabFormatTool(this)
            ifc = mlfourd.ImagingFormatContext2(magic(2));
            this.verifyEqual(ifc.stateTypeclass, 'mlfourd.MatlabFormatTool')
            this.verifyEqual(ifc.filesuffix, '.mat')
            ifc.filepath = pwd;
            fqfp = ifc.fqfp;

            ifc.selectNiftiTool();
            this.verifyEqual(ifc.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(ifc.filesuffix, '.nii.gz')
            this.verifyEqual(ifc.img, [1, 3; 4, 2])
            this.verifyEqual(ifc.hdr.dime.dim, [2 2 2 1 1 1 1 1])
            this.verifyEqual(ifc.hdr.dime.datatype, 64)
            this.verifyEqual(ifc.hdr.dime.bitpix, 64)
            this.verifyEqual(ifc.hdr.dime.pixdim, [1 1 1 1 1 1 1 1])
            this.verifyEqual(ifc.hdr.hist.descrip, 'instance of mlfourd.ImagingInfo')
            this.verifyEqual(ifc.hdr.hist.qform_code, 0)
            this.verifyEqual(ifc.hdr.hist.sform_code, 0)
            this.verifyEqual(ifc.hdr.hist.quatern_b, 0)
            this.verifyEqual(ifc.hdr.hist.quatern_c, 0)
            this.verifyEqual(ifc.hdr.hist.quatern_d, 0)
            this.verifyEqual(ifc.hdr.hist.qoffset_x, 0)
            this.verifyEqual(ifc.hdr.hist.qoffset_y, 0)
            this.verifyEqual(ifc.hdr.hist.qoffset_z, 0)
            this.verifyEqual(ifc.hdr.hist.originator, [1 1 0.5], 'AbsTol', 1e-7)
            ifc.save()
            this.verifyTrue(isfile([fqfp '.nii.gz']))
            deleteExisting([fqfp '.nii.gz'])

            ifc.selectFourdfpTool();
            this.verifyEqual(ifc.stateTypeclass, 'mlfourd.FourdfpTool')
            ifc.save()
            this.verifyTrue(isfile([fqfp '.4dfp.hdr']))
            deleteExisting([fqfp '.4dfp.*'])

            ifc.selectMghTool();
            this.verifyEqual(ifc.stateTypeclass, 'mlfourd.MghTool')
            ifc.append_fileprefix('_mghtool');
            ifc.save()
            this.verifyTrue(isfile([fqfp '_mghtool.mgz']))
            deleteExisting([fqfp '_mghtool.mgz'])   
            deleteExisting([fqfp '_mghtool.nii.gz'])            
        end
        function test_hdr_fdg(this)
            %% examines native 4dfp and two instances of nii.gz created by ImagingContext2 and nifti_4dfp, 
            %  then confirms expected hdr.hist, which is discrepant for nifti_4dfp. 

            import mlfourd.*

            % native 4dfp
            ifc_4 = ImagingFormatContext2(this.fdg_fqfn_4dfp);
            this.verifyEqual(ifc_4.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            hdr = ifc_4.hdr;
            this.verifyEqual(ifc_4.stateTypeclass, 'mlfourd.FourdfpTool')
            this.verifyEqual(hdr.hist.qoffset_x, -127)
            this.verifyEqual(hdr.hist.qoffset_y, -127)
            this.verifyEqual(hdr.hist.qoffset_z, -74)
            this.verifyEqual(hdr.hist.srow_x, [2 0 0 -127])
            this.verifyEqual(hdr.hist.srow_y, [0 2 0 -127])
            this.verifyEqual(hdr.hist.srow_z, [0 0 2 -74])
            this.verifyEqual(hdr.hist.originator, [128 128 75])

            % nii.gz from ImagingContext2 (compatibility = true)
            ifc_ = ImagingFormatContext2(this.fdg_ic_fqfn_nii);
            this.verifyEqual(ifc_.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            hdr = ifc_.hdr;
            this.verifyEqual(ifc_.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(hdr.hist.qoffset_x, -127)
            this.verifyEqual(hdr.hist.qoffset_y, -127)
            this.verifyEqual(hdr.hist.qoffset_z, -74)
            this.verifyEqual(hdr.hist.srow_x, [2 0 0 -127])
            this.verifyEqual(hdr.hist.srow_y, [0 2 0 -127])
            this.verifyEqual(hdr.hist.srow_z, [0 0 2 -74])
            this.verifyEqual(hdr.hist.originator, [128 128 75])

            % nii.gz from nifti_4dfp -n
            ifc__ = ImagingFormatContext2(this.fdg_nifti_4dfp_fqfn_nii);
            this.verifyEqual(ifc__.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            hdr = ifc__.hdr;
            this.verifyEqual(ifc__.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(hdr.hist.qoffset_x, 0)
            this.verifyEqual(hdr.hist.qoffset_y, 0)
            this.verifyEqual(hdr.hist.qoffset_z, 0)
            this.verifyEqual(hdr.hist.srow_x, [2 0 0 -127])
            this.verifyEqual(hdr.hist.srow_y, [0 2 0 -127])
            this.verifyEqual(hdr.hist.srow_z, [0 0 2 -68])
            this.verifyEqual(hdr.hist.originator, [128 128 75])
        end
        function test_hdr_T1(this)
            %% creates 4dfp & nii.gz from native mgz, then confirms expected hdr.hist, 
            %  which is discrepant for 4dfp. 

            this.setupT1('.4dfp.hdr')
            this.setupT1('.nii.gz')
            this.setupT1('.mgz')

            % native mgz
            ifc_m = ImagingFormatContext2('T1_test.mgz');
            this.verifyEqual(ifc_m.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            hdr = ifc_m.hdr;
            this.verifyEqual(ifc_m.stateTypeclass, 'mlfourd.MghTool')
            this.verifyEqual(hdr.hist.qoffset_x, 127.5002136230469, 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.qoffset_y, -86.3535156250000, 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.qoffset_z, 119.6074295043945, 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.srow_x, [-1  0 0 127.5002136230469], 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.srow_y, [ 0  0 1 -86.3535156250000], 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.srow_z, [ 0 -1 0 119.6074295043945], 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.originator, [128 128 128])

            % nii.gz from mri_convert
            ifc_n = ImagingFormatContext2('T1_test.nii.gz');
            this.verifyEqual(ifc_n.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            hdr = ifc_n.hdr;
            this.verifyEqual(ifc_n.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(hdr.hist.qoffset_x, 127.5002136230469, 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.qoffset_y, -86.3535156250000, 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.qoffset_z, 119.6074295043945, 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.srow_x, [-1  0 0 127.5002136230469], 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.srow_y, [ 0  0 1 -86.3535156250000], 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.srow_z, [ 0 -1 0 119.6074295043945], 'AbsTol', 1e-6)
            this.verifyEqual(hdr.hist.originator, [128 128 128])

            % 4dfp from nifti_4dfp -4
            import mlfourd.*
            ifc_4 = ImagingFormatContext2('T1_test.4dfp.hdr');
            this.verifyEqual(ifc_4.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            hdr = ifc_4.hdr;
            this.verifyEqual(ifc_4.stateTypeclass, 'mlfourd.FourdfpTool')
            this.verifyEqual(hdr.hist.qoffset_x, -127)
            this.verifyEqual(hdr.hist.qoffset_y, -127)
            this.verifyEqual(hdr.hist.qoffset_z, -127)
            this.verifyEqual(hdr.hist.srow_x, [1 0 0 -127])
            this.verifyEqual(hdr.hist.srow_y, [0 1 0 -127])
            this.verifyEqual(hdr.hist.srow_z, [0 0 1 -127])
            this.verifyEqual(hdr.hist.originator, [128 128 128])

            this.cleanT1('.4dfp.hdr')
            this.cleanT1('.nii.gz')
            this.cleanT1('.mgz')
        end
    end
    
    methods (TestClassSetup)
        function setupImagingFormatContext2(this)
            import mlfourd.*
            this.testTrivial_ = ImagingFormatContext2();
            this.testObj_ = ImagingFormatContext2(1);
        end
    end
    
    methods (TestMethodSetup)
        function setupImagingFormatContext2Test(this)
            import mlfourd.*;
            this.testTrivial = copy(this.testTrivial_);
            this.testObj = copy(this.testObj_);

            setupImagingTest(this);

            this.addTeardown(@this.cleanTestMethod)
        end
    end
    
    properties (Access = protected)
        testObj_
        testTrivial_
    end
    
    methods (Access = protected)
        function cleanTestMethod(this)
            cleanTestMethod@mlfourd_unittest.Test_Imaging(this);
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
