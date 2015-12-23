classdef Test_NIfTI < mlfourd_unittest.Test_mlfourd 
	%% TEST_NIFTI  

	%  Usage:  >> results = run(mlfourd_unittest.Test_NIfTI)
 	%          >> result  = run(mlfourd_unittest.Test_NIfTI, 'test_dt')
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
            fn = fullfile(this.fslPath, 'test_save.nii.gz');
        end    
        function fn = get.test_saveas_fqfn(this)
            fn = fullfile(this.fslPath, 'test_saveas.nii.gz');
        end
    end
    
	methods (Test) 
 		function test_afun(this) 
 			import mlfourd.*; 
 			this.assumeEqual(1,1); 
 			this.verifyEqual(1,1); 
 			this.assertEqual(1,1); 
 		end 
        function test_isaNIfTI(this)
            import mlfourd.*;
            this.assertTrue(isNIfTI(this.t1));
            this.assertTrue(isNIfTI(this.t1mask));
        end        
        function test_ctors(this)
            import mlfourd.*;
            fromfn    =            this.t1;        % from filename
            fromstrct = this.aCtor(this.t1struct); % from NIfTI struct
            fromobj   = this.aCtor(this.t1);       % from NIfTI object
            this.assertTrue(~isempty(fromfn));
            this.assertEqual(fromfn, fromstrct);            
            this.assertEqual(fromfn, fromobj);
        end
        function test_copyctor(this)
            import mlfourd.*;
            assert(isequal(this.t1, this.aCtor(this.t1)));
            t1ori   = this.t1;
            t1delta = this.t1;
            t1delta.img = [];
            this.assertTrue(isequal(t1ori, this.t1));
        end
        function test_clone(this)
            import mlfourd.*;
            this.assertTrue(isequal(this.t1, this.t1.clone));
        end
        function test_makeSimilar(this)
            t1sim     = this.t1.makeSimilar(this.t1.img);
            t1sim.img = t1sim.zeros;
            this.assertTrue(0 ~= sum(sum(sum(this.t1.img))));
            this.assertTrue(0 == sum(sum(sum(t1sim.img))));
        end
        function test_save(this)
            import mlfourd.*;
            fullt1 = this.aLoader(this.t1_fqfn);
            fullt1.save;
            saved  = this.aLoader(fullt1.fqfn);
            this.assertTrue(isequal(fullt1.img, saved.img));
        end
        function test_saveAs(this)
            import mlfourd.*;
            this.t1.saveas(this.test_saveas_fqfn);
            t1savedas = this.aLoader(this.test_saveas_fqfn);
            this.assertTrue(isequal(this.t1.img, t1savedas.img));
        end
        function test_filepath(this)
            this.t1_.filepath = '';
            this.assertTrue(strcmp(pwd, this.t1.filepath));
        end
        
        function test_entropy(this)
            this.assertEqual(this.T1ENTROPY, this.t1.entropy, 'RelTol', 1e-10);
        end
        function test_char(this)
            this.assertEqual( ...
                fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl/np755/mm01-020_p7377_2009feb5/fsl/t1_default.nii.gz'), this.t1.char);
        end
        function test_forceDouble(this)
            forced = this.t1mask.forceDouble;
            this.assertEqual('double', class(forced.img));
        end
        function test_scrubNanInf(this)
            tmp = this.t1;
            tmp.img(:,:,1) = nan;
            tmp = tmp.scrubNanInf;
            this.assertTrue(~any(isnan(tmp.img(:))));
        end        
        
        function test_aXplusy(this)
            One  = this.t1.ones;
            Tmp  = 2 * One + 1;
            img3 = 3 * ones(One.size);
            this.assertTrue(all(all(all(Tmp.img == img3))));
        end
        function test_AXplusy(this)
            One  = this.t1.ones;
            Tmp  = One .* One + 1;
            img2 = 2 * ones(One.size);
            this.assertTrue(all(all(all(Tmp.img == img2))));
        end
        function test_AXplusY(this)
            One   = this.t1.ones;
            Tmp   = One .* this.t1 + this.t1;
            img2t = 2 * this.t1.img;
            this.assertTrue(all(all(all(Tmp.img == img2t))));
        end
        function test_and_not(this)
            tmp = this.t1mask & (~this.t1mask);
            this.assertTrue(all(all(all(tmp.img == zeros(tmp.size)))));
        end
        function test_or_not(this)
            tmp = this.t1mask | ~this.t1mask;
            this.assertTrue(all(all(all(tmp.img == ones(tmp.size)))));
        end
 	end 

 	methods (TestClassSetup) 
 		function setupNIfTI(this)
            if (isempty(this.t1struct))
                this.t1struct_     = this.fqfn2struct(this.t1_fqfn); 
                this.t1struct_.img = this.t1struct_.img(:,:,this.ZRANGE);
            end
            if (isempty(this.t1))
                this.t1_     = this.fqfn2struct2NIfTI(this.t1_fqfn); 
                this.t1_.img = this.t1_.img(:,:,this.ZRANGE);
            end
            if (isempty(this.t1mask))
                this.t1mask_     = this.fqfn2struct2NIfTI(this.t1mask_fqfn); 
                this.t1mask_.img = this.t1mask_.img(:,:,this.ZRANGE);
            end
            
            this.pwd0_ = pwd;
            cd(this.fslPath);
 			this.testObj = mlfourd.NIfTI; 
            
            if (lexist(this.test_saveas_fqfn, 'file'))
                delete(this.test_saveas_fqfn); end
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
        function obj = aCtor(arg)
            obj = mlfourd.NIfTI(arg);
        end
        function obj = aLoader(arg)
            obj = mlfourd.NIfTI.load(arg);
        end
        function strct = fqfn2struct(fqfn) 
            fqnii = [fileprefix(fqfn) '.nii'];
            if (~lexist(fqnii, 'file'))
                try              
                    gunzip([fqnii '.gz']);
                catch ME
                    handexcept(ME, 'Test_NIfTI.fqfn2struct:  could not find %s', filename(fqfn));
                end
            end
            strct = load_untouch_nii(fqnii);
            delete(fqnii);
        end
        function nii   = fqfn2struct2NIfTI(fqfn)
            nii = mlfourd.NIfTI( ...
                  mlfourd_unittest.Test_NIfTI.fqfn2struct(fqfn));
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

