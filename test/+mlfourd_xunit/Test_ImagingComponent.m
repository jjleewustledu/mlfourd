classdef Test_ImagingComponent < mlfourd_xunit.Test_AbstractComponent
	%% TEST_IMAGINGCOMPONENT 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_ImagingComponent % in . or the matlab path 
 	%          >> runtests Test_ImagingComponent:test_nameoffunc 
 	%          >> runtests(Test_ImagingComponent, Test_Class2, Test_Class3, ...) 
    %  Use cases:
    %  -  single slice, single MR or PET series
    %  -  paired MR, PET, medical history, CBC, blood gases
    %  -  longitudinal imaging, history, labs for patient
    %  -  DSA
    %  -  OEF baseline images for all patients in a study
 	%  See also:  package xunit	
    %  Version $Revision: 2609 $ was created $Date: 2013-09-07 19:14:35 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-07 19:14:35 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_ImagingComponent.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_ImagingComponent.m 2609 2013-09-08 00:14:35Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

 	methods
        function test_isequal(this)
            imcps2copy = mlfourd.ImagingComposite(this.imcps2);
            assertTrue( this.imcps2.isequal(     imcps2copy));
            assertFalse(this.imcps2.isequal(this.imcps3));
        end
        function test_load(this)
            import mlfourd.*;
            assertTrue(isa(ImagingComponent.load(this.files2), ...
                'mlfourd.ImagingComposite'));
            assertTrue(isa(ImagingComponent.load(this.singleFile), ...
                'mlfourd.ImagingSeries'));
        end
        function test_seriesNumber(this)
            assertEqual(nan, this.imcps.get(2).seriesNumber);
        end
        function test_ctor(this) 
            if (mlpipeline.PipelineRegistry.instance.verbose)
                disp(this); end
        end
        
        function setUp(this)
            this.setUp@mlfourd_xunit.Test_AbstractComponent;
            cd(this.fslPath);
        end
        
        function this = Test_ImagingComponent(varargin)
            import mlfourd.*;
 			this = this@mlfourd_xunit.Test_AbstractComponent(varargin{:}); 
        end      
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
