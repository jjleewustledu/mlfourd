classdef PETConverter_2013mar4_1800 < mlfourd.AbstractConverter
    %% PETconverter converts ECAT_EXACT or Analyze files to fsl formats
    %  TO DO:   refactor into a composite pattern
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
    end
    
    properties
        orients2fix     = struct('img_type', { 'ptr' 'poc' 'poo' 'pho' 'ctr' 'coc' 'coo' 'cho' }, ...
                              'orientation', { 'y'   'y'   'y'   'y'   'y'   'y'   'y'   'y'   }); 
        unpackFolders   = {'962_4dfp'};
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
            try
                import mlfourd.*
                this = mlfourd.PETConverter(mpth);            
                if (this.islockedFslFolder('.petconverter'))
                    this.archiveFslFolder; 
                    error('mlfourd:DataDirectoryWasLocked', ...
                          'PETConverter.convertModalityPath');
                end
                dirnii = mlsystem.DirTool(this.unpackPath);
                if (~lcontains(dirnii.fns, NIfTId.FILETYPE_EXT))
                    this.analyze2nifti(this.unpackPath);
                end
                this.cleanAnalyze(this.unpackPath);
                this.copyUnpacked(this.unpackPath, this.fslPath);
                this.orientChange2Standard(this.fslPath);                
                this.orientRepair(this.fslPath, this.orients2fix);
                this.lockFslFolder('.petconverter');
            catch ME
                handwarning(ME, r);
            end
        end
        function this = convertSession(sessionPth, varargin)
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
        function this = createFromModalityPath(mpth)
            this = mlfourd.PETConverter(mpth);
        end     
        function fn   = hdrChoice(fns)
            assert(~isempty(fns));
            fn = fns{1};
        end
    end
    
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
            if (isempty(this.ocFqFilenames_))
                [~,f,~] = cellfun(@(x) filepartsx(x, mlfourd.NIfTId.FILETYPE_EXT), this.allFqFilenames, 'UniformOutput', false);
                this.ocFqFilenames_ = this.allFqFilenames(cell2logical(strfind(f, 'oc')));
            end
            fns = this.ocFqFilenames_;
        end % get.ocFqFilenames
        function fns  = get.trFqFilenames(this)
            fns = this.modalFqFilenames('tr'); 
        end % get.trFqFilenames   
        function fn   = get.hosumFqFilename(this)
            fn = mlfourd.PETConverter.brightest(this.hosumFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.hosumFqFilename is empty');
        end
        function fn   = get.oosumFqFilename(this)
            fn = mlfourd.PETConverter.brightest(this.oosumFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.oosumFqFilename is empty');
        end
        function fn   = get.hoFqFilename(this)
            fn = mlfourd.PETConverter.brightest(this.hoFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.hoFqFilename is empty');
        end
        function fn   = get.ooFqFilename(this)
            fn = mlfourd.PETConverter.brightest(this.ooFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.ooFqFilename is empty');
        end
        function fn   = get.ocFqFilename(this)
            fn = mlfourd.PETConverter.brightest(this.ocFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.ocFqFilename is empty');
        end
        function fn   = get.trFqFilename(this)
            fn = mlfourd.PETConverter.brightest(this.trFqFilenames);
            assert(~isempty(fn), 'mlfourd:MissingValues', 'get.trFqFilename is empty');
        end     
        function tt   = get.tracerTokens(this)
            c  = cellfun(@(x) [this.cprefix x '*'], this.tracers, 'UniformOutput', false);
            p  = cellfun(@(x) [this.pprefix x '*'], this.tracers, 'UniformOutput', false);
            tt = [c p];
        end
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
        function        copyUnpacked(this, srcpth, targpth)
            %% RENAME also assigns this.allFqFilenames
            %  Usage:   obj.copyUnpacked(source_path, target_path)
            %           obj.copyUnpacked('ECAT_EXACT/962_4dfp', 'fsl')
            
            import mlfourd.*;
            assert(lexist(srcpth, 'dir'));
            targpth = ensuredir(targpth);
            this.allFqFilenames = {'dummyfile'};
            
            dircoss = mlsystem.DirTool(fullfile(srcpth, 'cs01-999-*'));
            for c = 1:length(dircoss.fqfns) %#ok<FORFLG>
                cnames = regexp(dircoss.fns{c}, this.cossexp, 'names'); 
                if (~isempty(cnames))
                    targFqfn  = fullfilename(targpth, [this.cprefix cnames.tracer cnames.sum]);
                    this.allFqFilenames = [targFqfn  this.allFqFilenames];
                    copyfile(dircoss.fqfns{c}, targFqfn, 'f');
                end
            end
            
            dirpet  = mlsystem.DirTool(fullfile(srcpth, 'p*'));
            for p = 1:length(dirpet.fqfns) %#ok<FORFLG>
                pnames = regexp(dirpet.fns{p},  this.petexp,  'names'); 
                if (~isempty(pnames))
                    targFqfn  = fullfilename(targpth, [this.pprefix pnames.tracer pnames.sum]);
                    this.allFqFilenames = [targFqfn  this.allFqFilenames];
                    copyfile(dirpet.fqfns{p}, targFqfn, 'f');
                end
            end
        end % copyUnpacked 
    end 
    
    %% PROTECTED
    
    properties (Access = 'protected')
        cossexp         = 'cs01-999-(?<tracer>\w{2})\d{1}(?<sum>_\w+|)(.4dfp|).nii.gz';
        petexp          =    'p\d{4}(?<tracer>\w{2})\d{1}(?<sum>_\w+|)(.4dfp|).nii.gz';
        cprefix         = 'c';
        pprefix         = 'p';
    end 
    
    methods (Access = 'protected')
        function this = PETConverter_2013mar4_1800(petpth)
            %% PETCONVERTER
            %  Usage:  obj = PETConverter(pet_path) % from creation method
            
            this = this@mlfourd.AbstractConverter(petpth);
        end % ctor
        function fn   = hdrFqFilename(this, tracer)
            import mlfourd.*;
            assert(2 == length(tracer));
            dt = mlsystem.DirTool(fullfile(this.hdrPath, ['*' tracer '*.hdr.info']));
            fn = PETConverter.hdrChoice(dt.fqfns);
            assert(~isempty(fn), 'mlfourd:MissingValues', ['get.' tracer 'hdrFqFilename is empty']);
        end   
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        hoFqFilenames_
        ooFqFilenames_
        ocFqFilenames_
        trFqFilenames_
    end 
    
end % classdef
