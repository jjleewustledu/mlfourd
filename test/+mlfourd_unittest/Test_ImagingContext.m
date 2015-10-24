classdef Test_ImagingContext < mlfourd_unittest.Test_mlfourd
	%% TEST_IMAGINGCONTEXT 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImagingContext)
 	%          >> result  = run(mlfourd_unittest.Test_ImagingContext, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 18-Oct-2015 13:14:55
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
    properties
        blurring
        imcps
        mgh
        nii
        niid
        testFslFile
        testMriFile
        
 		registry
 		testObj
 	end

	methods (Test)
        function test_clone(this)
            import mlfourd.*;
            
            ic  = ImagingContext.load(this.imcps);
            ic2 = ic.clone;
            this.verifyNotSameHandle(ic, ic2);
            ic2.fqfilename = this.dwi_fqfn;
            this.verifyTrue(strcmp(ic.fqfilename, this.ep2dMean_fqfn));
            
            ic  = ImagingContext.load(this.nii);
            ic2 = ic.clone;
            this.verifyNotSameHandle(ic, ic2);
            ic2.fqfilename = this.dwi_fqfn;
            this.verifyTrue(strcmp(ic.fqfilename, this.ep2dMean_fqfn));
            
            ic  = ImagingContext.load(this.mgh);
            ic2 = ic.clone;
            this.verifyNotSameHandle(ic, ic2);
            ic2.fqfilename = this.dwi_fqfn;
            this.verifyEqual(ic.fqfilename, fullfile(this.sessionPath, 'mri', 'rawavg.mgz'));
            
            ic  = ImagingContext.load(this.ep2dMean_fqfn);
            ic2 = ic.clone;
            this.verifyNotSameHandle(ic, ic2);
            ic2.fqfilename = this.dwi_fqfn;
            this.verifyTrue(strcmp(ic.fqfilename, this.ep2dMean_fqfn));
        end
        function test_forceState(this)
            cd(fullfile(this.sessionPath, 'mri', ''));
            import mlfourd.*;            
            ic = ImagingContext.load(this.ep2dMean_fqfn);
            
            ic.forceState('component');
            this.verifyEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
            this.verifyEqual(this.ep2dMean_fqfn, ic.fqfilename)
            
            ic.forceState('NIfTI');
            this.verifyEqual('mlfourd.NIfTIState', ic.stateTypeclass);
            this.verifyEqual(this.ep2dMean_fqfn, ic.fqfilename)
            
            ic.forceState('NIfTId');
            this.verifyEqual('mlfourd.NIfTIdState', ic.stateTypeclass);
            this.verifyEqual(this.ep2dMean_fqfn, ic.fqfilename)
            
            ic.forceState('MGH');
            this.verifyEqual('mlfourd.MGHState', ic.stateTypeclass);
            this.verifyEqual(fullfile(this.fslPath, 'ep2d_default_mcf_meanvol.mgz'), ic.fqfilename)
            
            ic.forceState('mlfourd.ImagingLocation');
            this.verifyEqual('mlfourd.ImagingLocation', ic.stateTypeclass);
            this.verifyEqual(this.ep2dMean_fqfn, ic.fqfilename)
        end
        function test_changeState(this)
            import mlfourd.*;
            
            ic = ImagingContext.load(this.imcps);
            this.verifyEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
            
            newState = NIfTIState.load(this.nii, ic);
            ic.changeState(newState);  
            this.verifyEqual('mlfourd.NIfTIState', ic.stateTypeclass);
            
            newState = NIfTIdState.load(this.nii, ic);
            ic.changeState(newState);  
            this.verifyEqual('mlfourd.NIfTIdState', ic.stateTypeclass);
            
            newState = MGHState.load(this.mgh, ic);
            ic.changeState(newState);  
            this.verifyEqual('mlfourd.MGHState', ic.stateTypeclass);
            
            newState = ImagingLocation.load(this.ep2dMean_fqfn, ic);
            ic.changeState(newState);  
            this.verifyEqual('mlfourd.ImagingLocation', ic.stateTypeclass);
        end
        
 		function test_assignImcomponent(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.oc_fqfn);
            ic.imcomponent = this.imcps;
            this.verifyEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
            this.verifyEqual(this.ep2dMean_fqfn, ic.fqfilename);
        end 
 		function test_assignNifti(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.oc_fqfn);
            ic.nifti = this.nii;
            this.verifyEqual('mlfourd.NIfTIState', ic.stateTypeclass);
            this.verifyEqual(this.ep2dMean_fqfn, ic.fqfilename);
 		end 
 		function test_assignNiftid(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.oc_fqfn);
            ic.niftid = this.niid;
            this.verifyEqual('mlfourd.NIfTIdState', ic.stateTypeclass);
            this.verifyEqual(this.ep2dMean_fqfn, ic.fqfilename);
 		end 
 		function test_assignMgh(this)
            import mlfourd.* mlsurfer.*;
            ic = ImagingContext.load(this.oc_fqfn);
            ic.mgh = this.mgh;
            this.verifyEqual('mlfourd.MGHState', ic.stateTypeclass);
            this.verifyEqual(this.rawavg_fqfn, ic.fqfilename);
 		end 
 		function test_assignLocation(this) 
            import mlfourd.*;
            ic = ImagingContext.load(this.oc_fqfn);
            ic.filename = this.testFslFile;
            this.verifyEqual('mlfourd.ImagingLocation', ic.stateTypeclass);
            this.verifyEqual(this.testFslFile, ic.fqfilename);
        end 
                
 		function test_mgh2nifti(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.mgh);
            obj = ic.nifti;
            this.verifyClass(obj, 'mlfourd.NIfTI');
        end 
 		function test_mgh2niftid(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.mgh);
            obj = ic.niftid;
            this.verifyClass(obj, 'mlfourd.NIfTId');
        end 
 		function test_nifti2imcomponent(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.nii);
            obj = ic.imcomponent;
            this.verifyClass(obj, 'mlfourd.ImagingSeries');
            
            obj = ic.nifti;
            this.verifyClass(obj, 'mlfourd.NIfTI');
            this.verifyEqual('mlfourd.NIfTIState', ic.stateTypeclass);
 		end 
 		function test_niftid2imcomponent(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.niid);
            obj = ic.imcomponent;
            this.verifyClass(obj, 'mlfourd.ImagingSeries');
            
            obj = ic.niftid;
            this.verifyClass(obj, 'mlfourd.NIfTId');
            this.verifyEqual('mlfourd.NIfTIdState', ic.stateTypeclass);
 		end 
 		function test_imcomponent(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.imcps);
            obj = ic.imcomponent;
            this.verifyClass(obj, 'mlfourd.ImagingComposite');
 		end 
 		function test_location2imcomponent(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.ep2dMean_fqfn);
            obj = ic.imcomponent;
            this.verifyClass(obj, 'mlfourd.ImagingSeries');
 		end 
 		function test_location2nifti(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.ep2dMean_fqfn);
            obj = ic.nifti;
            this.verifyClass(obj, 'mlfourd.NIfTI');
        end 
 		function test_location2niftid(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.ep2dMean_fqfn);
            obj = ic.niftid;
            this.verifyClass(obj, 'mlfourd.NIfTId');
        end 
 		function test_location2mgh(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.ep2dMean_fqfn);
            obj = ic.mgh;
            this.verifyClass(obj, 'mlsurfer.MGH');
        end 
        
        function test_saveas(this)
            import mlfourd.*;
            cd(fullfile(this.sessionPath, 'fsl', ''));
            
            ic = ImagingContext.load(this.ep2dMean_fqfn);
            ic.saveas(this.testFslFile);
            this.verifyEqual('mlfourd.ImagingLocation', ic.stateTypeclass);
            this.verifyTrue(lexist(this.testFslFile, 'file'));
            delete(this.testFslFile);
            
            ic = ImagingContext.load(this.nii);
            ic.saveas(this.testFslFile);
            this.verifyEqual('mlfourd.ImagingLocation', ic.stateTypeclass);
            this.verifyTrue(lexist(this.testFslFile, 'file'));
            delete(this.testFslFile);
            
            ic = ImagingContext.load(this.niid);
            ic.saveas(this.testFslFile);
            this.verifyEqual('mlfourd.NIfTdState', ic.stateTypeclass);
            this.verifyTrue(lexist(this.testFslFile, 'file'));
            delete(this.testFslFile);
            
            ic = ImagingContext.load(this.imcps);
            ic.saveas(this.testFslFile);
            this.verifyEqual('mlfourd.ImagingLocation', ic.stateTypeclass);
            this.verifyTrue(lexist(this.testFslFile, 'file'));
            delete(this.testFslFile);
            
            cd(fullfile(this.sessionPath, 'fsl', ''));
            ic = ImagingContext.load(this.mgh);
            ic.saveas(this.testMriFile);
            this.verifyEqual('mlfourd.ImagingLocation', ic.stateTypeclass);
            this.verifyTrue(lexist(this.testMriFile, 'file'));
            delete(this.testMriFile);
        end
        
        function test_fqfilename(this)
            import mlfourd.*;
            ic = ImagingContext.load(ImagingComponent.load(this.ep2dMean_fqfn));
            this.verifyEqual(this.ep2dMean_fqfn, ic.fqfilename);
            
            ic.fqfilename = this.oc_fqfn;
            this.verifyEqual(this.oc_fqfn, ic.fqfilename);
        end
        function test_fileprefix(this)
            import mlfourd.*;
            ic = ImagingContext.load(NIfTId.load(this.ep2dMean_fqfn));
            this.verifyEqual(this.ep2dMean_fp, ic.fileprefix);
            
            ic.fqfilename = this.oc_fqfn;
            this.verifyEqual(this.oc_fqfn, ic.fqfilename);
        end
        function test_filepath(this)
            import mlfourd.* mlsurfer.*;
            ic = ImagingContext.load(MGH.load(this.ep2dMean_fqfn));
            this.verifyEqual(this.fslPath, ic.filepath);
            
            ic.fqfilename = this.oc_fqfn;
            this.verifyEqual(this.oc_fqfn, ic.fqfilename);
        end  
                
        function test_ctor(this)
            import mlfourd.*;
            ic = ImagingContext(this.nii);
            this.verifyEqual('mlfourd.NIfTIState', ic.stateTypeclass);
            ic = ImagingContext(this.niid);
            this.verifyEqual('mlfourd.NIfTIdState', ic.stateTypeclass);
            ic = ImagingContext(this.blurring);
            this.verifyEqual('mlfourd.NIfTIdState', ic.stateTypeclass);
            ic = ImagingContext(this.mgh);
            this.verifyEqual('mlfourd.MGHState', ic.stateTypeclass);
            ic = ImagingContext(this.imcps);
            this.verifyEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
            ic = ImagingContext(ic); % copy ctor
            this.verifyEqual('mlfourd.ImagingLocation', ic.stateTypeclass);
            ic = ImagingContext(this.testFslFile);
            this.verifyEqual('mlfourd.ImagingLocation', ic.stateTypeclass);
            ic = ImagingContext(ic); % copy ctor
            this.verifyEqual('mlfourd.ImagingLocation', ic.stateTypeclass);
            ic = ImagingContext([]);            
            this.verifyEqual('double', ic.stateTypeclass);
        end
    end

 	methods (TestClassSetup)
 		function setupImagingContext(this)
            import mlfourd.* mlsurfer.*;
            this.nii      = NIfTI.load(this.ep2dMean_fqfn);
            this.niid     = NIfTId.load(this.ep2dMean_fqfn);
            this.blurring = BlurringNIfTId.load(this.tr_fqfn);
            this.mgh      = MGH.load(this.rawavg_fqfn);
            this.imcps    = ImagingComposite.load({this.ep2dMean_fqfn this.oc_fqfn this.tr_fqfn});
            this.testMriFile = fullfile(this.sessionPath, 'mri', 'test_ImagingContext.nii.gz');
            this.testFslFile = fullfile(this.sessionPath, 'fsl', 'test_ImagingContext.nii.gz');
 		end
 	end

 	methods (TestClassTeardown)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

