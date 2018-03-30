classdef Test_SafeDir < TestCase 
	%% TEST_SAFEDIR 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_SafeDir % in . or the matlab path 
 	%          >> runtests Test_SafeDir:test_nameoffunc 
 	%          >> runtests(Test_SafeDir, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit%  Version $Revision: 2533 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_SafeDir.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_SafeDir.m 2533 2013-08-18 22:52:21Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function test_(this) 
 			%% TEST_  
 			%  Usage:   
 			import mlfourd.*; 
 		end % test_ 
 		function this = Test_SafeDir(varargin) 
 			this = this@TestCase(varargin{:}); 
 		end % Test_SafeDir (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

