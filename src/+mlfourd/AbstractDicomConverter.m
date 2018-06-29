classdef AbstractDicomConverter < mlfourd.AbstractConverter
	%% ABSTRACTDICOMCONVERTER is the interface for concrete strategies such as SurferDicomConverter, MRIConverter
    %  Uses:   singleton mlfourd.NamingRegistry
    %
    %  Version $Revision: 2608 $ was created $Date: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $,
 	%  last modified $LastChangedDate: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AbstractDicomConverter.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: AbstractDicomConverter.m 2608 2013-09-08 00:14:08Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    %% ABSTRACTIONS
    
    methods (Abstract, Static)
        convertSessions(patt, varargin)
        unpacksDcmDir(dcmdir, targdir, unpackInfo)
    end

    methods (Abstract)
        dicomQuery(this)
        structInfo2unpackInfo(this, structInfo)
    end

    %% CONCRETE 
    
    properties (Constant)
        modalityFolders = {'Trio' 'Avanto' 'Allegra' 'Symphony' 'ClinDesk' 'iSite' 'OutsideMR'};
    end
    
    properties  
        dicomFolders = {'CDR_OFFLINE' 'Osirix/DICOM' 'Osirix/Dicom' 'DICOM' 'Dicom' 'CDROM/DICOM/ST000000' 'cdrom/DICOM/ST000000'};
        imaNames = {'*.IMA' '*.ima' '*.DCM' '*.dcm'};
        paxFolder = 'PaxHeader';
        reportNames = {'*.SR'  '*.pdf' '*.I'};
        reportsFolder = 'DicomReports';
    end
    
    properties (Dependent)
        allFileprefixes
        dicomFolder
        dicomInfo
        dicomPath
        mrFolder
        mrPath
        mrReference
    end
    
    methods (Static) 
        function cleanImas(dcmPth, targPth)
            import mlfourd.*;
            DicomComponent.cleanReports(dcmPth, targPth);
            AbstractDicomConverter.extractNestedFolders(dcmPth, 'CDR_OFFLINE');
        end % static cleanImas
        function cleanPaxHeaders(dcmPth, ~)
            import mlfourd.*;
            if (lstrfind(dcmPth, 'CDR_OFFLINE'))
                try
                    paxPth = ensuredir( ...
                                 fullfile(dcmPth, '..', AbstractDicomConverter.paxFolder, ''));
                        r = ''; [~,r] = movefiles(fullfile(dcmPth, '*'), paxPth, 'f');
                    for n = 1:length(AbstractDicomConverter.imaNames) %#ok<FORFLG>
                        [~,r] = movefiles( ...
                            fullfilename(paxPth, AbstractDicomConverter.imaNames{n}), dcmPth); 
                    end
                catch ME
                   handexcept(ME, r);
                end
            end
        end % static cleanPaxHeaders
        function cleanReports(   dcmPth, ~)
            import mlfourd.*;
            if (lstrfind(dcmPth, 'CDR_OFFLINE'))
                try
                    r = '';
                    reportsPth = fullfile(dcmPth, '..', AbstractDicomConverter.reportsFolder, '');
                    reportsPth = ensuredir(reportsPth);
                    for n = 1:length(AbstractDicomConverter.reportNames) %#ok<FORFLG>
                        [~,r] = movefiles( ...
                            fullfilename(dcmPth, AbstractDicomConverter.reportNames{n}), reportsPth, 'f'); 
                    end
                catch ME
                    handexcept(ME, r);
                end
            end
        end % static cleanReports      
        function mpth = findModalityPath(pth, varargin)
            mpth = findModalityPath@mlfourd.AbstractConverter( ...
                @mlfourd.AbstractDicomConverter.findModalityPath, ...
                    mlfourd.AbstractDicomConverter.modalityFolders, ...
                        pth, varargin{:});
        end  
    end % static methods
    
	methods %% set/get 
        function pref = get.allFileprefixes(this)
            pref = this.namingRegistry_.FSL_NAMES;
        end
        function fld  = get.dicomFolder(this)
            [~,fld] = filepartsx(this.dicomPath, mlfourd.NIfTId.FILETYPE_EXT);
        end % get.dicomFolder
        function this = set.dicomInfo(this, cal)
            assert(isa(cal, 'mlfourd.ImagingArrayList'));
            assert(~isempty(cal));
            this.dicomInfo_ = mlfourd.ImagingArrayList(cal);
        end
        function cal  = get.dicomInfo(this)
            cal = mlfourd.ImagingArrayList(this.dicomInfo_);
        end
        function pth  = get.dicomPath(this)
            for d = 1:length(this.dicomFolders)
                pth = fullfile(this.mrPath, this.dicomFolders{d}, '');
                if (lexist(pth, 'dir')); return; end
            end
            error('mlfourd:PathNotFound', 'could not find any of:  %s', cell2str(this.dicomFolders));
        end % get.dicomPath
        function fld  = get.mrFolder(this)
            [~,fld] = filepartsx(this.mrPath, mlfourd.NIfTId.FILETYPE_EXT);
        end % get.mrFolder
        function pth  = get.mrPath(this)
            pth = this.modalityPath;
        end % get.mrPath
    end
    
    methods
        function fns  = modalFqFilenames(this, lbl)
            %% MODALFQFILENAMES uses lazy initialization of a cache of fully-qualified filenames
            
            lbl_ = [lbl 'FqFilenames_'];
            if (isempty(this.(lbl_)))
                this.(lbl_) = this.allFqFilenames(cell2logical(strfind(this.allFqFilenames, lbl)));
            end
            fns = this.(lbl_);
        end % modalFqFilenames
        function this = unpackDicom(this)
            this.dicomInfo = this.unpacksDcmDir( ...
                this.dicomPath, ...
                this.unpackPath, ...
                this.structInfo2unpackInfo(this.dicomQuery));
        end
    end 
    
    %% PROTECTED
    
    methods (Access = 'protected')
 		function this = AbstractDicomConverter(mpth)
            %% ABSTRACTDICOMCONVERTER is the abstract interface for DICOM conversion strategies
                       
            this = this@mlfourd.AbstractConverter(mpth);
 		end % ctor         
    end
    
    %% PRIVATE
    
    properties (Access = 'private')
        irFqFilenames_
        t1FqFilenames_
        tofFqFilenames_
        pdFqFilenames_
        t2FqFilenames_
        dwiFqFilenames_
        irllFqFilenames_
        localFqFilenames_
        pcFqFilenames_
        swiFqFilenames_
        dsaFqFilenames_
        adcFqFilenames_
        greFqFilenames_
        fieldmapFqFilenames_
        ep2dFqFilenames_
        aseFqFilenames_
        aslFqFilenames_
        hxoefFqFilenames_
        dicomInfo_
    end 
    
    methods (Static, Access = 'private') 
        function s    = extractNestedFolders(pth, patt)
            %% EXTRACTNESTEDFOLDERS finds folders with string-pattern in the specified filesystem path
            %  and moves the folders to the path (flattens)
            %  Usage:  status = *DicomConverter.extractNestedFolders(path, string_pattern)
            
            s = 0;
            if (lstrfind(pth, patt))
                try
                    dlist = mlsystem.DirTool(fullfile(pth, '*', ''));
                    for d = 1:length(dlist.fqdns) %#ok<*FORFLG>
                        [s,msg,mid] = movefile(dlist.fqdns{d}, fullfile(pth, '..', ''));
                    end
                catch ME
                    handexcept(ME, msg, mid);
                end
            end
        end % static extractNestedFolders
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

