classdef Test_DicomSession < mlfourd_xunit.Test_DicomComponent 
	%% TEST_DICOMSESSION 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_DicomSession % in . or the matlab path 
 	%          >> runtests Test_DicomSession:test_nameoffunc 
 	%          >> runtests(Test_DicomSession, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit	%  Version $Revision: 2499 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_DicomSession.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_DicomSession.m 2499 2013-08-18 22:52:21Z jjlee $ 
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
 		function this = Test_DicomSession(varargin) 
 			this = this@mlfourd_xunit.Test_DicomComponent(varargin{:}); 
 		end % Test_DicomSession (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

