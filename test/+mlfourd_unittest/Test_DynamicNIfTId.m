classdef Test_DynamicNIfTId < mlfourd_unittest.Test_NIfTId
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

	methods (Test) 
        function test_load(this)
            import mlfourd.*;
            dnii = DynamicNIfTId.load(this.hodyn_fqfn);
            component = NIfTId.load(this.hodyn_fqfn);
            this.assertTrue(isequal(dnii.component, component));
            this.assertEqual(dnii.img,        component.img);
            this.assertEqual(dnii.entropy,    0.999451341616353, 'RelTol', 1e-10);
            this.assertEqual(dnii.fileprefix, 'cs01-999-ho1');
            this.assertEqual(dnii.descrip(end-27:end), '; decorated by DynamicNIfTId');
            this.assertEqual(dnii.pixdim,     component.pixdim);
        end
 		function test_ctor(this)
            import mlfourd.*;
            ctor = DynamicNIfTId(this.hoNIfTId_);
            tsum = DynamicNIfTId(this.hoNIfTId_, 'timeSum', true);
            vsum = DynamicNIfTId(this.hoNIfTId_, 'volumeSum', true);
            blrd = DynamicNIfTId(this.hoNIfTId_, 'blur', true);
            
            this.assertEqual(ctor.component, this.hoNIfTId_);
            this.assertEqual(ctor.entropy, nan, 'RelTol', 1e-10);
            this.assertEqual(tsum.entropy, nan, 'RelTol', 1e-10);
            this.assertEqual(vsum.entropy, nan, 'RelTol', 1e-10);
            this.assertEqual(blrd.entropy, nan, 'RelTol', 1e-10);
        end 
        function test_timeSummed(this)
            tobj = this.testObj.timeSummed;
            this.assertEqual(tobj.size, [128 128 63]);
            this.assertEqual(tobj.entropy, nan, 'RelTol', 1e-10);
        end
        function test_volumeSummed(this)
            tobj = this.testObj.volumeSummed;
            this.assertEqual(tobj.size, 60);
            this.assertEqual(tobj.entropy, nan, 'RelTol', 1e-10);
        end
        function test_blurred(this)
            import mlfourd.*;
            this.testObj.blur = [16 16 16];
            tobj = this.testObj.blurred;
            this.assertEqual(tobj.size, 60);
            this.assertEqual(MaskedNIfTId.maxall( tobj), Inf);
            this.assertEqual(MaskedNIfTId.meanall(tobj), Inf);
            this.assertEqual(MaskedNIfTId.stdall( tobj), Inf);
            this.assertEqual(tobj.entropy, nan, 'RelTol', 1e-10);
        end
        function test_mcflirted(this)
        end
        function test_adjustedFrame(this)
        end
        function test_flirtedBrain(this)
        end
        function test_masked(this)
            import mlfourd.*;
            this.testObj.mask = NIfTId.load(this.mask_fqfn);
            tobj = this.testObj.masked;
            this.assertEqual(tobj.size, 60);
            this.assertEqual(MaskedNIfTId.maxall( tobj), Inf);
            this.assertEqual(MaskedNIfTId.meanall(tobj), Inf);
            this.assertEqual(MaskedNIfTId.stdall( tobj), Inf);
            this.assertEqual(tobj.entropy, nan, 'RelTol', 1e-10);
        end
 	end 

 	methods (TestClassSetup) 
 		function setupDynamicNIfTId(this) 
 			this.testObj = this.dynamicNIfTId_; 
 		end 
 	end 

 	methods (TestClassTeardown) 
 	end 

    methods        
 		function this = Test_DynamicNIfTId(varargin) 
            this = this@mlfourd_unittest.Test_NIfTId(varargin{:});
            
            import mlfourd.*;
            this.hoNIfTId_      = NIfTId.load(this.hodyn_fqfn);
            this.dynamicNIfTId_ = DynamicNIfTId(this.hoNIfTId_); 
 		end 
    end
    
    %% PRIVATE
    
    properties (Access = 'private')
        dynamicNIfTId_
        hoNIfTId_
    end
    
    methods
        function fn = hodyn_fqfn(this)
            fn = fullfile(this.sessionPath, 'ECAT_EXACT', 'coss', 'cs01-999-ho1.nii.gz');
        end
        function fn = mask_fqfn(this)
            fn = fullfile(this.sessionPath, 'fsl', 'cs01-999-ho1_161616fwhh_thresh250.nii.gz');
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

