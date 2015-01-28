classdef Test_ImagingParser < MyTestCase
	%% TEST_IMAGINGPARSER 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfourd.Test_ImagingParser % in . or the matlab path
	%          >> runtests mlfourd.Test_ImagingParser:test_nameoffunc
	%          >> runtests(mlfourd.Test_ImagingParser, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  Version $Revision: 2510 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_ImagingParser.m $
 	%  Developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: Test_ImagingParser.m 2510 2013-08-18 22:52:21Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        imp
    end
    
	methods 
        function test_inputParser(this) 
            p = this.imp.inputParser( ...
                'path', this.fslPath, 'returnType', 'fileprefix', 'fileprefixPattern', 't1_*');
            assertEqual(this.fslPath, p.Results.path);
            assertEqual('fileprefix', p.Results.returnType);
            assertEqual('t1_*',       p.Results.fileprefixPattern);
        end
        function test_ctor(this)
            disp(this.imp)
            assert(isa(this.imp, 'mlfourd.ImagingParser'));
        end
        
 		function this = Test_ImagingParser(varargin)
            this = this@MyTestCase(varargin{:}); 
            this.imp = mlfourd.ImagingParser(this.fslPath);
        end % ctor         
        function startUp(this)
            this.imp = this.imp.clearCache;
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

