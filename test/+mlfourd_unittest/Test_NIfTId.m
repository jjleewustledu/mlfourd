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
        doview = false
        noDelete = false
        pwd0
        ref
        registry
 		testObj 
 	end 

    properties (Dependent)
        dataroot
        fslPath 
        sessionPath
        smallT1_fp
        smallT1_niid  
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
        function g = get.sessionPath(this)
            g = this.registry.sessionPath;
        end
        function g = get.smallT1_fp(this)
            g = this.registry.smallT1_fp;
        end
        function g = get.smallT1_niid(this)
            g = mlfourd.NIfTId(this.registry.smallT1_fqfn);
        end
        function g = get.TmpDir(~)
            g = fullfile(getenv('HOME'), 'Tmp', '');
        end
    end
    
	methods (Test)
        
        %% test factory/ctor methods
        
        function test_testObj(this)
            this.verifyEqualNIfTId(this.testObj, this.smallT1_niid);
        end
        function test_loadAdjusted(this)
            niid = mlfourd.NIfTId.load(this.testObj.fqfilename, ...
                'bitpix', 64, ...
                'datatype', 64, ...
                'ext', magic(2), ...
                'filetype', 1, ...
                'label', 'new', ...
                'mmppix', [4 5 6], ...
                'noclobber', true, ...
                'pixdim', [1 2 3], ...
                'separator', '--'); % parameters are updated in alphabetical order
            this.verifyEqual(niid.bitpix, 64);
            this.verifyEqual(niid.datatype, 64);
            this.verifyTrue(lstrfind(niid.descrip, 'FreeSurfer Jan 19 2017'));
            this.verifyEqual(niid.ext, magic(2));
            this.verifyEqual(niid.filename, [this.testObj.fileprefix '.nii.gz']);
            this.verifyEqual(niid.filepath, this.testObj.filepath);
            this.verifyEqual(niid.fileprefix, this.testObj.fileprefix);
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            this.verifyEqual(niid.filetype, 1);
            this.verifyEqual(niid.fqfilename, [this.testObj.fqfileprefix '.nii.gz']);
            this.verifyEqual(niid.fqfileprefix, this.testObj.fqfileprefix);
            this.verifyEqual(niid.img, double(this.testObj.img));
            this.verifyEqual(niid.label, 'new');
            this.verifyEqual(niid.mmppix, [1 2 3]);
            this.verifyTrue( niid.noclobber);
            this.verifyEqual(niid.pixdim, [1 2 3]);
            this.verifyEqual(niid.separator, '--');
            this.verifyFalse(niid.untouch);
        end
        function test_loadMissingFile(this)
            niid = mlfourd.NIfTId.load('nonexistentFile.nii.gz'); % remaining parameters are default
            this.verifyEqual(niid.bitpix, 64);
            this.verifyEqual(niid.datatype, 64);
            this.verifyEqual(niid.descrip, 'instance of mlfourd.NIfTIInfo');
            this.verifyTrue(isempty(niid.ext));
            this.verifyEqual(niid.filename, 'nonexistentFile.nii.gz');
            this.verifyEqual(niid.filetype, []);
            this.verifyEqual(niid.hdr.dime.dim, [4 0 0 0 0 1 1 1]);
            this.verifyEqual(niid.hdr.dime.datatype, 64);
            this.verifyEqual(niid.hdr.dime.bitpix, 64);
            this.verifyEqual(niid.hdr.dime.pixdim, [1 1 1 1 1 1 1 1]);
            this.verifyEqual(niid.hdr.hist.descrip, 'instance of mlfourd.NIfTIInfo');
            this.verifyEqual(niid.hdr.hist.qform_code, 1);
            this.verifyEqual(niid.hdr.hist.sform_code, 1);
            this.verifyEqual(niid.hdr.hist.srow_x, [1 0 0 0]);
            this.verifyEqual(niid.hdr.hist.srow_y, [0 1 0 0]);
            this.verifyEqual(niid.hdr.hist.srow_z, [0 0 1 0]);
            this.verifyEqual(niid.hdr.hist.magic, 'n+1');
            this.verifyEqual(niid.hdr.hist.originator, [0 0 0]);
            this.verifyEqual(niid.img, []);
            this.verifyEqual(niid.originalType, 'char');
            this.verifyTrue(niid.untouch);
        end
        function test_loadFiletypes(this)
            import mlfourd.*;
            if (~lexist([this.smallT1_fp '.nii'], 'file'))
                gunzip([this.smallT1_fp '.nii.gz']);
            end
            if (~lexist([this.smallT1_fp '.mgz'], 'file'))
                mlbash(sprintf('mri_convert %s.nii.gz %s.mgz', this.smallT1_fp, this.smallT1_fp));
            end
            if (~lexist([this.smallT1_fp '.4dfp.hdr'], 'file'))
                mlbash(sprintf('nifti_4dfp -4 %s.nii %s.4dfp.hdr -N', this.smallT1_fp, this.smallT1_fp));
            end
            
            niigz     = NIfTId.load([this.smallT1_fp '.nii.gz']); % niftitools
            nii       = NIfTId.load([this.smallT1_fp '.nii']); % niftitools
            mgz       = NIfTId.load([this.smallT1_fp '.mgz']); % mri_convert
            fdfp      = NIfTId.load([this.smallT1_fp '.4dfp.hdr']); % nift_4dfp
            
            this.verifyEqual(niigz.filetype, 2);
            this.verifyEqual(nii.filetype, 2);
            this.verifyEqual(mgz.filetype, 2);
            this.verifyEqual(fdfp.filetype, 0);
            
            this.verifyEqual(double(niigz.img), double(nii.img));
            this.verifyEqual(double(niigz.img), double(mgz.img));
            this.verifyEqual(double(niigz.img), double(flip(fdfp.img, 1)));
        end
        function test_loadNoExtension(this)
            import mlfourd.*;
            pwd0_ = pushd(this.TmpDir);
            niid = NIfTId(this.ref.dicomAsNiigz);            
            this.verifyEqual(class(niid.img), 'int16');
            this.verifyEqual(size(niid.img),  [176 248 256]);
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            this.verifyClass(niid.imagingInfo, 'mlfourd.NIfTIInfo');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_loadNoExtension'));
            niid.saveas([tmp '.nii.gz']);
            this.verifyTrue(lexist([tmp '.nii.gz'], 'file'));
            this.deleteExisting([tmp '.nii.*']);
            if (this.doview); niid.fsleyes; end            
            popd(pwd0_);
        end        
        function test_load_4dfp(this)
            %% loads 4dfp created directly from DICOM and checks integrity; checks *.nii.gz created by nifti_4dfp.
            
            pwd0_ = pushd(this.TmpDir);
            niid = mlfourd.NIfTId(this.ref.dicomAsFourdfp); % sagittal
            this.verifyt1_dcm2niix_4dfp(niid);            
            this.verifyEqual(niid.filesuffix, '.4dfp.hdr');
            this.verifyClass(niid.imagingInfo, 'mlfourdfp.FourdfpInfo');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_load_4dfp'));
            niid.saveas([tmp '.4dfp.hdr']);
            this.verifyTrue(lexist_4dfp(tmp, 'file'));
            this.deleteExisting([tmp '.4dfp.*']);
            if (this.doview); niid.fsleyes; end          
            popd(pwd0_);
        end
        function test_load_niigz(this)
            pwd0_ = pushd(this.TmpDir);          
            niid = mlfourd.NIfTId(this.ref.dicomAsNiigz);
            this.verifyt1_dcm2niix(niid, '.nii.gz');
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            this.verifyClass(niid.imagingInfo, 'mlfourd.NIfTIInfo'); 
            
            tmp = tempFqfilename(fullfile(pwd, 'test_load_4dfp.nii.gz'));
            niid.saveas(tmp);
            this.verifyTrue(lexist(tmp, 'file'));
            this.deleteExisting(tmp);
            if (this.doview); niid.fsleyes; end        
            popd(pwd0_);
        end
        function test_load_nii(this)
            pwd0_ = pushd(this.TmpDir);      
            niid = mlfourd.NIfTId(this.ref.dicomAsNii);
            this.verifyt1_dcm2niix(niid, '.nii');    
            this.verifyEqual(niid.filesuffix, '.nii');
            this.verifyClass(niid.imagingInfo, 'mlfourd.NIfTIInfo');  
            
            tmp = tempFqfilename(fullfile(pwd, 'test_load_4dfp.nii'));
            niid.saveas(tmp);
            this.verifyTrue(lexist(tmp, 'file'));
            this.deleteExisting(tmp);
            if (this.doview); niid.fsleyes; end            
            popd(pwd0_);
        end
        function test_load_surfer_4dfp(this)
            %% loads *.nii.gz created directly from DICOM by Freesurfer and checks integrity; checks 4dfp created by nifti_4dfp. 
            
            pwd0_ = pushd(this.TmpDir);
            niid = mlfourd.NIfTId(this.ref.surferAsFourdfp);
            this.verify001_4dfp(niid);
            this.verifyEqual(niid.filesuffix, '.4dfp.hdr');
            this.verifyClass(niid.imagingInfo, 'mlfourdfp.FourdfpInfo');
            popd(pwd0_);
        end
        function test_load_surfer_niigz(this)
            pwd0_ = pushd(this.TmpDir);
            niid = mlfourd.NIfTId(this.ref.surferAsNiigz);
            this.verify001(niid, '.nii.gz');
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            this.verifyClass(niid.imagingInfo, 'mlfourd.NIfTIInfo');
            popd(pwd0_);
        end
        function test_load_surfer_nii(this)
            pwd0_ = pushd(this.TmpDir);
            niid = mlfourd.NIfTId(this.ref.surferAsNii);
            this.verify001(niid, '.nii');
            this.verifyEqual(niid.filesuffix, '.nii');
            this.verifyClass(niid.imagingInfo, 'mlfourd.NIfTIInfo');
            popd(pwd0_);
        end
        function test_load_surfer_mgz(this)
            pwd0_ = pushd(this.TmpDir);
            niid = mlfourd.NIfTId(this.ref.surferAsMgz);
            this.verify001(niid, '.nii.gz');
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            this.verifyClass(niid.imagingInfo, 'mlsurfer.MGHInfo');
            popd(pwd0_);
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
            this.verifyEqual(niid.descrip, 'instance of mlfourd.NIfTIInfo; new');
            this.verifyEqual(niid.ext, magic(2));
            this.verifyEqual(niid.filename, [this.testObj.fileprefix '.nii.gz']);
            this.verifyEqual(niid.filepath, this.testObj.filepath);
            this.verifyEqual(niid.fileprefix, this.testObj.fileprefix);
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            this.verifyEqual(niid.filetype, 1);
            this.verifyEqual(niid.fqfilename, [this.testObj.fqfileprefix '.nii.gz']);
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
            this.verifyEqual(niid.fileprefix(1:20), 'mlfourd_ImagingInfo_');
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            this.verifyEqual(niid.filetype, []);
            this.verifyEqual(niid.img, []);
            this.verifyTrue(niid.noclobber);
            this.verifyFalse(niid.untouch);
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
            warning('off'); 
            this.verifyFalse(o.isequaln(this.testObj));
            warning('on'); 
        end
        function test_save(this)
            fqfn = fullfile(this.fslPath, 'Test_NIfTId_test_save.nii.gz');
            this.deleteExisting(fqfn);
            
            this.testObj.fqfilename = fqfn;
            this.testObj.save;
            saved = mlfourd.NIfTId.load(fqfn);
            this.verifyEqual(saved.img, this.testObj.img);
            
            this.deleteExisting(fqfn);
        end
        function test_saveNoExtension(this)
            fqfp = fullfile(this.fslPath, 'Test_NIfTId_test_saveNoExtension');
            fqfn = [fqfp '.nii.gz'];
            this.deleteExisting(fqfn);
            
            this.testObj.fqfilename = fqfp;
            this.testObj.save;
            this.verifyTrue(lexist(fqfn, 'file'));
            saved = mlfourd.NIfTId.load(fqfn);
            this.verifyEqual(saved.img, this.testObj.img);
            
            this.deleteExisting(fqfn);
        end
        function test_saveasNiigz(this)
            fqfn = fullfile(this.fslPath, 'test_NIfTId_test_saveas.nii.gz');
            this.deleteExisting(fqfn);
            
            this.testObj.saveas(fqfn);
            savedas = mlfourd.NIfTId.load(fqfn);
            this.verifyEqual(savedas.img, this.testObj.img);
            
            this.deleteExisting(fqfn);
        end
        function test_saveasNii(this)
            fqfn = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNii.nii');
            this.deleteExisting(fqfn);
            
            this.testObj.saveas(fqfn);
            this.verifyTrue(lexist(fqfn, 'file'));
            
            this.deleteExisting(fqfn);
        end
        function test_saveasNifti1Hdr(this)
            pwd0_ = pushd(this.TmpDir);            
            fqfn0 = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNifti1Hdr.hdr');
            fqfn  = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNifti1Hdr.img');
            this.deleteExisting(fqfn0);
            this.deleteExisting(fqfn); 
            
            niid = mlfourd.NIfTId('ana001.hdr');
            niid.saveas(fqfn0);
            this.verifyTrue(lexist(fqfn0, 'file'));
            niid2 = mlniftitools.load_untouch_nii(fqfn0);
            this.verifyEqual(niid2.filetype, 1);
            
            this.deleteExisting(fqfn0);
            this.deleteExisting(fqfn); 
            popd(pwd0_);
        end
        function test_saveasMgz(this)
            fqfn = fullfile(this.fslPath, 'Test_NIfTId_test_saveasMgz.mgz');
            this.deleteExisting(fqfn);
            
            this.testObj.saveas(fqfn);
            this.verifyTrue(lexist(fqfn, 'file'));
            
            this.deleteExisting(fqfn);
        end
        function test_saveasNoExtension(this)
            fqfp = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNoExtension');
            fqfn = [fqfp '.nii.gz'];
            this.deleteExisting(fqfn);
            
            this.testObj.saveas(fqfp);
            this.verifyTrue(lexist(fqfn, 'file'));
            savedas = mlfourd.NIfTId.load(fqfn);
            this.verifyEqual(savedas.img, this.testObj.img);
            
            this.deleteExisting(fqfn);
        end
        
        function test_char(this)
            this.verifyEqual(this.testObj.char, this.smallT1_niid.fqfilename);
        end
        function test_double(this)
            this.verifyEqual(this.testObj.double, double(this.testObj.img));
        end
        function test_duration(this)
            this.verifyEqual(this.testObj.duration, 0);
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
            this.verifyEqual(this.testObj.bitpix, 32);
            this.verifyClass(this.testObj.img, 'single');
            
            this.testObj.bitpix = 64;
            this.verifyClass(this.testObj.img, 'double');
        end
        function test_creationDate(this)
            this.verifyTrue(lstrfind(this.testObj.creationDate, datestr(now, 1)));
        end
        function test_datatype(this)
            this.verifyEqual(this.testObj.datatype, 16);
            this.verifyClass(this.testObj.img, 'single');
            
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
            %this.verifyEqual(niid.descrip(1:148), ['NIfTId.adjustInnerNIfTIdAfterLoading read ' niid.fqfn]);
            niid = niid.prepend_descrip(    'toPrepend');
            this.verifyEqual(niid.descrip, ['toPrepend; ' descrip0]);
            niid = niid.append_descrip(     'toAppend');            
            this.verifyEqual(niid.descrip, ['toPrepend; ' descrip0 '; toAppend']); 
            niid.descrip = [niid.descrip    '; 0000......']; 
            for id = 1:999
                niid.descrip = [niid.descrip sprintf('%04i......', id)];
            end
            %this.verifyEqual(niid.descrip(1:180),    ['toPrepend; ' descrip0 '; toAppend; 0000.....']);            
            this.verifyEqual(niid.descrip(end-9:end), '0999......');
        end
        function test_entropy(this)
            this.verifyEqual(this.testObj.entropy, 2.015574498248682e-05, 'RelTol', 1e-8);
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
        function test_img(this)
            this.verifyEqual(this.testObj.img(64,64,32), single(318), 'RelTol', 1e-8);
            
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
            pet = mlfourd.NIfTId(fullfile(this.dataroot, 'fdgv2r1_on_resolved_sumt.4dfp.hdr'));
            this.verifyEqual(         pet.mmppix, [2.08626013 2.0862601 2.0312500], 'RelTol', 1e-4);            
            this.verifyEqual(this.testObj.mmppix, [2.00 2.00 2.00], 'RelTol', 1e-4);
        end
        function test_negentropy(this)
            this.verifyEqual(this.testObj.negentropy, -2.015574498248682e-05, 'RelTol', 1e-8);
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
        function test_originalType(this)
            this.verifyEqual(this.testObj.originalType, 'char');
        end
        function test_pixdim(this)
            this.verifyEqual(this.testObj.pixdim, [2 2 2], 'RelTol', 1e-4);
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
            this.deleteExisting(fqfn);
            
            [s,r] = mlbash('pwd', 'diaryFilename', fqfn);
            this.verifyEqual(s, 0);
            this.verifyEqual(strtrim(r), this.fslPath);
            this.verifyTrue(lexist(fqfn));
            str = mlio.TextIO.textfileToString(fqfn);
            this.verifyEqual(strtrim(str(41:end)), this.fslPath);
            
            this.deleteExisting(fqfn);
        end
        function test_mlbashLogger(this)
            fqfn = fullfile(this.fslPath, 'test_NIfTId_log.log');
            this.deleteExisting(fqfn);
            
            lg = mlpipeline.Logger(fqfn);
            [s,r] = mlbash('pwd', 'logger', lg);
            this.verifyEqual(s, 0);
            this.verifyEqual(strtrim(r), this.fslPath);
            c = lg.contents.cell;
            this.verifyTrue(lstrfind(c{1}, 'mlpipeline.Logger from jjlee at '));
            this.verifyTrue(lstrfind(c{3}, this.fslPath));
            
            this.deleteExisting(fqfn);
        end
 	end 

 	methods (TestClassSetup) 
 		function setupNIfTId(this)
            this = this.ensureFiles;
 			this.testObj_ = this.smallT1_niid;             
        end 
        function this = ensureFiles(this)
            
            % older tests
            this.registry = mlfourd.UnittestRegistry.instance('initialize');
            this.registry.sessionFolder = 'mm01-020_p7377_2009feb5';
            assert(isdir(this.sessionPath));
            
            % newer tests
            this.ref = mlfourd.ReferenceMprage;
            this.ref.copyfiles(this.TmpDir);
            pwd0_ = pushd(this.TmpDir);
            if (~lexist(this.ref.dicomAsNii, 'file'))
                gunzip(this.ref.dicomAsNiigz);
            end
            if (~lexist(this.ref.surferAsNii, 'file'))
                gunzip(this.ref.surferAsNiigz);
            end
            popd(pwd0_);
        end
 	end 

 	methods (TestMethodSetup)
		function setupNIfTIdTest(this)
            this.pwd0 = cd(this.fslPath);
 			this.testObj = this.testObj_; 
            this.addTeardown(@this.cleanupFiles);
 		end
    end
    
    %% PRIVATE
    
    properties (Access = 'private')
        testObj_
    end
    
    methods (Access = private)
        function cleanupFiles(this)
            this.deleteExisting(fullfile(this.fslPath, '*.log'));
            this.deleteExisting(fullfile(this.fslPath, 'Test_NIfTId*'));
            popd(this.pwd0);
        end
        function deleteExisting(this, varargin)
            if (this.noDelete)
                return
            end
            deleteExisting(varargin{:});
        end
        function verify001_4dfp(this, niid, varargin)
            ip = inputParser;
            addOptional(ip, 'suff', '.4dfp.hdr', @ischar);
            parse(ip, varargin{:});
            
            this.verifyEqual(class(niid.img), 'single');
            this.verifyEqual(size(niid.img),  [176 248 256]);
            this.verifyEqual(niid.originalType, 'char');
            this.verifyEqual(niid.entropy, 0.143003055853027, 'RelTol', 1e-6);
            this.verifyEqual(niid.filepath, this.TmpDir);
            this.verifyEqual(niid.fileprefix, '001');
            this.verifyEqual(niid.filesuffix, ip.Results.suff);
            this.verifyEqual(niid.hdr.hk.sizeof_hdr, 348);
            this.verifyEqual(niid.hdr.hk.extents, 0);
            this.verifyEqual(niid.hdr.dime.dim, [3 176 248 256 1 1 1 1]);
            this.verifyEqual(niid.hdr.dime.datatype, 16);
            this.verifyEqual(niid.hdr.dime.bitpix, 32);
            this.verifyEqual(niid.hdr.dime.pixdim, [1 1 1 1 1 1 1 1], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.dime.vox_offset, 352);
            this.verifyEqual(niid.hdr.dime.xyzt_units, 10);
            this.verifyEqual(niid.hdr.dime.glmax, 1296);
            this.verifyEqual(niid.hdr.dime.glmin, 0);
            this.verifyEqual(niid.hdr.hist.qform_code, 0);
            this.verifyEqual(niid.hdr.hist.sform_code, 1);
            this.verifyEqual(niid.hdr.hist.quatern_b, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_c, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_d, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_x, -87, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_y, -123, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_z, -127, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_x, [1 0 0 -87], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_y, [0 1 0 -123], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_z, [0 0 1 -127], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.originator, [88 124 128], 'RelTol', 1e-6)
            this.verifyEqual(niid.machine, 'ieee-le');
            this.verifyEqual(sum(sum(sum(niid.img))), single(1128125696), 'RelTol', 1e-6);
        end
        function verify001(this, niid, varargin)
            ip = inputParser;
            addOptional(ip, 'suff', '.nii.gz', @ischar);
            parse(ip, varargin{:});
            
            this.verifyEqual(class(niid.img), 'int16');
            this.verifyEqual(size(niid.img),  [248 256 176]);
            this.verifyEqual(niid.originalType, 'char');
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
        function verifyt1_dcm2niix_4dfp(this, niid, varargin)
            ip = inputParser;
            addOptional(ip, 'suff', '.4dfp.hdr', @ischar);
            parse(ip, varargin{:});
            
            this.verifyEqual(class(niid.img), 'single');
            this.verifyEqual(size(niid.img),  [176 248 256]);
            this.verifyEqual(niid.originalType, 'char');
            this.verifyEqual(niid.entropy, 0.143003055853027, 'RelTol', 1e-6);
            this.verifyEqual(niid.filepath, this.TmpDir);
            this.verifyEqual(niid.fileprefix, 't1_dcm2niix');
            this.verifyEqual(niid.filesuffix, ip.Results.suff);
            this.verifyEqual(niid.hdr.hk.sizeof_hdr, 348);
            this.verifyEqual(niid.hdr.hk.extents, 0);
            this.verifyEqual(niid.hdr.dime.dim, [3 176 248 256 1 1 1 1]);
            this.verifyEqual(niid.hdr.dime.datatype, 16);
            this.verifyEqual(niid.hdr.dime.bitpix, 32);
            this.verifyEqual(niid.hdr.dime.pixdim, [1 0.999997019767761 1 1 1 1 1 1], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.dime.vox_offset, 352);
            this.verifyEqual(niid.hdr.dime.xyzt_units, 10);
            this.verifyEqual(niid.hdr.dime.glmax, 1296);
            this.verifyEqual(niid.hdr.dime.glmin, 0);
            this.verifyEqual(niid.hdr.hist.qform_code, 0);
            this.verifyEqual(niid.hdr.hist.sform_code, 1);
            this.verifyEqual(niid.hdr.hist.quatern_b, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_c, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_d, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_x, -86.999478460139812, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_y, -123, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_z, -127, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_x, [0.999997019767761 0 0 -86.999478460139812], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_y, [0 1 0 -123], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_z, [0 0 1 -127], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.originator, [87.999779701232910 124 128], 'RelTol', 1e-6);
            this.verifyEqual(niid.machine, 'ieee-le'); 
            this.verifyEqual(sum(sum(sum(niid.img))), single(1.1281257e+09), 'RelTol', 1e-6);
        end
        function verifyt1_dcm2niix(this, niid, varargin)
            ip = inputParser;
            addOptional(ip, 'suff', '.nii.gz', @ischar);
            parse(ip, varargin{:});
            
            this.verifyEqual(class(niid.img), 'int16');
            this.verifyEqual(size(niid.img),  [176 248 256]);
            this.verifyEqual(niid.originalType, 'char');
            this.verifyEqual(niid.entropy, 0.143003055853027, 'RelTol', 1e-6);
            this.verifyEqual(niid.filepath, this.TmpDir);
            this.verifyEqual(niid.fileprefix, 't1_dcm2niix');
            this.verifyEqual(niid.filesuffix, ip.Results.suff);
            this.verifyEqual(niid.hdr.hk.sizeof_hdr, 348);
            this.verifyEqual(niid.hdr.hk.extents, 0);
            this.verifyEqual(niid.hdr.dime.dim, [3 176 248 256 1 1 1 1]);
            this.verifyEqual(niid.hdr.dime.datatype, 4);
            this.verifyEqual(niid.hdr.dime.bitpix, 16);
            this.verifyEqual(niid.hdr.dime.pixdim, [1 0.999997496604919 1 1 2.400000095367432 0 0 0], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.dime.vox_offset, 352);
            this.verifyEqual(niid.hdr.dime.xyzt_units, 10);
            this.verifyEqual(niid.hdr.dime.glmax, 1296);
            this.verifyEqual(niid.hdr.dime.glmin, 0);
            this.verifyEqual(niid.hdr.hist.qform_code, 1);
            this.verifyEqual(niid.hdr.hist.sform_code, 1);
            this.verifyEqual(niid.hdr.hist.quatern_b, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_c, -0.014834761619568, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.quatern_d, 0, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_x, -83.693443298339844, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_y, -81.353515625000000, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.qoffset_z, -1.379176177978516e+02, 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_x, [0.999557375907898 0 -0.029666258022189 -83.693443298339844], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_y, [0 1 0 -81.353515625000000], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.srow_z, [0.029666183516383 0 0.999559879302979 -1.379176177978516e+02], 'RelTol', 1e-6);
            this.verifyEqual(niid.hdr.hist.originator, [87.999779701232910 124 128], 'RelTol', 1e-6);
            this.verifyEqual(niid.machine, 'ieee-le'); 
            this.verifyEqual(sum(sum(sum(niid.img))), 1.1281257e+09, 'RelTol', 1e-6);
        end
        function verifyEqualNIfTId(this, n1, n2)
            toignore = [mlfourd.NIfTId.EQUALN_IGNORES ...
                {'filename' 'fileprefix' 'filesuffix' 'fqfilename' 'fqfileprefix' 'fqfn' 'fqfp' ...
                'filetype' 'imagingInfo'}];
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

