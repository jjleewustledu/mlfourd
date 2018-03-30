classdef Test_BlurredNIfTI < mlfourd_unittest.Test_NIfTI
	%% TEST_BLURREDNIFTI 

	%  Usage:  >> results = run(mlfourd_unittest.Test_BlurredNIfTI)
 	%          >> result  = run(mlfourd_unittest.Test_BlurredNIfTI, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 20-Oct-2015 20:11:30
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
	methods (Test) 		
        function        test_blurred(this)
            nii = this.t1;
            nii.fileprefix = 'test_blurred';
            nii = nii.blurred;
            this.assertEqual(6.355880021447207,         nii.entropy);
            this.assertEqual('test_blurred_131315fwhh', nii.fileprefix);
        end
        function        test_isaNIfTI(this) %#ok<MANU>
            %% empty to disable parent method
        end
 	end

 	methods (TestClassSetup)
 		function setupBlurredNIfTI(this) 			
            import mlfourd.*;
            t1     = NIfTI.load(this.t1_fqfn);
            t1mask = NIfTI.load(this.t1mask_fqfn);
            
            this.t1struct_ = BlurredNIfTI(NIfTI(struct(t1)));
            this.t1_       = BlurredNIfTI(t1);
            this.t1mask_   = BlurredNIfTI(t1mask);
 		end
 	end

 	methods (TestMethodSetup)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

