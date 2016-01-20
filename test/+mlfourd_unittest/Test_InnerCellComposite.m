classdef Test_InnerCellComposite < matlab.unittest.TestCase
	%% TEST_INNERCELLCOMPOSITE 

	%  Usage:  >> results = run(mlfourd_unittest.Test_InnerCellComposite)
 	%          >> result  = run(mlfourd_unittest.Test_InnerCellComposite, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 18-Jan-2016 23:09:16
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		registry
 		testObj
 	end

	methods (Test)
        function test_fevalThis(this)
            import mlfourd.* mlpatterns.*;
            icc = InnerCellComposite(CellComposite( ...
                { NIfTId(magic(2), 'fileprefix', 'one') ...
                  NIfTId(magic(3), 'fileprefix', 'two') ...
                  NIfTId(magic(4), 'fileprefix', 'three') }));
            icc = icc.fevalThis('append_fileprefix', '_appended');
            one = icc.get(1);
            this.verifyEqual(one.fileprefix, 'one_appended');
        end
        function test_fevalOut(this)
            import mlfourd.* mlpatterns.*;
            icc = InnerCellComposite(CellComposite( ...
                { NIfTId(magic(2), 'fileprefix', 'one') ...
                  NIfTId(magic(3), 'fileprefix', 'two') ...
                  NIfTId(magic(4), 'fileprefix', 'three') }));
            this.verifyEqual(icc.fevalOut('size'), ...
                { [2 2] [3 3] [4 4] });
        end
		function test_repmat(this)
            this.verifyTrue(isempty(this.testObj.repmat()));
            this.verifyEqual(this.testObj.repmat(1),       { 1     1     1     1});
            this.verifyEqual(this.testObj.repmat([1 2]),   {[1 2] [1 2] [1 2] [1 2]});
            this.verifyEqual(this.testObj.repmat(1, 2),    {{1 2} {1 2} {1 2} {1 2}});
            this.verifyEqual(this.testObj.repmat(1, 2, 3), {{1 2 3 } {1 2 3} {1 2 3} {1 2 3}});
 		end
	end

 	methods (TestClassSetup)
		function setupInnerCellComposite(this)
 			import mlfourd.*;
 			this.testObj_ = InnerCellComposite({0 1 2 3});
 		end
	end

 	methods (TestMethodSetup)
		function setupInnerCellCompositeTest(this)
 			this.testObj = this.testObj_;
 		end
	end

	properties (Access = 'private')
 		testObj_
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

