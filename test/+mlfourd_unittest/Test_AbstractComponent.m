classdef (Abstract) Test_AbstractComponent < mlfourd_unittest.Test_mlfourd
	%% TEST_ABSTRACTCOMPONENT 

	%  Usage:  >> results = run(mlfourd_unittest.Test_AbstractComponent)
 	%          >> result  = run(mlfourd_unittest.Test_AbstractComponent, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 18-Oct-2015 14:42:36
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties
        imcps
        imcps2
        imcps3
        imseries
        testedFqFilename
        savedFqFilename
    end
    
    properties (Dependent)
        files
        files2
        files3
        singleFile
    end

	methods %% GET
        function fns = get.files(this)
            fns = { this.t1_fqfn this.t2_fqfn this.ir_fqfn };
        end
        function fns = get.files2(this)
            fns = { this.tr_fqfn this.ho_fqfn };
        end
        function fns = get.files3(this)
            fns =   fullfilename(this.fslPath, this.oc_fp);
        end
        function fn  = get.singleFile(this)
            fn =    fullfilename(this.fslPath, this.oc_fp);
        end
    end

    methods (TestClassSetup)
        function setUpAbstractComponent(this)     
        end
    end
    
    methods (TestMethodSetup)
        function setupMethod(this)  
            import mlfourd.*;     
            
            if (isempty(this.imcps))            
                this.imcps = ImagingComponent.load(this.files);
            end
            if (isempty(this.imcps2))    
                this.imcps2 = ImagingComponent.load(this.files2);
            end
            if (isempty(this.imcps3))  
                this.imcps3 = ImagingComponent.load(this.files3);
            end
            
            if (isempty(this.imseries)) 
                this.imseries = ImagingSeries.createFromFilename(this.t1_fqfn);
            end
            this.assertEqual(this.imseries.length, 1);
            this.assertEqual(this.imseries.asList.length, 1);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

