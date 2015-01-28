classdef Test_PatientRecord < mlfourd_xunit.Test_mlfourd
	%% TEST_PATIENTRECORD  
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_PatientRecord % in . or the matlab path 
 	%          >> runtests Test_PatientRecord:test_nameoffunc 
 	%          >> runtests(Test_PatientRecord, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit	
    %  Version $Revision: 2522 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_PatientRecord.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_PatientRecord.m 2522 2013-08-18 22:52:21Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    properties
        patient
        petSeries
        mrSeries
        angioSeries
        hxPx
    end
	properties (Constant)
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient)
        NPNUM      = 'np755';
        SUBJECT_ID = 'mm01-020';
        PNUM       = 'p7377';
        SCAN_DATE  = '2009feb5';
    end

	methods 
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 
        
        function test_addPet(this)
            this.patient = this.patient.addPet(this.petSeries);
            assert(eqtool(this.petSeries, this.patient.imagingStudies.get(this.PNUM)));
        end

        function setUp(this)             
            import mlfourd.* mlfsl.*;
            this.patient = PatientRecord.createPatient(this.SUBJECT_ID);
            this.patient.addImagingSeries( ...
                PETImaging.createSeriesFromPath( ...
                    this.sessionPath(this.SUBJECT_ID, this.PNUM, this.SCAN_DATE)));
        end
        function tearDown(this)
        end
 		function this = Test_PatientRecord(varargin) 
            this = this@mlfourd_xunit.Test_mlfourd(varargin{:});
 		end % Test_PatientRecord (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
