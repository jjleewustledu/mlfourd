classdef Test_DicomComponent < mlfourd_xunit.Test_mlfourd
	%% TEST_DICOMCOMPONENT 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_DicomComposite % in . or the matlab path 
 	%          >> runtests Test_DicomComposite:test_nameoffunc 
 	%          >> runtests(Test_DicomComposite, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit%  Version $Revision: 2643 $ was created $Date: 2013-09-21 17:58:37 -0500 (Sat, 21 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:37 -0500 (Sat, 21 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_DicomComponent.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_DicomComponent.m 2643 2013-09-21 22:58:37Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

        function test_dicoms2cell(this)
            dc  = mlfourd.DicomSession.createFromPaths(this.dataPath, this.targPath);
            cal = dc.dicoms2cell(this.dataPath, this.targPath);
            assert(lstrfind(char(cal), 'Run 18'));
        end
        function test_createFromPaths(this)
            dc = mlfourd.DicomSession.createFromPaths(this.dataPath, this.targPath);
            assert(1 == length(dc));
        end
        function test_cleanImas(this)
            s  = mlfourd.DicomSession.cleanImas(this.dataPath, this.targPath);
            assert(0 == s);
            dt = mlsystem.DirTool(this.dataPath);
            assert(2904 == dt.length);
        end
        
        function setUp(this)
            cd(this.studyPath);
            mlfourd.DicomComposite.cleanTargets(this.studyPath);
        end
        function tearDown(this)
            cd(this.pwd0);
        end
 		function this = Test_DicomComponent(varargin) 
 			this = this@mlfourd_xunit.Test_mlfourd(varargin{:});
            this.preferredSession = 1;
 		end % Test_DicomComponent (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

