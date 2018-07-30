classdef Test_NIfTId < matlab.unittest.TestCase
	%% TEST_NIFTID  

	%  Usage:  >> results = run(mlfourd_unittest.Test_NIfTId)
 	%          >> result  = run(mlfourd_unittest.Test_NIfTId, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 

	properties
        registry
 		testObj 
        doview = true
 	end 

    properties (Dependent)
        dataroot
        fslPath 
        maskT1_fp
        maskT1_fqfn
        maskT1_niid
        sessionPath
        smallT1_fp
        smallT1_fqfn  
        smallT1_niid  
        smallT1_struct
        T1_mgz
        TmpDir
    end
    
    methods 
        
        %% GET/SET
        
        function g = get.dataroot(~)
            g = fullfile(getenv('HOME'), 'MATLAB-Drive', 'mlfourd', 'data', '');
        end
        function g = get.fslPath(this)
            g = this.registry.fslPath;
        end
        function g = get.maskT1_fp(this)
            g = this.registry.maskT1_fp;
        end
        function g = get.maskT1_fqfn(this)
            g = this.registry.maskT1_fqfn;
        end
        function g = get.maskT1_niid(this)
            g = mlfourd.NIfTId(this.maskT1_fqfn);
        end
        function g = get.sessionPath(this)
            g = this.registry.sessionPath;
        end
        function g = get.smallT1_fp(this)
            g = this.registry.smallT1_fp;
        end
        function g = get.smallT1_fqfn(this)
            g = this.registry.smallT1_fqfn;
        end
        function g = get.smallT1_niid(this)
            g = mlfourd.NIfTId(this.smallT1_fqfn);
        end
        function g = get.smallT1_struct(this)
            g = mlniftitools.load_untouch_nii(this.smallT1_fqfn);
        end
        function g = get.T1_mgz(this)
            g = fullfile(this.sessionPath, 'mri', 'T1.mgz');
        end
        function g = get.TmpDir(~)
            g = fullfile(getenv('HOME'), 'Tmp', '');
        end
    end
    
	methods (Test)
        
        %% test factory/ctor methods
        
        function test_testObj(this)
            this.verifyEqual(this.testObj, this.smallT1_niid);
        end
        function test_loadAdjusted(this)
            niid = mlfourd.NIfTId.load(this.testObj.fqfilename, ...
                'bitpix', 64, ...
                'datatype', 64, ...
                'descrip', 'new', ...
                'ext', magic(2), ...
                'filetype', 1, ...
                'label', 'new', ...
                'mmppix', [4 5 6], ...
                'noclobber', true, ...
                'pixdim', [1 2 3], ...
                'separator', '--'); % parameters are updated in alphabetical order
            this.verifyEqual(niid.bitpix, 64);
            this.verifyEqual(niid.datatype, 64);
            this.verifyTrue(lstrfind(niid.descrip, 't1_default_on_ho_meanvol_default_161616fwhh.nii.gz'));
            this.verifyEqual(niid.descrip(end-4:end), '; new');
            this.verifyEqual(niid.ext, magic(2));
            this.verifyEqual(niid.filename, [this.testObj.fileprefix '.hdr']);
            this.verifyEqual(niid.filepath, this.testObj.filepath);
            this.verifyEqual(niid.fileprefix, this.testObj.fileprefix);
            this.verifyEqual(niid.filesuffix, '.hdr');
            this.verifyEqual(niid.filetype, 1);
            this.verifyEqual(niid.fqfilename, [this.testObj.fqfileprefix '.hdr']);
            this.verifyEqual(niid.fqfileprefix, this.testObj.fqfileprefix);
            this.verifyEqual(niid.img, double(this.testObj.img));
            this.verifyEqual(niid.label, 'new');
            this.verifyEqual(niid.mmppix, [1 2 3]);
            this.verifyTrue( niid.noclobber);
            this.verifyEqual(niid.pixdim, [1 2 3]);
            this.verifyEqual(niid.separator, '--');
            this.verifyFalse(niid.untouch);
        end
        function test_loadMissingFileAdjusted(this)
            niid = mlfourd.NIfTId.load('nonexistentFile.nii.gz'); % remaining parameters are default
            this.verifyEqual(niid.bitpix, 64);
            this.verifyEqual(niid.descrip, 'instance of mlfourd.InnerNIfTId');
            this.verifyEqual(niid.filename, 'nonexistentFile.nii.gz');
            this.verifyEqual(niid.filetype, 2);
            this.verifyEqual(niid.hdr.dime.dim, [4 0 0 0 0 1 1 1]);
            this.verifyEqual(niid.hdr.dime.datatype, 64);
            this.verifyEqual(niid.hdr.dime.bitpix, 64);
            this.verifyEqual(niid.hdr.dime.pixdim, [1 1 1 1 1 0 0 0]);
            this.verifyEqual(niid.hdr.hist.descrip, 'instance of mlfourd.InnerNIfTId');
            this.verifyEqual(niid.img, []);
            this.verifyEqual(niid.originalType, 'char');
            this.verifyFalse(niid.untouch);
        end
        function test_loadFiletypes(this)
            import mlfourd.*;
            niigz     = NIfTId.load([this.smallT1_fp '.nii.gz']); % niftitools
            nii       = NIfTId.load([this.smallT1_fp '.nii']); % niftitools
            %nifti1hdr = NIfTId.load([this.smallT1_fp '_nifti1.hdr']); % niftitools
            mgz       = NIfTId.load([this.smallT1_fp '.mgz']); % mri_convert
            mgh       = NIfTId.load([this.smallT1_fp '.mgh']); % mri_convert
            %spmhdr    = NIfTId.load([this.smallT1_fp '_spm.hdr']); % niftitools
            %spmimg    = NIfTId.load([this.smallT1_fp '_spm.img']); % mri_convert
            
            this.verifyEqual(niigz.filetype, 2);
            this.verifyEqual(nii.filetype, 2);
            %this.verifyEqual(nifti1hdr.filetype, 1);
            this.verifyEqual(mgz.filetype, 2);
            this.verifyEqual(mgh.filetype, 2);
            %this.verifyEqual(spmhdr.filetype, 0);
            %this.verifyEqual(spmimg.filetype, 2);
            
            this.verifyEqual(niigz.img, nii.img);
            %this.verifyEqual(niigz.img, nifti1hdr.img);
            this.verifyEqual(niigz.img, mgz.img);
            this.verifyEqual(niigz.img, mgh.img);
            %this.verifyEqual(niigz.img, spmhdr.img);
            %this.verifyEqual(niigz.img, spmimg.img);
        end
        function test_loadNoExtension(this)
            import mlfourd.*;
            pwd0 = pushd(this.TmpDir);
            niid = NIfTId('t1_mprage_sag_series8');
            this.verifyEqual(niid.filename, 't1_mprage_sag_series8.nii.gz');
            this.verifyEqual(niid.size, [248 256 176]);
            this.verifyClass(niid.imagingInfo, 'mlfourdfp.FourdfpInfo');
            popd(pwd0);
        end
        
        function test_load_4dfp(this)
            %% loads 4dfp created directly from DICOM and checks integrity; checks *.nii.gz created by nifti_4dfp.
            
            pwd0 = pushd(this.TmpDir);
            x = {'.ifh' '.hdr' '.img' '.img.rec'};
            for ix = 1:length(x)
                copyfile(fullfile(this.dataroot, ['t1_mprage_sag_series8.4dfp' x{ix}]), ['t1_mprage_sag_series8.4dfp' x{ix}], 'f');
            end 
            copyfile(fullfile(this.dataroot, 't1_mprage_sag_series8.nii.gz'), 't1_mprage_sag_series8.nii.gz', 'f');
            
            niid = mlfourd.NIfTId('t1_mprage_sag_series8.4dfp.hdr', 'circshiftK', 1, 'N', true); % sagittal
            this.verifyEqual(class(niid.img), 'single');
            this.verifyEqual(size(niid.img),  [176 248 256]);
            this.verifyEqual(niid.originalType, 'struct');
            this.verifyEqual(niid.entropy, 0.143003055853027, 'RelTol', 1e-6);
            this.verifyEqual(niid.filepath, this.TmpDir);
            this.verifyEqual(niid.fileprefix, 't1_mprage_sag_series8');
            this.verifyEqual(niid.filesuffix, '.4dfp.hdr');
            this.verifyEqual(niid.hdr.hk.sizeof_hdr, 348);
            this.verifyEqual(niid.hdr.hk.extents, 0);
            this.verifyEqual(niid.hdr.dime.dim, [4 176 248 256 1 1 1 1]);
            this.verifyEqual(niid.hdr.dime.datatype, 16);
            this.verifyEqual(niid.hdr.dime.bitpix, 32);
            this.verifyEqual(niid.hdr.dime.pixdim, [1 1 1 1 1 0 0 0], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.dime.vox_offset, 352);
            this.verifyEqual(niid.hdr.dime.xyzt_units, 10);
            this.verifyEqual(niid.hdr.dime.glmax, 1296);
            this.verifyEqual(niid.hdr.dime.glmin, 0);
            this.verifyEqual(niid.hdr.hist.qform_code, 0);
            this.verifyEqual(niid.hdr.hist.sform_code, 3);
            this.verifyEqual(niid.hdr.hist.quatern_b, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_c, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_d, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_x, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_y, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_z, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_x, [1 0 0 -87], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_y, [0 1 0 -123], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_z, [0 0 1 -127], 'RelTol', 1e-6);
            this.verifyEqual(niid.machine, 'ieee-le');   
            imshow(fullfile(this.dataroot, 'NIfTId_t1_mprage_sag_series8_csK1_Ntrue.png'));  
            if (this.doview); niid.fsleyes; end
            
            niid1 = mlfourd.NIfTId('t1_mprage_sag_series8.nii.gz', 'circshiftK', 0, 'N', true);
            this.verifyEqualNIfTId(niid1,niid);
            if (this.doview); niid1.fsleyes; end
            
            popd(pwd0);
        end
        function test_load_nifti(this)
            %% loads *.nii.gz created directly from DICOM by Freesurfer and checks integrity; checks 4dfp created by nifti_4dfp. 
            
            pwd0 = pushd(this.TmpDir);
            copyfile(fullfile(this.dataroot, '001.nii.gz'), '001.nii.gz', 'f'); % transverse
            x = {'.ifh' '.hdr' '.img' '.img.rec'};
            for ix = 1:length(x)
                copyfile(fullfile(this.dataroot, ['001.4dfp' x{ix}]), ['001.4dfp' x{ix}], 'f');
            end           
            
            niid = mlfourd.NIfTId('001.nii.gz', 'circshiftK', 0, 'N', false);
            this.verifyEqual(class(niid.img), 'int16');
            this.verifyEqual(size(niid.img),  [248 256 176]);
            this.verifyEqual(niid.originalType, 'struct');
            this.verifyEqual(niid.entropy, 0.143003055853027, 'RelTol', 1e-6);
            this.verifyEqual(niid.filepath, this.TmpDir);
            this.verifyEqual(niid.fileprefix, '001');
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            this.verifyEqual(niid.hdr.hk.sizeof_hdr, 348);
            this.verifyEqual(niid.hdr.hk.extents, 0);
            this.verifyEqual(niid.hdr.dime.dim, [3 248 256 176 1 1 1 1]);
            this.verifyEqual(niid.hdr.dime.datatype, 4);
            this.verifyEqual(niid.hdr.dime.bitpix, 16);
            this.verifyEqual(niid.hdr.dime.pixdim, [-1 1 1 1 2.400000095367432 1 1 1], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.dime.vox_offset, 352);
            this.verifyEqual(niid.hdr.dime.xyzt_units, 10);
            this.verifyEqual(niid.hdr.dime.glmax, 1296);
            this.verifyEqual(niid.hdr.dime.glmin, 0);
            this.verifyEqual(niid.hdr.hist.qform_code, 1);
            this.verifyEqual(niid.hdr.hist.sform_code, 1);
            this.verifyEqual(niid.hdr.hist.quatern_b, -0.492527604103088, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_c, 0.492527604103088, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_d, -0.507362365722656, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_x, 83.6641998291016, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_y, 165.646484375, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_z, 122.161727905273, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_x, [0 0.029666258022189 -0.999559879302979 83.664199829101562], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_y, [-1 0 0 165.6464843750000], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_z, [0 -0.9995598793030 -0.0296662449837 122.1617279052734], 'RelTol', 1e-6);
            this.verifyEqual(niid.machine, 'ieee-le');   
            imshow(fullfile(this.dataroot, 'NIfTId_001_csK-1_Ntrue_datatype4.png'));
            if (this.doview); niid.fsleyes; end
            
            niid1 = mlfourd.NIfTId('001.4dfp.hdr', 'circshiftK', -1, 'N', true, 'datatype', 4);
            this.verifyEqualNIfTId(niid1,niid);
            % Warning: NIfTId.checkFields:  mismatch at field pixdim. 
            % > In mlfourd.NIfTId/checkFields (line 223)
            %   In mlfourd.NIfTId/hdrsequaln (line 471)
            %   In mlfourd.NIfTId/isequaln (line 53)
            %   In matlab.unittest.constraints.ObjectComparator>areEqualUsingIsequalOrIsequaln (line 131)
            %   In matlab.unittest.constraints.ObjectComparator/containerSatisfiedBy (line 50)
            %   In matlab.unittest.constraints.Comparator>deepComparisonIsSatisfied (line 352)
            %   In matlab.unittest.constraints.Comparator/satisfiedBy (line 84)
            %   In matlab.unittest.constraints.IsEqualTo/satisfiedBy (line 193)
            %   In matlab.unittest.internal.constraints.CasualDiagnosticDecorator/satisfiedBy (line 28)
            %   In matlab.unittest.internal.constraints.AliasDecorator/satisfiedBy (line 29)
            %   In matlab.unittest.internal.qualifications.QualificationDelegate/qualifyThat (line 80)
            %   In matlab.unittest.internal.qualifications.QualificationDelegate/qualifyEqual (line 149)
            %   In matlab.unittest.qualifications.Verifiable/verifyEqual (line 444)
            %   In mlfourd_unittest.Test_NIfTId/test_load_nifti (line 259)
            %   Columns 1 through 5
            % 
            %   -1.000000000000000   1.000000000000000   1.000000000000000   1.000000000000000   2.400000095367432
            % 
            %   Columns 6 through 8
            % 
            %    1.000000000000000   1.000000000000000   1.000000000000000
            % 
            %     -1     1     1     1     1     1     1     1

            if (this.doview); niid1.fsleyes; end
            
            popd(pwd0);
        end
        function test_load_nii(this)
            pwd0 = pushd(this.TmpDir);
            copyfile(fullfile(this.dataroot, '001.nii'), '001.nii', 'f');            
            this.verifyT1(mlfourd.NIfTId('001.nii'), '.nii');            
            popd(pwd0);
        end
        function test_load_niigz(this)
            pwd0 = pushd(this.TmpDir);
            copyfile(fullfile(this.dataroot, '001.nii.gz'), '001.nii.gz', 'f');            
            this.verifyT1(mlfourd.NIfTId('001.nii.gz'), '.nii.gz');            
            popd(pwd0);
        end
        function test_load_mgz(this)
            pwd0 = pushd(this.TmpDir);
            copyfile(fullfile(this.dataroot, '001.mgz'), 'f');            
            this.verifyT1(mlfourd.NIfTId('001.mgz'), '.nii.gz');   
            popd(pwd0);
        end
        
        function test_ctorParametersAdjusted(this)
            niid = mlfourd.NIfTId(this.testObj.img, ...
                'fileprefix', this.testObj.fileprefix, ...
                'bitpix', 64, ...
                'datatype', 64, ...
                'descrip', 'new', ...
                'ext', magic(2), ...
                'filetype', 1, ...
                'label', 'new', ...
                'mmppix', [4 5 6], ...
                'noclobber', true, ...
                'pixdim', [1 2 3], ...
                'separator', '--');            
            this.verifyEqual(niid.bitpix, 64);
            this.verifyEqual(niid.datatype, 64);
            this.verifyEqual(niid.descrip, 'instance of mlfourd.InnerNIfTId; new');
            this.verifyEqual(niid.ext, magic(2));
            this.verifyEqual(niid.filename, [this.testObj.fileprefix '.hdr']);
            this.verifyEqual(niid.filepath, this.testObj.filepath);
            this.verifyEqual(niid.fileprefix, this.testObj.fileprefix);
            this.verifyEqual(niid.filesuffix, '.hdr');
            this.verifyEqual(niid.filetype, 1);
            this.verifyEqual(niid.fqfilename, [this.testObj.fqfileprefix '.hdr']);
            this.verifyEqual(niid.fqfileprefix, this.testObj.fqfileprefix);
            this.verifyEqual(niid.img, double(this.testObj.img));
            this.verifyEqual(niid.label, 'new');
            this.verifyEqual(niid.mmppix, [1 2 3]);
            this.verifyTrue( niid.noclobber);
            this.verifyEqual(niid.pixdim, [1 2 3]);
            this.verifyEqual(niid.separator, '--');
            this.verifyFalse(niid.untouch);
        end
        function test_ctor(this)
            niid = mlfourd.NIfTId;
            this.verifyEqual(niid.bitpix, 64);
            this.verifyEqual(niid.datatype, 64);
            this.verifyEqual(niid.fileprefix(1:29), 'instance_mlfourd_InnerNIfTId_');
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            this.verifyEqual(niid.filetype, 2);
            this.verifyEqual(niid.img, []);
            this.verifyEqual(niid.noclobber, true);
            this.verifyTrue(niid.untouch);
        end
        function test_ctorChar(this)
            c = char(this.testObj);
            this.verifyEqual(mlfourd.NIfTId(c), this.testObj);
        end
        function test_ctorCharNoExtension(this)
            c = char(this.testObj);
            [p,f] = myfileparts(c);
            this.verifyEqual(mlfourd.NIfTId(fullfile(p, f)), this.testObj);
        end
        function test_ctorStruct(this)
            warning('off', 'MATLAB:structOnObject');
            s = struct(this.testObj);
            warning('on', 'MATLAB:structOnObject');
            this.verifyEqual(mlfourd.NIfTId(s), this.testObj);
        end
        function test_ctorNumeric(this)
            niid = mlfourd.NIfTId(this.testObj.img);
            this.verifyEqual(niid.img, this.testObj.img);
        end      
        function test_ctorINIfTI(this)
            niid = mlfourd.MaskingNIfTId(this.testObj);
            this.verifyEqual(niid.img, this.testObj.img);
        end        
        function test_copyCtor(this)
            cc = mlfourd.NIfTId(this.testObj);
            this.verifyEqual(cc, this.testObj);
            testObjImg = this.testObj.img;
            this.testObj.img = magic(10);
            this.verifyEqual(cc.img, testObjImg);
        end        
        function test_clone(this)
            a = this.testObj;
            b = a.clone;
            assert(isequal(a, b));
            a0 = a;
            adelta = a;
            adelta.img = [];
            this.verifyTrue(isequal(a0, a));
        end
        function test_view(this)
            this.testObj.view;
        end
        function test_makeSimilar(this)
            a = this.testObj;
            b = a.makeSimilar;
            assert(isequal(a, b));
            a0 = a;
            adelta = a;
            adelta.img = [];
            this.verifyTrue(isequal(a0, a));
        end
        
        %% test methods
        
        function test_isequaln(this)
            o = mlfourd.NIfTId(this.testObj);
            this.verifyTrue(o.isequaln(this.testObj));
            o.img(64, 64, 32) = -1e6;
            warning('off'); %#ok<WNOFF>
            this.verifyFalse(o.isequaln(this.testObj));
            warning('on'); %#ok<WNON>
        end
        function test_save(this)
            fqfn = fullfile(this.fslPath, 'Test_NIfTId_test_save.nii.gz');
            deleteExisting(fqfn);
            
            this.testObj.fqfilename = fqfn;
            this.testObj.save;
            saved = mlfourd.NIfTId.load(fqfn);
            this.verifyEqual(saved.img, this.testObj.img);
            
            deleteExisting(fqfn);
        end
        function test_saveNoExtension(this)
            fqfp = fullfile(this.fslPath, 'Test_NIfTId_test_saveNoExtension');
            fqfn = [fqfp '.nii.gz'];
            deleteExisting(fqfn);
            
            this.testObj.fqfilename = fqfp;
            this.testObj.save;
            this.verifyTrue(lexist(fqfn, 'file'));
            saved = mlfourd.NIfTId.load(fqfn);
            this.verifyEqual(saved.img, this.testObj.img);
            
            deleteExisting(fqfn);
        end
        function test_saveasNiiGz(this)
            fqfn = fullfile(this.fslPath, 'test_NIfTId_test_saveas.nii.gz');
            deleteExisting(fqfn);
            
            this.testObj.saveas(fqfn);
            savedas = mlfourd.NIfTId.load(fqfn);
            this.verifyEqual(savedas.img, this.testObj.img);
            
            deleteExisting(fqfn);
        end
        function test_saveasNii(this)
            fqfn = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNii.nii');
            deleteExisting(fqfn);
            
            this.testObj.saveas(fqfn);
            this.verifyTrue(lexist(fqfn, 'file'));
            
            deleteExisting(fqfn);
        end
        function test_saveasAnalyzeHdr(this)
            fqfn0 = fullfile(this.fslPath, 'Test_NIfTId_test_saveasAnalyzeHdr.hdr');
            fqfn  = fullfile(this.fslPath, 'Test_NIfTId_test_saveasAnalyzeHdr.img');
            deleteExisting(fqfn); deleteExisting(fqfn0);
            
            this.testObj.filetype = 0;
            this.testObj.saveas(fqfn);
            this.verifyTrue(lexist(fqfn, 'file'));
            imgobj = mlniftitools.load_untouch_nii(fqfn);
            this.verifyEqual(imgobj.filetype, 0);
            
            deleteExisting(fqfn); deleteExisting(fqfn0);
        end
        function test_saveasNifti1Hdr(this)
            fqfn0 = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNifti1Hdr.hdr');
            fqfn  = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNifti1Hdr.img');
            deleteExisting(fqfn); deleteExisting(fqfn0);
            
            niid = mlfourd.NIfTId.load([this.smallT1_fp '_nifti1.hdr']);
            niid.saveas(fqfn);
            this.verifyTrue(lexist(fqfn, 'file'));
            niid2 = mlniftitools.load_untouch_nii(fqfn);
            this.verifyEqual(niid2.filetype, 0);
            
            deleteExisting(fqfn); deleteExisting(fqfn0);
        end
        function test_saveasAnalyze4dHdr(this)
            fqfn0 = fullfile(this.fslPath, 'Test_NIfTId_test_saveasAnalyze4dHdr.hdr');
            fqfn  = fullfile(this.fslPath, 'Test_NIfTId_test_saveasAnalyze4dHdr.img');
            deleteExisting(fqfn); deleteExisting(fqfn0);
            
            niid = mlfourd.NIfTId.load([this.smallT1_fp '_analyze4d.hdr']);
            try
                niid.saveas(fqfn);
            catch ME
                this.verifyEqual(ME.identifier, 'MATLAB:nonExistentField');
            end
            
            deleteExisting(fqfn); deleteExisting(fqfn0);
        end
        function test_saveasMgz(this)
            fqfn = fullfile(this.fslPath, 'Test_NIfTId_test_saveasMgz.mgz');
            deleteExisting(fqfn);
            
            this.testObj.saveas(fqfn);
            this.verifyTrue(lexist(fqfn, 'file'));
            
            deleteExisting(fqfn);
        end
        function test_saveasMgh(this)
            fqfn = fullfile(this.fslPath, 'Test_NIfTId_test_saveasMgh.mgh');
            deleteExisting(fqfn);
            
            this.testObj.saveas(fqfn);
            this.verifyTrue(lexist(fqfn, 'file'));
            
            deleteExisting(fqfn);
        end
        function test_saveasNoExtension(this)
            fqfp = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNoExtension');
            fqfn = [fqfp '.nii.gz'];
            deleteExisting(fqfn);
            
            this.testObj.saveas(fqfp);
            this.verifyTrue(lexist(fqfn, 'file'));
            savedas = mlfourd.NIfTId.load(fqfn);
            this.verifyEqual(savedas.img, this.testObj.img);
            
            deleteExisting(fqfn);
        end
        
        function test_char(this)
            this.verifyEqual(this.testObj.char, this.smallT1_fqfn);
        end
        function test_double(this)
            this.verifyEqual(this.testObj.double, double(this.testObj.img));
        end
        function test_duration(this)
            this.verifyEqual(this.testObj.duration, 1);
        end
        function test_fov(this)
            this.verifyEqual(this.testObj.fov, [256  256  130], 'RelTol', 1e-6);
        end
        function test_matrixsize(this)
            this.verifyEqual(this.testObj.matrixsize, [128 128 65]);
        end    
        function test_ones(this)
            this.verifyEqual(this.testObj.ones.img, ones(size(this.testObj.img)));
        end
        function test_prod(this)
            o = prod(this.testObj, 3);
            this.verifyEqual(o.img, prod(this.testObj.img, 3));
        end
        function test_rank(this)
            this.verifyEqual(this.testObj.rank, 3);
        end
        function test_scrubNanInf(this)
            o = this.testObj;
            o.img(:,:,1) = nan;
            o = o.scrubNanInf;
            this.verifyTrue(~any(isnan(o.img(:))));
        end
        function test_single(this)
            this.verifyEqual(this.testObj.single, single(this.testObj.img));
        end
        function test_size(this)
            this.verifyEqual(this.testObj.size, size(this.testObj.img));
        end
        function test_sum(this)
            o = sum(this.testObj, 3);
            this.verifyEqual(o.img, single(sum(this.testObj.img, 3)));
        end
        function test_zeros(this)
            this.verifyEqual(this.testObj.zeros.img, zeros(size(this.testObj.img)));
        end
        
        %% test properties
        
        function test_bitpix(this)
            this.verifyEqual(this.testObj.bitpix, 16);
            this.verifyClass(this.testObj.img, 'int16');
            
            this.testObj.bitpix = 64;
            this.verifyClass(this.testObj.img, 'double');
        end
        function test_creationDate(this)
            this.verifyTrue(lstrfind(this.testObj.creationDate, datestr(now, 1)));
        end
        function test_datatype(this)
            this.verifyEqual(this.testObj.datatype, 4);
            this.verifyClass(this.testObj.img, 'int16');
            
            this.testObj.datatype = 64;
            this.verifyClass(this.testObj.img, 'double');
            this.testObj.datatype = 'double';
            this.verifyClass(this.testObj.img, 'double');
            this.testObj.datatype = 'uint8';
            this.verifyClass(this.testObj.img, 'uint8');
            this.testObj.datatype = 'int16';
            this.verifyClass(this.testObj.img, 'int16');
            this.testObj.datatype = 'int32';
            this.verifyClass(this.testObj.img, 'int32');
            this.testObj.datatype = 'int64';
            this.verifyClass(this.testObj.img, 'int64');
            this.testObj.datatype = 'double';
            this.verifyClass(this.testObj.img, 'double');
            this.testObj.datatype = 'single';
            this.verifyClass(this.testObj.img, 'single');
            this.testObj.datatype = 16;
            this.verifyClass(this.testObj.img, 'single');
        end
        function test_descrip(this)
            niid     = this.testObj;
            descrip0 = niid.descrip;
            this.verifyEqual(niid.descrip(1:148), ['NIfTId.adjustInnerNIfTIdAfterLoading read ' niid.fqfn]);
            niid = niid.prepend_descrip(    'toPrepend');
            this.verifyEqual(niid.descrip, ['toPrepend; ' descrip0]);
            niid = niid.append_descrip(     'toAppend');            
            this.verifyEqual(niid.descrip, ['toPrepend; ' descrip0 '; toAppend']); 
            niid.descrip = [niid.descrip    '; 0000......']; 
            for id = 1:999
                niid.descrip = [niid.descrip sprintf('%04i......', id)];
            end
            this.verifyEqual(niid.descrip(1:180),    ['toPrepend; ' descrip0 '; toAppend; 0000.....']);            
            this.verifyEqual(niid.descrip(end-9:end), '0999......');
        end
        function test_entropy(this)
            this.verifyEqual(this.testObj.entropy, 0.00002075192819, 'RelTol', 1e-8);
        end
        function test_ext(this)
            this.verifyEqual(this.testObj.ext, []);
        end
        function test_filename(this)
            fqfp = this.testObj.fqfileprefix;
            niid = mlfourd.NIfTId.load(fqfp);
            this.verifyEqual(niid.fqfilename, this.testObj.fqfilename);
        end
        function test_filepath(this)
            this.verifyEqual(this.testObj.filepath, this.fslPath);
            this.testObj.filepath = getenv('MLUNIT_TEST_PATH');
            this.verifyEqual(this.testObj.filepath, getenv('MLUNIT_TEST_PATH'));
        end
        function test_fileprefix(this)
            niid = this.testObj;
            this.verifyEqual(niid.fileprefix, this.smallT1_fp);
            niid =   niid.prepend_fileprefix(  'toPrepend_');
            this.verifyEqual(niid.fileprefix, ['toPrepend_' this.smallT1_fp]);
            niid =    niid.append_fileprefix( '_toAppend');            
            this.verifyEqual(niid.fileprefix, ['toPrepend_' this.smallT1_fp '_toAppend']);
        end
        function test_filesuffix(this)
            this.verifyEqual(this.testObj.filesuffix, '.nii.gz');
            this.testObj.filesuffix = '.mgz';            
            this.verifyEqual(this.testObj.filesuffix, '.mgz');
        end
        function test_filetype(this)
            this.verifyEqual(this.testObj.filetype, 2);
        end
        function test_hdr(this)
            this.verifyEqual(this.testObj.hdr.hk.sizeof_hdr, 348);
            this.verifyEqual(this.testObj.hdr.dime.dim,    [3 128 128 63 1 1 1 1]);
            this.verifyEqual(this.testObj.hdr.dime.pixdim, [-1 2.003313 2.003313 2.424999 1.5 1 1 1], 'RelTol', 1e-4);
            this.verifyEqual(this.testObj.hdr.dime.vox_offset, 352);
            this.verifyEqual(this.testObj.hdr.dime.glmax, 821.72595214, 'RelTol', 1e-8);
            this.verifyEqual(this.testObj.hdr.dime.glmin, 0.9186493158, 'RelTol', 1e-8);
            this.verifyEqual(this.testObj.hdr.hist.qform_code, 1);
            this.verifyEqual(this.testObj.hdr.hist.sform_code, 1);
            this.verifyEqual(this.testObj.hdr.hist.quatern_b, 0);
            this.verifyEqual(this.testObj.hdr.hist.quatern_c, 1);
            this.verifyEqual(this.testObj.hdr.hist.quatern_d, 0);
            this.verifyEqual(this.testObj.hdr.hist.qoffset_x,  54572.2500000000, 'RelTol', 1e-8);
            this.verifyEqual(this.testObj.hdr.hist.qoffset_y, -55587.9296875000, 'RelTol', 1e-8);
            this.verifyEqual(this.testObj.hdr.hist.qoffset_z, -62698.3750000000, 'RelTol', 1e-8);
            this.verifyEqual(this.testObj.hdr.hist.srow_x, [-2.0033130645752 0 0 54572.25],      'RelTol', 1e-6);
            this.verifyEqual(this.testObj.hdr.hist.srow_y, [0 2.0033130645752 0 -55587.9296875], 'RelTol', 1e-6);
            this.verifyEqual(this.testObj.hdr.hist.srow_z, [0 0 2.42499995231628 -62698.375],    'RelTol', 1e-6);
            this.verifyEqual(this.testObj.hdr.hist.magic, 'n+1');
        end
        function test_hdxml(this)
            this.verifyEqual(this.testObj.hdxml(1:12), '<nifti_image');
            this.verifyEqual(this.testObj.hdxml(end-1:end), '/>');
        end
        function test_img(this)
            this.verifyEqual(this.testObj.img(64,64,32), single(383.98629760), 'RelTol', 1e-8);
            
            this.testObj.img = [0 eps pi];
            this.verifyEqual(this.testObj.img, [0 eps pi]);
            this.verifyEqual(this.testObj.datatype, 64);
            this.verifyEqual(this.testObj.bitpix, 64);
            
            this.testObj.img = single([0 eps pi]);
            this.verifyEqual(this.testObj.img, single([0 eps pi]));
            this.verifyEqual(this.testObj.datatype, 16);
            this.verifyEqual(this.testObj.bitpix, 32);
            
            this.testObj.img = uint8([0 eps pi]);
            this.verifyEqual(this.testObj.img, uint8([0 eps pi]));
            this.verifyEqual(this.testObj.datatype, 2);
            this.verifyEqual(this.testObj.bitpix, 8);
            
            this.testObj.img = [false true];
            this.verifyEqual(this.testObj.img, uint8([0 1]));
            this.verifyEqual(this.testObj.datatype, 2);
            this.verifyEqual(this.testObj.bitpix, 8);
        end
        function test_label(this)
            this.verifyEqual(this.testObj.label, 't1_default_on_ho_meanvol_default_161616fwhh');
        end
        function test_machine(this)
            this.verifyEqual(this.testObj.machine, 'ieee-le');
        end
        function test_mmppix(this)
            pet = mlfourd.NIfTId(fullfile(this.dataroot, 'fdgv2r1_on_resolved_sumt.4dfp.ifh'));
            this.verifyEqual(         pet.mmppix, [2.08626013 2.0862601 2.0312500], 'RelTol', 1e-4);            
            this.verifyEqual(this.testObj.mmppix, [2.00 2.00 2.00], 'RelTol', 1e-4);
        end
        function test_negentropy(this)
            this.verifyEqual(this.testObj.negentropy, -0.00002075192819, 'RelTol', 1e-8);
        end
        function test_noclobber(this)
            this.cleanupFiles; 
            
            nexist = this.testObj;
            nexist.fileprefix = 'Test_NIfTId.test_noclobber';
            nexist.save;
            this.assumeTrue(nexist.noclobber); 
            this.verifyError(@nexist.save, 'mlfourd:IOError:noclobberPreventedSaving');
            
            fqfp = [nexist.fqfileprefix '_saveas'];
            nexist = nexist.saveas([fqfp '.nii.gz']);
            this.verifyTrue(lexist(nexist.fqfilename));
            this.verifyTrue(lexist(nexist.logger.fqfilename));
            this.verifyEqual(nexist.fqfp, nexist.logger.fqfp);
            
            this.cleanupFiles; 
        end
        function test_orient(this)
            this.verifyEqual(this.testObj.orient, 'RADIOLOGICAL');
        end
        function test_originalType(this)
            this.verifyEqual(this.testObj.originalType, 'struct');
        end
        function test_pixdim(this)
            this.verifyEqual(this.testObj.pixdim, [2.0033 2.0033 2.4250], 'RelTol', 1e-4);
        end
        function test_seriesNumber(this)
            this.verifyEqual(this.testObj.seriesNumber, nan);
        end
        function test_untouch(this)
            this.verifyTrue(this.testObj.untouch);
            obj = this.testObj;
            obj.noclobber = true;
            this.verifyError(@obj.save, 'mlfourd:IOError:noclobberPreventedSaving');
            
            obj.img = magic(2);
            this.verifyFalse(obj.untouch);
        end
        
        %% test helpers
        
        function test_mlbash(this)
            [s,r] = mlbash('pwd');
            this.verifyEqual(s, 0);
            this.verifyEqual(strtrim(r), this.fslPath);
        end
        function test_mlbashDiary(this)
            fqfn = fullfile(this.fslPath, 'test_NIfTId_log.log');
            deleteExisting(fqfn);
            
            [s,r] = mlbash('pwd', 'diaryFilename', fqfn);
            this.verifyEqual(s, 0);
            this.verifyEqual(strtrim(r), this.fslPath);
            this.verifyTrue(lexist(fqfn));
            str = mlio.TextIO.textfileToString(fqfn);
            this.verifyEqual(strtrim(str(41:end)), this.fslPath);
            
            deleteExisting(fqfn);
        end
        function test_mlbashLogger(this)
            fqfn = fullfile(this.fslPath, 'test_NIfTId_log.log');
            deleteExisting(fqfn);
            
            lg = mlpipeline.Logger(fqfn);
            [s,r] = mlbash('pwd', 'logger', lg);
            this.verifyEqual(s, 0);
            this.verifyEqual(strtrim(r), this.fslPath);
            this.verifyEqual(lg.contents(27:68), 'mlpipeline.Logger from jjlee at ophthalmic');
            this.verifyTrue(lstrfind(lg.contents(end-70:end), this.fslPath));
            
            deleteExisting(fqfn);
        end
 	end 

 	methods (TestClassSetup) 
 		function setupNIfTId(this)
            this.registry = mlfourd.UnittestRegistry.instance('initialize');
            this.registry.sessionFolder = 'mm01-020_p7377_2009feb5';
 			this.testObj_ = this.smallT1_niid; 
            this.oriPath_ = pwd;
 		end 
 	end 

 	methods (TestMethodSetup)
		function setupNIfTIdTest(this)
            cd(this.fslPath);
            dt = mlsystem.DirTool('*.log');
            if (dt.length > 0)
                delete('*.log');
            end
 			this.testObj = this.testObj_; 
            this.addTeardown(@this.cleanupFiles);
 		end
    end
    
    %% PRIVATE
    
    properties (Access = 'private')
        oriPath_
        testObj_
    end
    
    methods (Access = private)
        function cleanupFiles(this)
            deleteExisting2(fullfile(this.fslPath, 'Test_NIfTId*'));
            cd(this.oriPath_);
        end
        function verifyT1(this, niid, varargin)
            ip = inputParser;
            addOptional(ip, 'suff', '.nii.gz', @ischar);
            parse(ip, varargin{:});
            
            this.verifyEqual(class(niid.img), 'int16');
            this.verifyEqual(size(niid.img),  [248 256 176]);
            this.verifyEqual(niid.originalType, 'struct');
            this.verifyEqual(niid.entropy, 0.143003055853027, 'RelTol', 1e-6);
            this.verifyEqual(niid.filepath, this.TmpDir);
            this.verifyEqual(niid.fileprefix, '001');
            this.verifyEqual(niid.filesuffix, ip.Results.suff);
            this.verifyEqual(niid.hdr.hk.sizeof_hdr, 348);
            this.verifyEqual(niid.hdr.hk.extents, 0);
            this.verifyEqual(niid.hdr.dime.dim, [3 248 256 176 1 1 1 1]);
            this.verifyEqual(niid.hdr.dime.datatype, 4);
            this.verifyEqual(niid.hdr.dime.bitpix, 16);
            this.verifyEqual(niid.hdr.dime.pixdim, [-1 1 1 1 2.400000095367432 1 1 1], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.dime.vox_offset, 352);
            this.verifyEqual(niid.hdr.dime.xyzt_units, 10);
            this.verifyEqual(niid.hdr.dime.glmax, 1296);
            this.verifyEqual(niid.hdr.dime.glmin, 0);
            this.verifyEqual(niid.hdr.hist.qform_code, 1);
            this.verifyEqual(niid.hdr.hist.sform_code, 1);
            this.verifyEqual(niid.hdr.hist.quatern_b, -0.492527604103088, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_c,  0.492527604103088, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_d, -0.507362365722656, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_x,  83.664199829101562, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_y,  1.656464843750000e+02, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_z,  1.221617279052734e+02, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_x, [0 0.029666258022189 -0.999559879302979 83.664199829101562], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_y, [-1 0 0 1.656464843750000e+02], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_z, [0 -0.999559879302979 -0.029666244983673 1.221617279052734e+02], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.originator, [124 128 88], 'RelTol', 1e-6)
            this.verifyEqual(niid.machine, 'ieee-le');
            this.verifyEqual(sum(sum(sum(niid.img))), 1128125789);
        end
        function verifyEqualNIfTId(this, n1, n2)            
            toignore = [mlfourd.NIfTId.EQUALN_IGNORES ...
                {'filename' 'fileprefix' 'filesuffix' 'fqfilename' 'fqfileprefix' 'fqfn' 'fqfp' ...
                'filetype' 'imagingInfo' 'orient' }];
            props = properties(n1);
            
            for p = 1:length(props)
                if (~lstrfind(props{p}, toignore))
                    this.verifyEqual(n1.(props{p}), n2.(props{p}));
                end
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

