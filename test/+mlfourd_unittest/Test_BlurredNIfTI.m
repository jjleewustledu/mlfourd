classdef Test_BlurredNIfTI < mlfourd_unittest.Test_mlfourd 
	%% TEST_BLURREDNIFTI  

	%  Usage:  >> results = run(mlfourd_unittest.Test_BlurredNIfTI)
 	%          >> result  = run(mlfourd_unittest.Test_BlurredNIfTI, 'test_dt')
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

	methods (Test) 
 		function test_afun(this) 
 			import mlfourd.*; 
 			this.assumeEqual(1,1); 
 			this.verifyEqual(1,1); 
 			this.assertEqual(1,1); 
 		end 
 	end 

 	methods (TestClassSetup) 
 		function setupBlurredNIfTI(this) 
 			this.testObj = mlfourd.BlurredNIfTI; 
 		end 
 	end 

 	methods (TestClassTeardown) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

