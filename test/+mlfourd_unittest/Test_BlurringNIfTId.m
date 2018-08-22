classdef Test_BlurringNIfTId < mlfourd_unittest.Test_mlfourd
	%% TEST_BLURRINGNIFTID  

	%  Usage:  >> results = run(mlfourd_unittest.Test_BlurringNIfTId)
 	%          >> result  = run(mlfourd_unittest.Test_BlurringNIfTId, 'test_dt')
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

    properties (Dependent)
        maskT1_fp
        maskT1_fqfn
        maskT1_niid
        smallT1_fp
        smallT1_fqfn  
        smallT1_niid  
        smallT1_struct
        T1_mgz
    end
    
    methods %% GET/SET
        function g = get.maskT1_fp(this)
            g = this.registry.maskT1_fp;
        end
        function g = get.maskT1_fqfn(this)
            g = this.registry.maskT1_fqfn;
        end
        function g = get.maskT1_niid(this)
            g = mlfourd.NIfTId(this.maskT1_fqfn);
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
        function test_blurredDynamic(this)
            import mlfourd.*;
            ep2d = NIfTId.load(this.ep2d_fqfn);
            bnEp2d = BlurringNIfTId(ep2d);
            blurred = bnEp2d.blurred([2 4 3]);
            blurred.saveas(this.test_fqfn);
            this.verifyEqual(blurred.entropy,    8.696512620491689e-04, 'RelTol', 1e-10);
            this.verifyEqual(blurred.fileprefix, 'ep2d_default_243fwhh');
            this.verifyEqual(blurred.descrip,    [ep2d.descrip '; decorated by BlurringNIfTId; blurred to [2 4 3]']);
            this.verifyEqual(blurred.pixdim,     ep2d.pixdim);
            %blurred.freeview
         end
%         function test_blurredWater(this)
%             import mlfourd.*;
%             ho = NIfTId.load(fullfile(this.sessionPath, 'ECAT_EXACT', 'coss', 'cs01-999-ho1.nii.gz'));
%             bnHo = BlurringNIfTId(ho);        
%             blurred = bnHo.blurred([10 10 2]);  
%             blurred.saveas(this.test_fqfn);          
%             %blurred.freeview
%         end
        function test_blurredStatic(this)
            blurred = this.testObj.blurred([2 4 3]); %, this.maskT1_niid); 
            blurred.saveas(this.test_fqfn);
%            this.verifyEqual(blurred.entropy,    0.567605718841869 , 'RelTol', 1e-10);
            this.verifyEqual(blurred.fileprefix, 't1_default_on_ho_meanvol_default_161616fwhh_243fwhh');
            this.verifyEqual(blurred.descrip,    [this.smallT1_niid.descrip '; decorated by BlurringNIfTId; blurred to [2 4 3]']);
            this.verifyEqual(blurred.pixdim,     this.smallT1_niid.pixdim);            
            %blurred.freeview
        end
        
        function test_load(this)
            import mlfourd.*;
            bnii = BlurringNIfTId.load(this.t1_fqfn);
            component = NIfTId.load(this.t1_fqfn);
            this.verifyTrue(isequal(bnii.mask, 1));
            this.verifyTrue(isequal(bnii.blurCount, 0));
            this.verifyTrue(isequal(bnii.component, component));
            this.verifyEqual(double(bnii.img), double(component.img));
            this.verifyEqual(bnii.entropy,    0.120310143405054, 'RelTol', 1e-10);
            this.verifyEqual(bnii.fileprefix, 't1_default');
            this.verifyEqual(bnii.descrip(end-28:end), '; decorated by BlurringNIfTId');
            this.verifyEqual(bnii.pixdim,     component.pixdim);
        end
        function test_ctor4args(~)
        end
        function test_ctor2args(this)
            ctor = mlfourd.BlurringNIfTId(this.smallT1_niid, 'mask', this.maskT1_niid);
            this.verifyEqual(ctor.component, this.smallT1_niid);
            this.verifyEqual(ctor.mask,      this.maskT1_niid.double);
        end
        function test_clone(this)
            import mlfourd.*;            
            a = this.testObj;
            b = a.clone;
            assert(isequal(a, b));
            a0 = a;
            adelta = a;
            adelta.img = NaN;
            this.verifyTrue(isequal(a0, a));
        end
        function test_makeSimilar(this)
            sim = this.testObj.makeSimilar( ...
                'img',        ones(this.smallT1_niid.size), ...
                'datatype',   4, ...
                'label',      'labelled by test_makeSimilar', ...
                'bitpix',     32, ...
                'descrip',    'described by test_makeSimilar', ...
                'fileprefix', 'test_makeSimilar', ...
                'mmppix',     [2 3 4], ...
                'pixdim',     [2.1 3.1 4.1]);
            
            this.verifyEqual(sim.img(104,128,3),      1); % bitpix was 32
            this.verifyEqual(sim.datatype,            64);
            this.verifyEqual(sim.label,               'labelled by test_makeSimilar');
            this.verifyEqual(sim.bitpix,              64);
            this.verifyEqual(sim.descrip(end-11:end), 'made similar');
            this.verifyEqual(sim.fileprefix,          'test_makeSimilar');
            this.verifyEqual(sim.mmppix,              [2.1 3.1 4.1]);
            this.verifyEqual(sim.pixdim,              [2.1 3.1 4.1]);
            
            this.verifyEqual(sim.filename,           'test_makeSimilar.nii.gz');
            this.verifyEqual(sim.entropy,            0);
%            this.verifyEqual(sim.orient,             'RADIOLOGICAL');            
            this.verifyEqual(sim.duration, 0);
            this.verifyEqual(sim.rank, 3);
            this.verifyEqual(sim.size, [128 128 65]);
        end
        function test_save(this)
            import mlfourd.*;
            fullt1 = BlurringNIfTId.load(this.t1_fqfn);
            fullt1.fqfn = this.test_fqfn;
            fullt1.save;
            saved  = BlurringNIfTId.load(fullt1.fqfn);
            this.verifyTrue(isequal(fullt1.img, saved.img));
        end
        function test_saveas(this)
            import mlfourd.*;
            this.testObj.saveas(this.test_fqfn);
            savedas = BlurringNIfTId.load(this.test_fqfn);
            this.verifyTrue(isequal(this.testObj.img, savedas.img));
        end
 	end 

 	methods (TestClassSetup) 
 		function setupBlurringNIfTId(this) 
            this.registry = mlfourd.UnittestRegistry.instance('initialize');
            this.registry.sessionFolder = 'mm01-020_p7377_2009feb5';
            this.blurringNIfTIdObj_ = mlfourd.BlurringNIfTId(this.smallT1_niid);
 		end 
    end 
    
 	methods (TestMethodSetup)
		function setupNIfTIdTest(this)
            cd(this.fslPath);
 			this.testObj = this.blurringNIfTIdObj_;
            this.addTeardown(@this.cleanupFiles);
 		end
    end
    
    %% PRIVATE
    
    properties (Access = private)
        blurringNIfTIdObj_
    end
    
    methods (Access = private)
        function cleanupFiles(this)
            deleteExisting2(fullfile(this.fslPath, 'test_mlfourd*'));
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

