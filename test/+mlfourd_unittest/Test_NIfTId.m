classdef Test_NIfTId < mlfourd_unittest.Test_mlfourdd 
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
 		testObj 
 	end 

    properties (Constant)
        T1ENTROPY = 0.110414616093301;
        ZRANGE    = 70:74;
    end

    properties (Dependent)
        t1
        t1struct
        t1mask
        test_save_fqfn
        test_saveas_fqfn
    end
    
    methods %% GET/SET
        function t  = get.t1(this)
            t = this.t1_;
        end
        function t  = get.t1struct(this)
            t = this.t1struct_;
        end
        function t  = get.t1mask(this)
            t = this.t1mask_;
        end        
        function fn = get.test_save_fqfn(this)
            fn = fullfile(this.fslPath, 'test_NIfTId_save.nii.gz');
        end    
        function fn = get.test_saveas_fqfn(this)
            fn = fullfile(this.fslPath, 'test_NIfTId_saveas.nii.gz');
        end
    end
    
	methods (Test)
        function test_load(this)
            import mlfourd.*;
            niigz = this.reducedImg(NIfTId.load('t1_default.nii.gz', 'descrip:  .nii.gz'));
            nii   = this.reducedImg(NIfTId.load('testing.nii',       'descrip:  .nii'));
            mgz   = this.reducedImg(NIfTId.load('testing.mgz',       'descrip:  .mgz'));
            hdr   = this.reducedImg(NIfTId.load('testing001.hdr',    'descrip:  .hdr'));
            this.assertEqual(niigz.descrip, 'descrip:  .nii.gz');
            this.assertEqual(  nii.descrip, 'descrip:  .nii');
            this.assertEqual(  mgz.descrip, 'descrip:  .mgz');
            this.assertEqual(  hdr.descrip, 'descrip:  .hdr');
            this.assertEqual(niigz.img, nii.img);
            this.assertEqual(niigz.img, mgz.img);
            this.assertEqual(niigz.img, hdr.img);
        end
        function test_ctor4args(this)
            ctor = this.reducedImg( ...
                   mlfourd.NIfTId(this.t1.fqfilename, 'test_ctor4args', 'descrip:  ctor4args', [2 3 4]));
            this.assertEqual(ctor.img, this.t1.img);
            this.assertEqual(ctor.fileprefix, 'test_ctor4args');
            this.assertEqual(ctor.descrip,    'descrip:  ctor4args');
            this.assertEqual(ctor.pixdim, [2 3 4]);
        end
        function test_charCtor(this)
            cctor = this.reducedImg(mlfourd.NIfTId(this.t1.fqfilename));
            this.assertTrue(isequal(this.t1, cctor));
        end
        function test_structCtor(this)
            sctor = mlfourd.NIfTId(this.t1struct);
            this.assertTrue(isequal(this.t1.img, sctor.img));
        end
        function test_numericCtor(this)
            nctor = mlfourd.NIfTId(this.t1.img);
            this.assertEqual(this.t1.img, nctor.img);
        end
        function test_NIfTIInterfaceCtor(this)
            import mlfourd.*;
            ndctor = NIfTId(NIfTI(this.t1struct));
            this.assertTrue(isequal(this.t1, ndctor));
        end
        function test_INIfTIdCtor(this)
            nctor = mlfourd.NIfTId(this.t1);
            this.assertTrue(isequal(this.t1, nctor));
        end
        function test_copyCtor(this)
            import mlfourd.*;
            a = this.t1;
            b = NIfTId(this.t1);
            assert(isequal(a, b));
            a0 = a;
            adelta = a;
            adelta.img = [];
            this.assertTrue(isequal(a0, a));
        end
        function test_clone(this)
            import mlfourd.*;            
            a = this.t1;
            b = a.clone;
            assert(isequal(a, b));
            a0 = a;
            adelta = a;
            adelta.img = [];
            this.assertTrue(isequal(a0, a));
        end
        function test_makeSimilar(this)
            t1sim = this.t1.makeSimilar('img',        ones(this.t1.size), ...
                                        'datatype',   4, ...
                                        'label',      'labelled by test_makeSimilar', ...
                                        'bitpix',     32, ...
                                        'descrip',    'described by test_makeSimilar', ...
                                        'fileprefix', 'test_makeSimilar', ...
                                        'mmppix',     [2 3 4], ...
                                        'pixdim',     [2.1 3.1 4.1]);
            
            this.assertEqual(t1sim.img(104,128,3),      single(1)); % bitpix was 32
            this.assertEqual(t1sim.datatype,            16);
            this.assertEqual(t1sim.label,               'labelled by test_makeSimilar');
            this.assertEqual(t1sim.bitpix,              32);
            this.assertEqual(t1sim.descrip(end-28:end), 'described by test_makeSimilar');
            this.assertEqual(t1sim.fileprefix,          'test_makeSimilar');
            this.assertEqual(t1sim.mmppix,              [2.1 3.1 4.1]);
            this.assertEqual(t1sim.pixdim,              [2.1 3.1 4.1]);
            
            this.assertEqual(t1sim.ext,                []);
            this.assertEqual(t1sim.filetype,           2);
            this.assertEqual(t1sim.hdr.hk,             this.t1.hdr.hk);
            this.assertEqual(t1sim.hdr.dime.dim,       this.t1.hdr.dime.dim);   
            this.assertEqual(t1sim.hdr.hist.quatern_b, 0.0505929440259933, 'RelTol', 1e-4);           
            this.assertEqual(t1sim.hdr.hist.qoffset_x, -101.2082, 'RelTol', 1e-4);
            this.assertEqual(t1sim.hdr.hist.srow_x,    [1 2.0510e-10 0 -101.2082], 'RelTol', 1e-4);
            this.assertEqual(t1sim.originalType,       'mlfourd.NIfTId');
            this.assertEqual(t1sim.untouch,            false);
            this.assertEqual(t1sim.entropy,            0);
            this.assertEqual(t1sim.orient,             '');
            this.assertEqual(t1sim.filename,           'test_makeSimilar.nii.gz');
            this.assertEqual(t1sim.noclobber,          false);
            
            this.assertEqual(t1sim.duration, 1);
            this.assertEqual(t1sim.rank, 3);
            this.assertEqual(t1sim.size, [208 256 5]);
        end
        function test_forceDouble(this)
            forced = this.t1mask.forceDouble;
            this.assertEqual('double', class(forced.img));
        end
        function test_save(this)
            import mlfourd.*;
            fullt1 = NIfTId.load(this.t1_fqfn);
            fullt1.save;
            saved  = NIfTId.load(fullt1.fqfn);
            this.assertTrue(isequal(fullt1.img, saved.img));
        end
        function test_saveAs(this)
            import mlfourd.*;
            this.t1.saveas(this.test_saveas_fqfn);
            savedas = NIfTId.load(this.test_saveas_fqfn);
            this.assertTrue(isequal(this.t1.img, savedas.img));
        end
        
        function test_filepath(this)
            this.t1_.filepath = '';
            this.assertTrue(strcmp(pwd, this.t1.filepath));
        end  
        function test_entropy(this)
            this.assertEqual(this.T1ENTROPY, this.t1.entropy, 'RelTol', 1e-10);
        end      
        function test_char(this)
            this.assertEqual('/Volumes/InnominateHD2/Local/test/np755/mm01-020_p7377_2009feb5/fsl/t1_default.nii.gz', this.t1.char);
        end
        function test_rank(this)
            this.assertEqual(this.t1.rank, 3);
        end
        function test_scrubNanInf(this)
            tmp = this.t1;
            tmp.img(:,:,1) = nan;
            tmp = tmp.scrubNanInf;
            this.assertTrue(~any(isnan(tmp.img(:))));
        end        
 	end 

 	methods (TestClassSetup) 
 		function setupNIfTId(this)
            cd(this.fslPath);
 			this.testObj = mlfourd.NIfTId; 
 		end 
 	end 

 	methods (TestClassTeardown)
        function teardownNIfTId(this)
            if (lexist(this.test_saveas_fqfn, 'file'))
                delete(this.test_saveas_fqfn); end
        end
    end 
    
    methods
        function this = Test_NIfTId(varargin)
            this = this@mlfourd_unittest.Test_mlfourdd(varargin{:});
            this.preferredSession = 2;
            import mlfourd.*;
            this.t1struct_ = this.reducedImg(this.fqfn2struct(this.t1_fqfn));
            this.t1_       = this.reducedImg(NIfTId.load(this.t1_fqfn));
            this.t1mask_   = this.reducedImg(NIfTId.load(this.t1mask_fqfn));
        end
    end

    %% PROTECTED
    
    properties (Access = 'protected')  
        pwd0_
        t1_
        t1struct_
        t1mask_
    end
    
    methods (Static, Access = 'protected')
        function strct = fqfn2struct(fqfn) 
            strct = mlniftitools.load_untouch_nii(fqfn);
        end
        function nii   = fqfn2struct2NIfTId(fqfn)
            nii = mlfourd.NIfTId( ...
                  mlfourd_unittest.Test_NIfTId.fqfn2struct(fqfn));
        end
    end
    
    methods (Access = 'protected')
        function imobj = reducedImg(this, imobj)
            if (isa(imobj, 'mlfourd.INIfTId') || isstruct(imobj))
                imobj.img = imobj.img(:,:,this.ZRANGE);
            elseif (isnumeric(imobj))
                imobj = imobj(:,:,this.ZRANGE);
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

