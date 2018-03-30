classdef Test_ImagingComponent < mlpatterns_unittest.Test_AbstractComposite
	%% TEST_IMAGINGCOMPONENT 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImagingComponent)
 	%          >> result  = run(mlfourd_unittest.Test_ImagingComponent, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 18-Oct-2015 15:37:04
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties
 		testObj
 	end

	methods (Test)
        function test_isequal(this)
            imcps2copy = mlfourd.ImagingComposite(this.imcps2);
            this.verifyTrue( this.imcps2.isequal(     imcps2copy));
            this.verifyFalse(this.imcps2.isequal(this.imcps3));
        end
        function test_load(this)
            import mlfourd.*;
            this.verifyTrue(isa(ImagingComponent.load(this.files2), ...
                'mlfourd.ImagingComposite'));
            this.verifyTrue(isa(ImagingComponent.load(this.singleFile), ...
                'mlfourd.ImagingSeries'));
        end
        function test_seriesNumber(this)
            this.verifyEqual(nan, this.imcps.get(2).seriesNumber);
        end
        function test_ctor(this) 
            if (mlpipeline.PipelineRegistry.instance.verbose)
                disp(this); end
        end
 	end

 	methods (TestClassSetup)
 		function setupImagingComponent(this)
 			cd(this.fslPath);
 		end
 	end

 	methods (TestClassTeardown)
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

