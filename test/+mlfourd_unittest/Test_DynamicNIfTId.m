classdef Test_DynamicNIfTId < mlfourd_unittest.Test_mlfourd
	%% TEST_DYNAMICNIFTID  

	%  Usage:  >> results = run(mlfourd_unittest.Test_DynamicNIfTId)
 	%          >> result  = run(mlfourd_unittest.Test_DynamicNIfTId, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 

    properties 
        testObj
        testComp
    end
    
    properties (Dependent)
        mask_fqfn
        hodyn_fqfn        
        hodynNIfTId
        dynamicNIfTId
    end
    
    methods %% GET
        function fn = get.mask_fqfn(this)
            fn = fullfile(this.sessionPath, 'fsl', 'cs01-999-ho1_161616fwhh_thresh250.nii.gz');
        end
        function fn = get.hodyn_fqfn(this)
            fn = fullfile(this.sessionPath, 'ECAT_EXACT', 'coss', 'cs01-999-ho1.nii.gz');
        end
        function niid = get.hodynNIfTId(this)
            niid = mlfourd.NIfTId.load(this.hodyn_fqfn);
        end
        function niid = get.dynamicNIfTId(this)
            niid = mlfourd.DynamicNIfTId(this.hodynNIfTId);
        end
    end
    
	methods (Test) 
        function test_load(this)
            import mlfourd.*;
            niid  = this.testComp;
            dniid = this.testObj;
            this.verifyEqual(dniid.component,           niid);
            this.verifyEqual(dniid.img,                 niid.img);
            this.verifyEqual(dniid.entropy,             0.999451341616353, 'RelTol', 1e-8);
            this.verifyEqual(dniid.fileprefix,          'cs01-999-ho1');
            this.verifyEqual(dniid.descrip(end-27:end), '; decorated by DynamicNIfTId');
            this.verifyEqual(dniid.pixdim,              niid.pixdim);
        end
 		function test_ctor(this)
            import mlfourd.*;
            dniid = this.dynamicNIfTId;
            this.verifyEqual(dniid, this.dynamicNIfTId);
            this.verifyEqual(dniid.component, this.dynamicNIfTId.component);
        end 
        function test_timeSummed(this)
            ts = this.testObj.timeSummed;
            this.verifyEqual(ts.size, [128 128 63]);
            this.verifyEqual(ts.entropy, 0.962499036230927, 'RelTol', 1e-8);
            if (mlpipeline.PipelineRegistry.instance.verbose)
                ts.freeview
            end
        end
        function test_volumeSummed(this)
            vs = this.testObj.volumeSummed;
            this.verifyEqual(vs.size, [60 1]);
            this.verifyEqual(vs.entropy, 0, 'RelTol', 1e-8);
            if (mlpipeline.PipelineRegistry.instance.verbose)
                plot(vs.img);s
            end
        end
        function test_blurred(this)
            import mlfourd.*;
            to = this.testObj.blurred([4 4 4]);
            this.verifyEqual(to.descrip(143:end), ...
                'decorated by DynamicNIfTId; decorated by BlurringNIfTId; blurred to [4 4 4]');
            this.verifyEqual(to.size, [128 128 63 60]);
            this.verifyEqual(to.entropy, 1.185942655041996, 'RelTol', 1e-8);
            this.verifyEqual(dipmax( to), 939.327758789062, 'RelTol', 1e-8);
            this.verifyEqual(dipmean(to), 10.164494152465943, 'RelTol', 1e-8);
            this.verifyEqual(dipstd( to), 53.4597643887697, 'RelTol', 1e-8);
            if (mlpipeline.PipelineRegistry.instance.verbose)
                to.freeview
            end
        end
        function test_mcflirted(this)
        end
        function test_mcflirtedAfterBlur(this)
        end
        function test_revertedFrames(this)
        end
        function test_masked(this)
            import mlfourd.*;
            mask = NIfTId.load(this.mask_fqfn);
            to = this.testObj;
            to = to.masked(mask);
            this.verifyEqual(to.descrip, ...
                ['NIfTId.adjustFieldsAfterLoading read ' ...
                '/Volumes/InnominateHD3/Local/test/cvl/np755/mm01-020_p7377_2009feb5/ECAT_EXACT/coss/cs01-999-ho1.nii.gz; ' ...
                'decorated by DynamicNIfTId; ' ...
                'DynamicNIfTI.masked(cs01-999-ho1_161616fwhh_thresh250); made similar']);
            this.verifyEqual(to.fileprefix, 'cs01-999-ho1_masked');
            this.verifyEqual(to.size, [128 128 63 60]);
            this.verifyEqual(to.entropy, 0.698268544789383, 'RelTol', 1e-8);
            this.verifyEqual(dipmean(to), 13.6110725200996, 'RelTol', 1e-8);
            this.verifyEqual(dipstd( to), 119.214993730422, 'RelTol', 1e-8);
            if (mlpipeline.PipelineRegistry.instance.verbose)
                to.freeview;
            end
        end
 	end 

 	methods (TestClassSetup) 
 		function setupDynamicNIfTId(this) 
            this.testComp = this.hodynNIfTId;
 			this.testObj = mlfourd.DynamicNIfTId(this.testComp); 
 		end 
 	end 

 	methods (TestMethodSetup)
		function setupDynamicNIfTIdTest(this)
 		end
    end    
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

