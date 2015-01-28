classdef Test_ImageInterface  < mlfourd_xunit.Test_mlfourd
	%% TEST_IMAGEINTERFACE 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfourd.Test_ImageInterface % in . or the matlab path
	%          >> runtests mlfourd.Test_ImageInterface:test_nameoffunc
	%          >> runtests(mlfourd.Test_ImageInterface, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  Version $Revision: 2506 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_ImageInterface.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: Test_ImageInterface.m 2506 2013-08-18 22:52:21Z jjlee $
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
    end

	methods
        function fns = get.files(this)
            fns = { this.t1_fqfn this.t2_fqfn this.ir_fqfn };
        end
        function fns = get.files2(this)
            fns = { this.tr_fqfn this.ho_fqfn };
        end
        function fns = get.files3(this)
            fns =   fullfilename(this.fslPath, this.ocfp);
        end

 		function this = Test_ImageInterface(varargin) 
 			this = this@mlfourd_xunit.Test_mlfourd(varargin{:});         
        end
        function setUp(this)
            setUp@mlfourd_xunit.Test_mlfourd(this);
            import mlfourd.*;
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
            assertEqual(1, this.imseries.asCellArrayList.length);
        end        
        function tearDown(this)
            tearDown@mlfourd_xunit.Test_mlfourd(this);
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

