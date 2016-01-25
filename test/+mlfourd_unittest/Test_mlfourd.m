classdef (Abstract) Test_mlfourd < matlab.unittest.TestCase
    
    properties
        pwdOri
        registry
        showViewers = true
    end
    
    properties (Dependent)
        
        %% files
        
        adc_fp
        adc_fqfn
        adcCntxt
        bt1_fp
        bt1_fqfn
        bt1Cntxt
        dwi_fp
        dwi_fqfn
        dwiCntxt
        ep2d_fp
        ep2d_fqfn
        ep2dCntxt
        ep2dMcf_fp
        ep2dMcf_fqfn
        ep2dMcfCntxt
        ep2dMean_fp
        ep2dMean_fqfn
        ep2dMeanCntxt
        ho_fp
        ho_fqfn
        hoCntxt
        ir_fp
        ir_fqfn
        irCntxt
        oc_fp
        oc_fqfn
        ocCntxt
        oo_fp
        oo_fqfn
        ooCntxt
        rawavg_fp
        rawavg_fqfn
        rawavgCntxt
        reference
        t1_fp
        t1_fqfn
        t1Cntxt
        t1mask_fp
        t1mask_fqfn
        t1maskCntxt
        t2_fp
        t2_fqfn
        t2Cntxt        
        test_fp
        test_fqfn
        testCntxt
        tr_fp
        tr_fqfn
        trCntxt
        
        %% paths
        
        bettedPath
        cossPath
        dataPath
        ecatPath
        fslPath
        mrPath
        mriPath
        petPath
        sessionPath
        studyPath
        subjectsDir
        targPath
        testPath
    end
    
    methods %% GET
        
        %% files
        
        function fp  = get.adc_fp(this) 
            fp = this.registry.adc_fp;       
        end
        function fn  = get.adc_fqfn(this)
            fn = this.fqfilenameInFsl(this.adc_fp);
        end
        function ic  = get.adcCntxt(this)
            ic = mlfourd.ImagingContext.load(this.adc_fqfn);
        end
        function fp  = get.bt1_fp(this) %#ok<MANU>
            fp = 'bt1_default_restore';
        end 
        function fn  = get.bt1_fqfn(this)
            fn = this.fqfilenameInFsl(this.bt1_fp);
        end
        function ic  = get.bt1Cntxt(this)
            ic = mlfourd.ImagingContext.load(this.bt1_fqfn);
        end
        function fp  = get.dwi_fp(this) 
            fp = this.registry.dwi_fp;
        end
        function fn  = get.dwi_fqfn(this)
            fn = this.fqfilenameInFsl(this.dwi_fp);
        end
        function ic  = get.dwiCntxt(this)
            ic = mlfourd.ImagingContext.load(this.dwi_fqfn);
        end
        function fp  = get.ep2d_fp(this) 
            fp = this.registry.ep2d_fp;
        end   
        function fn  = get.ep2d_fqfn(this)
            fn = this.fqfilenameInFsl(this.ep2d_fp);
        end 
        function ic  = get.ep2dCntxt(this)
            ic = mlfourd.ImagingContext.load(this.ep2d_fqfn);
        end
        function fn  = get.ep2dMcf_fp(this) 
            fn = this.registry.ep2dMcf_fp;
        end
        function fn  = get.ep2dMcf_fqfn(this)
            fn = this.fqfilenameInFsl(this.ep2dMcf_fp);
        end
        function ic  = get.ep2dMcfCntxt(this)
            ic = mlfourd.ImagingContext.load(this.ep2dMcf_fqfn);
        end
        function fn  = get.ep2dMean_fp(this) 
            fn = this.registry.ep2dMean_fp;
        end
        function fn  = get.ep2dMean_fqfn(this)
            fn = this.fqfilenameInFsl(this.ep2dMean_fp);
        end
        function ic  = get.ep2dMeanCntxt(this)
            ic = mlfourd.ImagingContext.load(this.ep2dMean_fqfn);
        end
        function fp  = get.ho_fp(this) 
            fp = this.registry.ho_fp;
        end 
        function fn  = get.ho_fqfn(this)
            fn = this.fqfilenameInFsl(this.ho_fp);
        end
        function ic  = get.hoCntxt(this)
            ic = mlfourd.ImagingContext.load(this.ho_fqfn);
        end
        function fp  = get.ir_fp(this) %#ok<MANU>
            fp = 't2_default';
        end 
        function fn  = get.ir_fqfn(this)
            fn = this.fqfilenameInFsl(this.ir_fp);
        end
        function ic  = get.irCntxt(this)
            ic = mlfourd.ImagingContext.load(this.ir_fqfn);
        end
        function fp  = get.oc_fp(this) 
            fp = this.registry.oc_fp;
        end
        function fn  = get.oc_fqfn(this)
            fn = this.fqfilenameInFsl(this.oc_fp);
        end
        function ic  = get.ocCntxt(this)
            ic = mlfourd.ImagingContext.load(this.oc_fqfn);
        end
        function fp  = get.oo_fp(this) 
            fp = this.registry.oo_fp;
        end 
        function fn  = get.oo_fqfn(this)
            fn = this.fqfilenameInFsl(this.oo_fp);
        end
        function ic  = get.ooCntxt(this)
            ic = mlfourd.ImagingContext.load(this.oo_fqfn);
        end
        function fp  = get.rawavg_fp(this) %#ok<MANU>
            fp = 'rawavg';
        end
        function fn  = get.rawavg_fqfn(this)
            fn = fullfile(this.sessionPath, 'mri', [this.rawavg_fp '.mgz']);
        end
        function ic  = get.rawavgCntxt(this)
            ic = mlfourd.ImagingContext.load(this.rawavg_fqfn);
        end
        function ref = get.reference(this)
            ref = this.t1_fqfn;
        end   
        function fp  = get.test_fp(this) %#ok<MANU>
            fp = 'test';
        end    
        function fn  = get.test_fqfn(this)
            fn = this.fqfilenameInFsl('test');
        end
        function ic  = get.testCntxt(this)
            ic = mlfourd.ImagingContext.load(this.test_fqfn);
        end
        function fp  = get.t1_fp(this) 
            fp = this.registry.t1_fp;
        end 
        function fn  = get.t1_fqfn(this)
            fn = this.fqfilenameInFsl(this.t1_fp);
        end
        function ic  = get.t1Cntxt(this)
            ic = mlfourd.ImagingContext.load(this.t1_fqfn);
        end
        function fp  = get.t1mask_fp(this)
            fp = ['bt1_default_mask'];
        end
        function fn  = get.t1mask_fqfn(this)
            fn = this.fqfilenameInFsl(this.t1mask_fp);
        end        
        function ic  = get.t1maskCntxt(this)
            ic = mlfourd.ImagingContext.load(this.t1mask_fqfn);
        end
        function fp  = get.t2_fp(this) 
            fp = this.registry.t2_fp;
        end 
        function fn  = get.t2_fqfn(this)
            fn = this.fqfilenameInFsl(this.t2_fp);
        end
        function ic  = get.t2Cntxt(this)
            ic = mlfourd.ImagingContext.load(this.t2_fqfn);
        end
        function fp  = get.tr_fp(this) 
            fp = this.registry.tr_fp;
        end 
        function fn  = get.tr_fqfn(this)
            fn = this.fqfilenameInFsl(this.tr_fp);
        end
        function ic  = get.trCntxt(this)
            ic = mlfourd.ImagingContext.load(this.t2_fqfn);
        end
        
        %% paths
        
        function pth = get.bettedPath(this)
            pth = fullfile(this.fslPath, 'bet', '');
        end
        function pth = get.cossPath(this)
            pth = this.registry.cossPath;
        end
        function pth = get.dataPath(this)
            pth = fullfile(this.sessionPath, 'Trio', 'CDR_OFFLINE', '');
        end
        function pth = get.ecatPath(this)
            pth = this.registry.ecatPath;
        end
        function pth = get.fslPath(this)
            pth = this.registry.fslPath;
        end  
        function pth = get.mrPath(this)
            pth = fullfile(fullfile(this.sessionPath, 'Trio', ''));
        end
        function pth = get.mriPath(this)
            pth = this.registry.mriPath;
        end
        function pth = get.petPath(this) 
            pth = this.registry.petPath;
        end
        function pth = get.sessionPath(this)
            pth = this.registry.sessionPath;
        end
        function pth = get.studyPath(this)
            pth = this.subjectsDir;
        end
        function pth = get.subjectsDir(this)
            pth = this.registry.subjectsDir;
        end
        function pth = get.targPath(this)
            pth = fullfile(this.mrPath, 'unpack', '');
        end   
        function pth = get.testPath(~)
            pth = fullfile(getenv('MLUNIT_TEST_PATH'), ''); 
        end  
    end
    
    methods (TestClassSetup)
        function setupMlfourd(this)
            this.registry = mlfourd.UnittestRegistry.instance('initialize');
            this.pwdOri = pwd;
            this.addTeardown(@cd, this.pwdOri);
            cd(this.sessionPath); 
            this.addTeardown(@this.cleanUpTestfiles);
        end
    end
    
 	methods (TestMethodSetup)
		function setupMlfourdTest(this) %#ok<MANU>
 		end
    end
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function fn  = fqfilenameInFsl(this, name)
            if (iscell(name)) %% use only the first cell
                fn = this.fqfilenamesInFsl(name{1}); 
                return
            end
            assert(ischar(name));
            fn = fullfilename(this.fslPath, name);
        end
        function fns = fqfilenamesInFsl(this, names)
            names = ensureCell(names);
            fns   = cellfun(@this.fqfilenameInFsl, names, 'UniformOutput', false);
        end
        function       cleanUpTestfiles(this)
            deleteExisting(this.test_fqfn);
        end
        function       assertEntropies(this, objs, objs1)
            %% ASSERTENTROPIES
            %  @param objs is a numerical entropy or cell-array of them.
            %  @param objs1 is an imaging object with entropy or cell-array of them.
            %  objs and objs1 may be swapped.
            
            objs  = ensureCell(objs);
            objs1 = ensureCell(objs1);
            for o = 1:min(length(objs), length(objs1))
                try
                    if (isnumeric(objs{o}))
                        niid = mlfourd.NIfTId(objs1{o});
                        this.verifyEqual(objs{o}, niid.entropy, 'RelTol', 1e-6);
                    elseif (isnumeric(objs1{o}))
                        niid = mlfourd.NIfTId(objs{o});
                        this.verifyEqual(objs1{o}, niid.entropy, 'RelTol', 1e-6);
                    else
                        warning('mlfourd_unittest:unsupportedTypeclass', ...
                            'Test_mlfourd.assertEntropies:  class(objs{%i})->%s but class(objs1{%i})->%s', ...
                            o, class(objs{o}), o, class(objs1{o}));
                    end
                catch ME
                    handexcept(ME);
                end
            end
        end  
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

