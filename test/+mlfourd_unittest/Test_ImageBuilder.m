classdef Test_ImageBuilder < mlfourd_unittest.Test_mlfourd 
	%% TEST_IMAGEBUILDER  

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImageBuilder)
 	%          >> result  = run(mlfourd_unittest.Test_ImageBuilder, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 

	properties 
 		testObj        
 		converter
        imbuilder
        modalityPath
 	end 

	methods (Test)   
        function test_createFromConverter(this)
            obj = mlfourd.ImageBuilder.createFromConverter(this.converter);
            this.assertTrue(isa(obj, 'mlfourd.ImageBuilder'));
        end
        function test_referenceImage(this)
            this.imbuilder.referenceImage = this.t1_fqfn;
            this.assertTrue(isa(this.imbuilder.referenceImage, 'mlfourd.ImagingSeries'));
        end
        function test_average(this)
        end
 	end 

 	methods (TestClassSetup) 
 		function setupImageBuilder(this) 
 			this.testObj = this.imbuilder;
 		end 
 	end 

 	methods (TestClassTeardown) 
 	end 

	methods        
 		function this = Test_ImageBuilder(varargin) 
 			this = this@mlfourd_unittest.Test_mlfourd(varargin{:}); 
            this.modalityPath = this.ecatPath;
            this.converter = mlfourd.PETConverter.createFromModalityPath(this.modalityPath);
            this.imbuilder = mlfourd.ImageBuilder.createFromConverter(this.converter);
 		end 
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

