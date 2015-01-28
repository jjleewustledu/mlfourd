classdef Test_MRImagingComposite < TestCase 
	%% TEST_MRIMAGINGCOMPOSITE \n	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_MRImagingComposite % in . or the matlab path 
 	%          >> runtests Test_MRImagingComposite:test_nameoffunc 
 	%          >> runtests(Test_MRImagingComposite, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit%  Version $Revision: 2515 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_MRImagingComposite.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_MRImagingComposite.m 2515 2013-08-18 22:52:21Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function this = Test_MRImagingComposite(varargin) 
 			this = this@TestCase(varargin{:}); 
 		end % Test_MRImagingComposite (ctor) 
 		function test_(this) 
 			%% TEST_  
 			%  Usage:   
 			import mlfsl.*; 
 		end % test_ 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

