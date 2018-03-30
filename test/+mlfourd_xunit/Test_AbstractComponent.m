classdef Test_AbstractComponent  < mlfourd_xunit.Test_mlfourd
	%% TEST_ABSTRACTCOMPONENT 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfourd.Test_NIfTIInterface % in . or the matlab path
	%          >> runtests mlfourd.Test_NIfTIInterface:test_nameoffunc
	%          >> runtests(mlfourd.Test_NIfTIInterface, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  Version $Revision: 2609 $ was created $Date: 2013-09-07 19:14:35 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-07 19:14:35 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_AbstractComponent.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: Test_AbstractComponent.m 2609 2013-09-08 00:14:35Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties
        imcps
        imcps2
        imcps3
        imseries
        testedFqFilename
        savedFqFilename
    end
    
    properties (Dependent)
        files
        files2
        files3
        singleFile
    end

	methods %% GET
        function fns = get.files(this)
            fns = { this.t1_fqfn this.t2_fqfn this.ir_fqfn };
        end
        function fns = get.files2(this)
            fns = { this.tr_fqfn this.ho_fqfn };
        end
        function fns = get.files3(this)
            fns =   fullfilename(this.fslPath, this.ocfp);
        end
        function fn  = get.singleFile(this)
            fn =    fullfilename(this.fslPath, this.ocfp);
        end
    end
    
    methods
 		function this = Test_AbstractComponent(varargin) 
 			this = this@mlfourd_xunit.Test_mlfourd(varargin{:});         
        end
        function setUp(this)
            setUp@mlfourd_xunit.Test_mlfourd(this);
            import mlfourd.*;
            this.preferredSession = 2;
            if (isempty(this.imcps))            
                this.imcps = ImagingComponent.load(this.files);
            end
            if (isempty(this.imcps2))    
                this.imcps2 = ImagingComponent.load(this.files2);
            end
            if (isempty(this.imcps3))  
                this.imcps3 = ImagingComponent.load(this.files3);
            end
            if (isempty(this.imseries)) 
                this.imseries = ImagingSeries.createFromFilename(this.t1_fqfn);
            end
            assertEqual(1, this.imseries.length);
            assertEqual(1, this.imseries.length);
        end        
        function tearDown(this)
            tearDown@mlfourd_xunit.Test_mlfourd(this);
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

