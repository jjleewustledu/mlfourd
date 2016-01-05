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
        smallT1_fp = 't1_default_on_ho_meanvol_default'
        smallT1_mask_fp = 'bt1_default_mask_on_ho_meanvol_default'
 		testObj 
 	end 

    properties (Dependent)
        fslPath
        sessionPath
        smallT1_fqfn  
        smallT1_niid   
        smallT1_mask
        smallT1_struct
        
        test_save_fqfn
        test_saveas_fqfn
    end
    
    methods %% GET/SET
        function g = get.fslPath(this)
            g = fullfile(this.sessionPath, 'fsl', '');
        end
        function g = get.sessionPath(~)
            g = fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl', 'np755', 'mm01-020_p7377_2009feb5', '');
        end
        function g = get.smallT1_fqfn(this)
            g = fullfile(this.fslPath, [this.smallT1_fp '.nii.gz']);
        end
        function g = get.smallT1_niid(this)
            g = mlfourd.NIfTId(this.smallT1_fqfn);
        end
        function g  = get.smallT1_struct(this)
            g = this.fqfn2struct(this.smallT1_fqfn);
        end
        function g  = get.smallT1_mask(this)
            g = mlfourd.NIfTId( ...
                fullfile(this.fslPath, [this.smallT1_mask_fp '.nii.gz']));
        end        
        function fn = get.test_save_fqfn(this)
            fn = fullfile(this.fslPath, 'test_NIfTId_save.nii.gz');
        end    
        function fn = get.test_saveas_fqfn(this)
            fn = fullfile(this.fslPath, 'test_NIfTId_saveas.nii.gz');
        end
    end
    
	methods (Test)
        
        %% test factory/ctor methods
        
        function test_load(this)
            import mlfourd.*;
            niigz = NIfTId.load('Test_NIfTId_test_load.nii.gz', 'descrip:  .nii.gz');
            nii   = NIfTId.load('Test_NIfTId_test_load2.nii',    'descrip:  .nii');
            mgz   = NIfTId.load('Test_NIfTId_test_load3.mgz',    'descrip:  .mgz');
            hdr   = NIfTId.load('Test_NIfTId_test_load4.hdr',    'descrip:  .hdr');
            this.verifyEqual(niigz.descrip, 'descrip:  .nii.gz');
            this.verifyEqual(  nii.descrip, 'descrip:  .nii');
            this.verifyEqual(  mgz.descrip, 'descrip:  .mgz');
            this.verifyEqual(  hdr.descrip, 'descrip:  .hdr');
            this.verifyEqual(niigz.img, nii.img);
            this.verifyEqual(niigz.img, mgz.img);
            this.verifyEqual(niigz.img, hdr.img);
        end
        function test_ctorParameters(this)
%             ctor = mlfourd.NIfTId(magic(10), ...
%                 'fileprefix', 'Test_NIfTId_test_ctor4args', ...
%                 'descrip', 'from Test_NIfTId.test_ctor4args', ...
%                 'mmppix', [2 3 4]);
%             this.verifyEqual(ctor.img, magic(10));
%             this.verifyEqual(ctor.fileprefix, 'Test_NIfTId_test_ctor4args');
%             this.verifyEqual(ctor.descrip,    'from Test_NIfTId.test_ctor4args');
%             this.verifyEqual(ctor.pixdim, [2 3 4]);
        end
        function test_charCtor(this)
            c = char(this.testObj);
            this.verifyEqual(this.testObj, mlfourd.NIfTId(c));
        end
        function test_structCtor(this)
            warning('off'); %#ok<WNOFF>
            s = struct(this.testObj);
            warning('on'); %#ok<WNON>
            this.verifyEqual(this.testObj, mlfourd.NIfTId(s));
        end
        function test_numericCtor(this)
            niid = mlfourd.NIfTId(this.testObj.img);
            this.verifyEqual(niid.img, double(this.testObj.img));
        end
        function test_NIfTIInterfaceCtor(this)
%             import mlfourd.*;
%             niid = NIfTId(NIfTI.load(this.smallT1_fqfn));
%             this.verifyEqual(niid, NIfTId.load(this.smallT1_fqfn));
        end
        function test_INIfTICtor(this)
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
%             a = this.testObj;
%             b = a.clone;
%             assert(isequal(a, b));
%             a0 = a;
%             adelta = a;
%             adelta.img = [];
%             this.verifyTrue(isequal(a0, a));
        end
        function test_makeSimilar(this)
