classdef PETConverter < mlfourd.AbstractConverter
    %% PETconverter converts ECAT_EXACT or Analyze files to fsl formats
    %  TODO:  refactor into a composite pattern
    %
    % Created by John Lee on 2008-12-26.
    % Copyright (c) 2008 Washington University School of Medicine. All rights reserved.
    % Report bugs to bug.jjlee.wustl.edu@gmail.com.
    %
    %       Herscovitch P, Markham J, Raichle ME. Brain blood flow measured
    % with intravenous H2(15)O: I. theory and error analysis.
    % J Nucl Med 1983;24:782?789
    %
    %       Videen TO, Perlmutter JS, Herscovitch P, Raichle ME. Brain
    % blood volume, blood flow, and oxygen utilization measured with
    % O-15 radiotracers and positron emission tomography: revised metabolic
    % computations. J Cereb Blood Flow Metab 1987;7:513?516
    %
    %       Herscovitch P, Raichle ME, Kilbourn MR, Welch MJ. Positron
    % emission tomographic measurement of cerebral blood flow and
    % permeability: surface area product of water using [15O] water and
    % [11C] butanol. J Cereb Blood Flow Metab 1987;7:527?542
    %

    properties (Constant)
        modalityFolders = {'ECAT_EXACT'};  
        orients2fix     = struct('img_type', { 'ptr' 'poc' 'poo' 'pho' 'ctr' 'coc' 'coo' 'cho' 'tr_default' 'ho_default' 'oo_default' 'oc_default'}, ...
                              'orientation', { 'y'   'y'   'y'   'y'   'y'   'y'   'y'   'y'   'y'          'y'          'y'          'y'}); 
        unpackFolders   = {'962_4dfp'};
        cossexp         = 'cs01-999-(?<tracer>\w{2})\d{1}(?<sum>_\w+|)(.4dfp|).nii.gz';
        petexp          =    'p\d{4}(?<tracer>\w{2})\d{1}(?<sum>_\w+|)(.4dfp|).nii.gz';
        cprefix         = 'c';
        pprefix         = 'p';
    end
    
    properties (SetAccess = 'protected')
        hdrFolder = 'hdr_backup';
    end
    
    properties (Dependent)
          allFileprefixes
          
        hohdrFqFilename
        ochdrFqFilename
        oohdrFqFilename
        hosumFqFilenames
        oosumFqFilenames
           hoFqFilenames 
           ooFqFilenames
           ocFqFilenames
           trFqFilenames
        hosumFqFilename
        oosumFqFilename
           hoFqFilename
           ooFqFilename
           ocFqFilename
           trFqFilename
           
        hosumComposite
        oosumComposite
           hoComposite
           ooComposite
           ocComposite
           trComposite
        hosumSeries
        oosumSeries
           hoSeries
           ooSeries
           ocSeries
           trSeries
           
        petFolder
        folder962
        petPath
        path962
        hdrPath
        tracerTokens
    end
    
    methods (Static)
        function this = convertModalityPath(mpth)
            this = mlfourd.PETConverter(mpth);
            try          
                if (this.islockedFslFolder('.petconverter'))
                    this.archiveFslFolder; 
                    error('mlfourd:DataDirectoryWasLocked', ...
                          'PETConverter.convertModalityPath');
                end                               
                this.convertEcatExact(this.unpackPath, this.petexp, 'p');
                this.convertEcatExact(this.unpackPath, this.cossexp, 'c');
            catch ME
                handwarning(ME);
            end
        end
        function this = convertOnlyPet(modalPth)
            this = mlfourd.PETConverter(modalPth);
            this.convertEcatExact(this.unpackPath, this.petexp, 'p');
        end
        function this = convertOnlyCoss(modalPth)
            this = mlfourd.PETConverter(modalPth);
            this.convertEcatExact(this.unpackPath, this.cossexp, 'c');
        end
        
        function        coss2fsl(sessionPth)
            %% COSS2FSL works in session_path/ECAT_EXACT/coss, converting all *.4dfp.hdr tp NIfTI, 
            %  then preparing HO and OO scans for FSL or Freesurfer workflows.  
            %  *_g3.4dfp.nii.gz files are flipped AP->PA and witten to cossPth/../../fsl.  
            %  New fileprefixes are assigned according to O15Bulder const properties.
            %  Usage:   PETConverter.coss2fsl(session_path)
            
            if (~exist('sessionPth','var'))
                sessionPth = pwd; end
            cossPth = fullfile(sessionPth, 'ECAT_EXACT', 'coss', '');
            assert(lexist(cossPth, 'dir'));
            cd(cossPth);
            fprintf('mlfourd.PETConverter.coss2fsl:  working in filesystem location %s\n', cossPth);
            
            import mlfourd.* mlpet.*;
            try
                 mlbash('for h in *.4dfp.hdr; do fslchfiletype NIFTI_GZ $h; done');
            catch ME
                handexcept(ME);
            end
            createTracerNii('ho', O15Builder.HO_MEANVOL_FILEPREFIX);
            createTracerNii('oo', O15Builder.OO_MEANVOL_FILEPREFIX);
                        
            function nii = createTracerNii(tracerId, fprefix)
                nii            = mlfourd.NIfTI.load(fullfile(cossPth, ['cs01-999-' tracerId '1_g3.4dfp.nii.gz']));            
                nii.img        = flip4d(nii.img, 'y');            
                nii.filepath   = fullfile( ...
                                 filenparts(cossPth,-2), 'fsl', '');
                nii.fileprefix = fprefix;
                nii.save;
            end
        end
            
        function this    = convertSession(sessionPth, varargin)
            import mlfourd.*;
            this = PETConverter.convertModalityPath( ...
                   firstExistingFile( ...
                      sessionPth, ...
                      PETConverter.modalityFolders), ...
                   varargin{:});
        end
        function lastobj = convertSessions(patt, varargin)
            import mlfourd.*;
            dt = mlsystem.DirTool(patt);
            for s = 1:length(dt)
                fprintf('PETConverter will convert:  %s\n', dt.fqdns{s});
                lastobj = PETConverter.convertSession(dt.fqdns{s}, varargin{:});
            end
            assert(~isempty(lastobj));
        end
        function this    = createFromSessionPath(sessionpth)
            %% CREATEFROMSESSIONPATH only instantiates the class at a modality-path
            %  obj = PETonverter.createFromSessionPath(session_path)

            import mlfourd.*;
            this = PETConverter.createFromModalityPath( ...
                firstExistingFile(sessionpth, PETConverter.modalityFolders));
        end
        function this    = createFromModalityPath(mpth)
            this = mlfourd.PETConverter(mpth);
        end     
    end % static methods
    
    methods %% Set/Get all acesssible paths, folders, fileprefixes, filenames 
        function pth  = get.petPath(this)
            for p = 1:length(this.modalityFolders) %#ok<FORFLG>
                pth = fullfile(this.sessionPath, this.modalityFolders{p}, ''); 
                if (lexist(pth)); return; end
            end
            error('mlfourd:PathNotFound', 'could not find any of:  %s', cell2str(this.modalityFolders));
        end % get.pethPath
        function fld  = get.petFolder(this)
            [~,fld] = fileparts(this.petPath);
        end % get.petFolder
        function pth  = get.path962(this)
            pth = this.unpackPath;
        end % get.path962
        function fld  = get.folder962(this)
            fld = this.unpackFolder;
        end % get.folder962
        function pth  = get.hdrPath(this)
            pth = fullfile(this.modalityPath, this.hdrFolder, '');
        end
        function fn   = get.hohdrFqFilename(this)
            fn = this.hdrFqFilename('ho');
        end
        function fn   = get.ochdrFqFilename(this)
            fn = this.hdrFqFilename('oc');
        end
        function fn   = get.oohdrFqFilename(this)
            fn = this.hdrFqFilename('oo');
        end        
        function pref = get.allFileprefixes(this)
            pref = {};
            tracers = mlfourd.NamingRegistry.tracers;
            pref = [pref cellfun(@(x) [this.cprefix x], tracers, 'UniformOutput', false)];
            pref = [pref cellfun(@(x) [this.pprefix x], tracers, 'UniformOutput', false)];
        end % get.allFileprefixes
        function fns  = get.hoFqFilenames(this)
            fns = this.modalFqFilenames('ho');
        end % get.hoFqFilenames
        function fns  = get.hosumFqFilenames(this)
            picks = cell2logical(strfind(this.hoFqFilenames, 'sum'));
            pickf = cell2logical(strfind(this.hoFqFilenames, '_f')) & cell2logical(strfind(this.hoFqFilenames, 'to'));
            fns   = this.hoFqFilenames(picks | pickf); 
        end % get.hosumFqFilenames
        function fns  = get.ooFqFilenames(this)
            fns = this.modalFqFilenames('oo');
        end % get.ooFqFilenames
        function fns  = get.oosumFqFilenames(this)
            picks = cell2logical(strfind(this.ooFqFilenames, 'sum'));
            pickf = cell2logical(strfind(this.ooFqFilenames, '_f')) & cell2logical(strfind(this.ooFqFilenames, 'to'));
            fns   =  this.ooFqFilenames(picks | pickf); 
        end % get.oosumFqFilenames
        function fns  = get.ocFqFilenames(this)
            fns = this.modalFqFilenames('oc'); 
        end % get.ocFqFilenames
        function fns  = get.trFqFilenames(this)
            fns = this.modalFqFilenames('tr'); 
        end % get.trFqFilenames   
        function fn   = get.hosumFqFilename(this)
            fn = mlchoosers.ImagingChoosers.brightest(this.hosumFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.hosumFqFilename is empty');
        end
        function fn   = get.oosumFqFilename(this)
            fn = mlchoosers.ImagingChoosers.brightest(this.oosumFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.oosumFqFilename is empty');
        end
        function fn   = get.hoFqFilename(this)
            fn = mlchoosers.ImagingChoosers.brightest(this.hoFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.hoFqFilename is empty');
        end
        function fn   = get.ooFqFilename(this)
            fn = mlchoosers.ImagingChoosers.brightest(this.ooFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.ooFqFilename is empty');
        end
        function fn   = get.ocFqFilename(this)
            fn = mlchoosers.ImagingChoosers.brightest(this.ocFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.ocFqFilename is empty');
        end
        function fn   = get.trFqFilename(this)
            fn = mlchoosers.ImagingChoosers.brightest(this.trFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.trFqFilename is empty');
        end     
        function tt   = get.tracerTokens(this)
            c  = cellfun(@(x) [this.cprefix x '*'], this.tracers, 'UniformOutput', false);
            p  = cellfun(@(x) [this.pprefix x '*'], this.tracers, 'UniformOutput', false);
            tt = [c p];
        end
    end
    
    methods
        function fns    = modalFqFilenames(this, lbl)
            %% MODALFQFILENAMES uses lazy initialization of a cache of fully-qualified filenames
            
            lbl_ = [lbl 'FqFilenames_'];
            if (isempty(this.(lbl_)))
                this.(lbl_) = this.allFqFilenames(cell2logical(strfind(this.allFqFilenames, lbl)));
            end
            fns = this.(lbl_);
        end 
        function          convertEcatExact(this, varargin)
            %% CONVERTECATEXACT operates entirely within this.unpackPath
            %  Usage:  this.convertEcatExact([regex_for_files, pre-prefix, workPath])
            %                                 ^ this.petexp, this.cossexp
            %                                                  ^ 'p', 'c'
            %                                                              ^ defaults to this.unpackPath
            
            import mlfourd.*;
            p = inputParser;
            addOptional(p, 'fileRegexp', this.petexp,  @ischar);
            addOptional(p, 'prePrefix',  this.pprefix, @ischar);
            addOptional(p, 'workPath',   this.unpackPath, @(x) lexist(x,'dir'));
            parse(p, varargin{:}); 
            workpth = p.Results.workPath;
            
            dtWorkpth = mlsystem.DirTool(fullfile(workpth, '*'));   
            if (~lcontains(dtWorkpth.fns, INIfTI.FILETYPE_EXT))
                this.analyze2nifti(workpth); 
                this.cleanAnalyze(workpth); 
            end
            fns = this.renameTracers(dtWorkpth, p.Results.fileRegexp, p.Results.prePrefix);
            this.orientChange2Standard(workpth);      
            this.orientRepair(fns, this.orients2fix);
        end
        function          copyUnpacked(this, varargin)
            %% COPYUNPACKED also assigns this.allFqFilenames.
            %  @deprecated
            %  Usage:   obj.copyUnpacked(source_path, target_path)
            %           obj.copyUnpacked('ECAT_EXACT/962_4dfp', 'fsl')

            p = inputParser;
            addOptional(p, 'srcpth',  this.path962, @(x) lexist(x,'dir'));
            addOptional(p, 'targpth', this.path962, @ischar);
            parse(p, varargin{:});
            
            targpth = ensuredir(p.Results.targpth);
            this.allFqFilenames = {'dummyfile'};            
            dircoss = mlsystem.DirTool(fullfile(p.Results.srcpth, 'cs01-999-*'));
            fqfns   = this.renameTracers(dircoss, this.cossexp, 'c');
            copyfiles(fqfns, targpth, 'f');
            
            dirpet  = mlsystem.DirTool(fullfile(p.Results.srcpth, 'p*'));
            fqfns   = this.renameTracers(dirpet,  this.petexp,  'p');
            copyfiles(fqfns, targpth, 'f');
        end
        function newfns = renameTracers(this, varargin)
            %% RENAMETRACERS renames tracer files specified by a DirTool object, regex, and a character prefix;
            %  renaming is done in situ.   File contents are unchanged.
            %  Usage:  this.renameTracers([dirtool, regex_for_4dfp, prefix_to_fileprefix])
            %                              ^ mlsystem.DirTool(fullfile(962_4dfp_path, 'cs01-999-*'))
            %                                       ^ this.cossexp  
            %                                                       ^ 'c'
            
            import mlfourd.*;
            p = inputParser;
            addOptional(p, 'dtool',       mlsystem.DirTool(fullfile(this.unpackPath, 'p*4dfp*')), ...
                                                       @(x) isa(x, 'mlsystem.DirTool'));
            addOptional(p, 'regexp44dfp', this.petexp, @(x) ischar(x) && lstrfind(x, '<tracer>') && lstrfind(x, '<sum>'));
            addOptional(p, 'newPrefix'  , 'p',         @(x) ischar(x));
            parse(p, varargin{:});
             fqfns = p.Results.dtool.fqfns;
               fns = p.Results.dtool.fns;
            newfns = {};
            for f = 1:length(fqfns) %#ok<FORFLG>
                workpth = fileparts(fqfns{f});
                names   = regexp(fns{f}, p.Results.regexp44dfp, 'names'); 
                if (~isempty(names))
                    newfn  = fullfilename(workpth, [p.Results.newPrefix names.tracer names.sum]);
                    movefile(fqfns{f}, newfn, 'f');
                    newfns = [newfns newfn]; %#ok<AGROW>
                end
            end
            this.allFqFilenames = [newfns  this.allFqFilenames];
        end
    end 
    
    %% PROTECTED

    methods (Access = 'protected')
        function this = PETConverter(petpth)
            %% PETCONVERTER
            %  Usage:  obj = PETConverter(modality_path) % from creation method
            
            this = this@mlfourd.AbstractConverter(petpth);
            assert(lexist(petpth, 'dir'));
            charlen = length(petpth);
            assert(lstrfind(petpth(charlen-9:charlen), this.modalityFolders));
        end % ctor
        function fn   = hdrFqFilename(this, tracer)
            assert(2 == length(tracer));
            dt = mlsystem.DirTool(fullfile(this.hdrPath, ['*' tracer '*.hdr.info']));
            fn = mlfourd.PETConverter.hdrChoice(dt.fqfns);
            assert(~isempty(fn), 'mlfourd:MissingValues', ['get.' tracer 'hdrFqFilename is empty']);
        end   
    end 
    
end % classdef
