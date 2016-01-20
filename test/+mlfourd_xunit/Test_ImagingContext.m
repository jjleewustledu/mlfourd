classdef Test_ImagingContext < MyTestCase 
	%% TEST_IMAGINGCONTEXT  

	%  Usage:  >> runtests tests_dir  
	%          >> runtests mlfourd.Test_ImagingContext % in . or the matlab path 
	%          >> runtests mlfourd.Test_ImagingContext:test_nameoffunc 
	%          >> runtests(mlfourd.Test_ImagingContext, Test_Class2, Test_Class3, ...) 
	%  See also:  package xunit 

	%  $Revision: 2628 $ 
 	%  was created $Date: 2013-09-16 01:18:32 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:32 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_ImagingContext.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: Test_ImagingContext.m 2628 2013-09-16 06:18:32Z jjlee $ 
 	 

	properties 
        mgh
        nii
        imcps
        testMriFile
        testFslFile
 	end 

	methods
%         function test_clone(this)
%             import mlfourd.*;
%             ic  = ImagingContext.load(this.imcps);
%             ic2 = ic.clone;
%             ic2.fqfilename = this.tr_fqfn;
%             assertTrue(strcmp(ic.fqfilename, this.t1_fqfn));
%             ic  = ImagingContext.load(this.nii);
%             ic2 = ic.clone;
%             ic2.fqfilename = this.tr_fqfn;
%             assertTrue(strcmp(ic.fqfilename, this.t1_fqfn));
%             ic  = ImagingContext.load(this.mgh);
%             ic2 = ic.clone;
%             ic2.fqfilename = this.tr_fqfn;
%             assertTrue(strcmp(ic.fqfilename, this.t1_fqfn));
%             ic  = ImagingContext.load(this.t1_fqfn);
%             ic2 = ic.clone;
%             ic2.fqfilename = this.tr_fqfn;
%             assertTrue(strcmp(ic.fqfilename, this.t1_fqfn));
%         end
        function test_forceState(this)
            cd(fullfile(this.sessionPath, 'mri', ''));
            import mlfourd.*;
            ic = ImagingContext.load(this.t1_fqfn);
            ic.forceState('component');
            assertEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
            ic.forceState('NIfTI');
            assertEqual('mlfourd.NIfTIState', ic.stateTypeclass);
            ic.forceState('MGH');
            assertEqual('mlfourd.MGHState', ic.stateTypeclass);
            ic.forceState('mlfourd.FilenameState');
            assertEqual('mlfourd.FilenameState', ic.stateTypeclass);
        end
        function test_changeState(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.imcps);
            assertEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
            ic.changeState(NIfTIState.load(this.nii, ic));  
            assertEqual('mlfourd.NIfTIState', ic.stateTypeclass);
            ic.changeState(MGHState.load(this.mgh, ic));  
            assertEqual('mlfourd.MGHState', ic.stateTypeclass);
            ic.changeState(FilenameState.load(this.t1_fqfn, ic));  
            assertEqual('mlfourd.FilenameState', ic.stateTypeclass);
        end
        
 		function test_assignImcomponent(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.t2_fqfn);
            ic.composite = this.imcps;
            assertEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
            assertEqual(this.t1_fqfn, ic.fqfilename);
        end 
 		function test_assignNifti(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.t2_fqfn);
            ic.nifti = this.nii;
            assertEqual('mlfourd.NIfTIState', ic.stateTypeclass);
            assertEqual(this.t1_fqfn, ic.fqfilename);
 		end 
 		function test_assignMgh(this)
            import mlfourd.* mlsurfer.*;
            ic = ImagingContext.load(this.t2_fqfn);
            ic.mgh = this.mgh;
            assertEqual('mlfourd.MGHState', ic.stateTypeclass);
            assertEqual(this.rawavg_fqfn, ic.fqfilename);
 		end 
 		function test_assignLocation(this) 
            import mlfourd.*;
            ic = ImagingContext.load(this.t2_fqfn);
            ic.filename = this.testFslFile;
            assertEqual('mlfourd.FilenameState', ic.stateTypeclass);
            assertEqual(this.testFslFile, ic.fqfilename);
        end 
                
 		function test_mgh2nifti(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.mgh);
            ic.nifti;
            assertEqual('mlfourd.NIfTIState', ic.stateTypeclass);
        end 
 		function test_nift2composite(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.nii);
            ic.composite;
            assertEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
            ic.nifti;
            assertEqual('mlfourd.NIfTIState', ic.stateTypeclass);
 		end 
 		function test_location2composite(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.t1_fqfn);
            ic.composite;
            assertEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
 		end 
 		function test_location2nifti(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.t1_fqfn);
            ic.nifti;
            assertEqual('mlfourd.NIfTIState', ic.stateTypeclass);
        end 
 		function test_location2mgh(this)
            import mlfourd.*;
            ic = ImagingContext.load(this.t1_fqfn);
            ic.mgh;
            assertEqual('mlfourd.MGHState', ic.stateTypeclass);
        end 
        function test_fqfilename(this)
            ic = mlfourd.ImagingContext.load(this.t1_fqfn);
            assertEqual(this.t1_fqfn, ic.fqfilename);
        end
        function test_fileprefix(this)
            ic = mlfourd.ImagingContext.load(this.t1_fqfn);
            assertEqual(this.t1_fp, ic.fileprefix);
        end
        function test_filepath(this)
            ic = mlfourd.ImagingContext.load(this.t1_fqfn);
            assertEqual(this.fslPath, ic.filepath);
        end  
        function test_saveas(this)
            import mlfourd.*;
            cd(fullfile(this.sessionPath, 'fsl', ''));
            ic = ImagingContext.load(this.t1_fqfn);
            ic.saveas(this.testFslFile);
            assertEqual('mlfourd.FilenameState', ic.stateTypeclass);
            assertTrue(lexist(this.testFslFile, 'file'));
            %delete(this.testFslFile);
            
            ic = ImagingContext.load(this.nii);
            ic.saveas(this.testFslFile);
            assertEqual('mlfourd.FilenameState', ic.stateTypeclass);
            assertTrue(lexist(this.testFslFile, 'file'));
            %delete(this.testFslFile);
            ic = ImagingContext.load(this.imcps);
            ic.saveas(this.testFslFile);
            assertEqual('mlfourd.FilenameState', ic.stateTypeclass);
            assertTrue(lexist(this.testFslFile, 'file'));
            %delete(this.testFslFile);
            
            cd(fullfile(this.sessionPath, 'fsl', ''));
            ic = ImagingContext.load(this.mgh);
            ic.saveas(this.testMriFile);
            assertEqual('mlfourd.FilenameState', ic.stateTypeclass);
            assertTrue(lexist(this.testMriFile, 'file'));
            %delete(this.testMriFile);
        end
        
 		function this = Test_ImagingContext(varargin) 
 			this = this@MyTestCase(varargin{:}); 
            import mlfourd.* mlsurfer.*;
            this.nii      = NIfTI.load(this.t1_fqfn);
            this.mgh      = MGH.load(this.rawavg_fqfn);
            this.imcps    = ImagingComposite.load({this.t1_fqfn this.t2_fqfn this.tr_fqfn});
            this.testMriFile = fullfile(this.sessionPath, 'mri', 'test_ImagingContext.nii.gz');
            this.testFslFile = fullfile(this.sessionPath, 'fsl', 'test_ImagingContext.nii.gz');
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

