classdef PatientRecord 
	%% PATIENTRECORD is a container for organizing data-records by patient:
    %                - MR, PET, outside imaging
    %                - angio results
    %                - clinical history
    %                - demographics
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/PatientRecord.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: PatientRecord.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient)
        
        subjectId      % e.g., mm01-020
        imagingStudies
        medicalHistory
    end
    
    properties (Dependent)
        pid           % backwards compatibility
        npnumFolder
        patientFolder
        pnumFolder
        
        npnumPath
        patientPath
        pnumPath
    end
    
    properties (Access = 'protected')        
        npnum_
        pnum
        patient
        pnumPath_
    end
    
    methods (Static)
        
        function pat  = createPatient(subid, imgs, hxpx)
            %% CREATEPATIENT is a factory method
            
            pat = mlfourd.PatientRecord;
            assert(exist('subid','var'));
            pat.subjectId = subid;
            if (   exist('imgs','var'))
                pat.imagingStudies = imgs;
            end
            if (   exist('hxpx','var'))
                pat.medicalHistory = hxpx;
            end
        end
        function series  = createSeries(npnum, subjectId, pnum, scanDate)
            series = mlfsl.ImagingComponent;
            series.npnum_ = npnum;
            series.subjectId = subjectId;
            series.pnum = pnum;
            series.scanDate = scanDate;
        end % static createSeries
        function pnum    = ensurePnum(id)
            
            %% ENSUREPNUM validates & converts to canonical forms as needed
            %  pnum = ImagingComponent.ensurePnum(pnum)
            %  ^ pXXXX, int X                     ^ possibly longer string, patient-folder w/ p-number, double
            %    empty if unidentified
            pnum = '';
            switch(class(id))
                case 'char'
                    if (strncmpi('p', id, 1) && isnumeric(str2double(id(2:end))))
                        pnum = id;
                    end
                    s2d = str2double(id);
                    if (~isnan(s2d)) % SPOTRIAS
                        pnum = id;
                    end
                               % regexp for *_pXXXX_*, int X
                    [~, names] = regexpi(id, '[_]+(?<pnum>p[0-9]+)[_]+', 'tokens', 'names', 'once');
                    if (~isempty(struct2cell(names)))
                        pnum = names.pnum;
                    end
                case {'double','single'}
                    pnum = num2str(id);
                otherwise
                    error('mlfourd:InputParamErr', 'ImagingComponent.ensurePnum could not recognize id->%s\n', char(id));
            end
        end % static function ensurePnum
        function npnum   = ensureNpnum(id)
            
            %% ENSUREPNUM validates & converts to canonical forms as needed
            %  pnum = ImagingComponent.ensureNpnum(pnum)
            %  ^ npXXX, int X                      ^ possibly longer string, patient-folder w/ np-number
            %    empty if unidentified
            npnum = '';
            switch(class(id))
                case 'char'
                    if (strncmpi('np', id, 2) && isnumeric(str2double(id(2:end))))
                        npnum = id;
                    end
                               % regexp for *npXXX*, int X
                    [~, names] = regexpi(id, '(?<npnum>np[0-9]+)', 'tokens', 'names', 'once');
                    if (~isempty(struct2cell(names)))
                        npnum = names.npnum;
                    end
                otherwise
                    error('mlfourd:InputParamErr', 'ImagingComponent.ensureNpnum could not recognize id->%s\n', char(id));
            end
        end % static function ensureNpnum
        function patient = ensurePatient(id)
            
            %% ENSUREPNUM validates & converts to canonical forms as needed
            %  pnum = ImagingComponent.ensurePatient(pnum)
            %  ^ pXXXX, int X                 ^ possibly longer string, patient-folder
            %    empty if unidentified
            patient = ''; %#ok<NASGU>
            switch(class(id))
                case 'char'
                    if     (lstrfind(id, 'mm'))
                        [~, names] = regexpi(id, '(?<pat>mm[0-9][0-9]-[0-9]+)', 'tokens', 'names', 'once');
                    elseif (lstrfind(id, 'wu'))
                        [~, names] = regexpi(id, '(?<pat>wu[0-9][0-9][0-9])',   'tokens', 'names', 'once');
                    elseif (lstrfind(id, 'cs'))
                        [~, names] = regexpi(id, '(?<pat>cs[0-9][0-9]-[0-9]+)', 'tokens', 'names', 'once');
                    end
                    if (~isempty(struct2cell(names)))
                        patient = names.pat;                            
                    else
                        error('mlfourd:InputParamErr', 'ImagingComponent.ensurePatient could not recognize id->%s\n', char(id));
                    end
                otherwise
                        error('mlfourd:InputParamErr', 'ImagingComponent.ensurePatient could not recognize id->%s\n', char(id));
            end
        end % static function ensurePatient
    end % static methods  

	methods 
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 

        function this = set.pnum(this, id)
            this.pnum = mlfsl.ImagingComponent.ensurePnum(id);
        end
        function this = set.npnum_(this, id)
            this.npnum_ = mlfsl.ImagingComponent.ensureNpnum(id);
        end     
        function this = set.pid(this, id)
            this.pnum = mlfsl.ImagingComponent.ensurePnum(id);
        end
        function id   = get.pid(this)
            id = this.pnum;
        end
        function fld  = get.pnumFolder(this)
            fld = [];
            error('mlfsl:NotImplemented', 'ImagingComponent.get.pnumFolder');
        end
        function pth  = get.npnumPath(this)
            
            if (isempty(this.npnum_) || strcmpi('unknown', this.npnum_)) % best guess
                pth = pwd;
                return;
            end            
            pwd0  = pwd;
            found = strfind(lower(pwd0), this.npnum_);
            diff  = length(this.npnum_) - 1;
            if (numel(found) > 1)
                pth = pwd0(1:found(1)+diff);
            elseif (numel(found) == 1)
                pth = pwd0(1:found+diff);
            else
                pth = pwd0;
            end
        end % KLUDGE:  depends upon pwd    
        function this = set.pnumPath(this, pth)
            %% SET.PNUMPATH also adds argument to matlab's path; sets only pwd if argument is empty
            if (isempty(pth) || lstrfind(pth, 'unknown'))
                this.pnumPath_ = pwd;
            else
                this.pnumPath_ = pth;
                path(path, pth);
            end
            if (~lexist( pth, 'dir'))
                error('mlfourd:IOErr', 'ImagingComponent.set.pnumPath could not find %s\n', pth);
            end            
        end        
        function pth  = get.pnumPath(this)
            
            %% GET.PNUMPATH always returns a trailing '/'
            import mlfsl.* mlfourd.*;
            if (isempty(this.pnumPath_))
                pth = pwd;
                
                % remove ../fsl/bet/onFolders...
                fslIdx = strfind(pth, 'fsl');
                if (length(fslIdx) > 1); fslIdx = fslIdx(1); end
                if (~isempty(fslIdx))
                    pth = pth(1:fslIdx-2);
                end
            else
                pth = this.pnumPath_; 
            end
            if (~strcmp(filesep, pth(end))) % trailing '/'
                pth = [pth filesep];
            end
        end
        function this = addImagingSeries(this, series)
            this.imagingStudies(series.imgkey) = series;            
        end      
 		function this = PatientRecord() 
 			%% PATIENTRECORD (ctor) 
 			%  Usage:  
			this.imagingStudies = containers.Map;
            this.medicalHistory = containers.Map;
 		end % PatientRecord (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
