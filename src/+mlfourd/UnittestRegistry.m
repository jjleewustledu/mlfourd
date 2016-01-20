classdef UnittestRegistry < mlpatterns.Singleton
	%% UNITTESTREGISTRY  

	%  $Revision$
 	%  was created 19-Oct-2015 00:30:19
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64. 	

	properties
        adc_fp = 'adc_default'
        dwi_fp = 'dwi_default'
        ep2d_fp = 'ep2d_default'
        ep2dMcf_fp = 'ep2d_default_mcf'
        ep2dMean_fp = 'ep2d_default_mcf_meanvol'
        ho_fp = 'ho_meanvol_default'
        ir_fp = 'ir_default'
        maskT1_fp = 'bt1_default_mask_on_ho_meanvol_default'
        oc_fp = 'oc_default'
        oo_fp = 'oo_meanvol_default'
 		sessionFolder = 'mm01-020_p7377_2009feb5'
        smallT1_fp = 't1_default_on_ho_meanvol_default'
        t1_fp = 't1_default'
        t2_fp = 't2_default'
        tr_fp = 'tr_default'
    end

	properties (Dependent)
        cossPath
        dyn_fqfn
        ecatPath
        fslPath
        maskT1_fqfn
        mriPath
        petPath
        pnum
 		sessionPath
        subjectsDir
        smallT1_fqfn
        smallT1Cntxt
    end
    
    methods % GET
        function g = get.cossPath(this)
            g = fullfile(this.ecatPath, 'coss', '');
        end
        function g = get.dyn_fqfn(this)
            g = fullfile(this.petPath, [this.pnum 'ho1_frames'], [this.pnum 'ho1.nii.gz']);
        end
        function g = get.ecatPath(this)
            g = fullfile(fullfile(this.sessionPath, 'ECAT_EXACT', ''));
        end
        function g = get.fslPath(this)
            g = fullfile(this.sessionPath, 'fsl', '');
        end  
        function g = get.maskT1_fqfn(this)
            g = fullfile(this.fslPath, [this.maskT1_fp '.nii.gz']);
        end
        function g = get.mriPath(this)
            g = fullfile(fullfile(this.sessionPath, 'mri', ''));
        end
        function g = get.petPath(this) 
            g = fullfile(this.ecatPath, 'pet', '');
        end
        function g = get.pnum(this)
            g = str2pnum(this.sessionPath);
        end
        function g = get.sessionPath(this)
            g = fullfile(this.subjectsDir, this.sessionFolder, '');
        end
        function g = get.smallT1_fqfn(this)
            g = fullfile(this.fslPath, [this.smallT1_fp '.nii.gz']);
        end
        function g = get.smallT1Cntxt(this)
            g = mlfourd.ImagingContext.load(this.smallT1_fqfn);
        end
        function g = get.subjectsDir(~)
            g = fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl', 'np755', '');
        end
    end
    
    methods (Static)
        function this = instance(qualifier)
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            persistent uniqueInstance
            
            if (exist('qualifier','var') && ischar(qualifier))
                if (strcmp(qualifier, 'initialize'))
                    uniqueInstance = [];
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlfourd.UnittestRegistry();
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end
    
	methods (Access = 'private')		  
 		function this = UnittestRegistry(varargin) 			
 			this = this@mlpatterns.Singleton(varargin{:}); 			
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

