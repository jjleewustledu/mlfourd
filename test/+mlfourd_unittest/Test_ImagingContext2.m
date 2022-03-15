classdef Test_ImagingContext2 < mlfourd_unittest.Test_Imaging
	%% TEST_IMAGINGCONTEXT2 exercises ImagingContext2
    %
 	%  Created 10-Aug-2018 19:43:13 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_unittest.
 	%  Developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John J. Lee.
 	
	properties
        do_legacy = false
        fdg = 'fdgv1r1_sumt'
        fdg4d = 'fdgdt20190523132832_222' 
        fslroi_xmin  =  65
        fslroi_xsize =  44   % 66 remaining
        fslroi_xzoom =  0.25
        fslroi_ymin  =  82    
        fslroi_ysize =  83   % 82 remaining
        fslroi_yzoom =  1/3
        fslroi_zmin  =  0
        fslroi_zsize = -1    % 255 remaining
        fslroi_zzoom =  1
        LR = 'MNI152_T1_2mm_LR-masked'
        t1 = 't1_dcm2niix'
        testObj
    end
    
    properties (Dependent)
        filesystemTool
        fourdfpTool
        fslroi
        fslroi_zoom
        blurringTool
        dynamicsTool
        imagingFormat
        imagingTool
        maskingTool
        mgzTool
        niftiTool
        numericalTool
    end
    
    methods
        
        %% GET
        
        function g = get.filesystemTool(this)
            if this.compatibility
                g = 'mlfourd.FilesystemTool_20211201';
            else
                g = 'mlfourd.FilesystemTool';
            end
        end
        function g = get.fourdfpTool(this)
            if this.compatibility
                g = 'mlfourdfp.InnerFourdfp';
            else
                g = 'mlfourd.FourdfpTool';
            end
        end
        function g = get.fslroi(this)
            g = strcat(this.LR, '_fslroi');
        end
        function g = get.fslroi_zoom(this)
            g = [this.fslroi_xzoom this.fslroi_yzoom this.fslroi_zzoom];
        end   
        function g = get.blurringTool(this)
            if this.compatibility
                g = 'mlfourd.BlurringTool_20211201';
            else
                g = 'mlfourd.BlurringTool';
            end
        end
        function g = get.dynamicsTool(this)
            if this.compatibility
                g = 'mlfourd.DynamicsTool_20211201';
            else
                g = 'mlfourd.DynamicsTool';
            end
        end
        function g = get.imagingFormat(this)
            if this.compatibility
                g = 'mlfourd.ImagingFormatContext';
            else
                g = 'mlfourd.ImagingFormatContext2';
            end
        end
        function g = get.imagingTool(this)
            if this.compatibility
                g = 'mlfourd.ImagingFormatTool_20211201';
            else
                g = 'mlfourd.ImagingTool';
            end
        end
        function g = get.maskingTool(this)
            if this.compatibility
                g = 'mlfourd.MaskingTool_20211201';
            else
                g = 'mlfourd.MaskingTool';
            end
        end
        function g = get.mgzTool(this)
            if this.compatibility
                g = 'mlsurfer.InnerMGH';
            else
                g = 'mlfourd.MghTool';
            end
        end
        function g = get.niftiTool(this)
            if this.compatibility
                g = 'mlfourd.InnerNIfTI';
            else
                g = 'mlfourd.NiftiTool';
            end
        end
        function g = get.numericalTool(this)
            if this.compatibility
                g = 'mlfourd.NumericalTool_20211201';
            else
                g = 'mlfourd.MatlabTool';
            end
        end
    end

	methods (Test)
        function test_afun(this)
            import mlfourd.*
            this.assumeEqual(1,1);
            this.verifyEqual(1,1);
            this.assertEqual(1,1);

            this.verifyEqual(pwd, this.TmpDir)
        end
        
        function test_TrivialTool(this)
            obj = mlfourd.ImagingContext2();
            this.verifyEqual(obj.stateTypeclass, 'mlfourd.TrivialTool')
            this.verifyClass(obj.logger, 'mlpipeline.Logger2')
            this.verifyEqual(obj.fqfileprefix, obj.logger.fqfileprefix)            

            obj1 = mlfourd.ImagingContext2([]);
            this.verifyEqual(obj1.stateTypeclass, 'mlfourd.TrivialTool')
            this.verifyClass(obj1.logger, 'mlpipeline.Logger2')
            this.verifyEqual(obj1.fqfileprefix, obj1.logger.fqfileprefix)

            obj2 = copy(obj1);
            this.verifyTrue(haveDistinctStates(obj2, obj1));
            this.verifyTrue(haveDistinctContextHandles(obj2, obj1));

            obj2.addLog('touched by test_TrivialTool');
            this.verifyFalse(contains(char(obj1.logger.contents), 'touched by test_TrivialTool'))
        end

        %% ctor logic

        function test_ctor_empty(this)
            obj = mlfourd.ImagingContext2();
            this.verifyTrue(contains(obj.filepath, '/var'))
            this.verifyTrue(strcmp(obj.filesuffix, '.mat'))
            this.verifyEqual(obj.stateTypeclass, 'mlfourd.TrivialTool')
            this.verifyTrue(contains(obj.imagingFormat.filepath, '/var'))
            this.verifyTrue(strcmp(obj.imagingFormat.filesuffix, '.mat'))
            this.verifyEqual(obj.imagingFormat.stateTypeclass, 'mlfourd.TrivialFormatTool')
            this.verifyClass(obj.imagingFormat.viewer, 'mlfourd.Viewer')
        end
        function test_ctor(this)
 			import mlfourd.*            

            % filename
            ic = ImagingContext2([this.T1001 '.nii.gz'], 'compatibility', this.compatibility);
            this.verifyEqual(ic.stateTypeclass, this.filesystemTool)

            % numeric
            ic = ImagingContext2(magic(2), 'compatibility', this.compatibility);
            this.verifyEqual(ic.stateTypeclass, this.numericalTool)

            % ImagingFormatContext
