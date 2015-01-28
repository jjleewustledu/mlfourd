classdef Test_NamingRegistry < TestCase
	%% TEST_NAMINGCONVENTIONS 
    %% Usage:  runtests Test_NamingRegistry
	%% Version $Revision: 2516 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $  
	%% and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_NamingRegistry.m $ 
	%% Developed on Matlab 7.10.0.499 (R2010a) 
	%% $Id: Test_NamingRegistry.m 2516 2013-08-18 22:52:21Z jjlee $ 

    properties (Constant)
        XUNIT_PATH  = '/Users/jjlee/Tmp/xunit';
        TEST_FOLDER = '/Users/jjlee/Tmp/test_patient_folder';
    end
    
	properties (Access = 'private')
        reg
	end 

	methods 

		function this = Test_NamingRegistry(varargin)
            this      = this@TestCase(varargin{:});
        end
        
        function setUp(this)
            this.reg = mlfourd.NamingRegistry.instance;
        end
        
        function test_noSuffixed(this)
            assertEqual('asdf_jkl.nii.gz', ...
                NamingRegistry.notSuffixed('asdf_rot_jkl.nii.gz',    '_rot'));
            assertEqual('_asdf.nii.gz', ...
                NamingRegistry.notSuffixed('_mcf_meanvol_mcf_meanvol_asdf_mcf_meanvol.nii.gz', '_mcf_meanvol'));
            assertEqual('asdf_asdf', ...
                NamingRegistry.notSuffixed('asdf_mcf_meanvol_mcf_meanvol_asdf_mcf_meanvol',    '_mcf_meanvol'));
        end
        
        function test_meanvol(this)
            assertEqual('asdf_mcf_meanvol.nii.gz', NamingRegistry.meanvol('asdf.nii.gz'));            
            assertEqual('asdf_mcf_meanvol.nii.gz', NamingRegistry.meanvol('asdf_mcf_meanvol.nii.gz'));
        end
        
        function tearDown(this)
        end
	end 
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
