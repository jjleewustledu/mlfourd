classdef Test_ImageProcessingNIfTId < matlab.unittest.TestCase
	%% TEST_IMAGEPROCESSINGNIFTID 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImageProcessingNIfTId)
 	%          >> result  = run(mlfourd_unittest.Test_ImageProcessingNIfTId, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 10-Jan-2016 16:41:01
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		registry
 		testObj
 	end

	methods (Test)
		function test_montage(this)
 			import mlfourd.*;
            this.testObj.montage;            
 		end
	end

 	methods (TestClassSetup)
		function setupImageProcessingNIfTId(this)
 			import mlfourd.*;
            this.registry = mlfourd.UnittestRegistry.instance('initialize');
 			this.testObj_ = ImageProcessingNIfTId.load(this.registry.smallT1_fqfn);
 		end
	end

 	methods (TestMethodSetup)
		function setupImageProcessingNIfTIdTest(this)
            this.testObj = this.testObj_;
        end
    end

	properties (Access = 'private')
 		testObj_
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

