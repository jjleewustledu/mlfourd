classdef Test_MaskingNIfTId < mlfourd_unittest.Test_NIfTId
	%% TEST_MASKINGNIFTID  

	%  Usage:  >> results = run(mlfourd_unittest.Test_MaskingNIfTId)
 	%          >> result  = run(mlfourd_unittest.Test_MaskingNIfTId, 'test_dt')
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
            mnii = MaskingNIfTId.load(this.t1_fqfn);
            component = NIfTId.load(this.t1_fqfn);
            this.assertTrue(isequal(mnii.component, component));
            this.assertEqual(mnii.img,        component.img);
            this.assertEqual(mnii.entropy,    0.120310143405054, 'RelTol', 1e-10);
            this.assertEqual(mnii.fileprefix, 't1_default');
            this.assertEqual(mnii.descrip(end-27:end), '; decorated by MaskingNIfTId');
            this.assertEqual(mnii.pixdim,     component.pixdim);
        end
        function test_sumall(this)
            this.assertEqual(this.testObj.sumall(this.t1), 38708914);
        end
        function test_maxall(this)
            this.assertEqual(this.testObj.maxall(this.t1), 887);
        end
        function test_minall(this)
            this.assertEqual(this.testObj.minall(this.t1), 0);
        end
        function test_meanall(this)
            this.assertEqual(this.testObj.meanall(this.t1), 145.391053185096, 'RelTol', 1e-10);
        end
        function test_stdall(this)
            this.assertEqual(this.testObj.stdall(this.t1), 0.711757577388281, 'RelTol', 1e-10);
        end
        
        function test_ctor(this)
            ctor         = mlfourd.MaskingNIfTId(this.t1);
            binarized    = mlfourd.MaskingNIfTId(this.t1, 'binarize', true);
            threshed     = mlfourd.MaskingNIfTId(this.t1, 'thresh', 300);
            pthreshed    = mlfourd.MaskingNIfTId(this.t1, 'pthresh', 0.05);
            niftied      = mlfourd.MaskingNIfTId(this.t1, 'niftid_mask', binarized);
            freesurfered = mlfourd.MaskingNIfTId(this.t1, 'freesurfer_mask', this.t1);
            
            this.assertEqual(ctor.component, this.t1);              
            this.assertEqual(binarized.entropy, 0.110414616093301, 'RelTol', 1e-10);
            this.assertEqual(sum(sum(sum(binarized.img))), 262332);
            this.assertEqual(threshed.entropy, 0.864484339468461, 'RelTol', 1e-10);
            this.assertEqual(sum(sum(sum(threshed.img))), 76344);
            this.assertEqual(pthreshed.entropy, 0.947745004328329, 'RelTol', 1e-10);
            this.assertEqual(sum(sum(sum(pthreshed.img))), 97509);
            this.assertEqual(niftied.entropy, 0.110414616093301, 'RelTol', 1e-10);
            this.assertEqual(sum(sum(sum(niftied.img))), 38708914);
            this.assertEqual(freesurfered.entropy, 0.110414616093301, 'RelTol', 1e-10);
            this.assertEqual(sum(sum(sum(freesurfered.img))), 38708914);
            this.assertEqual(niftied.img, freesurfered.img);
        end
        function test_masked(this)
            obj = this.testObj.masked(this.binaryMask_);
            this.assertEqual(obj.entropy, 0.583001993712199, 'RelTol', 1e-10);
            %obj.freeview
        end
        function test_count(this)
            cnt = this.testObj.count;
            this.assertEqual(cnt, 262332, 'RelTol', 1e-10);
        end
        function test_thresh(this)
            obj = this.testObj.thresh(300);
            this.assertEqual(obj.entropy, 0.864484339468461, 'RelTol', 1e-10);
            this.assertEqual(sum(sum(sum(obj.img))), 76344);
            %obj.freeview
        end
        function test_pthresh(this)
            obj = this.testObj.pthresh(0.05);
            this.assertEqual(obj.entropy, 0.947745004328329, 'RelTol', 1e-10);
            this.assertEqual(sum(sum(sum(obj.img))), 97509);
            %obj.freeview
        end
 	end 

 	methods (TestClassSetup) 
 		function setupMaskedNIfTI(this) 
 			this.testObj = this.MaskingNIfTIdObj_; 
 		end 
 	end 
    
    methods        
 		function this = Test_MaskingNIfTId(varargin) 
            this = this@mlfourd_unittest.Test_NIfTId(varargin{:});
            this.MaskingNIfTIdObj_ = mlfourd.MaskingNIfTId(this.t1); 
            this.binaryMask_      = this.MaskingNIfTIdObj_.makeSimilar( ...
                                    'img', double(this.MaskingNIfTIdObj_.img > 400), ...
                                    'fileprefix', 'Test_MaskingNIfTId_binaryMask');
 		end 
    end
    
    %% PRIVATE
    
    properties (Access = 'private')
        MaskingNIfTIdObj_
        binaryMask_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