%             ifc = ImagingFormatContext([this.T1001 '.nii.gz']);
%             this.verifyEqual(ifc.stateTypeclass, 'mlfourd.InnerNIfTI')
%             ic_ifc = ImagingContext2(ifc, 'compatibility', true);
%             this.verifyEqual(ic_ifc.stateTypeclass, 'mlfourd.ImagingFormatTool_20211201')

            % ImagingFormatContext2
            ifc2 = ImagingFormatContext2([this.T1001 '.nii.gz']);
            ifc2.selectNiftiTool();
            this.verifyEqual(ifc2.stateTypeclass, 'mlfourd.NiftiTool')
            ic_ifc2 = ImagingContext2(ifc2, 'compatibility', false);
            this.verifyEqual(ic_ifc2.stateTypeclass, 'mlfourd.ImagingTool')

            % select ic
            if this.compatibility
                ic = ImagingContext2(ifc, 'compatibility', true);
            else
                ic = ImagingContext2(ifc2, 'compatibility', false);
            end

            % copy ctor, repeated
            ic2 = ImagingContext2(ic, 'compatibility', this.compatibility);
            this.verifyEqual(ic2.stateTypeclass, this.imagingTool)
            ic3 = ImagingContext2(ic2, 'compatibility', this.compatibility);
            this.verifyEqual(ic3.stateTypeclass, this.imagingTool)
            ic4 = ImagingContext2(ic3, 'compatibility', this.compatibility);
            this.verifyEqual(ic4.stateTypeclass, this.imagingTool)

            % copy, repeated
            ic5 = copy(ic4);
            this.verifyEqual(ic5.stateTypeclass, this.imagingTool)
            ic6 = copy(ic5);
            this.verifyEqual(ic6.stateTypeclass, this.imagingTool)
            ic7 = copy(ic6);
            this.verifyEqual(ic7.stateTypeclass, this.imagingTool)

            % copies have distinct handles
            this.assertTrue(ic == ic)
            this.assertFalse(ic == ic2)
            this.assertFalse(ic == ic3)
            this.assertFalse(ic == ic4)
            this.assertFalse(ic == ic5)
            this.assertFalse(ic == ic6)
            this.assertFalse(ic == ic7)
        end
        function test_ctor_layers(this)
 			import mlfourd.*;

            % construct with filename, as is typical
            ic = ImagingContext2([this.T1001 '.nii.gz'], 'compatibility', this.compatibility);
            this.verifyEqual(ic.stateTypeclass, this.filesystemTool);
            if this.compatibility
                this.verifyEqual(ic.fqfilename, [this.T1001 '.nii.gz']);
            else
                this.verifyEqual(ic.fqfilename, fullfile(pwd, [this.T1001 '.nii.gz']));
            end

            % verify imagingInfo
            this.verifyEqual(ic.imagingInfo.TransformName, 'Sform')
            this.verifyEqual(ic.imagingInfo.raw.srow_x, [-1 0 0  127])
            this.verifyEqual(ic.imagingInfo.raw.srow_y, [ 0 1 0 -127])
            this.verifyEqual(ic.imagingInfo.raw.srow_z, [ 0 0 1 -127])
            this.verifyEqual(ic.imagingInfo.hdr.hist.originator(1:3), [128 128 128])

            % verify imagingFormat
            ic.selectImagingTool();
            this.verifyEqual(DataHash(ic.imagingFormat.hdr), 'dcb4c8680e78424c2be2ffff580ee24c')
            this.verifyEqual(DataHash(ic.imagingFormat.img), '62a69f1eaf8320fbf958b3306f894abb')
        end
        function test_ctor_logical(this)
            obj = mlfourd.ImagingContext2(true(2,2,3,4), 'compatibility', this.compatibility);
            this.verifyEqual(ndims(obj), 4)
            this.verifyEqual(size(obj), [2,2,3,4])
            if this.compatibility
                this.verifyEqual(dipmin(obj), single(1))
                this.verifyEqual(dipmax(obj), single(1))
                this.verifyEqual(dipsum(obj), single(prod([2,2,3,4])))
            else
                this.verifyEqual(dipmin(obj), 1)
                this.verifyEqual(dipmax(obj), 1)
                this.verifyEqual(dipsum(obj), prod([2,2,3,4]))
            end
        end
        
        %% FilesystemTool

        function test_FilesystemTool_large_file(this)
            if this.compatibility
                return
            end
            tic
            obj = mlfourd.ImagingContext2(this.large_nii, 'compatibility', this.compatibility); %#ok<NASGU> 
            elapsed = toc;
            this.verifyLessThan(elapsed, 1)
        end
        function test_FilesystemTool_nii(this)
            obj = mlfourd.ImagingContext2([this.fdg4d '.nii.gz'], 'compatibility', this.compatibility);
            this.verifyEqual(obj.stateTypeclass, this.filesystemTool)
            if this.compatibility
                this.verifyEqual(obj.fqfilename, [this.fdg4d '.nii.gz'])
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.FilesystemTool_20211201')
                this.verifyClass(obj.imagingInfo, 'mlfourd.NIfTIInfo')
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.ImagingFormatTool_20211201')
            else
                this.verifyEqual(obj.fqfilename, fullfile(pwd, [this.fdg4d '.nii.gz']))
                this.verifyEqual(obj.fqfileprefix, obj.logger.fqfileprefix)
                this.verifyClass(obj.logger, 'mlpipeline.Logger2')    
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.FilesystemTool')
                this.verifyClass(obj.imagingInfo, 'mlfourd.NIfTIInfo')
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.ImagingTool')
            end

            % lightweight queries that do not read large data files
            %disp(obj.imagingInfo.raw)
            this.verifyEqual(obj.imagingInfo.raw.dim, [4 128 128 75 62 1 1 1])
            this.verifyEqual(obj.imagingInfo.raw.sizeof_hdr, 348)
            this.verifyEqual(obj.imagingInfo.raw.intent_code, 0)
            this.verifyEqual(obj.imagingInfo.raw.datatype, 16)
            this.verifyEqual(obj.imagingInfo.raw.bitpix, 32)
            this.verifyEqual(obj.imagingInfo.raw.pixdim, [-1 2 2 2 1 0 0 0])
            this.verifyEqual(obj.imagingInfo.raw.xyzt_units, 10)
            this.verifyEqual(obj.imagingInfo.raw.descrip, 'fdgdt20190523132832_222.4dfp.ifh converted with nifti_4dfp')
            this.verifyEqual(obj.imagingInfo.raw.qform_code, 0)
            this.verifyEqual(obj.imagingInfo.raw.sform_code, 1)
            this.verifyEqual(obj.imagingInfo.raw.srow_x, [-2 0 0  127])
            this.verifyEqual(obj.imagingInfo.raw.srow_y, [ 0 2 0 -127])
            this.verifyEqual(obj.imagingInfo.raw.srow_z, [ 0 0 2 -68])
            this.verifyEqual(size(obj), [128 128 75 62])
        end
        function test_FilesystemTool_4dfp(this)
            obj = mlfourd.ImagingContext2([this.fdg4d '.4dfp.hdr'], 'compatibility', this.compatibility);
            this.verifyEqual(obj.stateTypeclass, this.filesystemTool)
            if this.compatibility
                this.verifyEqual(obj.fqfilename, [this.fdg4d '.4dfp.hdr'])
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.FilesystemTool_20211201')
                this.verifyClass(obj.imagingInfo, 'mlfourd.FourdfpInfo')
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.ImagingFormatTool_20211201')
            else
                this.verifyEqual(obj.fqfilename, fullfile(pwd, [this.fdg4d '.4dfp.hdr']))
                this.verifyEqual(obj.fqfileprefix, obj.logger.fqfileprefix)
                this.verifyClass(obj.logger, 'mlpipeline.Logger2')
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.FilesystemTool')
                this.verifyClass(obj.imagingInfo, 'mlfourd.FourdfpInfo')
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.ImagingTool')
            end

            % lightweight queries that do not read large data files, 4dfp raw is an initial guess, intended for aufbau
            %disp(obj.imagingInfo.raw)
            this.verifyEqual(obj.imagingInfo.raw.dim, [4 128 128 75 62 1 1 1])
            this.verifyEqual(obj.imagingInfo.raw.sizeof_hdr, 348)
            this.verifyEqual(obj.imagingInfo.raw.intent_code, 0)
            this.verifyEqual(obj.imagingInfo.raw.datatype, 16)
            this.verifyEqual(obj.imagingInfo.raw.bitpix, 32)
            this.verifyEqual(obj.imagingInfo.raw.pixdim, [0 2 2 2 0 0 0 0])
            this.verifyEqual(obj.imagingInfo.raw.xyzt_units, 10)
            this.verifyEqual(obj.imagingInfo.raw.descrip, '')
            this.verifyEqual(obj.imagingInfo.raw.qform_code, 0)
            this.verifyEqual(obj.imagingInfo.raw.sform_code, 1)
            this.verifyEqual(obj.imagingInfo.raw.srow_x, [-2 0 0  127])
            this.verifyEqual(obj.imagingInfo.raw.srow_y, [ 0 2 0 -127])
            this.verifyEqual(obj.imagingInfo.raw.srow_z, [ 0 0 2 -74])
            this.verifyEqual(size(obj), [128 128 75 62])
        end
        function test_FilesystemTool_mgz(this)
            obj = mlfourd.ImagingContext2('T1.mgz', 'compatibility', this.compatibility);
            this.verifyEqual(obj.stateTypeclass, this.filesystemTool)
            if this.compatibility
                this.verifyEqual(obj.fqfilename, 'T1.mgz')
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.FilesystemTool_20211201')
                this.verifyClass(obj.imagingInfo, 'mlfourd.MGHInfo')
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.ImagingFormatTool_20211201')
            else
                this.verifyEqual(obj.fqfilename, fullfile(pwd, 'T1.mgz'))
                this.verifyEqual(obj.fqfileprefix, obj.logger.fqfileprefix)
                this.verifyClass(obj.logger, 'mlpipeline.Logger2')
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.FilesystemTool')
                this.verifyClass(obj.imagingInfo, 'mlfourd.MGHInfo')
                this.verifyEqual(obj.stateTypeclass, 'mlfourd.ImagingTool')
            end

            % lightweight queries that do not read large data files
            %disp(obj.imagingInfo.raw)
            this.verifyEqual(obj.imagingInfo.raw.dim, [3 256 256 256 1 1 1 1])
            this.verifyEqual(obj.imagingInfo.raw.sizeof_hdr, 348)
            this.verifyEqual(obj.imagingInfo.raw.intent_code, 0)
            this.verifyEqual(obj.imagingInfo.raw.datatype, 2)
            this.verifyEqual(obj.imagingInfo.raw.bitpix, 8)
            this.verifyEqual(obj.imagingInfo.raw.pixdim, [-1 1 1 1 2.40 1 1 1], 'AbsTol', 1e-5)
            this.verifyEqual(obj.imagingInfo.raw.xyzt_units, 10)
            this.verifyEqual(obj.imagingInfo.raw.descrip, '6.0.4:ddd0a010')
            this.verifyEqual(obj.imagingInfo.raw.qform_code, 0)
            this.verifyEqual(obj.imagingInfo.raw.sform_code, 1)
            this.verifyEqual(obj.imagingInfo.raw.quatern_b, 0, 'AbsTol', 1e-5)
            this.verifyEqual(obj.imagingInfo.raw.quatern_c, 1, 'AbsTol', 1e-5)
            this.verifyEqual(obj.imagingInfo.raw.quatern_d, 0, 'AbsTol', 1e-5)
            this.verifyEqual(obj.imagingInfo.raw.qoffset_x,  127.500214, 'AbsTol', 1e-5)
            this.verifyEqual(obj.imagingInfo.raw.qoffset_y,  -86.353516, 'AbsTol', 1e-5)
            this.verifyEqual(obj.imagingInfo.raw.qoffset_z, -135.392578125, 'AbsTol', 1e-5)
            this.verifyEqual(obj.imagingInfo.raw.srow_x, [-1  0 0  127.500214], 'AbsTol', 1e-5)
            this.verifyEqual(obj.imagingInfo.raw.srow_y, [ 0  1 0  -86.353516], 'AbsTol', 1e-5)
            this.verifyEqual(obj.imagingInfo.raw.srow_z, [ 0  0 1 -135.392578125], 'AbsTol', 1e-5)
            this.verifyEqual(size(obj), [256 256 256])
        end
        function test_nifti_fourdfp_matlabtool_logger(this)
            if this.compatibility
                return
            end

            ic = mlfourd.ImagingContext2([this.T1001 '.nii.gz'], 'compatibility', this.compatibility);
            this.verifyTrue(contains(string(ic.logger.contents), "mlpipeline.Logger2"))
            this.verifyTrue(contains(string(ic.logger.contents), "initialized"))
            ic.nifti;
            this.verifyTrue(contains(string(ic.logger.contents), "mlfourd.ImagingTool.selectNiftiTool()"))
            ic.fourdfp; 
            this.verifyTrue(contains(string(ic.logger.contents), "mlfourd.ImagingTool.selectFourdfpTool()"))
            ic = ic * 2;
            this.verifyTrue(contains(string(ic.logger.contents), "MatlabTool.bsxfun:  mtimes(T1001, 2)"))
            ic = ic.*ic;
            this.verifyTrue(contains(string(ic.logger.contents), "MatlabTool.bsxfun:  times("))
            tname = tempname;
            ic.saveas([tname '.nii.gz']);
            this.verifyTrue(contains(string(ic.logger.contents), "mlniftitools.save_nii(nii, /private/var/folders"))
            deleteExisting(strcat(tname, '*'))
        end
        function test_rename_deep_4dfp(this)
 			import mlfourd.*;
            if this.compatibility
                ifc = mlfourd.ImagingFormatContext('T1.4dfp.hdr');
            else
                ifc = mlfourd.ImagingFormatContext2('T1.4dfp.hdr');
            end
            ifc2 = copy(ifc);

            ifc2.fileprefix = 'ifc2_test';
            this.verifyEqual(ifc2.fileprefix, 'ifc2_test')
            this.verifyEqual(ifc2.imagingInfo.fileprefix, 'ifc2_test')
            this.verifyNotEqual(ifc.fileprefix, 'ifc2_test')
            this.verifyNotEqual(ifc.imagingInfo.fileprefix, 'ifc2_test')

            ic = mlfourd.ImagingContext2(ifc, 'compatibility', this.compatibility);
            ic2 = copy(ic);
            
            ic2.fileprefix = 'ic2_test';
            this.verifyEqual(ic2.fileprefix, 'ic2_test')
            this.verifyEqual(ic2.imagingFormat.fileprefix, 'ic2_test')
            this.verifyEqual(ic2.imagingInfo.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.imagingFormat.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.imagingInfo.fileprefix, 'ic2_test')        
        end
        function test_rename_deep_mgz(this)
 			import mlfourd.*;
            if this.compatibility
                ifc = mlfourd.ImagingFormatContext('T1.mgz');
            else
                ifc = mlfourd.ImagingFormatContext2('T1.mgz');
            end
            ifc2 = copy(ifc);

            ifc2.fileprefix = 'ifc2_test';
            this.verifyEqual(ifc2.fileprefix, 'ifc2_test')
            this.verifyEqual(ifc2.imagingInfo.fileprefix, 'ifc2_test')
            this.verifyNotEqual(ifc.fileprefix, 'ifc2_test')
            this.verifyNotEqual(ifc.imagingInfo.fileprefix, 'ifc2_test')

            ic = mlfourd.ImagingContext2(ifc, 'compatibility', this.compatibility);
            ic2 = copy(ic);
            
            ic2.fileprefix = 'ic2_test';
            this.verifyEqual(ic2.fileprefix, 'ic2_test')
            this.verifyEqual(ic2.imagingFormat.fileprefix, 'ic2_test')
            this.verifyEqual(ic2.imagingInfo.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.imagingFormat.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.imagingInfo.fileprefix, 'ic2_test')        
        end
        function test_rename_deep_niigz(this)
 			import mlfourd.*;
            if this.compatibility
                ifc = mlfourd.ImagingFormatContext('T1.nii.gz');
            else
                ifc = mlfourd.ImagingFormatContext2('T1.nii.gz');
            end
            ifc2 = copy(ifc);

            ifc2.fileprefix = 'ifc2_test';
            this.verifyEqual(ifc2.fileprefix, 'ifc2_test')
            this.verifyEqual(ifc2.imagingInfo.fileprefix, 'ifc2_test')
            this.verifyNotEqual(ifc.fileprefix, 'ifc2_test')
            this.verifyNotEqual(ifc.imagingInfo.fileprefix, 'ifc2_test')

            ic = mlfourd.ImagingContext2(ifc, 'compatibility', this.compatibility);
            ic2 = copy(ic);
            
            ic2.fileprefix = 'ic2_test';
            this.verifyEqual(ic2.fileprefix, 'ic2_test')
            this.verifyEqual(ic2.imagingFormat.fileprefix, 'ic2_test')
            this.verifyEqual(ic2.imagingInfo.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.imagingFormat.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.imagingInfo.fileprefix, 'ic2_test')        
        end
        function test_rename_deep_1(this)
            if this.compatibility
                return
            end

 			import mlfourd.*;
            ifc = mlfourd.ImagingFormatContext2(1);
            ifc2 = copy(ifc);

            ifc2.fileprefix = 'ifc2_test';
            this.verifyEqual(ifc2.fileprefix, 'ifc2_test')
            this.verifyEqual(ifc2.imagingInfo.fileprefix, 'ifc2_test')
            this.verifyNotEqual(ifc.fileprefix, 'ifc2_test')
            this.verifyNotEqual(ifc.imagingInfo.fileprefix, 'ifc2_test')

            ic = mlfourd.ImagingContext2(ifc, 'compatibility', false);
            ic2 = copy(ic);
            
            ic2.fileprefix = 'ic2_test';
            this.verifyEqual(ic2.fileprefix, 'ic2_test')
            this.verifyEqual(ic2.imagingFormat.fileprefix, 'ic2_test')
            this.verifyEqual(ic2.imagingInfo.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.imagingFormat.fileprefix, 'ic2_test')
            this.verifyNotEqual(ic.imagingInfo.fileprefix, 'ic2_test')        
        end

        %% legacy

        function test_legacy_ImagingContext(this)
            if (~this.do_legacy); return; end
            import mlfourd.*;
            
            ic2 = ImagingContext2([this.t1 '.4dfp.hdr']);                      
            ic  = ImagingContext( [this.t1 '.4dfp.hdr']);
            %hdr = this.adjustLegacyHdr(ic.fourdfp.hdr, ic2.fourdfp.hdr);
            %this.verifyEqual(hdr,            ic2.fourdfp.hdr, 'RelTol', 1e-4);
            this.verifyEqual(ic.fourdfp.img, ic2.fourdfp.img);
            
            ic2_ic = ImagingContext2(ic);
            %hdr_ = this.adjustLegacyHdr(ic2_ic.fourdfp.hdr, ic2.fourdfp.hdr);
            %this.verifyEqual(hdr_,               ic2.fourdfp.hdr, 'RelTol', 1e-4);
            this.verifyEqual(ic2_ic.fourdfp.img, ic2.fourdfp.img);            
            
