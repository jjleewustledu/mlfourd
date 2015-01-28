classdef Test_ImageBuilder < mlfourd_xunit.Test_NIfTIInterface
	%% TEST_IMAGEBUILDER
    %  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_ImageBuilder % in . or the matlab path 
 	%          >> runtests Test_ImageBuilder:test_nameoffunc 
 	%          >> runtests(Test_ImageBuilder, Test_Class2, Test_Class3, ...) 
    %  Use cases:
    %  -  unpack/convert DICOM to NIfTI or mgz
    %  -  reorient, fix orientations
    %  -  co-register to reference
    %  -  blur or block-average
    %  -  calculate metrics:   flow, blood volume, MTT, CMRO2, OEF, qBOLD, MROMI
 	%  See also:  package xunit
    %  Version $Revision: 2609 $ was created $Date: 2013-09-07 19:14:35 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-07 19:14:35 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_ImageBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_ImageBuilder.m 2609 2013-09-08 00:14:35Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties
 		converter
        imbuilder
        modalityPath
    end 

	methods
        function this = set.converter(this, c)
            assert(isa(c, 'mlfourd.ConverterInterface'));
            this.converter = c;
        end
        function c    = get.converter(this)
            assert(~isempty(this.converter));
            c = this.converter;
        end
        function pth  = get.modalityPath(this)
            pth = this.petPath;
        end
        
        function test_createFromConverter(this)
            obj = mlfourd.ImageBuilder.createFromConverter(this.converter);
            assert(isa(obj, 'mlfourd.ImageBuilder'));
        end
        function test_referenceImage(this)
            this.imbuilder.referenceImage = this.t1_fqfn;
            assert(isa(this.imbuilder.referenceImage, 'mlfourd.ImagingSeries'));
        end
        function test_average(this)
        end
        
 		function this = Test_ImageBuilder(varargin) 
 			this = this@mlfourd_xunit.Test_NIfTIInterface(varargin{:}); 
            this.modalityPath = this.petPath;
            this.converter = mlfourd.PETConverter.createFromModalityPath(this.modalityPath);
            this.imbuilder = mlfourd.ImageBuilder.createFromConverter(this.converter);
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

