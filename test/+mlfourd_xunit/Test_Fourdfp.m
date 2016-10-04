classdef Test_Fourdfp < mlfourd_xunit.Test_mlfourd
	%% TEST_FOURDFP 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfourd.Test_Fourdfp % in . or the matlab path
	%          >> runtests mlfourd.Test_Fourdfp:test_nameoffunc
	%          >> runtests(mlfourd.Test_Fourdfp, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  $Revision: 2502 $
 	%  was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_Fourdfp.m $, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id: Test_Fourdfp.m 2502 2013-08-18 22:52:21Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        aFourdfp
 	end

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

        function test_FILETYPE(this)
            assertEqual('4DFP', this.aFourdfp.FILETYPE);
        end
        function test_FILETYPE_EXT(this)
            assertEqual('.4dfp.ifh', this.aFourdfp.FILETYPE_EXT);
        end
        function test_SUPPORTED_EXTENSIONS(this)            
            assertEqual({'.4dfp.ifh'}, this.aFourdfp.SUPPORTED_EXTENSIONS);
        end
        function test_filetype(this)
            assertEqual(0, this.aFourdfp.filetype);
        end
        function test_filename(this)
            assertEqual([this.t1_fp '.4dfp.ifh'], this.aFourdfp.filename);
        end
        function test_fqfilename(this)
            assertEqual(fullfile(this.fslPath, [this.t1_fp '.4dfp.ifh']), this.aFourdfp.fqfilename);
        end
 		function test_load(this) 
 			import mlfourd.*; 
            assertEqual(this.aFourdfp, mlfourd.Fourdfp.load(this.aFourdfp.fqfilename));
 		end 
 		function test_save(this) 
 			import mlfourd.*; 
            tmp = this.aFourdfp;
            tmp.fqfilename = fullfile(this.fslPath, 'Test_fourdfp_test_save.4dfp.ifh');
            tmp.save;
            assertEqual(this.aFourdfp, mlfourd.Fourdfp.load(tmp.fqfilename));
            delete(tmp.fqfilename);
 		end 
 		function test_saveas(this) 
 			import mlfourd.*; 
            tmp = this.aFourdfp;
            tmp = tmp.saveas(fullfile(this.fslPath, 'Test_fourdfp_test_saveas.4dfp.ifh'));
            assertEqual(this.aFourdfp, mlfourd.Fourdfp.load(tmp.fqfilename));
            delete(tmp.fqfilename);
 		end 
 		function this = Test_Fourdfp(varargin) 
 			this = this@mlfourd_xunit.Test_mlfourd(varargin{:}); 
            this.aFourdfp = mlfourd.Fourdfp.load(this.t1_fqfn);
        end % ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