%             ic_ic2 = ImagingContext( ic2);
%             hdr__ = this.adjustLegacyHdr(ic_ic2.fourdfp.hdr, ic2.fourdfp.hdr);
%             this.verifyEqual(hdr__,              ic2.fourdfp.hdr, 'RelTol', 1e-4);
%             this.verifyEqual(ic_ic2.fourdfp.img, ic2.fourdfp.img);     
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

        %% select*Tool, fourdfp, mgz, nifti

        function test_selectFilesystemTool(this)
            %% Confirms methods of FilesystemTool.  Ensures selectFilesystemTool serializes imaging in memory.

            ic = this.T1001_ic_nii; % handle to fresh instance of test file

            this.verifyEqual(ic.stateTypeclass, this.filesystemTool) % ic instantiates as a filesystem tool
            this.verifyFalse(isempty(ic)) % do operations that read header from filesystem
            if ~this.compatibility
                this.verifyEqual(length(ic), 256)
                this.verifyEqual(ic.bytes, 64)
                this.verifyEqual(ndims(ic), 3)
                this.verifyEqual(numel(ic), 256^3)
            end
            this.verifyEqual(size(ic), [256 256 256])

            ic.selectNiftiTool(); % loads imaging into memory
            this.verifyEqual(ic.stateTypeclass, this.imagingTool)
            if ~this.compatibility
                this.verifyEqual(ic.bytes, 67108936) % explicit memory footprint of img
            end
            this.verifyEqual(size(ic.nifti.img), [256 256 256]) % explicit memory footprint of img
            fqfn = ic.fqfilename;
            deleteExisting(fqfn);            
            ic.fileprefix = mybasename(tempname);
            fqfn1 = ic.fqfilename;

            ic.selectFilesystemTool; % selecting FilesystemTool serializes data to fqfn1
            this.verifyTrue(~isfile(fqfn)); 
            this.verifyTrue(isfile(fqfn1)); 
            this.verifyEqual(ic.stateTypeclass, this.filesystemTool) % confirm state ~ filesystem tool
            this.verifyFalse(isempty(ic)) % repeat operations that read header from filesystem
            if ~this.compatibility
                this.verifyEqual(length(ic), 256)
                this.verifyEqual(ic.bytes, 64)
                this.verifyEqual(ndims(ic), 3)
                this.verifyEqual(numel(ic), 256^3)
            end
            this.verifyEqual(size(ic), [256 256 256])

            deleteExisting(strcat(ic.fqfp, '*'))
        end
        function test_selectImagingTool(this)
            ic = mlfourd.ImagingContext2([this.T1001 '.4dfp.hdr'], 'compatibility', this.compatibility);  
            this.verifyEqual(ic.stateTypeclass, this.filesystemTool);   
            if ~this.compatibility
                this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            end
            ic.selectImagingTool;
            this.verifyEqual(ic.stateTypeclass, this.imagingTool);  
            if ~this.compatibility
                this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.FourdfpTool')
            end 
            ic.selectNumericalTool;
            this.verifyEqual(ic.stateTypeclass, this.numericalTool);  
            if ~this.compatibility
                this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.MatlabFormatTool')
            end  
            ic.selectBlurringTool;
            this.verifyEqual(ic.stateTypeclass, this.blurringTool);  
            if ~this.compatibility
                this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.MatlabFormatTool')
            end             
            ic.selectImagingTool;
            this.verifyEqual(ic.stateTypeclass, this.blurringTool); % BlurringTool => ImagingTool
            if ~this.compatibility
                this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.MatlabFormatTool')
            end 
            ic.fileprefix = 'test_selectImagingTool';
            ic.selectFilesystemTool;
            this.verifyEqual(ic.stateTypeclass, this.filesystemTool);   
            if ~this.compatibility
                this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.FilesystemFormatTool')
            end 

            this.verifyTrue(isfile(ic.fqfilename))
        end
        function test_nifti2fourdfp(this)
 			obj = mlfourd.ImagingContext2([this.T1001 '.nii.gz'], 'compatibility', this.compatibility);
            this.verifyEqual(obj.stateTypeclass, this.filesystemTool)
