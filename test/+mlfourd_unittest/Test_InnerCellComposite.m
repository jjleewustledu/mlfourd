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
            icc = InnerCellComposite( ...
                { NIfTId(magic(2), 'fileprefix', 'one') ...
                  NIfTId(magic(3), 'fileprefix', 'two') ...
                  NIfTId(magic(4), 'fileprefix', 'three') });
            icc = icc.fevalThis('append_fileprefix', '_appended');
            one = icc.get(1);
            this.verifyEqual(one.fileprefix, 'one_appended');
        end
        function test_fevalOut(this)
            import mlfourd.* mlpatterns.*;
            icc = InnerCellComposite( ...
                { NIfTId(magic(2), 'fileprefix', 'one') ...
                  NIfTId(magic(3), 'fileprefix', 'two') ...
                  NIfTId(magic(4), 'fileprefix', 'three') });
            this.verifyEqual(icc.fevalOut('size'), { [2 2] [3 3] [4 4] });
            this.verifyEqual(icc.fevalOut('rank', magic(2)), { 2 2 2 });
            out = icc.fevalOut('sum', 2);
            this.verifyEqual({out{1}.img out{2}.img out{3}.img}, {[4;6] [15;15;15] [34;34;34;34]});
            out = icc.fevalOut('sum', 2, 'double');
            this.verifyEqual({out{1}.img out{2}.img out{3}.img}, {[4;6] [15;15;15] [34;34;34;34]});
        end
        function test_fevalOut2(this)
            import mlfourd.* mlpatterns.*;
            icc = InnerCellComposite( ...
                { NIfTId(magic(2), 'fileprefix', 'one') ...
                  NIfTId(magic(3), 'fileprefix', 'two') ...
                  NIfTId(magic(4), 'fileprefix', 'three') });
            [tf,msg] = icc.fevalOut('isequaln', NIfTId(magic(4), 'fileprefix', 'three'));
            this.verifyEqual(tf, {false false true});
            this.verifyEqual(msg, {'NIfTId.checkFields:  mismatch at field filename' ...
                                   'NIfTId.checkFields:  mismatch at field filename' ''});
        end
        function test_fevalIsequal(this)
            import mlfourd.* mlpatterns.*;
            icc = InnerCellComposite( ...
                { NIfTId(magic(2), 'fileprefix', 'one') ...
                  NIfTId(magic(3), 'fileprefix', 'two') ...
                  NIfTId(magic(4), 'fileprefix', 'three') });
            [tf,msg] = icc.fevalIsequal(NIfTId(magic(4), 'fileprefix', 'three'));
            this.verifyEqual(tf, {false false true});
            this.verifyEqual(msg, {'' '' ''});
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

