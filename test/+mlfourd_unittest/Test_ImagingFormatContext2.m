classdef Test_ImagingFormatContext2 < mlfourd_unittest.Test_Imaging
    %% TEST_IMAGINGFORMATCONTEXT2 exercises ImagingFormatContext2
    %  
    %  Created 15-Dec-2021 13:24:56 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_unittest.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    properties
        ref
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
        function test_711(this)
            if ~this.do_view
                return
            end

            ifc1 = mlfourd.ImagingFormatContext2('711-2B_111.4dfp.hdr');
            ifc1.selectFourdfpTool();
            ifc1.view()

            tmp = strcat(tempname, '.nii.gz');
            ifc1.saveas(tmp)
            mlbash(sprintf('fsleyes %s %s', '711-2B_111.4dfp.hdr', tmp))

            ifc2 = copy(ifc1);
            tmp1 = strcat(tempname, '.4dfp.hdr');
            ifc2.saveas(tmp1)
            mlbash(sprintf('fsleyes %s %s', tmp, tmp1))

            mlbash(sprintf('fsleyes %s %s', tmp1, '711-2B_111.4dfp.hdr'))

            deleteExisting(tmp)
            deleteExisting(tmp1)
        end
        function test_ctorAndSaveas(this)
            pwd0_ = pushd(this.TmpDir);
            
            %% orig has center/mmppix

            ifc = mlfourd.ImagingFormatContext2(fullfile(this.dataDir2, 'fdgcent.4dfp.hdr'));
            ifc.selectFourdfpTool();
            ifc.saveas(fullfile(this.TmpDir, 'fdgcent_dbg.4dfp.hdr'));
            ifh = mlfourdfp.IfhParser.load(fullfile(this.TmpDir, 'fdgcent_dbg.4dfp.ifh'), 'N', true); 
            this.verifyEmpty(ifc.imagingInfo.ifh.mmppix);
            this.verifyEmpty(ifc.imagingInfo.ifh.center);
            %this.verifyEqual(ifc.imagingInfo.ifh.mmppix, [2.086260000000000  -2.086260000000000  -2.031250000000000], 'RelTol');
            %this.verifyEqual(ifc.imagingInfo.ifh.center, [179.4184000000000  -181.5046000000000  -130.0000000000000], 'RelTol');
            this.verifyEmpty(ifh.center); 
            if (this.do_view)
                mlbash(sprintf('fsleyes %s/fdgcent.4dfp.img fdgcent_dbg.4dfp.img', this.dataDir2));
            end
            
            %% orig has no center/mmppix
            
            ifc1 = mlfourd.ImagingFormatContext2(fullfile(this.dataDir2, 'fdgnocent.4dfp.hdr'));
            ifc1.selectFourdfpTool();
            ifc1.saveas(fullfile(this.TmpDir, 'fdgnocent_dbg.4dfp.hdr'));
            ifh1 = mlfourdfp.IfhParser.load(fullfile(this.TmpDir, 'fdgnocent_dbg.4dfp.ifh'), 'N', true);
            this.verifyEmpty(ifc1.imagingInfo.ifh.mmppix);
            this.verifyEmpty(ifc1.imagingInfo.ifh.center);
            this.verifyEmpty(ifh1.center); 
            if (this.do_view)
                mlbash(sprintf('fsleyes %s/fdgnocent.4dfp.img fdgnocent_dbg.4dfp.img', this.dataDir2));
            end
            
            popd(pwd0_);
        end
        function test_LR(this)
            if ~this.do_view
                return
            end

            ifc1 = this.MNI152_LR_nii.nifti;
            ifc1.selectNiftiTool();
            ifc1.view()

            tmp = strcat(tempname, '.4dfp.hdr');
            ifc1.saveas(tmp)
            mlbash(sprintf('fsleyes %s %s', this.MNI152_LR_nii.fqfilename, tmp))

            ifc2 = copy(ifc1);
            tmp1 = strcat(tempname, '.nii.gz');
            ifc2.saveas(tmp1)
            mlbash(sprintf('fsleyes %s %s', tmp, tmp1))

            mlbash(sprintf('fsleyes %s %s', tmp1, this.MNI152_LR_nii.fqfilename))

            deleteExisting(tmp)
            deleteExisting(tmp1)
        end
        function test_MatlabFormatTool(this)
            ifc = mlfourd.ImagingFormatContext2(magic(2));
            this.verifyEqual(ifc.stateTypeclass, 'mlfourd.MatlabFormatTool')
            this.verifyEqual(ifc.filesuffix, '.mat')
            ifc.filepath = pwd;
            fqfp = ifc.fqfp;
            if this.do_view
                ifc.view()
            end

            ifc.selectNiftiTool();
            this.verifyEqual(ifc.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(ifc.filesuffix, '.nii.gz')
            this.verifyEqual(ifc.img, [1, 3; 4, 2])
            this.verifyEqual(ifc.hdr.dime.dim, [2 2 2 1 1 1 1 1])
            this.verifyEqual(ifc.hdr.dime.datatype, 64)
            this.verifyEqual(ifc.hdr.dime.bitpix, 64)
            this.verifyEqual(ifc.hdr.dime.pixdim, [-1 1 1 1 1 1 1 1])
            this.verifyEqual(ifc.hdr.hist.descrip, 'ImagingInfo.initialHdr')
            this.verifyEqual(ifc.hdr.hist.qform_code, 1)
            this.verifyEqual(ifc.hdr.hist.sform_code, 1)
            this.verifyEqual(ifc.hdr.hist.quatern_b, 0)
            this.verifyEqual(ifc.hdr.hist.quatern_c, 1)
            this.verifyEqual(ifc.hdr.hist.quatern_d, 0)
            this.verifyEqual(ifc.hdr.hist.qoffset_x, 0.5, 'AbsTol', 1e-7)
            this.verifyEqual(ifc.hdr.hist.qoffset_y, -0.5, 'AbsTol', 1e-7)
            this.verifyEqual(ifc.hdr.hist.qoffset_z, 0)
            this.verifyEqual(ifc.hdr.hist.originator(1:3), [0.5 0.5 0], 'AbsTol', 1e-7)
            ifc.save()
            this.verifyTrue(isfile([fqfp '.nii.gz']))
            deleteExisting([fqfp '.nii.gz'])

            ifc.selectFourdfpTool();
            this.verifyEqual(ifc.stateTypeclass, 'mlfourd.FourdfpTool')
            ifc.save()
            this.verifyTrue(isfile([fqfp '.4dfp.hdr']))
            deleteExisting([fqfp '.4dfp.*'])          
        end
        function test_hdr_fdg(this)
            %% examines native 4dfp and two instances of nii.gz created by ImagingContext2 and nifti_4dfp, 
            %  then confirms expected hdr.hist, which is discrepant for nifti_4dfp. 

            import mlfourd.*

            % native 4dfp
            ifc_4 = ImagingFormatContext2(this.fdg_fqfn_4dfp);
            this.verifyEqual(ifc_4.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            ifc_4.selectFourdfpTool();
            hdr = ifc_4.hdr;
            this.verifyEqual(ifc_4.stateTypeclass, 'mlfourd.FourdfpTool')
            this.verifyEqual(hdr.hist.qoffset_x,  127)
            this.verifyEqual(hdr.hist.qoffset_y, -127)
            this.verifyEqual(hdr.hist.qoffset_z, -74)
            this.verifyEqual(hdr.hist.srow_x, [-2 0 0  127])
            this.verifyEqual(hdr.hist.srow_y, [0  2 0 -127])
            this.verifyEqual(hdr.hist.srow_z, [0  0 2 -74])
            this.verifyEqual(hdr.hist.originator(1:3), [127 127 74])

            % nii.gz from ImagingContext2 (compatibility = true)
            ifc_ = ImagingFormatContext2(this.fdg_ic_fqfn_nii);
            this.verifyEqual(ifc_.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            ifc_.selectNiftiTool();
            hdr = ifc_.hdr;
            this.verifyEqual(ifc_.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(hdr.hist.qoffset_x, -127)
            this.verifyEqual(hdr.hist.qoffset_y, -127)
            this.verifyEqual(hdr.hist.qoffset_z, -74)
            this.verifyEqual(hdr.hist.srow_x, [ 2 0 0 -127])
            this.verifyEqual(hdr.hist.srow_y, [ 0 2 0 -127])
            this.verifyEqual(hdr.hist.srow_z, [ 0 0 2 -74])
            this.verifyEqual(hdr.hist.originator(1:3), [64.5 64.5 38], 'AbsTol', 1e-3)

            % nii.gz from nifti_4dfp -n
            ifc__ = ImagingFormatContext2(this.fdg_nifti_4dfp_fqfn_nii);
            this.verifyEqual(ifc__.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            ifc_.selectNiftiTool();
            hdr = ifc__.hdr;
            this.verifyEqual(ifc__.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(hdr.hist.qoffset_x, 0)
            this.verifyEqual(hdr.hist.qoffset_y, 0)
            this.verifyEqual(hdr.hist.qoffset_z, 0)
            this.verifyEqual(hdr.hist.srow_x, [ 2 0 0 -127])
            this.verifyEqual(hdr.hist.srow_y, [ 0 2 0 -127])
            this.verifyEqual(hdr.hist.srow_z, [ 0 0 2 -68])
            this.verifyEqual(hdr.hist.originator(1:3), [64.5 64.5 35], 'AbsTol', 1e-3)
        end
        function test_hdr_T1(this)
            %% creates 4dfp & nii.gz from native mgz, then confirms expected hdr.hist, 
            %  which is discrepant for 4dfp. 

            this.setupT1('.4dfp.hdr');
            this.setupT1('.nii.gz');
            this.setupT1('.mgz');

            % native mgz
            ifc_m = ImagingFormatContext2('T1_test.mgz');
            this.verifyEqual(ifc_m.stateTypeclass, 'mlfourd.FilesystemFormatTool');
            ifc_m.selectMghTool();
            hdr = ifc_m.hdr;
            this.verifyEqual(ifc_m.stateTypeclass, 'mlfourd.MghTool');
            this.verifyEqual(hdr.hist.qoffset_x,  127.5002136230469, 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.qoffset_y,  -86.3535156250000, 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.qoffset_z, -135.392578125, 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.srow_x, [-1  0 0  127.5002136230469], 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.srow_y, [ 0  1 0  -86.353515625], 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.srow_z, [ 0  0 1 -135.392578125], 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.originator(1:3), [128.4997863769531 87.353515625000000 136.3925704956055], 'AbsTol', 1e-5);

            % nii.gz from mri_convert
            ifc_n = ImagingFormatContext2('T1_test.nii.gz');
            this.verifyEqual(ifc_n.stateTypeclass, 'mlfourd.FilesystemFormatTool');
            ifc_n.selectNiftiTool();
            hdr = ifc_n.hdr;
            this.verifyEqual(ifc_n.stateTypeclass, 'mlfourd.NiftiTool');
            this.verifyEqual(hdr.hist.qoffset_x,  127.5002136230469, 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.qoffset_y,  -86.353515625, 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.qoffset_z, -135.392578125, 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.srow_x, [-1  0 0  127.5002136230469], 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.srow_y, [ 0  1 0  -86.353515625], 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.srow_z, [ 0  0 1 -135.392578125], 'AbsTol', 1e-5);
            this.verifyEqual(hdr.hist.originator(1:3), [128.4997863769531 87.353515625000000 136.3925704956055], 'AbsTol', 1e-5);

            % 4dfp from nifti_4dfp -4
            import mlfourd.*
            ifc_4 = ImagingFormatContext2('T1_test.4dfp.hdr');
            this.verifyEqual(ifc_4.stateTypeclass, 'mlfourd.FilesystemFormatTool');
            ifc_4.selectFourdfpTool();
            hdr = ifc_4.hdr;
            this.verifyEqual(ifc_4.stateTypeclass, 'mlfourd.FourdfpTool');
            this.verifyEqual(hdr.hist.qoffset_x,  127.5);
            this.verifyEqual(hdr.hist.qoffset_y, -127.5);
            this.verifyEqual(hdr.hist.qoffset_z, -127.5);
            this.verifyEqual(hdr.hist.srow_x, [-1 0 0  127.5]);
            this.verifyEqual(hdr.hist.srow_y, [ 0 1 0 -127.5]);
            this.verifyEqual(hdr.hist.srow_z, [ 0 0 1 -127.5]);
            this.verifyEqual(hdr.hist.originator(1:3), [127.5 127.5 127.5]);

            this.cleanT1('.4dfp.hdr');
            this.cleanT1('.nii.gz');
            this.cleanT1('.mgz');
        end
        function test_minus(this)
            % ref nii.gz
            ifc_ras = mlfourd.ImagingFormatContext2(strcat(this.RAS, '.nii.gz'));
            ifc_ras.selectNiftiTool();
            this.verifyEqual(ifc_ras.orient, 'NEUROLOGICAL');
            this.verifyEqual(ifc_ras.qfac, -1);

            ifc = copy(ifc_ras);
            if this.do_view
                ifc.view(ifc_ras.fqfn);
            end

            return

            ifc_4dfp = copy(ifc_ras);
            ifc_4dfp.selectFourdfpTool();
            this.verifyEqual(dipmax(ifc_ras - ifc_4dfp), 0);

            ifc_4dfp = copy(ifc_ras);
            fqfp = tempname;
            ifc_4dfp.saveas(strcat(fqfp, '.4dfp.hdr'));
            ifc_4dfp = mlfourd.ImagingFormatContext2(strcat(fqfp, '.4dfp.hdr'));
            ifc_4dfp.selectFourdfpTool();
            this.verifyEqual(dipmax(ifc_ras - ifc_4dfp), 0);
            deleteExisting(strcat(fqfp, '.4dfp.*'))

            % prep
            ic_ = mlfourd.ImagingForamtContext2(strcat(this.RAS, '.nii.gz'));
            ic_.saveas(strcat(this.RAS, '.4dfp.hdr'));

            % ref 4dfp.hdr
            ifc_ras = mlfourd.ImagingFormatContext2(strcat(this.RAS, '.4dfp.hdr'));
            ifc_ras.selectFourdfpTool();

            ic_nii = copy(ifc_ras);
            ic_nii.selectNiftiTool();
            this.verifyEqual(dipmax(ifc_ras - ic_nii), 0);

            ic_nii = copy(ifc_ras);
            fqfp = tempname;
            ic_nii.saveas(strcat(fqfp, '.nii.gz'));
            this.verifyEqual(ic_nii.orient, 'RADIOLOGICAL')
            ic_nii = mlfourd.ImagingFormatContext2(strcat(fqfp, '.nii.gz'));
            ic_nii.selectNiftiTool();
            this.verifyEqual(dipmax(ifc_ras - ic_nii), 0);
            deleteExisting(strcat(fqfp, '.*'))
            
        end
        function test_LAS(this)
            %% radiological; bottle points left anterior

            las = mlfourd.ImagingFormatContext2(strcat(this.LAS, '.nii.gz'));
            las.selectNiftiTool();
            las_ = copy(las);
            this.verifyEqual(las.orient, 'RADIOLOGICAL');
            this.verifyEqual(las.qfac, -1);
            this.verifyEqual(las.json_metadata.DeviceSerialNumber, '11009');

            if this.do_view
                las_.view(); 
                las_.disp_debug();

%                las_.selectFourdfpTool();
%                las_.view();
            end
        end
        function test_RAS(this)
            %% neurological; subject's nose tilts slightly to left

            ras = mlfourd.ImagingFormatContext2(strcat(this.RAS, '.nii.gz'));
            ras.selectNiftiTool();
            ras_ = copy(ras);
            this.verifyEqual(ras.orient, 'NEUROLOGICAL');
            this.verifyEqual(ras.qfac, -1);
            this.verifyEqual(ras.json_metadata.DeviceSerialNumber, '167047'); 

            if this.do_view
                ras_.view(); 
                ras_.disp_debug();

%                ras_.selectFourdfpTool();
%                ras_.view();
            end

            return

            % LAS and RAS have compatible internal representations
            las_fn = strcat(basename(tempname), '.nii.gz');
            copyfile(strcat(this.RAS, '.nii.gz'), las_fn);
            mlbash(sprintf('fslorient -forceradiological %s', las_fn));
            las = mlfourd.ImagingContext2(las_fn);
            
            diff = ras - las;
            this.verifyEqual(dipsum(diff), 0);
            deleteExisting(las);           
        end
    end
    
    methods (TestClassSetup)
        function setupImagingFormatContext2(this)
            import mlfourd.*
            this.testTrivial_ = ImagingFormatContext2();
            this.testObj_ = ImagingFormatContext2(1);

            this.ref = mlfourd.ReferenceMprage;
            this.ref.copyfiles(this.TmpDir);
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
