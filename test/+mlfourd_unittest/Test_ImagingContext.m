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
            g = fullfile(this.registry.petPath, [this.registry.pnum 'oc1_frames'], [this.registry.pnum 'oc_03.nii.gz']);
        end
        function g = get.tr_fqfn(this)            
            g = fullfile(this.registry.petPath, [this.registry.pnum 'tr1_frames'], [this.registry.pnum 'tr_01.nii.gz']);
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
            g = fullfile(this.registry.sessionPath, 'fal', 'Test_ImagingContext.nii.gz');
        end
        function g = get.testthis_fqfns(this)
            g = {fullfile(this.registry.sessionPath, 'fal', 'Test_ImagingContext1.nii.gz') ...
                 fullfile(this.registry.sessionPath, 'fal', 'Test_ImagingContext2.nii.gz') ...
                 fullfile(this.registry.sessionPath, 'fal', 'Test_ImagingContext3.nii.gz')};
        end
    end

	methods (Test)
        
        %% properties
        
        function test_filename(this)
            [p,f,e] = myfileparts(this.smallT1_fqfn);
            this.verifyEqual(this.testObj.filename, [f e]);
            this.testObj.filename = 'test_filename';
            this.verifyEqual(this.testObj.filename, fullfile(p, ['test_filename' e]));
        end
        function test_filepath(this)
            pwd0 = pwd;
            [p,f,e] = myfileparts(this.smallT1_fqfn);
            this.verifyEqual(this.testObj.fqfn, p);
            this.testObj.filepath = '/tmp';            
            this.verifyEqual(this.testObj.fqfn, fullfile('/tmp', [f e]));
            this.verifyEqual(pwd, pwd0);
        end
        function test_fileprefix(this)
            [p,f,e] = myfileparts(this.smallT1_fqfn);
            this.verifyEqual(this.testObj.fqfn, f);
            this.testObj.fileprefix = 'test_fileprefix';
            this.verifyEqual(this.testObj.fqfn, fullfile(p, ['test_fileprefix' e]));
        end
        function test_filesuffix(this)
            [p,f] = myfileparts(this.smallT1_fqfn);
            this.verifyEqual(this.testObj.fqfn, e);
            this.testObj.filesuffix = '.test';
            this.verifyEqual(this.testObj.fqfn, fullfile(p, [f '.test']));
        end
        function test_fqfilename(this)
            this.verifyEqual(this.testObj.fqfn, this.smallT1_fqfn);
            this.testObj.fqfilename = '/tmp/test_fqfilename.test';            
            this.verifyEqual(this.testObj.fqfn, fullfile('tmp', 'test_fqfilename.test'));
        end
        function test_stateTypeclass(this)
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.NIfTIdState');
            this.testObj.composite;
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.ImagingCompositeState');
            this.testObj.mgh;
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.MGHState');
            this.testObj.nifti;
            this.verifyEqual(this.testObj.stateTypeclass, 'mlfourd.NIfTIState');
        end
        
        %% query methods
        
        function test_char(this)
            this.verifyEqual(char(this.testObj),           this.imagingContext_.fqfilename);
            this.verifyEqual(char(this.testObj.composite), this.imagingContext_.fqfilename);
            this.verifyEqual(char(this.testObj.mgh),       this.imagingContext_.fqfilename);
            this.verifyEqual(char(this.testObj.nifti),     this.imagingContext_.fqfilename);
        end
        function test_double(this)
            this.verifyEqual(double(this.testObj),           this.imagingContext_.img);
            this.verifyEqual(double(this.testObj.composite), this.imagingContext_.img);
            this.verifyEqual(double(this.testObj.mgh),       this.imagingContext_.img);
            this.verifyEqual(double(this.testObj.nifti),     this.imagingContext_.img);
        end
        function test_get(this)
            this.verifyEqual(get(this.testObj, 1), this.smallT1_niid);
        end
        function test_length(this)
            this.verifyEqual(length(this.testObj), 1);
        end
          
        %% factory methods
        
        function test_ctor_NIfTId(this)
            import mlfourd.*;
            ic = ImagingContext(this.smallT1_niid);
            this.verifyEqual('mlfourd.NIfTIdState', ic.stateTypeclass);
            this.verifyEqual(class(ic.niftid), 'mlfourd.NIfTId');
            ic = ImagingContext(this.blurring);
            this.verifyEqual('mlfourd.NIfTIdState', ic.stateTypeclass);
            this.verifyEqual(class(ic.niftid), 'mlfourd.BlurringNIfTId');
            ic = ImagingContext(this.dynamic);
            this.verifyEqual('mlfourd.NIfTIdState', ic.stateTypeclass);
            this.verifyEqual(class(ic.niftid), 'mlfourd.DynamicNIfTId');
            ic = ImagingContext(this.masking);
            this.verifyEqual('mlfourd.NIfTIdState', ic.stateTypeclass);
            this.verifyEqual(class(ic.niftid), 'mlfourd.MaskingNIfTId');
            this.verifyEqual(ic.niftid.component, this.smallT1_niid);
        end
        function test_ctor_NIfTI(this)
            import mlfourd.*;
            ic = ImagingContext(this.smallT1_nii);
            this.verifyEqual('mlfourd.NIfTIState', ic.stateTypeclass);  
            this.verifyEqual(class(ic.nifti), 'mlfourd.NIfTI'); 
            this.verifyEqual(class(ic.niftid), 'mlfourd.NIfTId');
        end
        function test_ctor_MGH(this)
            import mlfourd.*;
            ic = ImagingContext(MGH.load( ...
                fullfile(this.registry.mriPath, 'T1.mgz')));
            this.verifyEqual('mlfourd.MGHState', ic.stateTypeclass);  
            this.verifyEqual(class(ic.mgh), 'mlfourd.MGH'); 
            this.verifyEqual(class(ic.niftid), 'mlfourd.NIfTId');
        end
        function test_ctor_ImagingComposite(this)
            %% TEST_CTOR_IMAGINGCOMPOSITE tests get, remove, add
            import mlfourd.*;
            ic = ImagingContext(this.niftic);
            this.verifyEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
            this.verifyEqual(ic.length, this.niftic.length);
            gotten = ic.get(2);
            this.verifyEqual(gotten, this.niftic.get(2));            
            this.assumeTrue(ic.length > 2);
            ic.remove(1);
            this.verifyEqual(ic.length, this.niftic.length - 1);
            this.verifyEqual(ic.get(1), this.niftic.get(2));
            ic.remove(2);
            this.verifyEqual(ic.length, this.niftic.length - 2);
            this.verifyEqual(ic.get(1), this.niftic.get(3));
            ic.add(gotten);            
            this.verifyEqual(ic.length, this.niftic.length - 1);
            this.verifyEqual(ic.get(ic.length), gotten);            
            this.verifyEqual(class(ic.niftid), 'mlfourd.NIfTId');
        end
        function test_ctor_char(this)
            import mlfourd.*;
            ic = ImagingContext(this.testthis_fqfn);
            this.verifyEqual('mlfourd.FilenameState', ic.stateTypeclass);
            this.verifyEqual(class(ic.niftid), 'mlfourd.NIfTId');
            this.verifyEqual(ic.niftid.fqfn, this.testthis_fqfn);
        end
        function test_ctor_double(this)
            import mlfourd.*;
            ic = ImagingContext(magic(3));            
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.DoubleState');
            this.verifyEqual(class(ic.niftid), 'mlfourd.NIfTId');
            this.verifyEqual(ic.niftid.img, magic(3));
        end     
        function test_ctor_ImagingContext(this)
            ic  = this.testObj;
            ic2 = mlfourd.ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            this.verifyEqual(ic.niftid, ic2.niftid);
            this.verifyFalse(lexist(ic.fqfn, 'file'));
            this.verifyFalse(lexist(ic2.fqfn, 'file'));
        end
        function test_ctor_ImagingContextNIfTId(this)
            import mlfourd.*;
            ic  = ImagingContext(this.smallT1_niid);
            ic2 = ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            this.verifyEqual(ic.niftid, ic2.niftid);
            this.verifyTrue(lexist(ic.fqfn, 'file'));
            this.verifyTrue(lexist(ic2.fqfn, 'file'));
        end
        function test_ctor_ImagingContextNIfTI(this)
            import mlfourd.*;
            ic  = ImagingContext(this.smallT1_nii);
            ic2 = ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            this.verifyEqual(ic.nifti, ic2.nifti);
            this.verifyTrue(lexist(ic.fqfn, 'file'));
            this.verifyTrue(lexist(ic2.fqfn, 'file'));
        end
        function test_ctor_ImagingContextImagingComposite(this)
            import mlfourd.*;
            ic  = ImagingContext(this.niftic);
            ic2 = ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            for c = 1:ic2.length
                this.verifyEqual(ic.composite{c}, ic2.composite{c});
                this.verifyTrue(lexist(ic.composite{c}.fqfn, 'file'));
                this.verifyTrue(lexist(ic2.composite{c}.fqfn, 'file'));
            end
        end
        function test_ctor_ImagingContextChar(this)
            import mlfourd.*;
            ic  = ImagingContext(this.testthis_fqfn);
            ic2 = ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            this.verifyEqual(ic.fqfn, ic2.fqfn);
            this.verifyFalse(lexist(ic.fqfn, 'file'));
            this.verifyFalse(lexist(ic2.fqfn, 'file'));
        end
        function test_ctor_ImagingContextDouble(this)
            import mlfourd.*;
            ic  = ImagingContext(magic(3), 'fqfilename', this.testthis_fqfn);
            ic2 = ImagingContext(ic);
            this.verifyNotSameHandle(ic, ic2);
            this.verifyEqual(ic.double, ic2.double);
            this.verifyFalse(lexist(ic.fqfn, 'file'));
            this.verifyFalse(lexist(ic2.fqfn, 'file'));
        end        
        function test_clone(this)
            import mlfourd.*;            
            
            ic00 = ImagingContext(this.ep2dMean_fqfn);
            
            ic0 = ImagingContext(ic00);
            ic  = ic0.clone;
            ic.filename = 'anotherFilename.nii.gz';
            this.verifyNotSameHandle(ic, ic0);
            this.verifyTrue(strcmp(ic0.fqfn, this.ep2dMean_fqfn));
            
            ic0 = ImagingContext(this.niftic);
            ic  = ic0.clone;
            ic.filename = 'anotherFilename.nii.gz';
            this.verifyNotSameHandle(ic, ic0);
            this.verifyTrue(strcmp(ic0.fqfn, this.niftic.fqfn));
            
            ic0 = ImagingContext(this.smallT1_niid);
            ic  = ic0.clone;
            ic.filename = 'anotherFilename.nii.gz';
            this.verifyNotSameHandle(ic, ic0);
            this.verifyTrue(strcmp(ic0.fqfn, this.smallT1_niid.fqfn));
            
            ic0  = ImagingContext(this.smallT1_nii);
            ic  = ic0.clone;
            ic.filename = 'anotherFilename.nii.gz';
            this.verifyNotSameHandle(ic, ic0);
            this.verifyTrue(strcmp(ic0.fqfn, this.smallT1_nii.fqfn));            
            
            ic0 = ImagingContext(this.ep2dMean_fqfn);
            ic  = ic0.clone;
            ic.filename = 'anotherFilename.nii.gz';
            this.verifyNotSameHandle(ic, ic0);
            this.verifyTrue(strcmp(ic0.fqfn, this.ep2dMean_fqfn));
            
            ic0 = ImagingContext(magic(3));
            ic  = ic0.clone;
            ic.double = magic(4);
            this.verifyNotSameHandle(ic, ic0);
            this.verifyEqual(ic0.img, magic(3));
        end           
        function test_load(this)
            import mlfourd.*;            
            ic = ImagingContext.load(this.smallT1_fqfn);
            this.verifyEqual('mlfourd.FilenameState', ic.stateTypeclass);
            this.verifyEqual(ic.niftid, this.smallT1_niid);
            
            ic = ImagingContext.load(this.pet_fqfns);
            this.verifyEqual('mlfourd.ImagingComponentState', ic.stateTypeclass);
            this.verifyEqual(ic.composite, this.niftic);
        end
        
        %% state changes
        
        function test_add(this)
            import mlfourd.*;
            niid = this.smallT1_niid.makeSimilar('fileprefix', 'Test_ImagingContext_test_add');
            ic = this.testObj;
            ic.add(niid);
            this.verifyTrue(ic.stateTypeclass, 'mlfourd.ImagingComponentState');
            this.verifyEqual(ic.get(1), this.smallT1_niid);
            this.verifyEqual(ic.get(2), niid);
            ic.remove(2);
            this.verifyTrue(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            this.verifyEqual(ic.niftid, this.smallT1_niid);
            if (getenv('VERBOSE'))
                ic.view(this.testObj);
            end
        end
        function test_atlas(this)
            import mlfourd.*;
            ic = ImagingContext(this.niftic);
            ic.atlas;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            n = ic.niftid;
            this.verifyNiftid(n, nan, nan, '');
            this.verifyEqual(n.orient, '');
            this.verifyEqual(n.mmmpix, []);
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.size, []);
            if (getenv('VERBOSE'))
                ic.view(this.testObj);
            end
        end
        function test_binarized(this)
            ic  = this.testObj;            
            ic.binarized;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            n = ic.niftid;
            this.verifyEqual(n.bitpix, 32);
            this.verifyEqual(n.datatype, 16);
            this.verifyEqual(n.entropy, nan, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(n.img))), 1, 'RelTol', 1e-8);
            this.verifyEqual(dipsum(n),  nan, 'RelTol', 1e-8);
            this.verifyEqual(n.orient, '');
            this.verifyEqual(n.mmmpix, []);
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.size, []);
            if (getenv('VERBOSE'))
                ic.view(this.testObj);
            end
        end
        function test_blurred(this)
            ic  = this.testObj;
            
            ic.blurred;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            n = ic.niftid;
            this.verifyEqual(n.countBlurred, 1);
            this.verifyEqual(n.bitpix, 32);
            this.verifyEqual(n.datatype, 16);
            this.verifyEqual(n.entropy, nan, 'RelTol', 1e-8);
            this.verifyEqual(dipsum(n),  nan, 'RelTol', 1e-8);
            this.verifyEqual(n.orient, '');
            this.verifyEqual(n.mmmpix, []);
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.size, []);
            if (getenv('VERBOSE'))
                ic.view(this.testObj);
            end
            
            ic.blurred([16 16 16]);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            n = ic.niftid;
            this.verifyEqual(n.countBlurred, 2);
            this.verifyEqual(n.bitpix, 32);
            this.verifyEqual(n.datatype, 16);
            this.verifyEqual(n.entropy, nan, 'RelTol', 1e-8);
            this.verifyEqual(dipsum(n),  nan, 'RelTol', 1e-8);
            this.verifyEqual(n.orient, '');
            this.verifyEqual(n.mmmpix, []);
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.size, []);
            if (getenv('VERBOSE'))
                ic.view(this.testObj);
            end
        end
        function test_masked(this)
            ic = this.testObj;            
            ic.masked(this.maskT1_niid);
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            n = ic.niftid;
            this.verifyEqual(n.bitpix, 32);
            this.verifyEqual(n.datatype, 16);
            this.verifyEqual(n.entropy, nan, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(n.img))), nan, 'RelTol', 1e-8);
            this.verifyEqual(dipsum(n),  nan, 'RelTol', 1e-8);
            this.verifyEqual(n.orient, '');
            this.verifyEqual(n.mmmpix, []);
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.size, []);
            if (getenv('VERBOSE'))
                ic.view(this.testObj);
            end
        end
        function test_threshp(this)
            ic = mlfourd.ImagingContext(this.maskT1_niid);            
            ic.threshp(50);
            ic.binarized;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            this.verifyEqual(ic.niftid, this.maskT1_niid);
        end
        function test_remove(this)
            import mlfourd.*;
            imc = this.niftic.clone;
            for r = this.niftic.length:-1:2
                removed = imc.remove(r);
                this.verifyTrue(imc.stateTypeclass, 'mlfourd.ImagingComponentState');
                this.verifyEqual(removed, this.niftic.get(r));          
            end
            this.verifyTrue(imc.stateTypeclass, 'mlfourd.NIfTIdState');
            this.verifyEqual(imc.niftid, this.niftic.get(1));
        end
        function test_save(this)
            ic = NIfTId('fqfilename', this.testthis_fqfn);
            ic.save;
            this.verifyEqual(ic.fqfilename, this.testthis_fqfn);
            this.verifyTrue(lexist(this.testthis_fqfn, 'file'));
        end
        function test_saveas(this)
            import mlfourd.*;            
            ic = this.testObj;
            ic.saveas(this.testthis_fqfn);
            this.verifyEqual(ic.fqfn, this.testthis_fqfn);
            this.verifyTrue(lexist(this.testthis_fqfn, 'file'));
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.FilenameState');            
            deleteExisting(this.testthis_fqfn);
            
            ic = this.niftic.clone;
            ic.saveas(this.testthis_fqfns);
            this.verifyEqual(ic.fqfn, this.testthis_fqfns);
            cellfun(@(x) this.verifyTrue(lexist(x, 'file')), this.testthis_fqfns);  
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.ImagingComponentState');          
            cellfun(@(x) deleteExisting(x), this.testthis_fqfns);
            
            ic = ImagingContext.load(this.smallT1_fqfn);
            ic.saveas(this.testthis_fqfn);
            this.verifyEqual(ic.fqfn, this.testthis_fqfn);
            this.verifyTrue(lexist(this.testthis_fqfn, 'file'));
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.FilenameState');            
            deleteExisting(this.testthis_fqfn);
            
            ic = ImagingContext(magic(10));
            ic.saveas(this.testthis_fqfn);
            this.verifyEqual(ic.fqfn, this.testthis_fqfn);
            this.verifyTrue(lexist(this.testthis_fqfn, 'file'));
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.DoubleState');            
            deleteExisting(this.testthis_fqfn);
        end
        function test_summed(this)
            import mlfourd.*;
            ic = this.niftic.clone;
            ic.summed;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            n = ic.niftid;
            this.verifyEqual(n.bitpix, 32);
            this.verifyEqual(n.datatype, 16);
            this.verifyEqual(n.entropy, nan, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(n.img))), nan, 'RelTol', 1e-8);
            this.verifyEqual(dipsum(n),  nan, 'RelTol', 1e-8);
            this.verifyEqual(n.orient, '');
            this.verifyEqual(n.mmmpix, []);
            this.verifyEqual(n.rank, 3);
            this.verifyEqual(n.size, []);
            if (getenv('VERBOSE'))
                ic.view(this.testObj);
            end
        end
        function test_thresh(this)
            ic  = mlfourd.ImagingContext(this.maskT1_niid);            
            ic.thresh(0.5);
            ic.binarized;
            this.verifyEqual(ic.stateTypeclass, 'mlfourd.NIfTIdState');
            this.verifyEqual(ic.niftid, this.maskT1_niid);
        end
        function test_timeSummed(this)
            import mlfourd.*;
            d = this.dynamic;
            this.verifyEqual(d.rank, 4);
            this.verifyEqual(d.entropy, nan, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(max(d.img)))), nan, 'RelTol', 1e-8);
            this.verifyEqual(dipsum(d),  nan, 'RelTol', 1e-8);
            d.timeSummed;
            this.verifyEqual(d.rank, 3);
            this.verifyEqual(d.entropy, nan, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(d.img))), nan, 'RelTol', 1e-8);
            this.verifyEqual(dipsum(d),  nan, 'RelTol', 1e-8);
            if (getenv('VERBOSE'))
                d.view(this.testObj);
            end
        end
        function test_volumeSummed(this)
            import mlfourd.*;
            d = this.dynamic;
            this.verifyEqual(d.rank, 4);
            this.verifyEqual(d.entropy, nan, 'RelTol', 1e-8);
            this.verifyEqual(max(max(max(max(d.img)))), nan, 'RelTol', 1e-8);
            this.verifyEqual(dipsum(d),  nan, 'RelTol', 1e-8);
            d.volumeSummed;
            this.verifyEqual(d.rank, 1);
            this.verifyEqual(d.entropy,  nan, 'RelTol', 1e-8);
            this.verifyEqual(max(d.img), nan, 'RelTol', 1e-8);
            this.verifyEqual(dipsum(d),   nan, 'RelTol', 1e-8);
            if (getenv('VERBOSE'))
                d.view(this.testObj);
            end
        end
    end

 	methods (TestClassSetup)
 		function setupImagingContext(this)
            import mlfourd.*;
            this.registry = UnittestRegistry.instance;
            this.registry.sessionFolder = 'mm01-007_p7686_2010aug20';
            this.imagingContext_ = ImagingContext(this.smallT1_niid);
 		end
 	end

 	methods (TestMethodSetup)
        function setupTest(this)
            this.testObj = mlfourd.ImagingContext(this.imagingContext_);
            deleteExisting(this.testthis_fqfn);
        end
    end
    
    %% PRIVATE
    
    properties (Access = private)
        imagingContext_
    end
    
    methods (Access = 'private')
        function verifyNiftid(this, niid, e, m, fp)
            this.assumeInstanceOf(niid, 'mlfourd.INIfTI');
            this.verifyEqual(niid.entropy, e, 'RelTol', 1e-6);
            this.verifyEqual(dipmad(niid), m, 'RelTol', 1e-4);
            this.verifyEqual(niid.fileprefix, fp); 
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

