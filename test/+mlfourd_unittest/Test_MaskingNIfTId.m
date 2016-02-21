classdef Test_MaskingNIfTId < matlab.unittest.TestCase
	%% TEST_MASKINGNIFTID  

	%  Usage:  >> results = run(mlfourd_unittest.Test_MaskingNIfTId)
 	%          >> result  = run(mlfourd_unittest.Test_MaskingNIfTId, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 

    properties
        registry
        testObj
        thr300
        viewManually = false
    end
    
    properties (Dependent)
        maskT1_fp
        maskT1_fqfn
        maskT1_niid
        smallT1_fp
        smallT1_fqfn  
        smallT1_niid
    end
    
    methods %% GET/SET
        function g = get.maskT1_fp(this)
            g = this.registry.maskT1_fp;
        end
        function g = get.maskT1_fqfn(this)
            g = this.registry.maskT1_fqfn;
        end
        function g = get.maskT1_niid(this)
            g = mlfourd.NIfTId(this.maskT1_fqfn);
        end
        function g = get.smallT1_fp(this)
            g = this.registry.smallT1_fp;
        end
        function g = get.smallT1_fqfn(this)
            g = this.registry.smallT1_fqfn;
        end
        function g = get.smallT1_niid(this)
            g = mlfourd.NIfTId(this.smallT1_fqfn);
        end
    end
    
	methods (Test) 
        function test_load(this)
            m = this.testObj;
            this.verifyEqual(m.component,           this.smallT1_niid);
            this.verifyEqual(m.bitpix,              this.smallT1_niid.bitpix);
            this.verifyEqual(m.descrip(end-27:end), '; decorated by MaskingNIfTId');
            this.verifyEqual(m.entropy,             2.075192819312446e-05, 'RelTol', 1e-6);
            this.verifyEqual(m.fqfilename,          this.smallT1_fqfn);
            this.verifyEqual(m.hdxml,               this.smallT1_niid.hdxml);
            this.verifyEqual(m.img,                 this.smallT1_niid.img);
            this.verifyEqual(m.mmppix,              this.smallT1_niid.mmppix);
        end
        function test_ctor(this)
            import mlfourd.*;
            c   = this.testObj;
            t   = MaskingNIfTId(this.smallT1_niid, 'thresh', 300);
            tp  = MaskingNIfTId(this.smallT1_niid, 'threshp', 87.65);
            tPZ = MaskingNIfTId(this.smallT1_niid, 'threshPZ', 87.65);            
            b   = MaskingNIfTId(this.thr300.component, 'binarized', true);
            
            this.verifyEqual(c.component, this.smallT1_niid);
            if (this.viewManually); c.freeview(this.smallT1_fqfn); end                           
            
            this.verifyObj(t, 0.532765334419431, 49403676.2174377, [this.smallT1_fp '_thr300']);  
            if (this.viewManually); t.freeview; end   
            
            this.verifyObj(tp, 0.539339309326423, 50114752.9769897, [this.smallT1_fp '_thrp88']);  
            if (this.viewManually); tp.freeview; end
            
            this.verifyObj(tPZ, 0.539339309326423,  50114752.9769897, [this.smallT1_fp '_thrPZ88']);  
            if (this.viewManually); tPZ.freeview; end   
            
            this.verifyObj(b, 0.532765334419431,  125089, [this.smallT1_fp '_thr300_binarized']);  
            if (this.viewManually); b.freeview; end      
        end
        function test_ctorMasked(this)            
            this.verifyWarning( ...
                @() mlfourd.MaskingNIfTId(this.smallT1_niid, 'masked', this.thr300), ...
                'mlfourd:possibleMaskingError');         
        end
        function test_ctorMultiArg(this)
            import mlfourd.*;
            b = MaskingNIfTId(this.thr300.component, 'binarize', true);
            c = MaskingNIfTId(this.smallT1_niid, 'masked', b, 'thresh', 400, 'threshp', 95, 'binarized', true);
            this.verifyObj(c, 0.286398603290942, 51610, [this.smallT1_fp '_maskedby_t1_default_on_ho_meanvol_default_thr300_binarized_thr400_thrp95_binarized']);             
            if (this.viewManually); c.freeview; end      
        end        
        function test_binarized(this)
            this.verifyObj(this.thr300.binarized, ...
                0.532765334419431, 125089, [this.smallT1_fp '_thr300_binarized']);
        end
        function test_count(this)
            this.verifyEqual(this.thr300.count, 125089);
        end
        function test_masked3D(this)
            this.verifyWarning( ...
                @() this.testObj.masked(this.thr300), 'mlfourd:possibleMaskingError');  
            
            m = this.testObj.masked(this.maskT1_niid);
            this.verifyObj(m, 0.567605718841869, 47585080.4438686, [this.smallT1_fp '_maskedby_bt1_default_mask_on_ho_meanvol_default']);
            if (this.viewManually)
                this.thr300.save;
                m.freeview(this.testObj.fqfn, this.maskT1_fqfn, this.thr300.fqfn); 
            end
        end
        function test_masked4D(this)
            import mlfourd.*;
            m4d = MaskingNIfTId(NIfTId(this.registry.dyn_fqfn));            
            
            this.verifyWarning( ...
                @() m4d.masked(this.thr300), 'mlfourd:possibleMaskingError');  
            
            m = m4d.masked(this.maskT1_niid);
            this.verifyObj(m, 0.411728868613467, 602335458, 'p7377ho1_maskedby_bt1_default_mask_on_ho_meanvol_default');
            if (this.viewManually)
                m.freeview;
                this.testObj.freeview; 
                this.maskT1_niid.freeview;
                this.thr300.save;
                this.thr300.fqfn; 
            end
        end
        function test_maskedByZ(this)
            m = this.testObj.maskedByZ([11 53]);
            this.verifyEqual(m.img(:,:,1:10),  zeros(128,128,10));
            this.verifyEqual(m.img(:,:,54:63), zeros(128,128,10));
            this.verifyEqual(dipsum(m.img(:,:,11:53)), 68616603.2058744, 'RelTol', 1e-10);
            if (this.viewManually); m.freeview; end
        end
        function test_maskedByZ4D(this)
            import mlfourd.*;
            m4d = MaskingNIfTId(NIfTId(this.registry.dyn_fqfn));             
            
            m = m4d.maskedByZ([11 53]);
            for t = 1:size(m4d,4)
                this.verifyEqual(m.img(:,:,1:10,  t),  zeros(128,128,10));
                this.verifyEqual(m.img(:,:,54:63, t), zeros(128,128,10));
            end
            this.verifyEqual(dipsum(m.img(:,:,11:53, :)), 704037557, 'RelTol', 1e-6);
            if (this.viewManually); m.freeview; end
        end
        function test_thresh(this)
            t = this.thr300.thresh(400);
            this.verifyObj(t, 0.293711917140021, 24252622.0848694, [this.smallT1_fp '_thr300_thr400']);
            if (this.viewManually); t.freeview; end
        end
        function test_threshp(this)
            t = this.testObj.threshp(87.65);
            this.verifyObj(t, 0.539339309326423, 50114752.9769897, [this.smallT1_fp '_thrp88']);
            if (this.viewManually); t.freeview; end
        end
        function test_threshPZ(this)
            t = this.testObj.threshPZ(87.65);
            this.verifyObj(t, 0.539339309326423, 50114752.9769897, [this.smallT1_fp '_thrPZ88']);
            if (this.viewManually); t.freeview; end
        end
        
        %% test helpers
        
        function test_dipiqr(this)
            this.verifyEqual(dipiqr(this.testObj), 47.4210848808289, 'RelTol', 1e-6);
        end
        function test_dipmad(this)
            this.verifyEqual(dipmad(this.testObj), 102.225440919867, 'RelTol', 1e-6);
        end
        function test_dipprctile(this)
            this.verifyEqual(dipprctile(this.testObj, 25), 2.27962350845337, 'RelTol', 1e-6);
        end
        function test_dipquantile(this)
            this.verifyEqual(dipquantile(this.testObj, 0.25), 2.27962350845337, 'RelTol', 1e-6);
        end
        function test_diptrimmean(this)
            this.verifyEqual(diptrimmean(this.testObj, 25), 34.6399866578098, 'RelTol', 1e-6);
        end
        
        function test_dipisfinite(this)
            this.verifyEqual(dipisfinite(this.testObj), true);
        end
        function test_dipisinf(this)
            this.verifyEqual(dipisinf(this.testObj), false);
        end
        function test_dipisnan(this)
            this.verifyEqual(dipisnan(this.testObj), false);
        end
        function test_dipisreal(this)
            this.verifyEqual(dipisreal(this.testObj), true);
        end
        function test_dipmax(this)
            this.verifyEqual(dipmax(this.testObj), 821.725952, 'RelTol', 1e-6);
        end
        function test_dipmean(this)
            this.verifyEqual(dipmean(this.testObj), 75.257871, 'RelTol', 1e-6);
        end
        function test_dipmedian(this)
            this.verifyEqual(dipmedian(this.testObj), 7.238812, 'RelTol', 1e-6);
        end
        function test_dipmin(this)
            this.verifyEqual(dipmin(this.testObj), 0.918649315834045, 'RelTol', 1e-5);
        end
        function test_dipmode(this)
            this.verifyEqual(dipmode(this.testObj), 2.279624, 'RelTol', 1e-6);
        end
        function test_dipprod(this)
            this.verifyFalse(isfinite(dipprod(this.testObj))); % numerical overflow
        end
        function test_diplogprod(this)
            this.verifyEqual(diplogprod(this.testObj), 2684005.06836689, 'RelTol', 1e-6);
        end
        function test_dipstd(this)
            this.verifyEqual(dipstd(this.testObj), 135.029968, 'RelTol', 1e-6);
        end
        function test_dipsum(this)
            this.verifyEqual(dipsum(this.testObj), 77680572.851196, 'RelTol', 1e-6);
        end
 	end 

 	methods (TestClassSetup) 
 		function setupMaskedNIfTI(this) 
            import mlfourd.*;
            this.registry = UnittestRegistry.instance; 
            this.registry.sessionFolder = 'mm01-020_p7377_2009feb5';
            this.MaskingNIfTId_ = MaskingNIfTId(this.smallT1_niid); 
            this.thr300_ = this.MaskingNIfTId_.thresh(300);
            this.verifyObj(this.thr300_, 0.532765334419431, 49403676.2174377, [this.smallT1_fp '_thr300']);
 		end 
    end 
    
 	methods (TestMethodSetup)
		function setupMaskingNIfTIdTest(this)
            import mlfourd.*;
 			this.testObj = this.MaskingNIfTId_;
            this.thr300  = this.thr300_;
            this.addTeardown(@this.cleanupFiles);
 		end
    end
    
    %% PRIVATE
    
    properties (Access = private)
        MaskingNIfTId_
        thr300_
    end
    
    methods (Access = private)
        function verifyObj(this, obj, e, s, fp)
            this.assumeInstanceOf(obj, 'mlfourd.INIfTI');
            this.verifyEqual(obj.entropy,    e, 'RelTol', 1e-6);
            this.verifyEqual(dipsum(obj),    s, 'RelTol', 1e-4);
            this.verifyEqual(obj.fileprefix, fp); 
        end
        function cleanupFiles(this)
            deleteExisting(this.thr300.fqfn);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

