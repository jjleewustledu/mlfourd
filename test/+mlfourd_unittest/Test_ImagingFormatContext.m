classdef Test_ImagingFormatContext < matlab.unittest.TestCase
	%% TEST_IMAGINGFORMATCONTEXT 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImagingFormatContext)
 	%          >> result  = run(mlfourd_unittest.Test_ImagingFormatContext, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 24-Jul-2018 01:23:51 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
        doview = true
        doview_mutate = true % slow
        noDelete = false
        pwd0
        ref
 		registry
 		testObj
    end
    
    properties (Dependent)
        dataDir
        TmpDir
    end

    methods
        
        %% GET/SET
        
        function g = get.dataDir(~)
            g = fullfile(getenv('HOME'), 'MATLAB-Drive/mlfourdfp/data', '');
        end
        function g = get.TmpDir(~)
            g = fullfile(getenv('HOME'), 'Tmp', '');
        end
    end
    
	methods (Test)
        function test_ctorAndSaveas(this)            
            pwd0_ = pushd(this.TmpDir);
            
            %% orig has center/mmppix
            
%             ifc = mlfourd.ImagingFormatContext(fullfile(this.dataDir, 'fdgcent.4dfp.hdr'));
%             ifc.saveas(fullfile(this.TmpDir, 'fdgcent_dbg.4dfp.hdr'));
%             ifh = mlfourdfp.IfhParser.load(fullfile(this.TmpDir, 'fdgcent_dbg.4dfp.ifh'), 'N', false);
%             this.verifyEqual(ifc.imagingInfo.ifh.mmppix, [2.0863   -2.0863   -2.0312], 'RelTol', 1e-4);
%             this.verifyEqual(ifc.imagingInfo.ifh.center, [179.4184 -181.5046 -130.0000], 'RelTol', 1e-6);            
%             this.verifyEqual(ifc.imagingInfo.ifh.center, ifh.center, 'RelTol', 1e-6);            
%             if (this.doview)
%                 mlbash(sprintf('fsleyes %s/fdgcent.4dfp.img fdgcent_dbg.4dfp.img', this.dataDir));
%             end

            ifc = mlfourd.ImagingFormatContext(fullfile(this.dataDir, 'fdgcent.4dfp.hdr'));
            ifc.saveas(fullfile(this.TmpDir, 'fdgcent_dbg.4dfp.hdr'));
            ifh = mlfourdfp.IfhParser.load(fullfile(this.TmpDir, 'fdgcent_dbg.4dfp.ifh'), 'N', true); 
            this.verifyEqual(ifc.imagingInfo.ifh.mmppix, [], 'RelTol');
            this.verifyEqual(ifc.imagingInfo.ifh.center, [], 'RelTol');
            this.verifyEmpty(ifh.center); 
            if (this.doview)
                mlbash(sprintf('fsleyes %s/fdgcent.4dfp.img fdgcent_dbg.4dfp.img', this.dataDir));
            end
            
            %% orig has no center/mmppix

%             ifc = mlfourd.ImagingFormatContext(fullfile(this.dataDir, 'fdgnocent.4dfp.hdr'));
%             ifc.saveas(fullfile(this.TmpDir, 'fdgnocent_dbg.4dfp.hdr'));
%             ifh = mlfourdfp.IfhParser.load(fullfile(this.TmpDir, 'fdgnocent_dbg.4dfp.ifh'), 'N', false);
%             this.verifyEmpty(ifc.imagingInfo.ifh.mmppix);
%             this.verifyEmpty(ifc.imagingInfo.ifh.center);
%             this.verifyEmpty(ifh.center);          
%             if (this.doview)
%                 mlbash(sprintf('fsleyes %s/fdgnocent.4dfp.img fdgnocent_dbg.4dfp.img', this.dataDir));
%             end
            
            ifc = mlfourd.ImagingFormatContext(fullfile(this.dataDir, 'fdgnocent.4dfp.hdr'));
            ifc.saveas(fullfile(this.TmpDir, 'fdgnocent_dbg.4dfp.hdr'));
            ifh = mlfourdfp.IfhParser.load(fullfile(this.TmpDir, 'fdgnocent_dbg.4dfp.ifh'), 'N', true);
            this.verifyEmpty(ifc.imagingInfo.ifh.mmppix);
            this.verifyEmpty(ifc.imagingInfo.ifh.center);
            this.verifyEmpty(ifh.center); 
            if (this.doview)
                mlbash(sprintf('fsleyes %s/fdgnocent.4dfp.img fdgnocent_dbg.4dfp.img', this.dataDir));
            end
            
            popd(pwd0_);
        end
        function test_copy(this)
 			import mlfourd.*;
            niih_ = ImagingFormatContext(this.ref.dicomAsNiigz); 
            same  = niih_;
            this.verifySameHandle(same, niih_);
            diff  = copy(niih_);
            this.verifyNotSameHandle(diff, niih_);
        end    
        function test_ctor_trivial(this)
            import mlfourd.*;
            ifc = ImagingFormatContext;
            this.verifyClass(ifc.imagingInfo, 'mlfourd.NIfTIInfo');
            this.verifyEqual(ifc.innerTypeclass, 'mlfourd.InnerNIfTI');
            
            ifc = ImagingFormatContext(1);
            this.verifyClass(ifc.imagingInfo, 'mlfourd.NIfTIInfo');
            this.verifyEqual(ifc.innerTypeclass, 'mlfourd.InnerNIfTI');
            
            ifc = ImagingFormatContext(sprintf('nonexistentfile_D%s.4dfp.hdr', datestr(now,30)));
            this.verifyTrue(~lexist(ifc.fqfilename, 'file'));
            this.verifyClass(ifc.imagingInfo, 'mlfourdfp.FourdfpInfo');
            this.verifyEqual(ifc.innerTypeclass, 'mlfourdfp.InnerFourdfp');            
        end
        function test_ctor_noExtension(this)
            import mlfourd.*;
            ifc = ImagingFormatContext(myfileprefix(this.ref.dicomAsNiigz));
            this.verifyEqual(class(ifc.img), 'single');
            this.verifyEqual(ifc.size, [176 248 256]);
            this.verifyEqual(ifc.filesuffix, '.nii.gz');
            this.verifyClass(ifc.imagingInfo, 'mlfourd.NIfTIInfo');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_ctor_noExtension'));
            ifc.saveas([tmp '.nii.gz']);
            this.verifyTrue(lexist([tmp '.nii.gz'], 'file'));
            this.deleteExisting([tmp '.nii*']);
            if (this.doview); ifc.fsleyes; end
        end      
        function test_ctor_NIfTId(this)
 			import mlfourd.*;       
            niid = NIfTId(this.ref.dicomAsNiigz);
            niih = ImagingFormatContext(niid);
            
            this.verifyEqual(niih.hdr, niid.hdr);
            this.verifyEqual(niih.img, niid.img);
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(niih.size, [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            this.verifyClass(niih.imagingInfo, 'mlfourd.NIfTIInfo');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_ctor_NIfTId'));
            niih.saveas([tmp '.nii.gz']);
            this.verifyTrue(lexist([tmp '.nii.gz'], 'file'));
            this.deleteExisting([tmp '.nii*']);
            if (this.doview); niih.fsleyes; end
        end  
        function test_ctor_t1niigz(this) 
 			import mlfourd.*;           
            niih = ImagingFormatContext(this.ref.dicomAsNiigz); 
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            this.verifyClass(niih.imagingInfo, 'mlfourd.NIfTIInfo');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_ctor_t14dfp(this)
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.dicomAsFourdfp); % sagittal            
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            this.verifyClass(niih.imagingInfo, 'mlfourdfp.FourdfpInfo');   
               
            if (this.doview); niih.fsleyes; end 
            niih.saveas('test_ctor_t14dfp.4dfp.hdr');
            mlbash('fsleyes test_ctor_t14dfp.4dfp.hdr');
            deleteExisting('test_ctor_t14dfp.4dfp.hdr');
        end
        function test_ctor_001mgz(this)
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.surferAsMgz); % sagittal            
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [248 256 176]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            this.verifyClass(niih.imagingInfo, 'mlsurfer.MGHInfo');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_ctor_001mgz'));
            niih.saveas([tmp '.mgz']);
            this.verifyTrue(lexist([tmp '.mgz'], 'file'));
            this.deleteExisting([tmp '.mgz']);
            if (this.doview); niih.freeview; end
        end
        function test_ctor_001niigz(this)
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.surferAsNiigz); % sagittal            
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [248 256 176]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            this.verifyClass(niih.imagingInfo, 'mlfourd.NIfTIInfo');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_ctor_001niigz'));
            niih.saveas([tmp '.nii.gz']);
            this.verifyTrue(lexist([tmp '.nii.gz'], 'file'));
            this.deleteExisting([tmp '.nii*']);
            if (this.doview); niih.fsleyes; end
        end
        function test_ctor_0014dfp(this) 
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.surferAsFourdfp); % sagittal            
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            this.verifyClass(niih.imagingInfo, 'mlfourdfp.FourdfpInfo');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_ctor_0014dfp'));
            niih.saveas([tmp '.4dfp.hdr']);
