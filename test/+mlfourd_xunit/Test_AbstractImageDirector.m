classdef Test_AbstractImageDirector < TestCase 
	%% TEST_IMAGINGDIRECTOR 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_AbstractImageDirector % in . or the matlab path 
 	%          >> runtests Test_AbstractImageDirector:test_nameoffunc 
 	%          >> runtests(Test_AbstractImageDirector, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit%  Version $Revision: 2496 $ was created $Date: 2013-08-18 17:52:20 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 17:52:20 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_AbstractImageDirector.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_AbstractImageDirector.m 2496 2013-08-18 22:52:20Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        mprInfo
        dicomPath
        unpackPath
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function test_createFromBuilder(this) 
 			%% TEST_CREATEFROMBUILDER 
 			%  Usage:   
 			import mlfourd.* mlfsl.*; 
            mr = MRImagingComponent.createSeries(this.dicomPath); % simplest
            b  = SurferImageBuilder.createFromImaging(mr);
            d  = AbstractImageDirector.createFromBuilder(b);
            assert(false);
 		end % test_createFromBuilder 
 		function this = Test_AbstractImageDirector(varargin) 
 			this = this@TestCase(varargin{:}); 
            this.mprInfo = struct( ...
                'dicom_path', this.dicomPath, ...
                'target_path', this.unpackPath, ...
                'index', 2, ...
                'name', 'mpr', ...
                'type', 'mgz', ...
                'new_name', '001.mgz');
 		end % Test_AbstractImageDirector (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

