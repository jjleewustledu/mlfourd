classdef Test_BlurringTool < matlab.unittest.TestCase
	%% TEST_BLURRINGTOOL 

	%  Usage:  >> results = run(mlfourd_unittest.Test_BlurringTool)
 	%          >> result  = run(mlfourd_unittest.Test_BlurringTool, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 10-Aug-2018 02:51:14 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
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
        function test_blurred(this)
            tic
            obj = this.testObj.blurred(10);
            toc
            obj.fsleyes;
            this.verifyEqual(obj.filename, 'T1_b100.4dfp.hdr');
            
            tic
            obj = this.testObj.blurred(10, 'krnlMult', 1);
            toc
            obj.fsleyes;
            this.verifyEqual(obj.filename, 'T1_b100.4dfp.hdr');
        end
	end

 	methods (TestClassSetup)
		function setupBlurringTool(this)
 		end
	end

 	methods (TestMethodSetup)
		function setupBlurringToolTest(this)
 			import mlfourd.*;
 			this.testObj = ImagingContext2('/Users/jjlee/Tmp/T1.4dfp.hdr');
 			this.addTeardown(@this.cleanTestMethod);
 		end
	end

	properties (Access = private)
 	end

	methods (Access = private)
		function cleanTestMethod(this)
 		end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

