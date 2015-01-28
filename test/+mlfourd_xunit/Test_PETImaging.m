classdef Test_PETImaging < Test_ImagingComponent
	%% TEST_PETSTUDY  
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_PETStudy % in . or the matlab path 
 	%          >> runtests Test_PETStudy:test_nameoffunc 
 	%          >> runtests(Test_PETStudy, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit	%  Version $Revision: 2524 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_PETImaging.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_PETImaging.m 2524 2013-08-18 22:52:21Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
 	end 

	methods 
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 

        function test_clean(this)
            import mlfsl.*;
        end
        function setUp(this)
            setUp@Test_ImagingComponent
        end
        function tearDown(this)
            tearDown@Test_ImagingComponent
        end
 		function this = Test_PETImaging(varargin) 
 			this = this@Test_ImagingComponent(varargin{:}); 
 		end % Test_PETImaging (ctor) 
        
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
