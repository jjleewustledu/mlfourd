classdef Test_ImgRecorder < matlab.unittest.TestCase
	%% TEST_IMGRECORDER 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImgRecorder)
 	%          >> result  = run(mlfourd_unittest.Test_ImgRecorder, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 11-Dec-2015 18:57:32
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties
 		sessionPath
        workPath
        niidFilename
        niid
 		testObj
 	end

	methods (Test)
 		function test_ctor(this) 			
            this.verifyEqual(this.testObj.contents(103:144), 'mlfourd.ImgRecorder by jjlee at ophthalmic');
 			this.verifyEqual(this.testObj.fileprefix, this.niid.fileprefix);
            this.verifyEqual(this.testObj.filesuffix, '.img.rec');
        end
        function test_add(this)
            this.testObj.add(sprintf('test_string_3\ntest_string4\ntest_string5'));
            this.verifyEqual(this.testObj.contents(226:237), 'test_string5');
        end
        function test_countOf(this)
            this.verifyEqual(this.testObj.countOf('test_string_1'), 1);
        end
        function test_get(this)
            this.verifyEqual(this.testObj.get(3), 'test_string_2');
        end
        function test_length(this)
            this.verifyEqual(this.testObj.length, 3);
        end
        function test_locationsOf(this)
            this.verifyEqual(this.testObj.locationsOf('test_string_1'), 2);
        end
        function test_save(this)
            mlbash(sprintf('rm %s', this.testObj.fqfilename));
            this.testObj.save;
            this.verifyTrue(lexist(this.testObj.fqfilename, 'file'));
            c = mlio.FilesystemRegistry.textfileToCell(this.testObj.fqfilename);
            this.verifyEqual(c{4}, 'test_string_1');
        end
        function test_saveas(this)
            newFqfn = [this.testObj.fqfileprefix 'new.img.rec'];
            mlbash(sprintf('rm %s', newFqfn));
            this.testObj.saveas(newFqfn);
            this.verifyTrue(lexist(newFqfn, 'file'));
            c = mlio.FilesystemRegistry.textfileToCell(newFqfn);
            this.verifyEqual(c{4}, 'test_string_1');
        end
 	end

 	methods (TestClassSetup)
 		function setupImgRecorder(this)
 			import mlfourd.*;
            this.sessionPath  = fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl', 'np755', 'mm01-020_p7377_2009feb5', '');
            this.workPath     = fullfile(this.sessionPath, 'fsl', '');
            this.niidFilename = fullfile(this.workPath, 't2_006.nii.gz');
            this.niid         = NIfTId.load(this.niidFilename);
 		end
 	end

 	methods (TestMethodSetup)
 		function setup(this)
 			import mlfourd.*;         
 			this.testObj = ImgRecorder(this.niid);
            this.testObj.add('test_string_1');
            this.testObj.add('test_string_2');
        end
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

