classdef Test_BlurringNIfTId < mlfourd_unittest.Test_NIfTId
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
    
	methods (Test) 
        function test_blurredDynamic(this)
            import mlfourd.*;
            ep2d = NIfTId.load(this.ep2d_fqfn);
            bnEp2d = BlurringNIfTId(ep2d);
            blurred = bnEp2d.blurred([2 4 3]);
            blurred.saveas('test_blurredDynamic');
            this.assertEqual(blurred.entropy,    2.076199075639435e-04, 'RelTol', 1e-10);
            this.assertEqual(blurred.fileprefix, 'ep2d_default_243fwhh');
            this.assertEqual(blurred.descrip,    [ep2d.descrip '; decorated by BlurringNIfTId; blurred to [2 4 3]']);
            this.assertEqual(blurred.pixdim,     ep2d.pixdim);
            %blurred.freeview
        end
        function test_blurredWater(this)
            import mlfourd.*;
            ho = NIfTId.load(fullfile(this.sessionPath, 'ECAT_EXACT', 'coss', 'cs01-999-ho1.nii.gz'));
            bnHo = BlurringNIfTId(ho);        
            blurred = bnHo.blurred([10 10 2]);  
            blurred.saveas('test_blurredWater');          
            %blurred.freeview
        end
        function test_blurredStatic(this)
            blurred = this.testObj.blurred([2 4 3], this.t1mask); 
            blurred.saveas('test_blurredStatic');
            this.assertEqual(blurred.entropy,    0.882394593833631, 'RelTol', 1e-10);
            this.assertEqual(blurred.fileprefix, 't1_default_243fwhh');
            this.assertEqual(blurred.descrip,    [this.t1.descrip '; decorated by BlurringNIfTId; blurred to [2 4 3]']);
            this.assertEqual(blurred.pixdim,     this.t1.pixdim);            
            %blurred.freeview
        end
        
        function test_load(this)
            import mlfourd.*;
            bnii = BlurringNIfTId.load(this.t1_fqfn);
            component = NIfTId.load(this.t1_fqfn);
            this.assertTrue(isequal(bnii.mask, 1));
            this.assertTrue(isequal(bnii.blurCount, 0));
            this.assertTrue(isequal(bnii.component, component));
            this.assertEqual(bnii.img,        component.img);
            this.assertEqual(bnii.entropy,    0.120310143405054, 'RelTol', 1e-10);
            this.assertEqual(bnii.fileprefix, 't1_default');
            this.assertEqual(bnii.descrip(end-28:end), '; decorated by BlurringNIfTId');
            this.assertEqual(bnii.pixdim,     component.pixdim);
        end
        function test_ctor4args(~)
        end
        function test_ctor2args(this)
            ctor = mlfourd.BlurringNIfTId(this.t1, 'mask', this.t1mask);
            this.assertEqual(ctor.component, this.t1);
            this.assertEqual(ctor.mask,      this.t1mask.img);
        end
        function test_clone(this)
            import mlfourd.*;            
            a = this.testObj;
            b = a.clone;
            assert(isequal(a, b));
            a0 = a;
            adelta = a;
            adelta.img = NaN;
            this.assertTrue(isequal(a0, a));
        end
        function test_makeSimilar(this)
            sim = this.testObj.makeSimilar( ...
                'img',        ones(this.t1.size), ...
                'datatype',   4, ...
                'label',      'labelled by test_makeSimilar', ...
                'bitpix',     32, ...
                'descrip',    'described by test_makeSimilar', ...
                'fileprefix', 'test_makeSimilar', ...
                'mmppix',     [2 3 4], ...
                'pixdim',     [2.1 3.1 4.1]);
            
            this.assertEqual(sim.img(104,128,3),      single(1)); % bitpix was 32
            this.assertEqual(sim.datatype,            16);
            this.assertEqual(sim.label,               'labelled by test_makeSimilar');
            this.assertEqual(sim.bitpix,              32);
            this.assertEqual(sim.descrip(end-28:end), 'described by test_makeSimilar');
            this.assertEqual(sim.fileprefix,          'test_makeSimilar');
            this.assertEqual(sim.mmppix,              [2.1 3.1 4.1]);
            this.assertEqual(sim.pixdim,              [2.1 3.1 4.1]);
            
            this.assertEqual(sim.filename,           'test_makeSimilar.nii.gz');
            this.assertEqual(sim.noclobber,          false);
            this.assertEqual(sim.entropy,            0);
            this.assertEqual(sim.orient,             '');            
            this.assertEqual(sim.duration, 1);
            this.assertEqual(sim.rank, 3);
            this.assertEqual(sim.size, [208 256 5]);
        end
        function test_save(this)
            import mlfourd.*;
            fullt1 = BlurringNIfTId.load(this.t1_fqfn);
            fullt1.save;
            saved  = BlurringNIfTId.load(fullt1.fqfn);
            this.assertTrue(isequal(fullt1.img, saved.img));
        end
        function test_saveas(this)
            import mlfourd.*;
            this.testObj.saveas(this.test_saveas_fqfn);
            savedas = BlurringNIfTId.load(this.test_saveas_fqfn);
            this.assertTrue(isequal(this.testObj.img, savedas.img));
        end
 	end 

 	methods (TestClassSetup) 
 		function setupBlurringNIfTId(this) 
            this.blurringNIfTIdObj_ = mlfourd.BlurringNIfTId(this.t1); 
 			this.testObj            = this.blurringNIfTIdObj_;
 		end 
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        blurringNIfTIdObj_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

