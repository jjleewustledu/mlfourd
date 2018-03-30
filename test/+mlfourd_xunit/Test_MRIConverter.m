classdef Test_MRIConverter < mlfourd_xunit.Test_mlfourd 
	%% TEST_MRICONVERTER 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_MRIConverter % in . or the matlab path 
 	%          >> runtests Test_MRIConverter:test_nameoffunc 
 	%          >> runtests(Test_MRIConverter, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit	%  Version $Revision: 2513 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_MRIConverter.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_MRIConverter.m 2513 2013-08-18 22:52:21Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Constant)
        files     = { ...
                '05-001p7936_20111118_001_001_localizer.nii' ...
                '05-001p7936_20111118_001_002_TRA_MPRAGE__WHOLE_HD.nii' ...
                '05-001p7936_20111118_001_003_TRAN_FLAIR.nii' ...
                '05-001p7936_20111118_001_004_TRAN_TSE_T2.nii' ...
                '05-001p7936_20111118_001_005_AX_SE_T1.nii' ...
                '05-001p7936_20111118_001_006_gre_field_mapping_update.nii' ...
                '05-001p7936_20111118_001_007_DIFF_EPI__iPaT_2.nii' ...
                '05-001p7936_20111118_001_009_TRANS_EPI_PERFUSION.nii' ...
                '05-001p7936_20111118_001_013_Short_TOF.nii' ...
                '05-001p7936_20111118_001_017_AX_SE_T1.nii' ...
                '05-001p7936_20111118_001_018_TRA_MPRAGE__WHOLE_HD.nii' };
        entropies = { 4.485115439171584 ...
                      5.262640469680973 ...
                      5.753388005808461 ...
                      6.374177653871484 ...
                      5.884976588605346 ...
                      4.593451707487834 ...
                      3.142011374837753 ...
                      3.142011374837753 };
    end 

    properties
        converter
    end
    
	properties (Dependent)
        mcvertPath
        dicomPath
 	end 

	methods
        function pth = get.mcvertPath(this)
            pth = fullfile(this.sessionPath, 'Trio', 'MRIConvert', '');
        end
        function pth = get.dicomPath(this)
            pth = fullfile(this.sessionPath, 'Trio', 'CDR_OFFLINE', '');
        end
        
        function test_orientRepair(this)
            import mlfourd.* mlfourd_xunit.*;
            copyfiles(fullfile(this.mcvertPath, '*.nii', this.fslPath), 'f');
            MRIConverter.orientRepair(this.fslPath, this.converter.orients2fix);  
            this.converter.orientChange2Standard(this.fslPath);
            %Test_MRIConverter.assertEntropies(this.entropies, this.files);
 		end 
 		function test_unpacksDcmDir(this)
            mlfourd.MRIConverter.unpacksDcmDir(this.dicomPath, this.mcvertPath);
            for f = 1:length(this.files) 
                file = fullfile(this.converter.mcverterDout, ...
                                this.converter.pidFolder, ...
                                this.converter.seriesFolder(this.serNum(this.files{f}), this.seqDesc(this.files{f}), this.serDate(this.files{f})), ...
                                this.files{f});
                assertTrue(lexist(file, 'file'));
            end
        end
        function test_ctor(this)
            assertTrue(isa(this.converter, 'mlfourd.MRIConverter'));
            assertEqual(this.mcvertPath, this.converter.mcverterDout);
            assertEqual(this.dicomPath,  this.converter.mcverterDin);
        end
        
 		function this = Test_MRIConverter(varargin) 
 			this = this@mlfourd_xunit.Test_mlfourd(varargin{:}); 
            this.preferredSession = 1;
            this.converter = mlfourd.MRIConverter.createFromModalityPath(this.mrPath);
            this.converter.mcverterDout = this.mcvertPath;
            this.converter.mcverterDin = this.dicomPath;
 		end % Test_MRIConverter (ctor) 
    end 
    
    %% PRIVATE
    
    methods (Access = 'private')
        function str = seqDesc(~, file)
            str = file(30:end-4);
        end
        function str = serDate(this, file)
            assert(ischar(file));
            assert(~isempty(strfind(this.files, file)));
            str = file(13:20);
        end
        function str = serNum(~, file)
            str = file(26:28);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

