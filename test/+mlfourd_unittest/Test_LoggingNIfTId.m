classdef Test_LoggingNIfTId < matlab.unittest.TestCase
	%% TEST_LOGGINGNIFTID 

	%  Usage:  >> results = run(mlfourd_unittest.Test_LoggingNIfTId)
 	%          >> result  = run(mlfourd_unittest.Test_LoggingNIfTId, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 10-Jan-2016 16:42:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		registry
 		testObj
 	end

    properties (Dependent)
        fslPath 
        sessionPath
        smallT1_fp
        smallT1_fqfn  
        smallT1_niid
    end
    
    methods %% GET/SET
        function g = get.fslPath(this)
            g = this.registry.fslPath;
        end
        function g = get.sessionPath(this)
            g = this.registry.sessionPath;
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
        function test_addLog(this)
            this.testObj.addLog('running test_addLog');
            this.verifyEqual(this.testObj.logger.contents(end-18:end), 'running test_addLog');
        end
        function test_componentChange(this)
            import mlfourd.*;
            b  = BlurringNIfTId( ...
                     NIfTId(this.smallT1_fqfn), 'blur', [16 16 16]);
                 
            cc = BlurringNIfTId(this.testObj, 'blur', [16 16 16]);
            this.verifyEqual(cc.blurCount, 1);
            this.verifyEqual(cc.descrip.id, 'jjlee');
            this.verifyEqual(cc.img, b.img);
            this.verifyTrue(lstrfind(cc.descrip.contents, 'mlfourd.LoggingNIfTId'))
            
            cc = LoggingNIfTId(b);
            this.verifyEqual(cc.logger.id, 'jjlee');
            this.verifyEqual(cc.descrip.id, 'jjlee');
            this.verifyEqual(cc.img, b.img);
            this.verifyTrue(lstrfind(cc.descrip.contents, 'mlfourd.LoggingNIfTId'))
        end
        function test_CellArrayList(this)
            import mlpatterns.*;
            cal = CellArrayList;
            cal.add({'a' 'b' 'c'});
            cal2 = CellArrayList(cal);
            this.verifyNotSameHandle(cal2, cal);
        end
        function test_clone(this)
            LEN = this.testObj.logger.length;
            clone = this.testObj.clone;
            this.verifyNotSameHandle(clone.logger, this.testObj.logger);
            
            clone.addLog('test_clone');
            this.verifyEqual(this.testObj.logger.length, LEN);
            this.verifyEqual(clone.logger.length, LEN+4);
            
            this.testObj.addLog('test_clone2');
            this.verifyEqual(clone.logger.length, LEN+4);
            this.verifyEqual(this.testObj.logger.length, LEN+2);
        end
		function test_ctor(this)
 			this.verifyEqual(this.testObj.logger.callerid, 'mlfourd_LoggingNIfTId');
 			this.verifyEqual(this.testObj.logger.contents(end-33:end), 'decorated by mlfourd.LoggingNIfTId');
            [~,r] = mlbash('hostname');
 			this.verifyEqual(this.testObj.logger.hostname, strtrim(r));
 			this.verifyEqual(this.testObj.logger.id, getenv('USER'));
 			this.verifyEqual(this.testObj.logger.fqfilename, ...
                [this.testObj.fqfileprefix mlpipeline.Logger.FILETYPE_EXT]);
 			this.verifyEqual(this.testObj.logger.length, 3);
 			this.verifyFalse(this.testObj.logger.isempty);
            gotten = this.testObj.logger.get(1);
 			this.verifyEqual(gotten(1:49), 'mlfourd.LoggingNIfTId from jjlee at innominate on');
            c = this.testObj.logger.char;
 			this.verifyEqual(c(end-33:end), 'decorated by mlfourd.LoggingNIfTId');
        end
        function test_descripChange(this)
            this.testObj = this.testObj.prepend_descrip('prepending');
            this.verifyEqual(this.testObj.logger.contents(end-9:end), 'prepending');
            c = this.testObj.component;            
            this.verifyEqual(c.descrip(1:10), 'prepending');
            
            d = 'Test_LoggingNIfTId.test_descripChange';
            this.testObj.descrip = d;
            this.verifyEqual(this.testObj.logger.contents(end-length(d)+1:end), d);
            c = this.testObj.component;
            this.verifyEqual(c.descrip, d);
            
            this.testObj = this.testObj.append_descrip('appending');
            this.verifyEqual(this.testObj.logger.contents(end-8:end), 'appending');
            c = this.testObj.component;
            this.verifyEqual(c.descrip(end-8:end), 'appending');
        end
        function test_fqfilenameChange(this)
            this.testObj.fqfilename =                          '/tmp/Test_LoggingNIfTId_test_fqfilenameChange.mgz';
            this.verifyEqual(this.testObj.fqfilename,          '/tmp/Test_LoggingNIfTId_test_fqfilenameChange.mgz');
            this.verifyEqual(this.testObj.fqfileprefix,        '/tmp/Test_LoggingNIfTId_test_fqfilenameChange');
            this.verifyEqual(this.testObj.filepath,            '/tmp');
            this.verifyEqual(this.testObj.fileprefix,               'Test_LoggingNIfTId_test_fqfilenameChange');
            this.verifyEqual(this.testObj.filesuffix,                                                        '.mgz');
            this.verifyEqual(this.testObj.logger.fqfilename,   '/tmp/Test_LoggingNIfTId_test_fqfilenameChange.log');
            this.verifyEqual(this.testObj.logger.fqfileprefix, '/tmp/Test_LoggingNIfTId_test_fqfilenameChange');
            this.verifyEqual(this.testObj.logger.filepath,     '/tmp');
            this.verifyEqual(this.testObj.logger.fileprefix,        'Test_LoggingNIfTId_test_fqfilenameChange');
            this.verifyEqual(this.testObj.logger.filesuffix,                                                 '.log');
        end
        function test_imgChange(this)
            this.testObj.img(64,64,32) = -1;
            c = this.testObj.component;
            this.verifyEqual(c.img(64,64,32), single(-1));
        end
        function test_createIteratorLogger(this)
            iter = this.testObj.createIteratorLogger;
            c = this.testObj.logger.contents;
            while (iter.hasNext)
                this.verifyTrue(lstrfind(c, iter.next));
            end
        end
        function test_logger(this)
            lg = this.testObj.logger;
            this.verifyEqual(lg.callerid, 'mlfourd_LoggingNIfTId');
            this.verifyEqual(lg.contents(1:49), 'mlfourd.LoggingNIfTId from jjlee at innominate on');
            this.verifyEqual(lg.hostname, 'innominate');
            this.verifyEqual(lg.id, 'jjlee');
            this.verifyEqual(lg.fqfilename, [this.smallT1_niid.fqfileprefix '.log']);
        end
        function test_save(this)
            FP = 'Test_Logging_test_save';
            this.testObj.fileprefix = FP;
            this.testObj.save;
            this.verifyTrue(lexist(fullfile(this.fslPath, [FP '.nii.gz']), 'file'));
            this.verifyTrue(lexist(fullfile(this.fslPath, [FP '.log']), 'file'));
            deleteExisting(fullfile(this.fslPath, [FP '.nii.gz']));
            deleteExisting(fullfile(this.fslPath, [FP '.log']));
        end
        function test_saveas(this)
            FQFP = fullfile(this.fslPath, 'Test_Logging_test_saveas');
            this.testObj = this.testObj.saveas(FQFP);
            this.verifyEqual(this.testObj.fqfp, FQFP);
            this.verifyTrue(lexist( this.testObj.fqfilename, 'file'));
            this.verifyTrue(lexist([this.testObj.fqfileprefix '.log'], 'file'));
            deleteExisting(fullfile([FQFP '.nii.gz']));
            deleteExisting(fullfile([FQFP '.log']));            
        end
        function test_setters(this)
            this.testObj.img(64,64,32) = -1;
            this.testObj.bitpix = 64;
            this.testObj.datatype = 64;
            this.testObj.label = 'Test_LoggingNIfTId.test_setters assigned label';
            this.testObj.mmppix = [0.5 0.5 0.5];
            this.testObj.descrip = 'Test_LoggingNIfTId.test_setters assigned descrip';
            this.verifyEqual(length(this.testObj.logger.contents), 668);
            this.verifyEqual(this.testObj.logger.contents(end-47:end), ...
                'Test_LoggingNIfTId.test_setters assigned descrip');
        end
	end

 	methods (TestClassSetup)
		function setupLoggingNIfTId(this)
            this.registry = mlfourd.UnittestRegistry.instance;
 		end
	end

 	methods (TestMethodSetup)
		function setupLoggingNIfTIdTest(this)
            import mlfourd.*;
 			this.testObj = LoggingNIfTId(NIfTId(this.smallT1_niid));
 		end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

