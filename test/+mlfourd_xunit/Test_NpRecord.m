classdef Test_NpRecord < TestCase 
	%% TEST_NPRECORD 
    %  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_NpRecord % in . or the matlab path 
 	%          >> runtests Test_NpRecord:test_nameoffunc 
 	%          >> runtests(Test_NpRecord, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit%  Version $Revision: 2520 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_NpRecord.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_NpRecord.m 2520 2013-08-18 22:52:21Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        
        np
        patient
        atlas
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function test_createNp(this) 
 			import mlfourd.*;
            this.np = NpRecord.createNp;
        end
        function test_addPatient(this)
            this.np = this.np.addPatient(this.patient);
            assert(eqtool(this.patient, this.np.patients.get()));
        end
        
        function this = Test_NpRecord(varargin) 
 			this = this@TestCase(varargin{:}); 
 		end % Test_NpRecord (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

