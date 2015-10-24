classdef AbstractDicomConverter < mlfourd.AbstractConverter
	%% ABSTRACTDICOMCONVERTER is the interface for concrete strategies such as SurferDicomConverter, MRIConverter
    %  Uses:   singleton mlfourd.NamingRegistry
    %
    %  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/AbstractDicomConverter.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: AbstractDicomConverter.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    %% ABSTRACTIONS
    
    methods (Abstract, Static)
        unpackDicom(dcmdir, targdir, unpackInfo)
        scanDicom(dcmdir, targdir)
    end % abstract static methdos

    methods (Abstract, Static, Access = 'protected')
        parseInfoFile(fname)
        parseInfoCell(ca)
    end % abstract static protected methods
    
    methods (Abstract)
        dicomQuery(this)
        dicoms2structInfo(this)
        structInfo2unpackInfo(this, structInfo)
    end % abstract methods    

    properties (Constant)
          imaNames    = {'*.IMA' '*.ima' '*.DCM' '*.dcm'};
       reportNames    = {'*.SR'  '*.pdf' '*.I'};
       reportsFolder  =  'DicomReports';
           paxFolder  =  'PaxHeader';    
         dicomFolders = {'CDR_OFFLINE' 'Osirix/DICOM' 'CDROM/DICOM/ST000000' 'cdrom/DICOM/ST000000' 'DICOM'};
      modalityFolders = {'Trio' 'Avanto' 'Allegra' 'Symphony' 'ClinDesk' 'iSite' 'OutsideMR'};       
        orients2fix   = struct('img_type', { 'ase' 'local' }, 'orientation', { 'y' 'y' });
    end % constant properties
    
    properties (Dependent)
        allFileprefixes
        irFqFilenames 
        t1FqFilenames
        tofFqFilenames
        pdFqFilenames
        t2FqFilenames
        dwiFqFilenames
        irllFqFilenames
        localFqFilenames
        pcFqFilenames
        swiFqFilenames
        dsaFqFilenames
        adcFqFilenames
        greFqFilenames
        fieldmapFqFilenames
        ep2dFqFilenames
        aseFqFilenames
        aslFqFilenames
        hxoefFqFilenames
        irFqFilename
        t1FqFilename
        tofFqFilename
        pdFqFilename
        t2FqFilename
        dwiFqFilename
        irllFqFilename
        localFqFilename
        pcFqFilename
        swiFqFilename
        dsaFqFilename
        adcFqFilename
        greFqFilename
        fieldmapFqFilename
        ep2dFqFilename
        ep2dmeanvolFqFilename
        aseFqFilename
        asemeanvolFqFilename
        aslFqFilename
        aslmeanvolFqFilename
        hxoefFqFilename
        mrPath
        mrFolder
        dicomPath
        dicomFolder
    end % dependent properties
    
    methods (Static)
        function s    = cleanImas(      dcmPth, targPth)
            import mlfourd.*;
            s = DicomComponent.cleanReports(dcmPth, targPth);
            %s = [s DicomComponent.cleanPaxHeaders(dcmPth)];
            s = [s NamingRegistry.extractNestedFolders(dcmPth, 'CDR_OFFLINE')];
        end % static cleanImas
        function s    = cleanPaxHeaders(dcmPth, ~)
            import mlfourd.*;
            s = 0; r = '';
            if (lstrfind(dcmPth, 'CDR_OFFLINE'))
                try
                    paxPth = ensureFolderExists( ...
                                 fullfile(dcmPth, '..', AbstractDicomConverter.paxFolder, ''));
                        [s,r] = movefiles(fullfile(dcmPth, '*'), paxPth, 'f');
                    for n = 1:length(AbstractDicomConverter.imaNames) %#ok<FORFLG>
                        [s,r] = movefiles(fullfile(paxPth, AbstractDicomConverter.imaNames{n}), dcmPth); 
                    end
                catch ME
                   handexcept(ME, sprintf('last s->%i r->%s', s, r));
                end
            end
        end % static cleanPaxHeaders
        function s    = cleanReports(   dcmPth, ~)
            import mlfourd.*;
            s  = 0; r = '';
            if (lstrfind(dcmPth, 'CDR_OFFLINE'))
                try
                    reportsPth = fullfile(dcmPth, '..', AbstractDicomConverter.reportsFolder, '');
                    reportsPth = ensureFolderExists(reportsPth);
                    for n = 1:length(AbstractDicomConverter.reportNames) %#ok<FORFLG>
                        [s,r] = movefiles(fullfile(dcmPth, AbstractDicomConverter.reportNames{n}), reportsPth, 'f'); 
                    end
                catch ME
                    handexcept(ME, sprintf('last s->%i r->%s', s, r));
                end
            end
        end % static cleanReports        
    end % static methods
    
	methods
        
        function pref = get.allFileprefixes(this)
            pref = this.namereg_.FSL_NAMES;
        end
        function fns  = get.irFqFilenames(this)
            fns = this.modalFqFilenames('ir');
        end 
        function fns  = get.t1FqFilenames(this)
            fns = this.modalFqFilenames('t1');
        end         
        function fns  = get.tofFqFilenames(this)
            fns = this.modalFqFilenames('tof');
        end 
        function fns  = get.pdFqFilenames(this)
            fns = this.modalFqFilenames('pd');
        end 
        function fns  = get.t2FqFilenames(this)
            fns = this.modalFqFilenames('t2');
        end 
        function fns  = get.dwiFqFilenames(this)
            fns = this.modalFqFilenames('dwi');
        end 
        function fns  = get.irllFqFilenames(this)
            fns = this.modalFqFilenames('irll');
        end 
        function fns  = get.localFqFilenames(this)
            fns = this.modalFqFilenames('local');
        end 
        function fns  = get.pcFqFilenames(this)
            fns = this.modalFqFilenames('pc');
        end 
        function fns  = get.swiFqFilenames(this)
            fns = this.modalFqFilenames('swi');
        end 
        function fns  = get.dsaFqFilenames(this)
            fns = this.modalFqFilenames('dsa');
        end 
        function fns  = get.adcFqFilenames(this)
            fns = this.modalFqFilenames('adc');
        end 
        function fns  = get.greFqFilenames(this)
            fns = this.modalFqFilenames('gre');
        end 
        function fns  = get.fieldmapFqFilenames(this)
            fns = this.modalFqFilenames('fieldmap');
        end 
        function fns  = get.ep2dFqFilenames(this)
            fns = this.modalFqFilenames('ep2d');
        end 
        function fns  = get.aseFqFilenames(this)
            fns = this.modalFqFilenames('ase');
        end 
        function fns  = get.aslFqFilenames(this)
            fns = this.modalFqFilenames('asl');
        end 
        function fns  = get.hxoefFqFilenames(this)
            fns = this.modalFqFilenames('hxoef');
        end 
        function fn   = get.irFqFilename(this)
            fn = this.timeindFqFilename('ir');
        end
        function fn   = get.t1FqFilename(this)
            fn = this.timeindFqFilename('t1');
        end
        function fn   = get.tofFqFilename(this)
            fn = this.timeindFqFilename('tof');
        end
        function fn   = get.pdFqFilename(this)
            fn = this.timeindFqFilename('pd');
        end
        function fn   = get.t2FqFilename(this)
            fn = this.timeindFqFilename('t2');
        end
        function fn   = get.dwiFqFilename(this)
            fn = this.timeindFqFilename('dwi');
        end
        function fn   = get.irllFqFilename(this)
            fn = this.timeindFqFilename('irll');
        end
        function fn   = get.localFqFilename(this)
            fn = this.timeindFqFilename('local');
        end
        function fn   = get.pcFqFilename(this)
            fn = this.timeindFqFilename('pc');
        end
        function fn   = get.swiFqFilename(this)
            fn = this.timeindFqFilename('swi');
        end
        function fn   = get.dsaFqFilename(this)
            fn = this.timeindFqFilename('dsa');
        end
        function fn   = get.adcFqFilename(this)
            fn = this.timeindFqFilename('adc');
        end
        function fn   = get.greFqFilename(this)
            fn = this.timeindFqFilename('gre');
        end
        function fn   = get.fieldmapFqFilename(this)
            fn = this.timeindFqFilename('fieldmap');
        end
        function fn   = get.ep2dmeanvolFqFilename(this)
            fn = this.timeindFqFilename('ep2d');
        end
        function fn   = get.ep2dFqFilename(this)
            fn = this.timedepFqFilename('ep2d');
        end
        function fn   = get.asemeanvolFqFilename(this)
            fn = this.timeindFqFilename('ase');
        end
        function fn   = get.aseFqFilename(this)
            fn = this.timedepFqFilename('ase');
        end
        function fn   = get.aslmeanvolFqFilename(this)
            fn = this.timeindFqFilename('asl');
        end
        function fn   = get.aslFqFilename(this)
            fn = this.timedepFqFilename('asl');
        end
        function fn   = get.hxoefFqFilename(this)
            fn = this.timedepFqFilename('hxoef');
        end
        function pth  = get.mrPath(this)
            pth = this.modalityPath;
        end % get.mrPath
        function pth  = get.dicomPath(this)
            for d = 1:length(this.dicomFolders)
                pth = fullfile(this.mrPath, this.dicomFolders{d}, '');
                if (lexist(pth, 'dir')); return; end
            end
            error('mlfourd:PathNotFound', 'could not find any of:  %s', cell2str(this.dicomFolders));
        end % get.dicomPath
        function fld  = get.mrFolder(this)
            [~,fld] = fileparts(this.mrPath);
        end % get.mrFolder
        function fld  = get.dicomFolder(this)
            [~,fld] = fileparts(this.dicomPath);
        end % get.dicomFolder
        
        function fp   = t1(this, varargin)
                  fp = this.formFilename( ...
                       this.mostEntropy( ...
                       this.fqfnsInFslpath('t1')), varargin{:});
        end        
        function fp   = t2(this, varargin)
                  fp = this.formFilename( ...
                       this.mostNegentropy( ...
                       this.fqfnsInFslpath('t2')), varargin{:});
        end
        function fp   = flair(this, varargin)
                  fp = this.formFilename( ...
                       this.fqfnsInFslpath('flair'), varargin{:});
        end        
        function fp   = flair_abs(this, varargin)
                  fp = this.formFilename( ...
                       this.fqfnsInFslpath('flair_abs'), varargin{:});
        end        
        function fp   = ep2d(this, varargin)
                  fp = this.formFilename( ...
                       this.longestDuration( ...
                       this.timeDependent( ...
                       this.fqfnsInFslpath0('ep2d'))), varargin{:});
        end        
        function fp   = ep2dMean(this, varargin)
                  fp = this.formFilename( ...
                       this.mostNegentropy( ...
                       this.timeIndependent( ...
                       this.fqfnsInFslpath('ep2d'))), varargin{:});
        end
        function fns  = modalFqFilenames(this, lbl)
            %% MODALFQFILENAMES uses lazy initialization of a cache of fully-qualified filenames
            
            lbl_ = [lbl 'FqFilenames_'];
            if (isempty(this.(lbl_)))
                this.(lbl_) = this.allFqFilenames(cell2logical(strfind(this.allFqFilenames, lbl)));
            end
            fns = this.(lbl_);
        end % modalFqFilenames
        function        unpack(this, varargin)
            %% UNPACK unpacks DICOM/NIfTI to an fsl-folder
            %  Usage:  unpack 
            %          unpack(unpack_path) 
            %          unpack(unpack_path, fsl_path)
            
            this.dicoms2cell;
            switch (nargin-1)
                case 0
                    this.unpack(this.unpackPath, this.fslPath);
                case 1
                    this.unpack(varargin{1},     this.fslPath);
                case 2
                    % funnel
                    this.rename(varargin{1}, varargin{2}); % abstract
                    this.reorient2std(       varargin{2});
                otherwise
                    error('mlfourd:TooManyNargin', 'AbstractDicomConverter.unpack.vargin->%i', cell2str(vargin));
            end
        end % unpack 
        function cal  = dicoms2cell(this)
            %% DICOMS2CELL
            %  Usage:   cal = obj.dicoms2cell
            %           ^ series-info embedded in CellArrayList
            
            cal = this.unpackInfo2cell(this.structInfo2unpackInfo(this.dicomQuery));
        end % dicoms2cell
        function cal  = unpackInfo2cell(this, unpackInfo)
 			%% UNPACKINFO2CELL
 			%  Usage:  cal = obj.unpackInfo2cell(unpackInfo)
            %                                 ^ struct-array with fields:  index, seq_type, ext, name
            %          ^ session info embedded in CellArrayList
            
            cal = this.unpackDicom(this.dicomPath, this.unpackPath, unpackInfo);
            assert(cal.length > 0);
 		end % unpackInfo2cell
    end % methods
    
    %% PROTECTED
    
    methods (Access = 'protected')
 		function this = AbstractDicomConverter(mrpth)
            %% ABSTRACTDICOMCONVERTER is the abstract interface for DICOM conversion strategies
                       
            this = this@mlfourd.AbstractConverter(mrpth);
 		end % ctor         
    end % protected methods
    
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
        unknownFqFilenames_
    end % private properties

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

