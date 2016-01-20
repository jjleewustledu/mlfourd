classdef Test_NIfTIc < matlab.unittest.TestCase
	%% TEST_NIFTIC 

	%  Usage:  >> results = run(mlfourd_unittest.Test_NIfTIc)
 	%          >> result  = run(mlfourd_unittest.Test_NIfTIc, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 15-Jan-2016 02:58:05
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		registry
 		testObj
    end
    
    properties (Dependent)
        petPath
        pnum
        ho_fqfn
        oo_fqfn
        oc_fqfn
        tr_fqfn
        ho_niid
        oo_niid
        oc_niid
        tr_niid
    end
    
    methods %% GET
        function g = get.petPath(this)
            g = this.registry.petPath;
        end
        function g = get.pnum(this)
            g = this.registry.pnum;
        end
        function g = get.ho_fqfn(this)
            g = fullfile(this.petPath, [this.pnum 'ho1_frames'], [this.pnum 'ho1.nii.gz']);
        end
        function g = get.oo_fqfn(this)
            g = fullfile(this.petPath, [this.pnum 'oo1_frames'], [this.pnum 'oo1.nii.gz']);
        end
        function g = get.oc_fqfn(this)
            g = fullfile(this.petPath, [this.pnum 'oc1_frames'], [this.pnum 'oc1_03.nii.gz']);
        end
        function g = get.tr_fqfn(this)
            g = fullfile(this.petPath, [this.pnum 'tr1_frames'], [this.pnum 'tr1_01.nii.gz']);
        end
        function g = get.ho_niid(this)
            g = mlfourd.NIfTId.load(this.ho_fqfn);
        end
        function g = get.oo_niid(this)
            g = mlfourd.NIfTId.load(this.oo_fqfn);
        end
        function g = get.oc_niid(this)
            g = mlfourd.NIfTId.load(this.oc_fqfn);
        end
        function g = get.tr_niid(this)
            g = mlfourd.NIfTId.load(this.tr_fqfn);
        end
    end

	methods (Test)
        function test_setup(this)
            this.verifyInstanceOf(this.testObj, 'mlfourd.NIfTIc');
        end
		function test_ctor(this)            
            this.verifyEqual(this.testObj.fileprefix, ...
                {[this.pnum 'ho1'] [this.pnum 'oo1'] [this.pnum 'oc1_03'] [this.pnum 'tr1_01']});
            this.verifyEqual(this.testObj.entropy, ...
                {0.998338839919038 0.999074795939385 0.982401060352590 0.808870803446918}, 'RelTol', 1e-6);
        end
        function test_decoration(this)
            d = mlfourd.NumericalNIfTIc(this.testObj);
            disp(d.component);
            this.verifyTrue(isa(d.component, 'mlfourd.NIfTIc'));
        end
	end

 	methods (TestClassSetup)
		function setupNIfTIc(this)
 			import mlfourd.*;
            this.registry = UnittestRegistry.instance;
            this.registry.sessionFolder = 'mm01-007_p7686_2010aug20';
 			this.testObj_ = NIfTIc({this.ho_niid, this.oo_niid, this.oc_niid, this.tr_niid});
 		end
	end

 	methods (TestMethodSetup)
		function setupNIfTIcTest(this)
 			this.testObj = this.testObj_;
 		end
	end

	properties (Access = private)
 		testObj_
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

