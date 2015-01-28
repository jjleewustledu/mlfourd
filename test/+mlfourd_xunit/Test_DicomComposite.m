classdef Test_DicomComposite < mlfourd_xunit.Test_DicomComponent & mlfourd.DicomComposite
	%% TEST_DICOMCOMPOSITE 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_DicomComposite % in . or the matlab path 
 	%          >> runtests Test_DicomComposite:test_nameoffunc 
 	%          >> runtests(Test_DicomComposite, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit	%  Version $Revision: 2628 $ was created $Date: 2013-09-16 01:18:32 -0500 (Mon, 16 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:32 -0500 (Mon, 16 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_DicomComposite.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_DicomComposite.m 2628 2013-09-16 06:18:32Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

        function test_renameSurfer4fsls(this)
            mlfourd.DicomComposite.renameSurfer4fsls(this.studyPath);
        end
        function test_traverseNPPath(this)
            out = mlfourd.DicomComposite.traverseNPPath( ...
                  mlfourd.ImagingArrayList, this.studyPath, @mlfourd_xunit.Test_DicomComposite.traversalTester);
            assert(43 == out.length);
        end
 		function test_dicoms2cell2(this)
            dc  = mlfourd.DicomComposite.createFromPaths(this.studyPath);
            cal = dc.dicoms2cell(this.studyPath);
            assert(cal.length > 0);
        end
        function test_createFromPaths2(this)
            dc = mlfourd.DicomComposite.createFromPaths(this.studyPath);
            assert(38 == length(dc));
        end        
        function test_cleanImas2(this)
            mlfourd.DicomComposite.cleanImas(this.studyPath);
            dt = mlsystem.DirTool(this.dataPaths{1});
            assert(2906 == dt.length);
        end
        function test_listUniqueInfo(this) 
 			%% TEST_LISTUNIQUESEQTYPES accesses 'seq_type' using DicomComponent's listUniqueInfo method
            
 			import mlfourd.*;
            dc          = DicomComposite.createFromPaths(this.studyPath);
            [str,degen] = dc.listUniqueInfo('seq_type'); 
            assert(strncmp(str, 'DIFFEPIiPaT2 2', 14));
                                keys      =  degen.keys;
            assert(strcmp(      keys{1}, 'DIFFEPIiPaT2'));
                                values    =  degen.values;
            assert(             values{1} == 2);
            assert(       degen.Count     == 9);
 		end 
        function test_mapInfoToSession(this)
            %% TEST_MAPINFOTOSESSION 
            
 			import mlfourd.*;
            dc      = DicomComposite.createFromPaths(this.studyPath);
            map     = dc.mapInfoToSession('seq_type'); 
            itsKeys = map.keys;
            assert(strcmp(map(itsKeys{10}), 'mm01-020_p0000_2010feb00'));
            assert(strcmp(map(itsKeys{14}), 'mm01-020_p0000_2010feb00'));
        end
        
 		function this = Test_DicomComposite(varargin) 
 			this = this@mlfourd_xunit.Test_DicomComponent(varargin{:}); 
 		end % Test_DicomComposite (ctor) 
 	end % methods
    
    methods (Static, Access = 'private')
        
        function out = traversalTester(strA, strB)
            str = sprintf('traversalTester:  %s, %s\n', strA, strB);
            out = mlfourd.ImagingArrayList;
            out.add(str);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

