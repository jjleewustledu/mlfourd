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
 	end 

    properties (Dependent)
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
    end
    
    methods %% GET/SET
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
            niid = NIfTId.load(this.smallT1_fp);
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            this.verifyEqual(niid.img, this.testObj.img);
        end
        function test_load_surfer(this)
            niid = mlfourd.NIfTId(this.T1_mgz);
            this.verifyEqual(niid.filepath, myfileparts(this.T1_mgz));
            this.verifyEqual(niid.fileprefix, 'T1');
            this.verifyEqual(niid.filesuffix, '.nii.gz');
            %this.verifyTrue(~lexist(niid.fqfilename));
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
%         function test_ctorNIfTIInterface(this)
%             import mlfourd.*;
%             niid = NIfTId(NIfTI.load(this.smallT1_fqfn));
%             this.verifyEqual(niid, NIfTId.load(this.smallT1_fqfn));
%         end
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
%         function test_saveasAnalyzeHdr(this)
%             fqfn0 = fullfile(this.fslPath, 'Test_NIfTId_test_saveasAnalyzeHdr.hdr');
%             fqfn  = fullfile(this.fslPath, 'Test_NIfTId_test_saveasAnalyzeHdr.img');
%             deleteExisting(fqfn); deleteExisting(fqfn0);
%             
%             this.testObj.filetype = 0;
%             this.testObj.saveas(fqfn);
%             this.verifyTrue(lexist(fqfn, 'file'));
%             imgobj = mlniftitools.load_untouch_nii(fqfn);
%             this.verifyEqual(imgobj.filetype, 0);
%             
%             deleteExisting(fqfn); deleteExisting(fqfn0);
%         end
%         function test_saveasNifti1Hdr(this)
%             fqfn0 = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNifti1Hdr.hdr');
%             fqfn  = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNifti1Hdr.img');
%             deleteExisting(fqfn); deleteExisting(fqfn0);
%             
%             niid = mlfourd.NIfTId.load([this.smallT1_fp '_nifti1.hdr']);
%             niid.saveas(fqfn);
%             this.verifyTrue(lexist(fqfn, 'file'));
%             niid2 = mlniftitools.load_untouch_nii(fqfn);
%             this.verifyEqual(niid2.filetype, 0);
%             
%             deleteExisting(fqfn); deleteExisting(fqfn0);
%         end
%         function test_saveasAnalyze4dHdr(this)
%             fqfn0 = fullfile(this.fslPath, 'Test_NIfTId_test_saveasAnalyze4dHdr.hdr');
%             fqfn  = fullfile(this.fslPath, 'Test_NIfTId_test_saveasAnalyze4dHdr.img');
%             deleteExisting(fqfn); deleteExisting(fqfn0);
%             
%             niid = mlfourd.NIfTId.load([this.smallT1_fp '_analyze4d.hdr']);
%             try
%                 niid.saveas(fqfn);
%             catch ME
%                 this.verifyEqual(ME.identifier, 'MATLAB:nonExistentField');
%             end
%             
%             deleteExisting(fqfn); deleteExisting(fqfn0);
%         end
%         function test_saveasSpmHdr(this)
%             fqfn0 = fullfile(this.fslPath, 'Test_NIfTId_test_saveasSpmHdr.hdr');
%             fqfn  = fullfile(this.fslPath, 'Test_NIfTId_test_saveasSpmHdr.img');
%             deleteExisting(fqfn); deleteExisting(fqfn0);
%             
%             niid = mlfourd.NIfTId.load([this.smallT1_fp '_spm.hdr']);
%             try
%                 niid.saveas(fqfn);
%             catch ME
%                 this.verifyEqual(ME.identifier, 'MATLAB:nonExistentField');
%             end
%             
%             deleteExisting(fqfn); deleteExisting(fqfn0);
%         end
%         function test_saveasMgz(this)
%             fqfn = fullfile(this.fslPath, 'Test_NIfTId_test_saveasMgz.mgz');
%             deleteExisting(fqfn);
%             
%             this.testObj.saveas(fqfn);
%             this.verifyTrue(lexist(fqfn, 'file'));
%             
%             deleteExisting(fqfn);
%         end
%         function test_saveasMgh(this)
%             fqfn = fullfile(this.fslPath, 'Test_NIfTId_test_saveasMgh.mgh');
%             deleteExisting(fqfn);
%             
%             this.testObj.saveas(fqfn);
%             this.verifyTrue(lexist(fqfn, 'file'));
%             
%             deleteExisting(fqfn);
%         end
%         function test_saveasSpmImg(this)
%             fqfn = fullfile(this.fslPath, 'Test_NIfTId_test_saveasSpmImg.img');
%             deleteExisting(fqfn);
%             
%             this.testObj.saveas(fqfn);
%             this.verifyTrue(lexist(fqfn, 'file'));
%             imgobj = mlniftitools.load_untouch_nii(fqfn);
%             this.verifyEqual(imgobj.filetype, 0);
%             
%             deleteExisting(fqfn);
%         end
%         function test_saveasNoExtension(this)
%             fqfp = fullfile(this.fslPath, 'Test_NIfTId_test_saveasNoExtension');
%             fqfn = [fqfp '.nii.gz'];
%             deleteExisting(fqfn);
%             
%             this.testObj.saveas(fqfp);
%             this.verifyTrue(lexist(fqfn, 'file'));
%             savedas = mlfourd.NIfTId.load(fqfn);
%             this.verifyEqual(savedas.img, this.testObj.img);
%             
%             deleteExisting(fqfn);
%         end
            
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
            this.verifyEqual(this.testObj.bitpix, 32);
        end
        function test_creationDate(this)
            this.verifyTrue(ischar(this.testObj.creationDate) && ...
                            20 == length(this.testObj.creationDate));
        end
        function test_datatype(this)
            this.verifyEqual(this.testObj.datatype, 16);
        end
        function test_descrip(this)
            niid     = this.testObj;
            descrip0 = niid.descrip;
            this.verifyEqual(niid.descrip(1:148), ['NIfTId.adjustFieldsAfterLoading read ' niid.fqfn]);
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
%         function test_hdr(this)
%             this.verifyEqual(this.testObj.hdr.hk.sizeof_hdr, 348);
%             this.verifyEqual(this.testObj.hdr.dime.dim,    [3 128 128 63 1 1 1 1]);
%             this.verifyEqual(this.testObj.hdr.dime.pixdim, [-1 2.003313 2.003313 2.424999 1.5 1 1 1], 'RelTol', 1e-4);
%             this.verifyEqual(this.testObj.hdr.dime.vox_offset, 352);
%             this.verifyEqual(this.testObj.hdr.dime.glmax, 821.72595214, 'RelTol', 1e-8);
%             this.verifyEqual(this.testObj.hdr.dime.glmin, 0.9186493158, 'RelTol', 1e-8);
%             this.verifyEqual(this.testObj.hdr.hist.qform_code, 1);
%             this.verifyEqual(this.testObj.hdr.hist.sform_code, 1);
%             this.verifyEqual(this.testObj.hdr.hist.quatern_b, 0);
%             this.verifyEqual(this.testObj.hdr.hist.quatern_c, 1);
%             this.verifyEqual(this.testObj.hdr.hist.quatern_d, 0);
%             this.verifyEqual(this.testObj.hdr.hist.qoffset_x,  54572.2500000000, 'RelTol', 1e-8);
%             this.verifyEqual(this.testObj.hdr.hist.qoffset_y, -55587.9296875000, 'RelTol', 1e-8);
%             this.verifyEqual(this.testObj.hdr.hist.qoffset_z, -62698.3750000000, 'RelTol', 1e-8);
%             this.verifyEqual(this.testObj.hdr.hist.srow_x, [-2.0033130645752 0 0 54572.25],      'RelTol', 1e-6);
%             this.verifyEqual(this.testObj.hdr.hist.srow_y, [0 2.0033130645752 0 -55587.9296875], 'RelTol', 1e-6);
%             this.verifyEqual(this.testObj.hdr.hist.srow_z, [0 0 2.42499995231628 -62698.375],    'RelTol', 1e-6);
%             this.verifyEqual(this.testObj.hdr.hist.magic, 'n+1');
%         end
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
            this.verifyEqual(this.testObj.machine.arch, 'maci64');
            this.verifyEqual(this.testObj.machine.maxsize, 281474976710655);
            this.verifyEqual(this.testObj.machine.endian, 'L');
        end
        function test_mmppix(this)
            this.verifyEqual(this.testObj.mmppix, [2.0033 2.0033 2.4250], 'RelTol', 1e-4);
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
        testObj_
    end
    
    methods (Access = private)
        function cleanupFiles(this)
            deleteExisting2(fullfile(this.fslPath, 'Test_NIfTId*'));
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