%             simObj = this.testObj.makeSimilar( ...
%                 'img',        ones(this.testObj.size), ...
%                 'datatype',   4, ...
%                 'label',      'labeled by Test_NIfTId.test_makeSimilar', ...
%                 'bitpix',     32, ...
%                 'descrip',    'described by Test_NIfTId.test_makeSimilar', ...
%                 'fileprefix', 'Test_NIfTId_test_makeSimilar', ...
%                 'mmppix',     [2 3 4], ...
%                 'pixdim',     [2.1 3.1 4.1]);
%             
%             this.verifyEqual(simObj.img(104,128,3),      single(1)); % bitpix was 32
%             this.verifyEqual(simObj.datatype,            16);
%             this.verifyEqual(simObj.label,               'labeled by Test_NIfTId.test_makeSimilar');
%             this.verifyEqual(simObj.bitpix,              32);
%             this.verifyEqual(simObj.descrip(end-40:end), 'described by Test_NIfTId.test_makeSimilar');
%             this.verifyEqual(simObj.fileprefix,          'Test_NIfTId_test_makeSimilar');
%             this.verifyEqual(simObj.mmppix,              [2.1 3.1 4.1]);
%             this.verifyEqual(simObj.pixdim,              [2.1 3.1 4.1]);
%             
%             this.verifyEqual(simObj.ext,                this.testObj.ext);
%             this.verifyEqual(simObj.filetype,           this.testObj.filetype);
%             this.verifyEqual(simObj.hdr.hk,             this.testObj.hdr.hk);
%             this.verifyEqual(simObj.hdr.dime.dim,       this.testObj.hdr.dime.dim);     
%             this.verifyEqual(simObj.hdr.hist.qoffset_x, this.testObj.hdr.hist.qoffset_x);
%             this.verifyEqual(simObj.hdr.hist.srow_x,    this.testObj.hdr.hist.srow_x);
%             this.verifyEqual(simObj.originalType,       this.testObj.originalType);
%             this.verifyEqual(simObj.untouch,            this.testObj.untouch);
%             this.verifyEqual(simObj.entropy,            this.testObj.entropy);
%             this.verifyEqual(simObj.orient,             this.testObj.orient);
%             this.verifyEqual(simObj.filename,           this.testObj.filename);
%             this.verifyEqual(simObj.noclobber,          this.testObj.noclobber);
%             
%             this.verifyEqual(simObj.duration, 1);
%             this.verifyEqual(simObj.rank, 3);
%             this.verifyEqual(simObj.size, [128 128 63]);
        end
        
        %% test methods
        
        function test_forceDouble(this)
            forced = this.testObj.forceDouble;
            this.verifyEqual('double', class(forced.img));
        end
        function test_forceSingle(this)
            forced = this.testObj.forceSingle;
            this.verifyEqual('single', class(forced.img));
        end
        function test_isequaln(this)
            o = mlfourd.NIfTId(this.testObj);
            this.verifyTrue(o.isequaln(this.testObj));
            o.img(64, 64, 32) = -1e6;
            warning('off'); %#ok<WNOFF>
            this.verifyFalse(o.isequaln(this.testObj));
            warning('on'); %#ok<WNON>
        end
        function test_save(this)
            this.testObj.fqfilename = this.test_save_fqfn;
            this.testObj.save;
            saved = mlfourd.NIfTId.load(this.test_save_fqfn);
            this.verifyEqual(saved.img, this.testObj.img);
        end
        function test_saveAs(this)
            this.testObj.saveas(this.test_saveas_fqfn);
            savedas = mlfourd.NIfTId.load(this.test_saveas_fqfn);
            this.verifyEqual(savedas.img, this.testObj.img);
        end
            
        function test_char(this)
            this.verifyEqual(this.testObj.char, this.smallT1_fqfn);
        end
        function test_double(this)
            this.verifyEqual(this.testObj.double, double(this.testObj.img));
        end
        function test_duration(this)
        end
        function test_fov(this)
        end
        function test_matrixsize(this)
        end        
        function test_numel(this)
            this.verifyEqual(this.testObj.numel, numel(this.testObj.img));
        end
        function test_ones(this)
            %this.verifyEqual(this.testObj.ones, ones(size(this.testObj.img)));
        end
        function test_prod(this)
            o = prod(this.testObj, 3);
            this.verifyEqual(o.img, double(prod(this.testObj.img, 3)));
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
        function test_prodSize(this)
            this.verifyEqual(this.testObj.prodSize, numel(this.testObj.img));
        end
        function test_sum(this)
            o = sum(this.testObj, 3);
            this.verifyEqual(o.img, double(sum(this.testObj.img, 3)));
        end
        function test_zeros(this)
            %this.verifyEqual(this.testObj.zeros, zeros(size(this.testObj.img)));
        end
        
        function test_ensureDble(this)
        end
        function test_ensureSing(this)
        end
        function test_ensureInt16(this)
        end
        function test_ensureInt32(this)
        end
        function test_ensureUint8(this)
        end
        function test_switchableSqueeze(this)
        end
        
        %% test properties
        
        function test_ext(this)
            this.verifyEqual(this.testObj.ext, []);
        end
        function test_filetype(this)
            this.verifyEqual(this.testObj.filetype, 2);
        end
        function test_hdr(this)
            this.verifyEqual(this.testObj.hdr.hk.sizeof_hdr, 348);
            this.verifyEqual(this.testObj.hdr.dime.dim,    [3 128 128 63 1 1 1 1]);
            this.verifyEqual(this.testObj.hdr.dime.pixdim, [-1 2.0033 2.0033 2.4250 1.5000 0 0 0], 'RelTol', 1e-4);
            this.verifyEqual(this.testObj.hdr.dime.vox_offset, 352);
            this.verifyEqual(this.testObj.hdr.dime.glmax, 821.72595214, 'RelTol', 1e-8);
            this.verifyEqual(this.testObj.hdr.dime.glmin, 0.9186493158, 'RelTol', 1e-8);
            this.verifyEqual(this.testObj.hdr.hist.qform_code, 2);
            this.verifyEqual(this.testObj.hdr.hist.sform_code, 2);
            this.verifyEqual(this.testObj.hdr.hist.qoffset_x,  54572.2500000000, 'RelTol', 1e-8);
            this.verifyEqual(this.testObj.hdr.hist.qoffset_y, -55587.9296875000, 'RelTol', 1e-8);
            this.verifyEqual(this.testObj.hdr.hist.qoffset_z, -62698.3750000000, 'RelTol', 1e-8);
            this.verifyEqual(this.testObj.hdr.hist.srow_x, [-2.0033130645752 0 0 54572.25],      'RelTol', 1e-6);
            this.verifyEqual(this.testObj.hdr.hist.srow_y, [0 2.0033130645752 0 -55587.9296875], 'RelTol', 1e-6);
            this.verifyEqual(this.testObj.hdr.hist.srow_z, [0 0 2.42499995231628 -62698.375],    'RelTol', 1e-6);
        end
        function test_img(this)
            this.verifyEqual(this.testObj.img(64,64,32), single(383.98629760), 'RelTol', 1e-8);
        end
        function test_originalType(this)
            this.verifyEqual(this.testObj.originalType, 'struct');
        end
        function test_untouch(this)
            this.verifyTrue(this.testObj.untouch);
        end
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
            niid = this.testObj;
            d    = niid.descrip;
            this.verifyEqual(niid.descrip(1:131), ['NIfTId.load read ' niid.fqfn ' on']);
            niid = niid.prepend_descrip(    'toPrepend');
            this.verifyEqual(niid.descrip, ['toPrepend; ' d]);
            niid = niid.append_descrip(     'toAppend');            
            this.verifyEqual(niid.descrip, ['toPrepend; ' d '; toAppend']); 
            niid.descrip = [niid.descrip    '; 0000......']; 
            for id = 1:999
                niid.descrip = [niid.descrip sprintf('%04i......', id)];
            end
            this.verifyEqual(niid.descrip(1:185),    ['toPrepend; ' d '; toAppend; 0000......']);            
            this.verifyEqual(niid.descrip(end-9:end), '0999......');
        end
        function test_entropy(this)
            this.verifyEqual(this.testObj.entropy, 0.00002075192819, 'RelTol', 1e-8);
        end
        function test_fileprefix(this)
            niid = this.testObj;
            this.verifyEqual(niid.fileprefix, this.smallT1_fp);
            niid =   niid.prepend_fileprefix(  'toPrepend_');
            this.verifyEqual(niid.fileprefix, ['toPrepend_' this.smallT1_fp]);
            niid =    niid.append_fileprefix( '_toAppend');            
            this.verifyEqual(niid.fileprefix, ['toPrepend_' this.smallT1_fp '_toAppend']);
        end
        function test_hdxml(this)
            this.verifyEqual(this.testObj.hdxml(1:12), '<nifti_image');
            this.verifyEqual(this.testObj.hdxml(end-1:end), '/>');
        end
        function test_label(this)
            this.verifyEqual(this.testObj.label, 't1_default_on_ho_meanvol_default');
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
        function test_orient(this)
            this.verifyEqual(this.testObj.orient, 'RADIOLOGICAL');
        end
        function test_pixdim(this)
            this.verifyEqual(this.testObj.pixdim, [2.0033 2.0033 2.4250], 'RelTol', 1e-4);
        end
        function test_seriesNumber(this)
            this.verifyEqual(this.testObj.seriesNumber, nan);
        end
 	end 

 	methods (TestClassSetup) 
 		function setupNIfTId(this)
            import mlfourd.*;
            cd(this.fslPath);
 		end 
 	end 

 	methods (TestMethodSetup)
		function setupNIfTIdTest(this)
 			this.testObj = this.smallT1_niid; 
 		end
    end
    
 	methods (TestClassTeardown)
        function teardownNIfTId(this)
            if (lexist(this.test_saveas_fqfn, 'file'))
                delete(this.test_saveas_fqfn); end
            if (lexist(this.test_save_fqfn, 'file'))
                delete(this.test_save_fqfn); end
        end
    end 

    %% PROTECTED
    
    methods (Static, Access = 'protected')
        function strct = fqfn2struct(fqfn) 
            strct = mlniftitools.load_untouch_nii(fqfn);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

