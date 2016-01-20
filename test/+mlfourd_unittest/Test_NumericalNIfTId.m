classdef Test_NumericalNIfTId < matlab.unittest.TestCase
	%% TEST_NUMERICALNIFTID 

	%  Usage:  >> results = run(mlfourd_unittest.Test_NumericalNIfTId)
 	%          >> result  = run(mlfourd_unittest.Test_NumericalNIfTId, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 10-Jan-2016 16:33:27
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		registry
 		testObj
 	end

	methods (Test)
        function test_clone(this)
            this.verifyInstanceOf(this.testObj.clone, 'mlfourd.NumericalNIfTId');
            this.verifyEqual(this.testObj.clone, this.testObj);
        end
        function test_copyCtor(this)
            copy = mlfourd.NumericalNIfTId(this.testObj);
            this.verifyInstanceOf(copy, 'mlfourd.NumericalNIfTId');
            this.verifyEqual(copy, this.testObj);
        end
		function test_makeSimilar(this)
            sim = this.testObj.makeSimilar('fileprefix', 'test_makeSimilar');
            this.verifyInstanceOf(sim, 'mlfourd.NumericalNIfTId');
            this.verifyEqual(sim.img, this.testObj.img);
        end
        function test_usxfun(this)
            c = transpose(this.testObj);
            this.verifyInstanceOf(c, 'mlfourd.NumericalNIfTId');
            this.verifyEqual(c.img, transpose(magic(2)));
        end
        function test_bsxfun(this)
            c = this.testObj + magic(2); % overloaded plus
            this.verifyInstanceOf(c, 'mlfourd.NumericalNIfTId');
            this.verifyEqual(c.img, 2*magic(2));
        end
        function test_umethods(this)
            meths = { ...
                'abs' 'ctranspose' 'transpose' ...
                'not' ...
                'dipiqr' 'dipisinf' 'dipisnan' 'dipisfinite' 'dipisreal' 'diplogprod' 'dipmad' ...
                'dipmax' 'dipmean' 'dipmedian' 'dipmin' 'dipmode' 'dipprod' 'dipstd' 'dipsum'};
            for m = 1:length(meths)
                h = str2func(meths{m});
                this.verifyEqual(this.testObj.(meths{m}).img, double(h(magic(2))));
            end
        end
        function test_bmethods(this)            
            meths = {'atan2' 'rdivide' 'ldivide' 'hypot' 'max' 'min' 'minus' 'mod' 'plus' 'power' 'rem' 'times' ...
                'eq' 'ne' 'lt' 'le' 'gt' 'ge' 'and' 'or' 'xor'};
            b = pi * magic(2);
            for m = 1:length(meths)
                h = str2func(meths{m});
                this.verifyEqual(this.testObj.(meths{m})(b).img, double(h(magic(2), b)));
            end
        end
        function test_bscalarmethods(this)
            meths = {'dipprctile' 'dipquantile' 'diptrimmean'};
            b = 0.5;
            for m = 1:length(meths)
                h = str2func(meths{m});
                this.verifyEqual(this.testObj.(meths{m})(b).img, h(magic(2), b));
            end
        end
	end

 	methods (TestClassSetup)
		function setupNumericalNIfTId(this)
 			import mlfourd.*;
 			this.testObj_ = NumericalNIfTId(NIfTId(magic(2)));
 		end
	end

 	methods (TestMethodSetup)
		function setupNumericalNIfTIdTest(this)
            this.testObj = this.testObj_;
 		end
    end

    properties (Access = private)
        testObj_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

