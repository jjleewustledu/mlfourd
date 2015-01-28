classdef Test_BlurredNIfTI < mlfourd_xunit.Test_NIfTI
	%% TEST_BLURREDNIFTI   

	%  Usage:  >> runtests tests_dir  
	%          >> runtests mlfourd_xunit.Test_BlurredNIfTI % in . or the matlab path 
	%          >> runtests mlfourd_xunit.Test_BlurredNIfTI:test_nameoffunc 
	%          >> runtests(mlfourd_xunit.Test_BlurredNIfTI, Test_Class2, Test_Class3, ...) 
	%  See also:  package xunit 

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 

	methods 
        function        test_blurred(this)
            nii = this.t1;
            nii.fileprefix = 'test_blurred';
            nii = nii.blurred;
            assertEqual(6.355880021447207,         nii.entropy);
            assertEqual('test_blurred_131315fwhh', nii.fileprefix);
        end
        function        test_isaNIfTI(this) %#ok<MANU>
            %% empty to disable parent method
        end
 		function this = Test_BlurredNIfTI(varargin) 
            this = this@mlfourd_xunit.Test_NIfTI(varargin{:});
            
            import mlfourd.*;
            this.t1struct_ = BlurredNIfTI(NIfTI(this.t1struct_));
            this.t1_       = BlurredNIfTI(this.t1_);
            this.t1mask_   = BlurredNIfTI(this.t1mask_);
 		end 
    end 
    
    methods (Static, Access = 'protected')
        function obj = aCtor(arg) % overload
            obj = mlfourd.BlurredNIfTI(arg);
        end
        function obj = aLoader(arg) % overload
            obj = mlfourd.BlurredNIfTI.load(arg);
        end
    end
    
    properties (Access = 'private')
        test_nifti_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