%             this.verifyClass(obj.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyEqual(obj.filesuffix, '.nii.gz')
            this.verifyClass(obj.fourdfp, this.imagingFormat)
            this.verifyEqual(obj.fourdfp.stateTypeclass, this.fourdfpTool)
            this.verifyClass(obj.fourdfp.imagingInfo, 'mlfourd.FourdfpInfo')
            this.verifyEqual(obj.fourdfp.filesuffix, '.4dfp.hdr');
            this.verifyEqual(obj.stateTypeclass, this.imagingTool)
            this.verifyClass(obj.imagingInfo, 'mlfourd.FourdfpInfo')
            this.verifyEqual(obj.filesuffix, '.4dfp.hdr');
        end
        function test_nifti2fourdp2(this)
            if ~this.do_view
                return
            end

            %obj = copy(this.MNI152_LR_nii); 
            obj = mlfourd.ImagingContext2('T1_fslreorient2std.nii.gz', 'compatibility', this.compatibility);
            [~,r] = mlbash(sprintf('fslhd %s', obj.fqfn));
            obj.view(); % y normal
            obj.selectFourdfpTool();
            obj.view(); % y flipped
            tmpfp = tempname;
            tmpfn = strcat(tmpfp, '.4dfp.hdr');
            obj.saveas(tmpfn);
            [~,r] = mlbash(sprintf('fslhd %s', tmpfn));
            mlbash(sprintf('fsleyes %s', tmpfn)); % y flipped
            deleteExisting(strcat(tmpfp, '*'));

            % repeat to detect cycles
            obj.selectFourdfpTool();
            obj.view(); % y flipped
            tmpfp = tempname;
            tmpfn = strcat(tmpfp, '.4dfp.hdr');
            obj.saveas(tmpfn);
            [~,r] = mlbash(sprintf('fslhd %s', tmpfn));
            mlbash(sprintf('fsleyes %s', tmpfn)); % y flipped
            deleteExisting(strcat(tmpfp, '*'));
        end
        function test_fourdfp2nifti(this)
 			obj = mlfourd.ImagingContext2([this.T1001 '.4dfp.hdr'], 'compatibility', this.compatibility);
            this.verifyEqual(obj.stateTypeclass, this.filesystemTool)
%             this.verifyClass(obj.imagingInfo, 'mlfourd.FourdfpInfo')
            this.verifyEqual(obj.filesuffix, '.4dfp.hdr')
            this.verifyClass(obj.nifti, this.imagingFormat)
            this.verifyEqual(obj.nifti.stateTypeclass, this.niftiTool)
            this.verifyClass(obj.nifti.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyEqual(obj.nifti.filesuffix, '.nii.gz');
            this.verifyEqual(obj.stateTypeclass, this.imagingTool)
            this.verifyClass(obj.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyEqual(obj.filesuffix, '.nii.gz'); 
        end
        function test_fourdfp2nifti2(this)
            if ~this.do_view
                return
            end

 			%obj = copy(this.MNI152_LR_nii); 
            obj = mlfourd.ImagingContext2('711-2B_111.4dfp.hdr', 'compatibility', this.compatibility);
            [~,r] = mlbash(sprintf('fslhd %s', obj.fqfn));
            %obj = copy(obj.selectFourdfpTool());
            obj.view(); % y flipped
            obj.selectNiftiTool();
            obj.view(); % y normal
            tmpfp = tempname;
            tmpfn = strcat(tmpfp, '.nii.gz');
            obj.saveas(tmpfn);
            [~,r] = mlbash(sprintf('fslhd %s', tmpfn));
            mlbash(sprintf('fsleyes %s', tmpfn)); % y normal
            deleteExisting(strcat(tmpfp, '*'));
            
            % repeat to detect cycles
            obj.selectNiftiTool();
            obj.view(); % y normal
            tmpfp1 = tempname;
            tmpfn1 = strcat(tmpfp1, '.nii.gz');
            obj.saveas(tmpfn1);
            [~,r1] = mlbash(sprintf('fslhd %s', tmpfn1));
            mlbash(sprintf('fsleyes %s', tmpfn1)); % y normal
            deleteExisting(strcat(tmpfp1, '*'));
        end
        function test_saveas(this)
            this.testObj.saveas([this.testObj.fileprefix '_test_saveas.mat']);
            this.verifyTrue(isfile([this.testObj.fileprefix '.mat']));
            deleteExisting(this.testObj.filename);

            ic_n = mlfourd.ImagingContext2([this.RAS '.nii.gz']);
            ic_4 = copy(ic_n);
            ic_4.saveas([this.RAS '.4dfp.hdr']);

            % are internal arrays aligned after reading filesystem?
            ic_diff = mlfourd.ImagingContext2([this.RAS '.nii.gz']) - mlfourd.ImagingContext2([this.RAS '.4dfp.hdr']);
            this.verifyEqual(dipmax(ic_diff), 0);

            ic = copy(ic_n);
            ic.saveas([ic.fileprefix '_test_saveas.4dfp.hdr']);
            this.verifyTrue(isfile([ic.fileprefix '.4dfp.hdr']));
            if this.do_view
                mlbash(sprintf('fsleyes %s %s', ic_n.fqfn, ic.fqfn));
            end
            deleteExisting(ic.fqfn);

            ic = copy(ic_4);
            ic.saveas([ic.fileprefix '_test_saveas.nii.gz']);
            this.verifyTrue(isfile([ic.fileprefix '.nii.gz']));
            if this.do_view
                mlbash(sprintf('fsleyes %s %s', ic_4.fqfn, ic.fqfn));
            end

            deleteExisting(ic.fqfn);
        end
        function test_compatibility(this)
            import mlfourd.*

            ic_nii = ImagingContext2('T1.nii.gz', 'compatibility', this.compatibility);
            this.verifyClass(ic_nii.nifti, this.imagingFormat)
            this.verifyClass(ic_nii.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyClass(ic_nii.fourdfp, this.imagingFormat)
            this.verifyClass(ic_nii.imagingInfo, 'mlfourd.FourdfpInfo')
            this.verifyClass(ic_nii.mgz, this.imagingFormat)
            this.verifyClass(ic_nii.imagingInfo, 'mlfourd.MGHInfo')

            ic_4dfp = ImagingContext2('T1.4dfp.hdr', 'compatibility', this.compatibility);
            this.verifyClass(ic_4dfp.nifti, this.imagingFormat)
            this.verifyClass(ic_4dfp.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyClass(ic_4dfp.fourdfp, this.imagingFormat)
            this.verifyClass(ic_4dfp.imagingInfo, 'mlfourd.FourdfpInfo')
            this.verifyClass(ic_4dfp.mgz, this.imagingFormat)
            this.verifyClass(ic_4dfp.imagingInfo, 'mlfourd.MGHInfo')

            ic_mgz = ImagingContext2('T1.mgz', 'compatibility', this.compatibility);
            this.verifyClass(ic_mgz.nifti, this.imagingFormat)
            this.verifyClass(ic_mgz.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyClass(ic_mgz.fourdfp, this.imagingFormat)
            this.verifyClass(ic_mgz.imagingInfo, 'mlfourd.FourdfpInfo')
            this.verifyClass(ic_mgz.mgz, this.imagingFormat)
            this.verifyClass(ic_mgz.imagingInfo, 'mlfourd.MGHInfo')
        end
        function test_LR(this)
            if ~this.do_view
                return
            end

            ic1 = this.MNI152_LR_nii;
            ic1.selectNiftiTool();
            ic1.view()

            tmp = strcat(tempname, '.4dfp.hdr');
            ic1.saveas(tmp)
            mlbash(sprintf('fsleyes %s %s', this.MNI152_LR_nii.fqfilename, tmp))

            ifc2 = copy(ic1);
            tmp1 = strcat(tempname, '.nii.gz');
            ifc2.saveas(tmp1)
            mlbash(sprintf('fsleyes %s %s', tmp, tmp1))

            mlbash(sprintf('fsleyes %s %s', tmp1, this.MNI152_LR_nii.fqfilename))

            deleteExisting(tmp)
            deleteExisting(tmp1)
        end
        function test_filesuffix(this)
            tempname_ = tempname;

            ic = mlfourd.ImagingContext2('T1001.nii.gz', 'compatibility', this.compatibility);
            ic.selectImagingTool();
            ic.fqfp = tempname_;
            this.verifyClass(ic.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(size(ic.imagingFormat.img), [256 256 256])
            ic.save();
            this.verifyTrue(isfile([ic.fqfp '.nii.gz']))
            if this.do_view; ic.view; end
            
            ic.filesuffix = '.4dfp.hdr';
            this.verifyClass(ic.imagingInfo, 'mlfourd.FourdfpInfo')
            this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.FourdfpTool')
            this.verifyEqual(size(ic.imagingFormat.img), [256 256 256])
            ic.save();
            this.verifyTrue(isfile([ic.fqfp '.4dfp.hdr']))
            if this.do_view; ic.view; end

            ic.filesuffix = '.nii.gz';
            this.verifyClass(ic.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(size(ic.imagingFormat.img), [256 256 256])
            ic.save();
            this.verifyTrue(isfile([ic.fqfp '.nii.gz']))
            if this.do_view; ic.view; end

            ic.filesuffix = '.nii';
            this.verifyClass(ic.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(size(ic.imagingFormat.img), [256 256 256])
            ic.save();
            this.verifyTrue(isfile([ic.fqfp '.nii']))
            if this.do_view; ic.view; end

            ic.filesuffix = '.nii.gz';
            this.verifyClass(ic.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(size(ic.imagingFormat.img), [256 256 256])
            ic.save();
            this.verifyTrue(isfile([ic.fqfp '.nii.gz']))
            if this.do_view; ic.view; end

            ic.filesuffix = '.mgz';
            this.verifyClass(ic.imagingInfo, 'mlfourd.MGHInfo')
            this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.MghTool')
            this.verifyEqual(size(ic.imagingFormat.img), [256 256 256])
            ic.save();
            this.verifyTrue(isfile([ic.fqfp '.mgz']))
            if this.do_view; ic.view; end

            ic.filesuffix = '.nii.gz';
            this.verifyClass(ic.imagingInfo, 'mlfourd.NIfTIInfo')
            this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.NiftiTool')
            this.verifyEqual(size(ic.imagingFormat.img), [256 256 256])
            ic.save();
            this.verifyTrue(isfile([ic.fqfp '.nii.gz']))
            if this.do_view; ic.view; end

            deleteExisting(strcat(tempname_, '.*'))
        end
        function test_orient(this)
            [~,r] = mlbash(sprintf('fslorient -getorient %s.nii.gz', this.RAS));
            this.verifyEqual(strtrim(r), 'NEUROLOGICAL');    

            ic_ras = mlfourd.ImagingContext2(strcat(this.RAS, '.nii.gz'));
            ic_ras.selectNiftiTool();
            ic_ras.fqfp = tempname;
            ic_ras.save();
            [~,r] = mlbash(sprintf('fslorient -getorient %s.nii.gz', ic_ras.fqfp));
            this.verifyEqual(strtrim(r), 'RADIOLOGICAL');

            deleteExisting(strcat(ic_ras.fqfp, '.*'))
        end

        %% mlpatterns.Numerical
        
        function test_minus_starting_nii(this)
            % ref nii.gz
            ic_ras = mlfourd.ImagingContext2(strcat(this.RAS, '.nii.gz'));
            ic_ras.selectNiftiTool();
            this.verifyEqual(ic_ras.orient, 'RADIOLOGICAL');
            this.verifyEqual(ic_ras.qfac, -1);

            ic_4dfp = copy(ic_ras);
            ic_4dfp.selectFourdfpTool();
            this.verifyEqual(dipmax(ic_ras - ic_4dfp), 0); % internally consistent

            ic_4dfp = copy(ic_ras); % nii -> 4dfp
            tmpfp = tempname;
            ic_4dfp.saveas(strcat(tmpfp, '.4dfp.hdr'));
            ic_4dfp = mlfourd.ImagingContext2(strcat(tmpfp, '.4dfp.hdr')); % go through filesystem
            ic_4dfp.selectFourdfpTool();
            this.verifyEqual(dipmax(ic_ras - ic_4dfp), 0); % internally consistent after saving to filesystem
            deleteExisting(strcat(tmpfp, '.4dfp.*'))
        end
        function test_minus_starting_4dfp(this)
            % generate fresh
            ic_ = mlfourd.ImagingContext2(strcat(this.RAS, '.nii.gz'));
            ic_.saveas(strcat(this.RAS, '.4dfp.hdr')); 

            % ref 4dfp.hdr
            ic_ras = mlfourd.ImagingContext2(strcat(this.RAS, '.4dfp.hdr'));
            ic_ras.selectFourdfpTool();
            this.verifyEqual(ic_ras.orient, '');
            this.verifyEqual(ic_ras.qfac, 0);

            ic_nii = copy(ic_ras);
            ic_nii.selectNiftiTool();
            this.verifyEqual(dipmax(ic_ras - ic_nii), 0); % internally consistent

            ic_nii = copy(ic_ras); % 4dfp -> nii
            tmpfp = tempname;
            ic_nii.saveas(strcat(tmpfp, '.nii.gz'));
            ic_nii = mlfourd.ImagingContext2(strcat(tmpfp, '.nii.gz')); % go through filesystem
            ic_nii.selectNiftiTool();
            this.verifyEqual(dipmax(ic_ras - ic_nii), 0); % internally consistent after saving to filesystem
            deleteExisting(strcat(tmpfp, '.nii.gz'))            
        end
        function test_times(this)
            ic_ras = mlfourd.ImagingContext2(strcat(this.RAS, '.nii.gz'));
            this.verifyEqual(dipmax(ic_ras), 3748);
            ic_ras = ic_ras * 2;
            this.verifyEqual(dipmax(ic_ras), 2*3748);
        end
        function test_not(this)
            ic = mlfourd.ImagingContext2(1, 'compatibility', this.compatibility);
            copy_ic = copy(ic);
            not_ic = ~copy_ic;
            this.verifyClass(not_ic, 'mlfourd.ImagingContext2');
            this.verifyEqual(not_ic.stateTypeclass, this.numericalTool);
            if this.compatibility
                this.verifyEqual(not_ic.nifti.img, uint8(0));
            else
                this.verifyEqual(not_ic.nifti.img, false);
            end
            this.verifyEqual(ic.nifti.img, 1);
            this.verifyEqual(copy_ic.nifti.img, 1);
        end
        function test_plus(this)
            testobj = this.testObj + this.testObj;
            this.verifyClass(testobj, 'mlfourd.ImagingContext2');
            this.verifyEqual(testobj.stateTypeclass, this.numericalTool);
            this.verifyEqual(this.testObj.nifti.img, 1);
            this.verifyEqual(double(testobj.nifti.img), 2);
        end
        function test_axpy(this)
            testobj = copy(this.testObj);
            testobj.fileprefix = 'test_axpy_testobj';
            product = testobj*2 + this.testObj;
            this.verifyEqual(testobj.stateTypeclass, this.numericalTool);
            this.verifyEqual(double(product.nifti.img), 3);
            this.verifyEqual(testobj.nifti.img, 1);
        end
        function test_eq(this)
            ic = mlfourd.ImagingContext2(1, 'compatibility', this.compatibility);
            ic2 = ic;
            ic3 = copy(ic);
            this.verifyTrue(ic == ic2);
            this.verifyFalse(ic2 == ic3);
        end
        
        %% BlurringTool
        
        function test_blurred(this)
            import mlfourd.*;
            if this.compatibility
                fdg_ = ImagingFormatContext(fullfile(this.dataDir2, [this.fdg '.4dfp.hdr']));
            else
                fdg_ = ImagingFormatContext2(fullfile(this.dataDir2, [this.fdg '.4dfp.hdr']));
            end
            fdg_.img(:,:,:,2) = fdg_.img;
            
            ic2_ = ImagingContext2(fdg_, 'compatibility', this.compatibility);
            ic2  = ic2_.blurred([1 10 20]);
            if (this.do_view)
                ic2.fsleyes; end
            this.verifyTrue(lstrfind(ic2.fileprefix, '_b200'));
        end
        
        %% DynamicsTool
        
        function test_timeAveraged(this)
            import mlfourd.*; 

            img = ones(2,2,2,4);           
            ic = ImagingContext2(img, 'compatibility', this.compatibility);
            ic1 = ic.timeAveraged();
            this.verifyEqual(double(ic1), ones(2,2,2));
            ic2 = ic.timeAveraged([2 3]);
            this.verifyEqual(double(ic2), ones(2,2,2));
            ic3 = ic.timeAveraged('weights', ones(1,4)/4);
            this.verifyEqual(double(ic3), ones(2,2,2));
            ic3 = ic.timeAveraged('taus', [1 1 1 1]);
            this.verifyEqual(double(ic3), ones(2,2,2));

            img = zeros(2,2,2,4);
            img(:,:,:,2) = ones(2,2,2);
            img(:,:,:,3) = 2*ones(2,2,2);
            img(:,:,:,4) = 3*ones(2,2,2);
            ic = ImagingContext2(img, 'compatibility', this.compatibility);
            ic1 = ic.timeAveraged();
            this.verifyEqual(double(ic1), 1.5*ones(2,2,2), 'AbsTol', 1e-15);
            ic2 = ic.timeAveraged([2 3]);
            this.verifyEqual(double(ic2), 1.5*ones(2,2,2), 'AbsTol', 1e-15);
            ic3 = ic.timeAveraged('weights', [0 1 0.5 1/3]);
            this.verifyEqual(double(ic3), 3*ones(2,2,2), 'AbsTol', 1e-15);
            ic3 = ic.timeAveraged('taus', [0 1 2 3]);
            if this.compatibility
                this.verifyEqual(double(ic3), (14/6)*ones(2,2,2), 'AbsTol', 1e-5);
            else
                this.verifyEqual(double(ic3), (14/6)*ones(2,2,2), 'AbsTol', 1e-15);
            end
            ic4 = ic.timeAveraged(2:4, 'weights', [0 1 0.5 1/3]);
            this.verifyEqual(double(ic4), 3*ones(2,2,2), 'AbsTol', 1e-15);            
        end
        function test_timeContracted(this)
            import mlfourd.*;  

            img = ones(2,2,2,4);          
            ic  = ImagingContext2(img, 'compatibility', this.compatibility);    
            ic1 = ic.timeContracted;
            this.verifyEqual(double(ic1), 4*ones(2,2,2));       
            ic2 = ic.timeContracted([2 3]);
            this.verifyEqual(double(ic2), 2*ones(2,2,2));
        end
        function test_volumeAveraged(this)
            img  = ones(2,2,2,4);
            mimg = zeros(2,2,2);
            mimg(1,1,1) = 1;

            import mlfourd.*;            
            ic  = ImagingContext2(img, 'compatibility', this.compatibility);  
            ic1 = ic.volumeAveraged;
            this.verifyEqual(double(ic1), [1 1 1 1]);      
            ic2 = ic.volumeAveraged(mimg);
            this.verifyEqual(double(ic2), [1 1 1 1]);
        end
        function test_volumeContracted(this)
            img  = ones(2,2,2,4);
            mimg = zeros(2,2,2);
            mimg(1,1,1) = 1;

            import mlfourd.*; 
            ic  = ImagingContext2(img, 'compatibility', this.compatibility);  
            ic1 = ic.volumeContracted;
            this.verifyEqual(double(ic1), [8 8 8 8]);
            ic2 = ic.volumeContracted(mimg);
            this.verifyEqual(double(ic2), [1 1 1 1]);
            
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
            ic = ImagingContext2(img, 'compatibility', this.compatibility);
            ic = ic.binarized;
            this.verifyEqual(dipsum(double(ic)), 2);
        end
        function test_count(this)
            img = zeros(2,2,2,2);
            img(1,1,1,1) = 999;
            img(2,2,2,2) = 999;
            
            import mlfourd.*;
            ic = ImagingContext2(img, 'compatibility', this.compatibility);
            this.verifyEqual(ic.count, 2);
        end
        function test_masked2d(this)
            img   = ones(2,2);            
            mimg2 = zeros(2,2);
            mimg2(1,1) = 1;            
            
            import mlfourd.*;
            ic = ImagingContext2(img, 'compatibility', this.compatibility);
            ic = ic.masked(mimg2);
            this.verifyEqual(dipsum(double(ic)), 1);
        end
        function test_masked3d(this)
            img   = ones(2,2,2);
            mimg2 = zeros(2,2);   mimg2(1,1) = 1;            
            mimg3 = zeros(2,2,2); mimg3(1,1,1) = 1;
            
            import mlfourd.*;
            ic  = ImagingContext2(img, 'compatibility', this.compatibility);
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
            ic  = ImagingContext2(img, 'compatibility', this.compatibility);
            ic3 = ic.masked(mimg3);
            this.verifyEqual(dipsum(double(ic3)), 2);
            ic4 = ic.masked(mimg4);
            this.verifyEqual(dipsum(double(ic4)), 1);
        end
        function test_maskedMaths(this)
            img   = ones(2,2,2,2);
            mimg3 = zeros(2,2,2); mimg3(1,1,1) = 1; mimg3(2,2,2) = 1;            
            
            import mlfourd.*;
            ic  = ImagingContext2(img, 'compatibility', this.compatibility);
            ic3 = ic.maskedMaths(mimg3, @sum);
            this.verifyEqual(dipsum(double(ic3)), 2);
        end
        function test_thresh(this)
            ic = this.T1001_ic_nii;
            ic1 = ic.thresh(127);
            this.assertTrue(contains(ic1.fileprefix, '_thr127'))
            if this.compatibility
                this.assertEqual(dipmean(ic1), single(5.044450879096985), 'AbsTol', 1e-7) % ImagingContext2 adjusts datatype
            else
                this.assertEqual(dipmean(ic1), 5.044450879096985, 'AbsTol', 1e-7) % ImagingContext2 adjusts datatype
            end

            ifc1 = ic1.nifti();
            this.assertTrue(contains(ifc1.fileprefix, '_thr127'))
            this.assertEqual(dipmean(ifc1.img), 5.044450879096985, 'AbsTol', 1e-7) % dipmax() first converts to double
        end
        function test_threshp(this)
            ic = this.T1001_ic_nii;
            ic1 = ic.threshp(20);
            this.assertTrue(contains(ic1.fileprefix, '_thrp20'))
            if this.compatibility
                this.assertEqual(dipmean(ic1), single(21.224115610122681), 'AbsTol', 1e-7) % ImagingContext2 adjusts datatype
            else
                this.assertEqual(dipmean(ic1), 18.895865380764, 'AbsTol', 1e-7) % ImagingContext2 adjusts datatype
            end

            ifc1 = ic1.nifti();
            this.assertTrue(contains(ifc1.fileprefix, '_thrp20'))
            if this.compatibility
                this.assertEqual(dipmean(ifc1.img), 21.224115610122681, 'AbsTol', 1e-7) 
            else
                this.assertEqual(dipmean(ifc1.img), 18.895865380764008, 'AbsTol', 1e-7) % dipmax() first converts to double
            end
        end
        function test_uthresh(this)
            ic = this.T1001_ic_nii;
            ic1 = ic.uthresh(127);
            this.assertTrue(contains(ic1.fileprefix, '_uthr127'))
            if this.compatibility
                this.assertEqual(dipmax(ic1), single(127)) % ImagingContext2 adjusts datatype
            else
                this.assertEqual(dipmax(ic1), 127) % ImagingContext2 adjusts datatype
            end

            ifc1 = ic1.nifti();
            this.assertTrue(contains(ifc1.fileprefix, '_uthr127'))
            this.assertEqual(dipmax(ifc1.img), 127) % dipmax() first converts to double
        end
        function test_uthreshp(this)
            ic = this.T1001_ic_nii;
            ic1 = ic.uthreshp(80);
            this.assertTrue(contains(ic1.fileprefix, '_uthrp80'))
            if this.compatibility
                this.assertEqual(dipmax(ic1), single(49)) % ImagingContext2 adjusts datatype
            else
                this.assertEqual(dipmax(ic1), 204) % ImagingContext2 adjusts datatype
            end

            ifc1 = ic1.nifti();
            this.assertTrue(contains(ifc1.fileprefix, '_uthrp80'))
            if this.compatibility
                this.assertEqual(dipmax(ifc1.img), 49) % dipmax() first converts to double
            else
                this.assertEqual(dipmax(ifc1.img), 204) % dipmax() first converts to double
            end
        end
        function test_zoomed(this)
            this.createFslroi;            
            ic   = mlfourd.ImagingContext2(strcat(this.t1, '.nii.gz'), 'compatibility', this.compatibility); 
            
            zin  = ic.zoomed(44, 88, 62, 124, 0, -1);
            zin.save;
            zout = zin.zoomed(-44, 176, -62, 248, 0, -1);
            zout.save
            if (this.do_view)
                ic.fsleyes(zin.fqfilename, zout.fqfilename); end
            deleteExisting(zin.fqfilename);
            deleteExisting(zout.fqfilename);
        end
        function test_qsforms(this)
            ic = mlfourd.ImagingContext2([this.t1 '.nii.gz'], 'compatibility', this.compatibility);
            ic.saveas([this.t1 '_test.nii.gz']);            
            if (this.do_view)
                ic.fsleyes([this.t1 '_test.nii.gz']); end
        end
        
        %% MatlabTool

        function test_MatlabTool(this)
            obj = mlfourd.ImagingContext2(magic(2), 'compatibility', this.compatibility);
            this.verifyEqual(obj.stateTypeclass, this.numericalTool)
            this.verifyClass(obj.logger, 'mlpipeline.Logger2')
            this.verifyEqual(obj.filesuffix, '.mat')
            this.verifyEqual(double(obj), magic(2))
            this.verifyEqual(double(obj * 2), magic(2) * 2)
            this.verifyEqual(double(obj * obj), magic(2) * magic(2))
            this.verifyEqual(double(obj .* obj), magic(2) .* magic(2)) % element-by-element
            this.verifyEqual(double(obj^3), magic(2)^3)
            this.verifyEqual(double(obj.^3), magic(2).^3) % element-by-element
            this.verifyEqual(double(expm(obj)), expm(magic(2)), 'RelTol', 1e-7)
            this.verifyEqual(double(exp(obj)), exp(magic(2)), 'RelTol', 1e-7) % element-by-element

            % Will fail:
            % ----------
            % this.verifyTrue(obj.numeq(magic(2)))
            % this.verifyTrue(obj.numneq(ones(2)))
            % this.verifyTrue(obj.isequal(magic(2)))
            % this.verifyTrue(obj.lt(5*ones(2)))
        end
        function test_MatlabTool_logical(this)
            if this.compatibility
                return
            end

            off_diag = logical([0 1; 1 0]);

            % inequalities
            obj = mlfourd.ImagingContext2(magic(2), 'compatibility', this.compatibility);
            objc1 = copy(obj);
            objc2 = copy(obj);
            objc3 = copy(obj);
            this.verifyEqual(obj.imagingFormat.img, objc1.imagingFormat.img)
            this.verifyEqual(obj.imagingFormat.img, objc2.imagingFormat.img)
            this.verifyEqual(obj.imagingFormat.img, objc3.imagingFormat.img)

            this.verifyEqual(objc1.numgt(2.5).imagingFormat.img, off_diag) % ~ [0 1; 1 0]
            this.verifyEqual(objc2.gt(2.5).imagingFormat.img, off_diag) % ~ [0 1; 1 0]
            gt_objc3 = objc3 > 2.5; % ~ [0 1; 1 0]
            this.verifyEqual(gt_objc3.imagingFormat.img, off_diag)

            % numeq
            obj = mlfourd.ImagingContext2(off_diag, 'compatibility', false);
            this.verifyEqual(obj.numeq(off_diag).imagingFormat.img, true(2))

            % isequal
            obj = mlfourd.ImagingContext2(off_diag, 'compatibility', false);
            this.verifyEqual(obj.isequal(off_diag).imagingFormat.img, true)

            % not
            obj = mlfourd.ImagingContext2(off_diag, 'compatibility', false);
            this.verifyEqual(not(obj).imagingFormat.img, not(off_diag))
            tilde_obj = ~obj;
            this.verifyEqual(tilde_obj.imagingFormat.img, ~off_diag)

            % logical cast
            obj = mlfourd.ImagingContext2(off_diag, 'compatibility', false);
            this.verifyEqual(logical(obj), [false true; true false])

            % double cast
            obj = mlfourd.ImagingContext2(off_diag, 'compatibility', false);
            this.verifyEqual(double(obj), [0 1; 1 0])

            % eq reveals different handles
            obj1 = mlfourd.ImagingContext2(off_diag, 'compatibility', false);
            obj2 = mlfourd.ImagingContext2(off_diag, 'compatibility', false);
            this.verifyEqual(obj2.eq(obj1), false)
            this.verifyEqual(obj2 == obj1, false)
        end
        function test_zeros(this)
            ic1 = this.T1001_ic_nii.zeros();
            %this.assertTrue(contains(ic1.fileprefix, '_zeros'))
            this.assertEqual(dipsum(ic1), 0)

            ifc1 = ic1.nifti();
            %this.assertTrue(contains(ifc1.fileprefix, '_zeros'))
            this.assertEqual(dipsum(ifc1.img), 0)
        end
        function test_sqrt_nii(this)
            if this.compatibility
                return
            end

            ic = this.T1001_ic_nii;
            ic = sqrt(ic);
            this.verifyEqual(ic.filename, 'T1001_sqrt.nii.gz')
            if ~this.compatibility
                this.verifyEqual(ic.bytes, 134217800)
            end
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.MatlabTool')
            this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.MatlabFormatTool')
            this.verifyEqual(ic.imagingFormat.mmppix, [1 1 1])
            this.verifyEqual(ic.imagingFormat.originator(1:3), [128 128 128])
            this.verifyEqual(ic.imagingInfo.hdr.dime.dim, [3 256 256 256 1 1 1 1])
            this.verifyEqual(ic.imagingInfo.hdr.hist.qform_code, 0)
            this.verifyEqual(ic.imagingInfo.hdr.hist.sform_code, 1)
            this.verifyEqual(ic.dipmax, 15.968719482421875, 'AbsTol', 1e-7)
        end
        function test_power_4dfp(this)
            ic = this.T1001_ic_4dfp;
            ic = ic.^2;
            this.verifyEqual(ic.filename, 'T1001_power_2.4dfp.hdr')
            if ~this.compatibility
                this.verifyEqual(ic.bytes, 134217800)
            end
            if this.compatibility
                this.verifyEqual(ic.stateTypeclass, 'mlfourd.NumericalTool_20211201')
                this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourdfp.InnerFourdfp')
            else
                this.verifyEqual(ic.stateTypeclass, 'mlfourd.MatlabTool')
                this.verifyEqual(ic.imagingFormat.stateTypeclass, 'mlfourd.MatlabFormatTool')
            end
            this.verifyEqual(ic.imagingFormat.mmppix, [1 1 1])
            this.verifyEqual(ic.imagingFormat.originator(1:3), [127.5 127.5 127.5])
            this.verifyEqual(ic.imagingInfo.hdr.dime.dim, [3 256 256 256 1 1 1 1]) % artefact of T1001_ic_4dfp?
            this.verifyEqual(ic.imagingInfo.hdr.hist.qform_code, 0)
            this.verifyEqual(ic.imagingInfo.hdr.hist.sform_code, 1)
            if this.compatibility
                this.verifyEqual(ic.dipmax, single(65025), 'AbsTol', 1e-7)
            else
                this.verifyEqual(ic.dipmax, 65025, 'AbsTol', 1e-7)
            end
        end

        %% PointCloudTool

        function test_PointCloudTool(this)
            ic = mlfourd.ImagingContext2(strcat(this.TOF, '.nii.gz'));
            pc = ic.pointCloud('thresh', 150);
            this.verifyFalse(isnumeric(pc))
            this.verifyEqual(class(pc), 'pointCloud')
            
            if this.do_view
                figure;
                pcshow(pc);
            end

            ic_ = copy(ic);
            ic_.setPointCloud(pc);
            ic_ = ic - ic_;
            if this.do_view
                ic_.view()
            end
            this.verifyEqual(dipmax(ic_), 149)
            this.verifyEqual(dipmin(ic_), 0)
        end

        %% 
        
        function test_ifh(this)
            this.assertTrue(lexist([this.t1 '.4dfp.hdr'], 'file'));
            testfp = sprintf('test_ifh');
            deleteExisting([testfp '*']);
            ic2 = mlfourd.ImagingContext2([this.t1 '.4dfp.hdr'], 'compatibility', this.compatibility);
            ic2 = ic2.saveas([testfp '.4dfp.hdr']);
            ifh = mlfourdfp.IfhParser.load([testfp '.4dfp.ifh']);
            this.verifyEqual( ...            
                ic2.fourdfp.imagingInfo.ifh.fileprefix, ...
                ifh.fileprefix); %% TODO:  fix not passing
        end
        function test_save(this)
            this.testObj.save;
            this.verifyTrue(lexist(this.testObj.fqfilename, 'file'));
            delete(this.testObj.fqfilename);
        end         
        function test_copy(this)
 			import mlfourd.*;
 			obj_ = ImagingContext2(this.T1001_fqfn_nii, 'compatibility', this.compatibility);
 			obj = copy(obj_);
            this.assertTrue(obj_ == obj_) % sames handles
            this.assertFalse(obj == obj_) % distinct handles
        end
        function test_haveDistinctStates(this)
 			import mlfourd.*;
 			obj_ = ImagingContext2(this.T1001_fqfn_nii, 'compatibility', this.compatibility);
 			obj = copy(obj_);
            this.assertFalse(haveDistinctStates(obj_, obj_))
            this.assertTrue(haveDistinctStates(obj, obj_))
        end
        function test_haveDistinctContextHandles(this)
            if this.compatibility
                return
            end

 			import mlfourd.*;
 			obj_ = ImagingContext2(this.T1001_fqfn_nii, 'compatibility', this.compatibility);
 			obj = copy(obj_);
            this.assertFalse(haveDistinctContextHandles(obj_, obj_))
            this.assertTrue(haveDistinctContextHandles(obj, obj_))
        end
        function test_copy_zeros(this)
            acopy = copy(this.T1001_ic_nii);
            ic1 = acopy.zeros();
            %this.assertTrue(contains(ic1.fileprefix, '_zeros'))
            this.assertEqual(dipsum(ic1), 0)

            ifc1 = ic1.nifti;
            %this.assertTrue(contains(ifc1.fileprefix, '_zeros'))
            this.assertEqual(dipsum(ifc1.img), 0)
        end

        %% found while testing Fung2013

        function test_Fung2013_zeros_nifti(this)
            anatomy_ = mlfourd.ImagingContext2('T1001.nii.gz', 'compatibility', this.compatibility);
            ic_ = anatomy_.zeros();
            ifc_ = ic_.nifti;
            %this.assertTrue(contains(ifc_.fileprefix, '_zeros'))
            this.assertEqual(dipsum(ifc_.img), 0)
        end
        function test_Fung2013_zeros_copy(this)
            anatomy_ = copy(mlfourd.ImagingContext2('T1001.nii.gz', 'compatibility', this.compatibility));
            anatomy = copy(anatomy_);
            ic = anatomy.zeros();
            ifc = ic.nifti;
            %this.assertTrue(contains(ifc.fileprefix, '_zeros'))
            this.assertEqual(dipsum(ifc.img), 0)
        end
        function test_Fung2013_zeros_Bids(this)
            pwd0 = pushd(fullfile(getenv('HOME'), 'Singularity/CCIR_00559_00754/derivatives/resolve/sub-S58163/pet'));
            bids = mlraichle.Ccir559754Bids();
            anatomy = bids.t1w_ic;
            ic = anatomy.zeros();
            ifc = ic.nifti;
            %this.assertTrue(contains(ifc.fileprefix, '_zeros'))
            this.assertEqual(dipsum(ifc.img), 0)
            popd(pwd0);
        end
        function test_Fung2013_sum(this)
            pwd0 = pushd(fullfile(getenv('HOME'), 'Singularity/CCIR_00559_00754/derivatives/resolve/sub-S58163/pet'));
            bids = mlraichle.Ccir559754Bids();
            anatomy = bids.t1w_ic;
            ic = sum(anatomy, 3);
            ifc = ic.nifti;
            this.assertTrue(contains(ifc.fileprefix, '_sum_3'))
            this.assertEqual(ndims(ifc), 2)
            popd(pwd0);
        end
        function test_Fung2013_MatlabTool(this)
            ic = mlfourd.ImagingContext2(this.T1001_fqfn_nii);
            icL = ic.imdilate(strel('sphere', 2));
            icR = ic.imdilate(strel('sphere', 4));
            ic2 = icL + icR;
            this.verifyEqual(ic2.filesuffix, '.nii.gz')

            ic2 = ic2.binarized();
            fqfn = ic2.fqfn;
            ic2.save();
            this.verifyTrue(isfile(fqfn))
            deleteExisting(fqfn)
            
            ic3 = ic + copy(ic);
            this.verifyEqual(ic3.fileprefix, 'T1001_plus_size_256_256_256')
        end
    end

 	methods (TestClassSetup)
		function setupImagingContext2(this)
            import mlfourd.*;
            this.testObj_ = ImagingContext2(1, 'compatibility', this.compatibility);
 		end
    end

 	methods (TestMethodSetup)
		function setupImagingContext2Test(this)
 			import mlfourd.*;
 			this.testObj = copy(this.testObj_);

            setupImagingTest(this);
            
            if ~isfile([this.t1 '.nii.gz'])
                copyfile(fullfile(this.dataDir, [this.t1 '.nii.gz']));
            end
            if ~isfile_4dfp(this.t1)
                copyfile(fullfile(this.dataDir, [this.t1 '.4dfp.*']));
            end
            if ~isfile([this.fdg '.nii.gz'])
                copyfile(fullfile(this.dataDir2, [this.fdg '.nii.gz']));
            end
            if ~isfile_4dfp(this.fdg)
                copyfile(fullfile(this.dataDir2, [this.fdg '.4dfp*']));
            end
            if ~isfile([this.fdg4d '.nii.gz'])
                copyfile(fullfile(this.dataDir, [this.fdg4d '.nii.gz']));
            end
            if ~isfile_4dfp(this.fdg4d)
                copyfile(fullfile(this.dataDir, [this.fdg4d '.4dfp*']));
            end

 			this.addTeardown(@this.cleanTestMethod);
 		end
    end

	properties (Access = protected)
        testObj_
    end
    
    methods (Static, Access = protected)
        function hdr = adjustLegacyHdr(hdr, hdr2)
            hdr.hk.regular = 'r';
            hdr.dime.dim(1) = 3; % hdr2 is more NIfTI compliant
            hdr.dime.pixdim(6:8) = [1 1 1];
            hdr.hist.descrip = hdr2.hist.descrip;
            hdr.hist.sform_code = 1;
            hdr.hist.qoffset_x = hdr2.hist.qoffset_x;
            hdr.hist.qoffset_y = hdr2.hist.qoffset_y;
            hdr.hist.qoffset_z = hdr2.hist.qoffset_z;
            if (isfield(hdr2, 'extra'))
                hdr.extra = hdr2.extra;
            else
                hdr.extra = [];
            end
        end
    end

	methods (Access = protected)
		function cleanTestMethod(this)
            cleanTestMethod@mlfourd_unittest.Test_Imaging(this);
        end
        function createFslroi(this)
            if (lexist(fullfile(this.TmpDir, this.fslroi), 'file'))
                return
            end
            mlbash(sprintf('fslroi %s %s %i %i %i %i %i %i', ...
                this.LR, this.fslroi, ...
                this.fslroi_xmin, this.fslroi_xsize, ...
                this.fslroi_ymin, this.fslroi_ysize, ...
                this.fslroi_zmin, this.fslroi_zsize));
        end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

