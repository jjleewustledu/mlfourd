classdef Test_ImagingContext < matlab.unittest.TestCase
	%% TEST_IMAGINGCONTEXT 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImagingContext)
 	%          >> result  = run(mlfourd_unittest.Test_ImagingContext, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 18-Oct-2015 13:14:55
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
    properties
        registry
 		testObj
        testObjs
        view = false
    end
    
    properties (Dependent)
        dynamic
        blurring
        ho_fqfn
        niftic
        masking
        maskT1_fp
        maskT1_fqfn
        maskT1_niid
        numerical
        oc_fqfn
        oo_fqfn
        pet_fqfns
        smallT1_fp
        smallT1_fqfn
        smallT1_niid
        smallT1_nii
        testthis_fqfn
        testthis_fqfns
        tr_fqfn
    end
    
    methods %% GET
        function g = get.dynamic(this)
            g = mlfourd.DynamicNIfTId.load(this.ho_fqfn);
        end
        function g = get.blurring(this)
            g = mlfourd.BlurringNIfTId.load(this.smallT1_fqfn);
        end
        function g = get.ho_fqfn(this)            
            g = fullfile(this.registry.petPath, [this.registry.pnum 'ho1_frames'], [this.registry.pnum 'ho1.nii.gz']);
        end
        function g = get.oo_fqfn(this)            
            g = fullfile(this.registry.petPath, [this.registry.pnum 'oo1_frames'], [this.registry.pnum 'oo1.nii.gz']);
        end
        function g = get.oc_fqfn(this)            
            g = fullfile(this.registry.petPath, [this.registry.pnum 'oc1_frames'], [this.registry.pnum 'oc1_03.nii.gz']);
        end
        function g = get.tr_fqfn(this)            
            g = fullfile(this.registry.petPath, [this.registry.pnum 'tr1_frames'], [this.registry.pnum 'tr1_01.nii.gz']);
        end
        function g = get.niftic(this)
            g = mlfourd.NIfTIc.load(this.pet_fqfns);
        end
        function g = get.masking(this)
            g = mlfourd.MaskingNIfTId.load(this.smallT1_fqfn);
        end        
        function g = get.maskT1_fp(this)
            g = this.registry.maskT1_fp;
        end
        function g = get.maskT1_fqfn(this)
            g = this.registry.maskT1_fqfn;
        end
        function g = get.maskT1_niid(this)
            g = mlfourd.NIfTId(this.maskT1_fqfn);
        end
        function g = get.numerical(this)
            g = mlfourd.NumericalNIfTId(this.smallT1_niid);
        end   
        function g = get.pet_fqfns(this)
            g = {this.ho_fqfn this.oo_fqfn this.oc_fqfn  this.tr_fqfn};
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
        function g = get.smallT1_nii(this)
            g = mlfourd.NIfTI(this.smallT1_fqfn);
        end
        function g = get.testthis_fqfn(this)
            g = fullfile(this.registry.sessionPath, 'fsl', 'Test_ImagingContext.nii.gz');
        end
        function g = get.testthis_fqfns(this)
            p = this.registry.pnum;
            g = {fullfile(this.registry.petPath, [p 'ho1_frames'], ['Test_ImagingContext_' p 'ho1.nii.gz']) ...
                 fullfile(this.registry.petPath, [p 'oo1_frames'], ['Test_ImagingContext_' p 'oo1.nii.gz']) ...
                 fullfile(this.registry.petPath, [p 'oc1_frames'], ['Test_ImagingContext_' p 'oc1_03.nii.gz']) ...
                 fullfile(this.registry.petPath, [p 'tr1_frames'], ['Test_ImagingContext_' p 'tr1_01.nii.gz'])};
        end
    end

	methods (Test)
        function test_setup(this)
            this.verifyInstanceOf(this.testObj, 'mlfourd.ImagingContext');
        end        
        function test_imagingType(this)
            import mlraichle.*;
            obj = fullfile(getenv('PPG'), 'jjlee', 'HYGLY24', 'V1', 'mpr.4dfp.img');
            this.verifyEqual(imagingType('fn', obj),             basename(obj));
            this.verifyEqual(imagingType('fqfn', obj),           obj);
            this.verifyEqual(imagingType('fp', obj),             'mpr');
            this.verifyEqual(imagingType('fqfp', obj),           myfileprefix(obj));
            this.verifyEqual(imagingType('folder', obj),         'V1');
            this.verifyEqual(imagingType('path', obj),           myfileparts(obj));
            this.verifyEqual(imagingType('ext', obj),            '.4dfp.img');
            this.verifyClass(imagingType('imagingContext', obj), 'mlfourd.ImagingContext');
        end
        function test_locationType(this)
            import mlraichle.*;
            loc = fullfile(getenv('PPG'), 'jjlee', 'HYGLY24', 'V1', '');
            this.verifyEqual(locationType('path', loc), loc);
            this.verifyEqual(locationType('folder', loc), 'V1');
        end
        
        %% properties
        
        function test_filename(this)
            [~,f,e] = myfileparts(this.smallT1_fqfn);
            this.verifyEqual(this.testObj.filename, [f e]);
            this.testObj.filename = 'test_filename.mgz';
            this.verifyEqual(this.testObj.filename, 'test_filename.mgz');
        end
        function test_filepath(this)
            pwd0 = pwd;
            [p,f,e] = myfileparts(this.smallT1_fqfn);
            this.verifyEqual(this.testObj.filepath, p);
            this.testObj.filepath = '/tmp';            
            this.verifyEqual(this.testObj.fqfn, fullfile('/tmp', [f e]));
            this.verifyEqual(pwd, pwd0);
        end
        function test_fileprefix(this)
            [p,f,e] = myfileparts(this.smallT1_fqfn);
            this.verifyEqual(this.testObj.fileprefix, f);
            this.testObj.fileprefix = 'test_fileprefix';
            this.verifyEqual(this.testObj.fqfn, fullfile(p, ['test_fileprefix' e]));
        end
        function test_filesuffix(this)
            [p,f,e] = myfileparts(this.smallT1_fqfn);
            this.verifyEqual(this.testObj.filesuffix, e);
            this.testObj.filesuffix = '.test';
            this.verifyEqual(this.testObj.fqfn, fullfile(p, [f '.test']));
        end
        function test_fqfilename(this)
            this.verifyEqual(this.testObj.fqfn, this.smallT1_fqfn);
            this.testObj.fqfilename = '/tmp/test_fqfilename.test';            
            this.verifyEqual(this.testObj.fqfn, '/tmp/test_fqfilename.test');
        end
        function test_stateTypeclass(this)
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.NIfTIdState');
            this.testObj.niftic;
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.NIfTIcState');
            this.testObj.mgh;
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.MGHState');
            this.testObj.niftid;
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.NIfTIdState');
        end
        
        %% query methods
        
        function test_char(this)
            fqfn = this.imagingContext_.fqfilename;
            this.verifyEqual(char(this.testObj),         fqfn);
            this.verifyEqual(char(this.testObj.niftic), {fqfn});
            this.verifyEqual(char(this.testObj.mgh),     fqfn);
            this.verifyEqual(char(this.testObj.niftid),  fqfn);
        end
        function test_double(this)
            img = double(this.smallT1_niid.img);
            this.verifyEqual(double(this.testObj),        img);
            cached = double(this.testObj.niftic);
            this.verifyEqual(cached{1},                   img);
            this.verifyEqual(double(this.testObj.mgh),    img);
            this.verifyEqual(double(this.testObj.niftid), img);
        end
        function test_view_niftid(this)
            this.testObj.view;
        end
        function test_view_niftic(this)
            this.testObjs.view;
        end
        function test_view_options(this)
            mriPth  = fullfile(this.registry.sessionPath, 'mri');
            surfPth = fullfile(this.registry.sessionPath, 'surf');
            ic = mlfourd.ImagingContext(fullfile(mriPth, 'T1.mgz'));
            ic.view({ ...
                fullfile(mriPth,  'wm.mgz') ...
                fullfile(mriPth,  'brainmask.mgz') ...
                fullfile(mriPth,  'aseg.mgz:colormap=lut:opacity=0.2') ...
         ['-f ' fullfile(surfPth, 'lh.white:edgecolor=blue')] ...
                fullfile(surfPth, 'lh.pial:edgecolor=red') ...
                fullfile(surfPth, 'rh.white:edgecolor=blue') ...
                fullfile(surfPth, 'rh.pial:edgecolor=red')});
        end
        function test_view_additionalImagingContext(this)
            this.testObj.view(this.testObj);
        end
        function test_view_additionalImagingContexts(this)
            this.testObj.view(this.testObj, this.testObj);
        end
        function test_view_ensureAnyFormsSaved(this)
            this.testObj = this.testObj.binarized;
            this.testObj.view;
        end
          
        %% factory methods
        
        function test_ctor_NIfTId(this)
            import mlfourd.*;
            ic = ImagingContext(this.smallT1_niid);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            this.verifyEqual(class(ic.niftid),  'mlfourd.NIfTId');
            ic = ImagingContext(this.blurring);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            this.verifyEqual(class(ic.niftid),  'mlfourd.NIfTId');
            ic = ImagingContext(this.dynamic);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            this.verifyEqual(class(ic.niftid),  'mlfourd.NIfTId');
            ic = ImagingContext(this.masking);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            this.verifyEqual(class(ic.niftid),  'mlfourd.NIfTId');
            this.verifyEqual(ic.niftid, this.smallT1_niid);
        end
        function test_ctor_MGH(this)
            import mlfourd.*;
            ic = ImagingContext(mlsurfer.MGH.load( ...
                fullfile(this.registry.mriPath, 'T1.mgz')));
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.MGHState');  
            this.verifyEqual(class(ic.mgh),     'mlsurfer.MGH'); 
            this.verifyEqual(class(ic.niftid),  'mlfourd.NIfTId');
        end
        function test_ctor_NIfTIc(this)
            import mlfourd.*;
            ic = this.testObjs;
            niic = ic.niftic;
            
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIcState');
            this.verifyEqual(ic.length, niic.length);
            this.verifyEqual(ic.csize,  niic.csize);  
            this.verifyEqual(ic.find(niic.get(1)), 1);
            this.verifyEqual(ic.get(1), ImagingContext(niic.get(1)));            
            ic.add(this.smallT1_niid);
            this.verifyEqual(ic.get(ic.length), ImagingContext(this.smallT1_niid));            
            this.verifyInstanceOf(ic.createIterator, 'mlpatterns.CompositeIterator'); 
            
            len = ic.length;
            for l = len:-1:1
                ic.rm(l);
            end
            this.verifyEqual(ic.isempty, true);
        end
        function test_ctor_char(this)
            import mlfourd.*;
            ic = ImagingContext(this.testthis_fqfn);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.FilenameState');
            this.verifyEqual(class(ic.niftid),  'mlfourd.NIfTId');
            this.verifyEqual(ic.niftid.fqfn,    this.testthis_fqfn);
        end
        function test_ctor_double(this)
            import mlfourd.*;
            ic = ImagingContext(magic(3));            
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            this.verifyEqual(class(ic.niftid),  'mlfourd.NIfTId');
            this.verifyEqual(ic.niftid.img, magic(3));
        end     
        function test_ctor_ImagingContext(this)
            ic  = this.testObj;
            ic2 = mlfourd.ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            this.verifyEqual(ic.niftid, ic2.niftid);
        end
        function test_ctor_ImagingContext_NIfTId(this)
            import mlfourd.*;
            ic  = ImagingContext(this.smallT1_niid);
            ic2 = ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            this.verifyEqual(ic.niftid, ic2.niftid);
        end
        function test_ctor_ImagingContext_NIfTIc(this)
            import mlfourd.*;
            ic  = this.testObjs;
            ic2 = ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            for c = 1:ic2.length
                this.verifyEqual(ic.get(c), ic2.get(c));
            end
        end
        function test_ctor_ImagingContext_char(this)
            import mlfourd.*;
            ic  = ImagingContext(this.testthis_fqfn);
            ic2 = ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            this.verifyEqual(ic.fqfn, ic2.fqfn);
            this.verifyFalse(lexist(ic.fqfn,  'file'));
            this.verifyFalse(lexist(ic2.fqfn, 'file'));
        end
        function test_ctor_ImagingContext_double(this)
            import mlfourd.*;
            ic  = ImagingContext(magic(3));
            ic2 = ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            this.verifyEqual(ic.double, ic2.double);
            this.verifyEqual(ic.niftid, ic2.niftid);
            this.verifyFalse(lexist(ic.niftid.fqfn,  'file'));
            this.verifyFalse(lexist(ic2.niftid.fqfn, 'file'));
        end        
        function test_clone(this)
            import mlfourd.*;            
                      
            ic0 = this.testObj;
            ic  = ic0.clone;
            ic.filename = 'anotherFilename.nii.gz';
            this.verifyNotSameHandle(ic, ic0);
            this.verifyTrue(strcmp(ic0.fqfn, this.testObj.fqfn));
            
            ic0 = this.testObjs;
            ic  = ic0.clone;
            ic.filename = {'1.nii.gz' '2.nii.gz' '3.nii.gz' '4.nii.gz'};
            this.verifyNotSameHandle(ic, ic0);
            this.verifyTrue(all(strcmp(ic0.fqfn, this.testObjs.fqfn)));
            
            ic0 = ImagingContext(this.tr_fqfn);
            ic  = ic0.clone;
            ic.filename = 'anotherFilename.nii.gz';
            this.verifyNotSameHandle(ic, ic0);
            this.verifyTrue(strcmp(ic0.fqfn, this.tr_fqfn));
            
            ic0 = ImagingContext(magic(3));
            ic  = ic0.clone;
            this.verifyNotSameHandle(ic, ic0);
        end           
        function test_load(this)
            import mlfourd.*;            
            ic = ImagingContext.load(this.smallT1_fqfn);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.FilenameState');
            this.verifyEqual(ic.niftid, this.smallT1_niid);
            
            ic = ImagingContext.load(this.pet_fqfns);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIcState');
            this.verifyEqual(ic.niftic, this.niftic);
            a = ic.niftic;
            b = this.niftic;
            for idx = 1:min(a.length, b.length)
                this.verifyEqual(a.get(idx), b.get(idx));
            end
        end
        
        %% state changes
        
        function test_addLog(this)
            this.testObj.fileprefix = 'Test_ImagingContext.test_addLog';
            this.testObj.addLog('test_addLog called this.testObj.addLog');
            this.verifyEqual(this.testObj.niftid.logger.contents(end-37:end), 'test_addLog called this.testObj.addLog');
            this.testObj.save;
            tc = mlio.TextIO.textfileToCell(this.testObj.niftid.logger.fqfilename);
            this.verifyEqual(tc{end}(end-37:end), 'test_addLog called this.testObj.addLog');
        end
        function test_atlas_niftid(this)
            import mlfourd.*;
            ho = ImagingContext(NumericalNIfTId.load(this.ho_fqfn));
            oc = ImagingContext(NumericalNIfTId.load(this.oc_fqfn));
            oo = ImagingContext(NumericalNIfTId.load(this.oo_fqfn));
            tr = ImagingContext(NumericalNIfTId.load(this.tr_fqfn));
            this.verifyEqual(ho.stateTypeclass, 'mlfourd.NumericalNIfTIdState');            
            atl = ho.atlas(oc, oo, tr);
            
            this.verifyInstanceOf(atl, 'mlfourd.ImagingContext');
            this.verifyEqual(atl.stateTypeclass, 'mlfourd.NumericalNIfTIdState');
            this.verifyEqual(atl.niftid.size, [128 128 63]);
            this.verifyNiftid(atl.niftid, 1.59063853530086, 21.402881131310050, 'p7686ho1_sumt_atlas');            
            if (this.view)
                ic.view;
            end          
        end
        function test_atlas_niftic(this)
            ic = this.testObjs;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIcState'); 
            ic = ic.atlas;
            
            this.verifyInstanceOf(ic, 'mlfourd.ImagingContext');
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NumericalNIfTIdState');
            this.verifyEqual(ic.niftid.size, [128 128 63]);
            this.verifyNiftid(ic.niftid, 1.59063853530086, 21.402881131310050, 'p7686ho1_zeros_sumt_atlas');            
            if (this.view)
                ic.view;
            end
        end
        function test_binarized(this)
            ic = this.testObj;
            warning('off', 'mlfourd:possibleMaskingError')
            ic = ic.binarized;
            warning('on', 'mlfourd:possibleMaskingError');
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NumericalNIfTIdState');
            n = ic.niftid;
            this.verifyEqual(n.bitpix, 64);
            this.verifyEqual(n.datatype, 64);
            this.verifyEqual(n.entropy, 0.856561563380557, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(n.img))), 1, 'RelTol', 1e-8);
            this.verifyEqual(min(min(min(n.img))), 0, 'RelTol', 1e-8);
            this.verifyEqual(dipmedian(n),  1, 'RelTol', 1e-8);
            this.verifyEqual(n.orient, 'RADIOLOGICAL');
            this.verifyEqual(n.mmppix, [2.003313064575195   2.003313064575195   2.424999952316284], 'RelTol', 1e-8);
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.size, [128 128 63]);
            if (this.view)
                ic.view;
            end
        end
        function test_blurred(this)
            ic = this.testObj;
            ic = ic.blurred([20 10 5]);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NumericalNIfTIdState');
            n = ic.niftid;
            this.verifyEqual(n.bitpix, 32);
            this.verifyEqual(n.datatype, 16);
            this.verifyEqual(n.entropy, 2.37397311238268, 'RelTol', 1e-8);
            this.verifyEqual(dipmedian(n), 2.688815116882324, 'RelTol', 1e-8);
            this.verifyEqual(n.orient, 'RADIOLOGICAL');
            this.verifyEqual(n.mmppix, [2.003313064575195   2.003313064575195   2.424999952316284], 'RelTol', 1e-8);
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.size, [128 128 63]);            
            if (this.view)
                ic.view;
            end
        end
        function test_close(this)
            fqfn = fullfile(this.registry.fslPath, 'Test_ImagingContext.test_close.nii.gz');
            this.testObj.fqfn = fqfn;
            cached = this.testObj;
            
            this.testObj.save;
            this.testObj.close;
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.FilenameState');
            this.verifyTrue(lexist(fqfn));
            ic = mlfourd.ImagingContext.load(fqfn);
            this.verifyEqual(ic.niftid.fqfn, cached.fqfn);
        end
        function test_masked(this)
            ic = this.testObj;            
            ic = ic.masked(this.maskT1_niid);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NumericalNIfTIdState');
            n = ic.niftid;
            this.verifyEqual(n.bitpix, 64);
            this.verifyEqual(n.datatype, 64);
            this.verifyEqual(n.entropy, 0.637515188367567, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(n.img))), 644, 'RelTol', 1e-8);
            this.verifyEqual(dipmedian(n),  0, 'RelTol', 1e-8);
            this.verifyEqual(n.orient, 'RADIOLOGICAL');
            this.verifyEqual(n.mmppix, [2.003313064575195   2.003313064575195   2.424999952316284], 'RelTol', 1e-8);
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.size, [128 128 63]);
            if (this.view)
                ic.view;
            end
        end
        function test_maskedByZ(this)
            ic = this.testObj;            
            ic = ic.maskedByZ([30 60]);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NumericalNIfTIdState');
            n = ic.niftid;
            this.verifyEqual(n.bitpix, 64);
            this.verifyEqual(n.datatype, 64);
            this.verifyEqual(n.entropy, 0.93319705894137, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(n.img))), 524, 'RelTol', 1e-8);
            this.verifyEqual(dipmedian(n),  0, 'RelTol', 1e-8);
            this.verifyEqual(n.orient, 'RADIOLOGICAL');
            this.verifyEqual(n.mmppix, [2.003313064575195   2.003313064575195   2.424999952316284], 'RelTol', 1e-8);
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.size, [128 128 63]);
            if (this.view)
                ic.view;
            end
        end
        function test_rm(this)
            import mlfourd.*;
            niid1 = this.testObjs.get(1);
            for r = this.testObjs.length:-1:2
                this.testObjs.rm(r);
                stc = this.testObjs.stateTypeclass;
                this.verifyEqual(stc, 'mlfourd.NIfTIcState');
            end
            stc = this.testObjs.stateTypeclass;
            this.verifyEqual(stc, 'mlfourd.NIfTIcState');
            this.verifyEqual(this.testObjs.niftid, niid1.niftid);
        end
        function test_save(this)
            import mlfourd.*;
            ic = ImagingContext(NIfTId(this.testthis_fqfn));
            this.verifyEqual(ic.fqfilename, this.testthis_fqfn);
            this.verifyError(@ic.save, 'mlfourd:saveError');
            this.verifyFalse(lexist(this.testthis_fqfn, 'file'));
            
            ic = ImagingContext(NIfTId(magic(2), 'fqfilename', this.testthis_fqfn));
            this.verifyEqual(ic.fqfilename, this.testthis_fqfn);
            ic.save;
            this.verifyTrue(lexist(this.testthis_fqfn, 'file'));
        end
        function test_saveasThenClose(this)
            import mlfourd.*;            
            ic = this.testObj;
            ic.saveas(this.testthis_fqfn);
            this.verifyEqual(ic.fqfn, this.testthis_fqfn);
            this.verifyTrue(lexist(this.testthis_fqfn, 'file'));
            ic.close;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.FilenameState');            
            this.deleteFiles;
        end
        function test_saveasNIfTIcState(this)
            ic = this.testObjs;
            this.verifyWarning(@() ic.saveas('Test_ImagingContext_'), 'mlfourd:ambiguousCompositeRequest');
            this.verifyEqual(ic.fqfn, this.testthis_fqfns);
            cellfun(@(x) this.verifyTrue(lexist(x, 'file')), this.testthis_fqfns);  
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIcState');  
            this.deleteFiles;
        end
        function test_saveasManyNIfTIcState(this)
            ic = this.testObjs;
            ic.saveas(this.testthis_fqfns);
            this.verifyEqual(ic.fqfn, this.testthis_fqfns);
            cellfun(@(x) this.verifyTrue(lexist(x, 'file')), this.testthis_fqfns);  
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIcState');  
            this.deleteFiles;
        end
        function test_saveasFilenameState(this)
            ic = mlfourd.ImagingContext.load(this.smallT1_fqfn);
            ic.saveas(this.testthis_fqfn);
            this.verifyEqual(ic.fqfn, this.testthis_fqfn);
            this.verifyTrue(lexist(this.testthis_fqfn, 'file'));
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.FilenameState');   
            this.deleteFiles;
        end
        function test_saveasDoubleState(this)
            ic = mlfourd.ImagingContext(magic(10));
            ic.saveas(this.testthis_fqfn);
            this.verifyEqual(ic.fqfn, this.testthis_fqfn);
            this.verifyTrue(lexist(this.testthis_fqfn, 'file'));
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState'); 
            this.deleteFiles;  
        end
        function test_thresh(this)
            ic  = mlfourd.ImagingContext(this.maskT1_niid);            
            ic  = ic.thresh(0.5);
            ic  = ic.binarized;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NumericalNIfTIdState');
            this.verifyEqual(ic.niftid.img, double(this.maskT1_niid.img));
        end
        function test_threshp(this)
            ic = mlfourd.ImagingContext(this.maskT1_niid);            
            ic = ic.threshp(50);
            ic = ic.binarized;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NumericalNIfTIdState');
            this.verifyEqual(ic.niftid.img, double(this.maskT1_niid.img));
        end
        function test_timeSummed(this)
            import mlfourd.*;
            ic = ImagingContext(this.dynamic);
            n  = ic.numericalNiftid;
            this.verifyEqual(n.rank, 4);
            this.verifyEqual(n.entropy, 0.998338839919038, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(max(n.img)))), int16(9386), 'RelTol', 1e-8);
            this.verifyEqual(dipmedian(n), 7, 'RelTol', 1e-8);
            
            ic = ic.timeSummed;
            n  = ic.numericalNiftid;
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.entropy, 0.944750979221247, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(n.img))), single(30620), 'RelTol', 1e-8);
            this.verifyEqual(dipmedian(n),  583, 'RelTol', 1e-8);
            if (this.view)
                n.view(this.testObj);
            end
        end
        function test_volumeSummed(this)
            import mlfourd.*;
            ic = ImagingContext(this.dynamic);
            d  = ic.numericalNiftid;
            this.verifyEqual(d.rank, 4);
            this.verifyEqual(d.entropy, 0.998338839919038, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(max(d.img)))), int16(9386), 'RelTol', 1e-8);
            this.verifyEqual(dipmedian(d), 7, 'RelTol', 1e-8);
            
            ic2 = ic.volumeSummed;
            d   = ic2.numericalNiftid;
            this.verifyEqual(d.rank, 2);
            this.verifyEqual(d.entropy, 0, 'RelTol', 1e-8);
            this.verifyEqual(max(d.img), single(460087520), 'RelTol', 1e-8);
            this.verifyEqual(dipmedian(d), 24437700, 'RelTol', 1e-8);
            e   = ic.numericalNiftid;
            this.verifyEqual(e.rank, 4);
            this.verifyEqual(e.entropy, 0.998338839919038, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(max(e.img)))), int16(9386), 'RelTol', 1e-8);
            this.verifyEqual(dipmedian(e), 7, 'RelTol', 1e-8);
            if (this.view)
                d.view(this.testObj);
            end
        end
    end

 	methods (TestClassSetup)
 		function setupImagingContext(this)
            import mlfourd.*;
            this.registry = UnittestRegistry.instance('initialize');
            this.registry.sessionFolder = 'mm01-007_p7686_2010aug20';
            this.imagingContext_  = ImagingContext(this.smallT1_niid);
            this.imagingContexts_ = ImagingContext(this.niftic);
            cd(fullfile(this.registry.sessionPath, 'fsl', ''));
 		end
 	end

 	methods (TestMethodSetup)
        function setupTest(this)
            this.deleteFiles;
            this.testObj  = this.imagingContext_.clone;
            this.testObjs = this.imagingContexts_.clone;            
            this.addTeardown(@this.deleteFiles);
        end
    end
    
    %% PRIVATE
    
    properties (Access = private)
        imagingContext_
        imagingContexts_
    end
    
    methods (Access = 'private')
        function verifyIC(this, ic, e, m, fp)
            this.assumeInstanceOf(ic, 'mlfourd.ImagingContext');
            this.verifyEqual(ic.niftid.entropy, e, 'RelTol', 1e-6);
            this.verifyEqual(dipmad(ic.niftid.img), m, 'RelTol', 1e-4);
            this.verifyEqual(ic.fileprefix, fp); 
        end
        function verifyNiftid(this, niid, e, m, fp)
            this.assumeInstanceOf(niid, 'mlfourd.INIfTI');
            this.verifyEqual(niid.entropy, e, 'RelTol', 1e-6);
            this.verifyEqual(dipmad(niid), m, 'RelTol', 1e-4);
            this.verifyEqual(niid.fileprefix, fp); 
        end
        function deleteFiles(this)
            p = this.registry.pnum;
            deleteExisting2(fullfile(this.registry.sessionPath, 'fsl', 'Test_ImagingContext*'));
            deleteExisting2(fullfile(this.registry.petPath, [p 'ho1_frames'], 'Test_ImagingContext*'));
            deleteExisting2(fullfile(this.registry.petPath, [p 'oo1_frames'], 'Test_ImagingContext*'));
            deleteExisting2(fullfile(this.registry.petPath, [p 'oc1_frames'], 'Test_ImagingContext*'));
            deleteExisting2(fullfile(this.registry.petPath, [p 'tr1_frames'], 'Test_ImagingContext*'));
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

