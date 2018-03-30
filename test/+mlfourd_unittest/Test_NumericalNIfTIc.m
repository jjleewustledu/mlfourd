classdef Test_NumericalNIfTIc < matlab.unittest.TestCase
	%% TEST_NUMERICALNIFTIC 

	%  Usage:  >> results = run(mlfourd_unittest.Test_NumericalNIfTIc)
 	%          >> result  = run(mlfourd_unittest.Test_NumericalNIfTIc, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 16-Jan-2016 12:27:16
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		registry
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
		function setupNumericalNIfTIc(this)
 			import mlfourd.*;
 			this.testObj_ = NumericalNIfTIc;
 		end
	end

 	methods (TestMethodSetup)
		function setupNumericalNIfTIcTest(this)
 			this.testObj = this.testObj_;
 		end
	end

	properties (Access = private)
 		testObj_
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