%            niih.saveas([tmp '.4dfp.hdr']);
            this.verifyTrue(lexist_4dfp(tmp, 'file'));
            niih.fsleyes;
            if (this.doview)
                mlbash(sprintf('fsleyes %s.4dfp.hdr', tmp)); 
            end
            this.deleteExisting([tmp '.4dfp.*']);
        end
        function test_ctor_ana001(this) 
 			import mlfourd.*;
            niih = ImagingFormatContext('ana001.hdr', 'circshiftK', 0, 'N', false); % sagittal            
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.hdr');
            
            if (this.doview); niih.fsleyes; end            
        end
        function test_ctor_T1mgz(this)
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.T1AsMgz);
            this.verifyEqual(class(niih.img), 'uint8');
            this.verifyEqual(size(niih.img),  [256 256 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            this.verifyClass(niih.imagingInfo, 'mlsurfer.MGHInfo');
            
            if (this.doview); niih.freeview; end
        end
        function test_ctor_T1niigz(this)
 			import mlfourd.*;            
            niih = ImagingFormatContext(this.ref.T1AsNiigz);
            this.verifyEqual(class(niih.img), 'uint8');
            this.verifyEqual(size(niih.img),  [256 256 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            this.verifyClass(niih.imagingInfo, 'mlfourd.NIfTIInfo');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_ctor_T14dfp(this) 
 			import mlfourd.*;            
            niih = ImagingFormatContext(this.ref.T1AsFourdfp);
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [256 256 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            this.verifyClass(niih.imagingInfo, 'mlfourdfp.FourdfpInfo');
            
            if (this.doview); niih.fsleyes; end
        end        
        function test_ctor_ct4dfp(this)
            if (~lexist_4dfp('ct'))
                copyfile(fullfile(this.dataDir, 'ct.*'));
            end            
 			import mlfourd.*;            
            niih = ImagingFormatContext('ct.4dfp.hdr');
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [512 512 74]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            this.verifyClass(niih.imagingInfo, 'mlfourdfp.FourdfpInfo');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_ctor_fdg4dfp(this)
            if (~lexist_4dfp('fdgv1r1_sumt'))
                copyfile(fullfile(this.dataDir, 'fdgv1r1_sumt.*'));
            end            
 			import mlfourd.*;            
            niih = ImagingFormatContext('fdgv1r1_sumt.4dfp.hdr');
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [172 172 127]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            this.verifyClass(niih.imagingInfo, 'mlfourdfp.FourdfpInfo');
            
            if (this.doview); niih.fsleyes; end
        end            
        function test_mutateInnerImagingFormatByFilesuffix(this) 
            %% starts with this.ref.dicomAsNiigz; calls saveas with '.nii.gz', '.4dfp.hdr'.   
            
            if (~this.doview_mutate); return; end
 			import mlfourd.*;                               
            fpOri = myfileprefix(this.ref.dicomAsNiigz);
            xs = {'.nii.gz' '.4dfp.hdr'};
            
            for ix = 1:length(xs)
                fprintf('test_mutateInnerImagingFormatByFilesuffix:  loading %s%s\n', fpOri, xs{ix});
                ifc_ = ImagingFormatContext([fpOri xs{ix}]);
                mlbash(sprintf('fsleyes %s', ifc_.fqfilename));
                fpTmp = tempFqfilename(fullfile(pwd, 'test_mutateInnerImagingFormatByFilesuffix'));
                for jx = 1:length(xs) 
                    ifc = copy(ifc_);
                    ifc.saveas([fpTmp xs{jx}]);
                    fprintf('test_mutateInnerImagingFormatByFilesuffix:  saving as %s%s\n', fpOri, xs{jx});
                    this.verifyTrue(lexist(ifc.fqfilename, 'file'));
                    mlbash(sprintf('fsleyes %s', ifc.fqfilename));
                end
                this.deleteExisting([fpTmp '.*']);
            end            
        end          
        function test_mutateInnerImagingFormatByFilesuffix_mgz_4dfp(this) 
            %% starts with this.ref.dicomAsNiigz; calls saveas with '.nii.gz', '.mgz', '.4dfp.hdr'.    
            
            if (~this.doview_mutate); return; end
 			import mlfourd.*;                               
            fpOri  = myfileprefix(this.ref.dicomAsNiigz) %#ok<NOPRT>
            fpTmp  = tempFqfilename(fullfile(pwd, 'test_mutateInnerImagingFormatByFilesuffix_mgz_4dfp')); 
            fpTmp_ = tempFqfilename(fullfile(pwd, 'test_mutateInnerImagingFormatByFilesuffix_mgz_4dfp_')); 
            
            % mgz -> 4dfp
            ifc = ImagingFormatContext([fpOri '.mgz']);
            ifc.saveas([fpTmp '.4dfp.hdr']);
            this.verifyEqual(fpTmp, ifc.fqfileprefix);
            mlbash(sprintf('fsleyes %s', ifc.fqfilename));
            
            % 4dfp -> mgz
            ifc_ = ImagingFormatContext(ifc.fqfilename, 'hist', ifc.hdr.hist);
            ifc_.saveas([fpTmp_ '.mgz']);
            this.verifyEqual(fpTmp_, ifc_.fqfileprefix);
            mlbash(sprintf('fsleyes %s', ifc_.fqfilename));
            
            this.deleteExisting([fpTmp '.*']);
            this.deleteExisting([fpTmp_ '.*']);
        end     
        function test_mutateInnerImagingFormatByFilesuffix_T1_mgz_4dfp(this) 
            %% starts with this.ref.dicomAsNiigz; calls saveas with '.nii.gz', '.mgz', '.4dfp.hdr'.   
            
            if (~this.doview_mutate); return; end
 			import mlfourd.*;     
            fpTmp  = tempFqfilename(fullfile(pwd, 'test_mutateInnerImagingFormatByFilesuffix_T1_mgz_4dfp')); 
            fpTmp_ = tempFqfilename(fullfile(pwd, 'test_mutateInnerImagingFormatByFilesuffix_T1_mgz_4dfp_')); 
            
            % mgz -> 4dfp
            ifc = ImagingFormatContext('T1.mgz');
            hist = ifc.hdr.hist;
            %ifc.fsleyes;
            ifc.saveas([fpTmp '.4dfp.hdr']);
            this.verifyEqual(fpTmp, ifc.fqfileprefix);
            %ifc.fsleyes; 
            mlbash(sprintf('fsleyes %s', ifc.fqfilename));        
            
            % 4dfp -> mgz
            ifc_ = ImagingFormatContext(ifc.fqfilename, 'hist', hist);
            %ifc.fsleyes;
            ifc_.saveas([fpTmp_ '.mgz']);
            this.verifyEqual(fpTmp_, ifc_.fqfileprefix);
            %ifc.fsleyes;
            mlbash(sprintf('fsleyes %s', ifc_.fqfilename));
            
            this.deleteExisting([fpTmp '.*']);
            this.deleteExisting([fpTmp_ '.*']);
        end     
        function test_set_filesuffix(this)
            if (~this.doview); return; end
 			import mlfourd.*;                    
            tmp = tempFqfilename(fullfile(pwd, 'test_set_filesuffix'));            
            ifc_ = ImagingFormatContext(this.ref.T1AsMgz);
            
            ifc = copy(ifc_);
            ifc.fqfileprefix = tmp;
            ifc.filesuffix = '.4dfp.hdr';
            ifc.save;
            mlbash(sprintf('fsleyes %s', ifc.filename)); % previously, AP, LR flips incorrect because of public mutateInnerImagingFormatByFilesuffix
            this.deleteExisting([tmp '*']); 
            
            ifc = copy(ifc_);
            ifc.filename = [tmp '.4dfp.hdr'];
            ifc.save;
            mlbash(sprintf('fsleyes %s', ifc.filename)); %  previously, AP, LR flips incorrect because of public mutateInnerImagingFormatByFilesuffix
            this.deleteExisting([tmp '*']); 
            
            ifc = copy(ifc_);
            ifc.saveas([tmp '.4dfp.hdr']);
            mlbash(sprintf('fsleyes %s', ifc.filename)); % ok
            this.deleteExisting([tmp '*']); 
        end
        
        function test_T1roundtrip(this)
            if (~this.doview); return; end                            
            tmp = tempFqfilename(fullfile(pwd, 'test_T1roundtrip'));  
 			import mlfourd.*;
            ifc_ = ImagingFormatContext(this.ref.T1AsMgz);         
            
            niigz = ifc_.saveas([tmp '.nii.gz']);          
            fdfp  = ifc_.saveas([tmp '.4dfp.hdr']);
            mgz   = ifc_.saveas([tmp '.mgz']);
            mlbash(sprintf('fsleyes %s %s %s %s', this.ref.T1AsMgz, niigz.fqfilename, fdfp.fqfilename, mgz.fqfilename));
            
            this.deleteExisting([tmp '.*']);
        end        
        function test_ctroundtrip(this)
            if (~this.doview); return; end            
            if (~lexist_4dfp('ct') || ~lexist('ct.nii.gz'))
                copyfile(fullfile(this.dataDir, 'ct.*'));
            end            
            tmp = tempFqfilename(fullfile(pwd, 'test_ctroundtrip'));  
 			import mlfourd.*;   
            ifcn = ImagingFormatContext('ct.nii.gz');
            ifc4 = ImagingFormatContext('ct.4dfp.hdr');
            
            out = ifcn.saveas([tmp '_nii.nii.gz']); 
            disp(out)
            out = ifcn.saveas([tmp '_nii.4dfp.hdr']);
            disp(out)
            out = ifc4.saveas([tmp '_4dfp.4dfp.hdr']);
            disp(out)
            out = ifc4.saveas([tmp '_4dfp.nii.gz']);           
            disp(out)
            mlbash(sprintf( ...
                'fsleyes %s_nii.nii.gz %s_nii.4dfp.hdr %s_4dfp.4dfp.hdr %s_4dfp.nii.gz', tmp, tmp, tmp, tmp));
            
            this.deleteExisting([tmp '.*']);
        end
        function test_fdgroundtrip(this)
            if (~this.doview); return; end
            ori = 'fdgv1r1_sumt';
            if (~lexist_4dfp(ori) || ~lexist([ori '.nii.gz']))
                copyfile(fullfile(this.dataDir, [ori '.*']));
            end
            tmp = tempFqfilename(fullfile(pwd, 'test_fdgroundtrip'));  
 			import mlfourd.*;   
            ifcn = ImagingFormatContext([ori '.nii.gz']);
            ifc4 = ImagingFormatContext([ori '.4dfp.hdr']);
            
            out = ifcn.saveas([tmp '_nii.nii.gz']); 
            disp(out)
            out = ifcn.saveas([tmp '_nii.4dfp.hdr']);
            disp(out)
            out = ifc4.saveas([tmp '_4dfp.4dfp.hdr']);
            disp(out)
            out = ifc4.saveas([tmp '_4dfp.nii.gz']);           
            disp(out)
            mlbash(sprintf( ...
                'fsleyes %s_nii.nii.gz %s_nii.4dfp.hdr %s_4dfp.4dfp.hdr %s_4dfp.nii.gz', tmp, tmp, tmp, tmp));
            
            this.deleteExisting([tmp '.*']);
        end
	end

 	methods (TestClassSetup)
		function setupImagingFormatContext(this)
            this.ref = mlfourd.ReferenceMprage;
            this.ref.copyfiles(this.TmpDir);
            fp = myfileprefix(this.ref.dicomAsNiigz); 
            if (~lexist([fp '.mgz']))
                mlbash(sprintf('mri_convert %s.nii.gz %s.mgz', fp, fp));
            end
 		end
	end

 	methods (TestMethodSetup)
		function setupImagingFormatContextTest(this)
 			import mlfourd.*;
 			this.testObj = ImagingFormatContext([]);
            this.pwd0 = pushd(this.TmpDir);
 			this.addTeardown(@this.cleanTestMethod);
 		end
    end
    
    %% PRIVATE

	properties (Access = private)
 	end

	methods (Access = private)
		function cleanTestMethod(this)
            popd(this.pwd0);
        end
        function deleteExisting(this, varargin)
            if (this.noDelete)
                return
            end
            deleteExisting(varargin{:});
        end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

