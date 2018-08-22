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
        dataDir = '/Users/jjlee/MATLAB-Drive/mlfourdfp/data'
        doview = true
        noDelete = false
        pwd0
        ref
 		registry
 		testObj
    end
    
    properties (Dependent)
        TmpDir
    end

    methods
        
        %% GET/SET
        
        function g = get.TmpDir(~)
            g = fullfile(getenv('HOME'), 'Tmp', '');
        end
    end
    
	methods (Test)
        function test_copy(this)
 			import mlfourd.*;
            niih_ = ImagingFormatContext(this.ref.dicomAsNiigz); 
            same  = niih_;
            this.verifySameHandle(same, niih_);
            diff  = copy(niih_);
            this.verifyNotSameHandle(diff, niih_);
        end    
        function test_ctor_noExtension(this)
            import mlfourd.*;
            niih = ImagingFormatContext(myfileprefix(this.ref.dicomAsNiigz));
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(niih.size, [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            this.verifyClass(niih.imagingInfo, 'mlfourdfp.FourdfpInfo');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_ctor_noExtension'));
            niih.saveas([tmp '.4dfp.hdr']);
            this.verifyTrue(lexist([tmp '.4dfp.hdr'], 'file'));
            this.deleteExisting([tmp '.4dfp.*']);
            if (this.doview); niih.fsleyes; end
        end      
        function test_ctor_NIfTId(this)
 			import mlfourd.*;            
            niih = ImagingFormatContext(NIfTId(this.ref.dicomAsNiigz));
            this.verifyEqual(class(niih.img), 'int16');
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
            this.verifyEqual(class(niih.img), 'int16');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.nii.gz');
            this.verifyClass(niih.imagingInfo, 'mlfourd.NIfTIInfo');
            
            if (this.doview); niih.fsleyes; end
        end
        function test_ctor_t14dfp(this)
 			import mlfourd.*;
            niih = ImagingFormatContext(this.ref.dicomAsFourdfp, 'circshiftK', 0, 'N', true); % sagittal            
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            this.verifyClass(niih.imagingInfo, 'mlfourdfp.FourdfpInfo');   
               
            if (this.doview); niih.fsleyes; end 
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
            niih = ImagingFormatContext(this.ref.surferAsFourdfp, 'circshiftK', 0, 'N', true); % sagittal            
            this.verifyEqual(class(niih.img), 'single');
            this.verifyEqual(size(niih.img),  [176 248 256]);
            this.verifyEqual(niih.filesuffix, '.4dfp.hdr');
            this.verifyClass(niih.imagingInfo, 'mlfourdfp.FourdfpInfo');
            
            tmp = tempFqfilename(fullfile(pwd, 'test_ctor_0014dfp'));
            niih.saveas([tmp '.4dfp.hdr']);
            this.verifyTrue(lexist_4dfp(tmp, 'file'));
            this.deleteExisting([tmp '.4dfp.*']);
            if (this.doview); niih.fsleyes; end
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
            niih = ImagingFormatContext(this.ref.T1AsFourdfp, 'circshiftK', 0, 'N', true);
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
            %% starts with this.ref.dicomAsNiigz; calls saveas with '.nii.gz', '.mgz', '.4dfp.hdr'.     
            %  loading t1_dcm2niix.mgz and saving as t1_dcm2niix.4dfp.hdr FAILS.
            
            if (~this.doview); return; end
 			import mlfourd.*;                               
            fpOri = myfileprefix(this.ref.dicomAsNiigz);
            xs = {'.nii.gz' '.mgz' '.4dfp.hdr'};
            
            for ix = 1:length(xs)
                fprintf('test_mutateInnerImagingFormatByFilesuffix:  loading %s%s\n', fpOri, xs{ix});
                ifc_ = ImagingFormatContext([fpOri xs{ix}]);
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
            niih_ = ImagingFormatContext(this.ref.T1AsMgz);
            mlbash(sprintf('fsleyes %s', this.ref.T1AsMgz));            
            
            niih = niih_.saveas([tmp '.nii.gz']);
            mlbash(sprintf('fsleyes %s', niih.fqfilename));            
            niih = niih_.saveas([tmp '.4dfp.hdr']);
            mlbash(sprintf('fsleyes %s', niih.fqfilename));
            niih = niih_.saveas([tmp '.mgz']);
            mlbash(sprintf('fsleyes %s', niih.fqfilename));
            
            this.deleteExisting([tmp '.*']);
        end        
        function test_ctroundtrip(this)
            if (~this.doview); return; end            
            if (~lexist_4dfp('ct'))
                copyfile(fullfile(this.dataDir, 'ct.*'));
            end
            tmp = tempFqfilename(fullfile(pwd, 'test_ctroundtrip'));  
 			import mlfourd.*;            
            niih_ = ImagingFormatContext('ct.4dfp.hdr');
            mlbash('fsleyes ct.4dfp.hdr');
            
            niih = niih_.saveas([tmp '.nii.gz']);
            mlbash(sprintf('fsleyes %s', niih.fqfilename));  
            niih = niih_.saveas([tmp '.4dfp.hdr']);
            mlbash(sprintf('fsleyes %s', niih.fqfilename));
            
            this.deleteExisting([tmp '.*']);
        end
        function test_fdgroundtrip(this)
            if (~this.doview); return; end
            if (~lexist_4dfp('fdgv1r1_sumt'))
                copyfile(fullfile(this.dataDir, 'fdgv1r1_sumt.*'));
            end
            tmp = tempFqfilename(fullfile(pwd, 'test_fdgroundtrip'));  
 			import mlfourd.*;            
            niih_ = ImagingFormatContext('fdgv1r1_sumt.4dfp.hdr');
            mlbash('fsleyes fdgv1r1_sumt.4dfp.hdr');
            
            niih = niih_.saveas([tmp '.nii.gz']);
            mlbash(sprintf('fsleyes %s', niih.fqfilename));            
            niih = niih_.saveas([tmp '.4dfp.hdr']);
            mlbash(sprintf('fsleyes %s', niih.fqfilename));
            
            this.deleteExisting([tmp '.*']);
        end
	end

 	methods (TestClassSetup)
		function setupNIfTIHeavy(this)
 			import mlfourd.*;
 			this.testObj_ = ImagingFormatContext([]);
            this.ref = mlfourd.ReferenceMprage;
            this.ref.copyfiles(this.TmpDir);
            fp = myfileprefix(this.ref.dicomAsNiigz); 
            if (~lexist([fp '.mgz']))
                mlbash(sprintf('mri_convert %s.nii.gz %s.mgz', fp, fp));
            end
 		end
	end

 	methods (TestMethodSetup)
		function setupNIfTIHeavyTest(this)
            this.pwd0 = pushd(this.TmpDir);
 			this.testObj = this.testObj_;
 			this.addTeardown(@this.cleanTestMethod);
 		end
    end
    
    %% PRIVATE

	properties (Access = private)
 		testObj_
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

