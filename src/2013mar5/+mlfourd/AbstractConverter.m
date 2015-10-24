classdef AbstractConverter < mlfourd.ConverterInterface
	%% ABSTRACTCONVERTER is the interface for concrete strategies such as SurferDicomConverter, MRIConverter
    %  Abstract properties:  allFileprefixes, modalityFolders, unpackFolders, orients2fix
    %  
    %  Version $Revision: 2318 $ was created $Date: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AbstractConverter.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: AbstractConverter.m 2318 2013-01-20 06:52:48Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    %% ABSTRACTIONS
    
    properties (Abstract, Constant)
        modalityFolders
    end
    
    properties (Abstract)
        allFileprefixes
        orients2fix
        unpackFolders
    end

    methods (Static, Abstract)
        convertModalityPath(modalPth)
        convertSession(sessionPth, varargin)
        convertSessions(patt, varargin)
        createFromModalityPath(modalPth)
    end
    
    methods (Abstract)
        copyUnpacked(this, sourcePth, targetPth)
        modalFqFilenames(this, lbl)
    end

    %% CONCRETE 
    
    properties (Constant)
        ODT = 'float';
    end
    
    properties (Dependent)
        allFilenames
        allFqFilenames  
        fslPath                       
        modalityFolder 
        modalityPath % rootpath for AbstractConverter objects 
        sessionFolder      
        sessionPath
        studyFolder
        studyPath
        tmpFolder
        tmpPath   
        unknownFqFilename 
        unknownFqFilenames 
        unpackFolder      
        unpackPath  
    end
    
    methods (Static)
        function          parconvertStudy(studyPth, patt)
            if (~exist('patt', 'var'))
                patt = '*'; end
            dt = mlfourd.DirTool(fullfile(studyPth, patt));
            dns = dt.fqdns;
            handles = cellfun(@convertSession, cell(size(dns)));
            matlabpool close force local
            matlabpool local
            parfor d = 1:length(dns)
                try
                    handles{d}(dns{d});
                catch ME
                    handwarning(ME);
                end
            end
            matlabpool close
        end % static convertStudy  
        function          convertStudy(studyPth, patt, varargin)
            if (~exist('patt', 'var'))
                patt = '*'; end
            dt  = mlfourd.DirTool(fullfile(studyPth, patt));
            dns = dt.fqdns;
            for d = 1:length(dns)
                try
                    mlfourd.AbstractConverter.convertSession(dns{d}, varargin{:});
                catch ME
                    handwarning(ME);
                end
            end
        end % static convertStudy
        function this   = createFromSessionPath(sessionpth)
            %% CREATEFROMSESSIONPATH only instantiates the class at a modality-path
            %  obj = SurferDicomConverter.createFromModalityPaty(modality_path)

            import mlfourd.*;
            this = AbstractConverter.createFromModalityPath( ...
                firstExistingFile(sessionpth, AbstractConverter.modalityFolders));
        end
        function          orientRepair(obj, o2fix)
            %% ORIENTCHANGESTRATEGY flips image-objects along requested orientations
            %  Usage:  nifti = AbstractConverter.orientRepair(imgObj, o2fix)
            %                                                         ^ fileprefix, numerics, ImageInterface, cell-array
            %                                                                 ^ struct
            
            import mlfourd.*;
            try
                if (iscell(obj))
                    for b = 1:length(obj)
                        AbstractConverter.orientRepair(obj{b}, o2fix)
                    end
                elseif (isa(obj, 'ImageInterface'))
                    AbstractConverter.reorientByImageInterface(obj, o2fix);
                elseif (isnumeric(obj))
                    AbstractConverter.fixImageLeafOrientLeaf(NIfTI(obj), o2fix);
                elseif (ischar(obj))
                    AbstractConverter.reorientByLocation(obj, o2fix);
                else                
                    handwarning(ME1, ...
                        ['AbstractConverter.orientRepair failed to change ' char(obj) ' to ' char(o2fix)]);
                end
            catch ME
                handwarning(ME);
            end
        end % static orientRepair 
        
        function fns    = brightest(fns)
            import mlfourd.*;
            fns = ImagingParser.brightest(AbstractConverter.ensureFilenames(fns));
        end
        function fn     = lowestSeriesNumber(fns)
            import mlfourd.*;
            fn = ImagingParser.lowestSeriesNumber(AbstractConverter.ensureFilename(fns));
        end
        function fns    = mostEntropy(fns)
            import mlfourd.*;
            fns = ImagingParser.mostEntropy(AbstractConverter.ensureFilenames(fns));
        end
        function fns    = mostNegentropy(fns)
            import mlfourd.*;
            fns = ImagingParser.mostNegentropy(AbstractConverter.ensureFilenames(fns));
        end
        function fns    = smallestVoxels(fns)
            import mlfourd.*;
            fns = ImagingParser.smallestVoxels(AbstractConverter.ensureFilenames(fns));
        end
        function fns    = longestDuration(fns)
            import mlfourd.*;
            fns = ImagingParser.longestDuration(AbstractConverter.ensureFilenames(fns));
        end
        function fns    = timeDependent(fns)
            import mlfourd.*;
            fns = ImagingParser.timeDependent(AbstractConverter.ensureFilenames(fns));
        end % static timeDependent
        function fns    = timeIndependent(fns)
            import mlfourd.*;
            fns = ImagingParser.timeIndependent(AbstractConverter.ensureFilenames(fns));
        end % static timeIndependent
        function fns    = notMcf(fns)
            import mlfourd.*;
            fns = FlirtBuilder.notMcf(AbstractConverter.ensureFilenames(fns));
        end % static notMcf
        function fns    = notFlirted(fns)
            import mlfourd.*;
            fns = FlirtBuilder.notFlirted(AbstractConverter.ensureFilenames(fns));
        end % static notFlirted
        function fns    = notBetted(fns)
            import mlfourd.*;
            fns = FlirtBuilder.notBetted(AbstractConverter.ensureFilenames(fns));
        end % static notBetted
        function fns    = isPet(fns)
            import mlfourd.*;
            fns = ImagingParser.isPet(AbstractConverter.ensureFilenames(fns));
        end % static isPet
        function fns    = notIsPet(fns)
            import mlfourd.*;
            fns = ImagingParser.notIsPet(AbstractConverter.ensureFilenames(fns));
        end % static notIsPet
        function          analyze2nifti(pth)
            %% ANALYZE2NIFTI
            %  Usage:  AbstractConverter.analyze2nifti([full_path])
            
            import mlfourd.*;
            if (~exist('pth', 'var')); pth = pwd; end
            anaList = DirTool(fullfile(pth, '*.hdr'));
            for n = 1:length(anaList.fqfns)  %#ok<FORFLG>
                mlbash(['fslchfiletype ' NIfTI.FILETYPE ' ' anaList.fqfns{n}]);  
            end
        end % static analyze2nifti   
    end % static methods

    methods %% Getters/setters, increasing order of dependency
        function this = set.allFqFilenames(this, fns)
            this.allFqFilenames_ = cell(1,length(fns)); g = 1;
            for f = 1:length(fns)
                if (lexist(fns{f}, 'file'))
                    this.allFqFilenames_{g} = fns{f};
                    g = g + 1;
                end
            end
        end % set.allFqFilenames
        function fns  = get.allFqFilenames(this)
            if (isempty(this.allFqFilenames_))
                for p = 1:length(this.allFileprefixes)
                    dt   = mlfourd.DirTool(fullfile(this.fslPath, [this.allFileprefixes{p} '*']));
                    this = this.updateFqFilenames_(dt.fqfns);
                end
            end
            fns = this.allFqFilenames_;
        end % get.allFqFilenames        
        function this = set.allFilenames(this, fns)
            this.allFqFilenames = cellfun(@(x) fullfile(this.fslPath, x), fns, 'UniformOutput', false);
        end % set.allFilenames
        function fns  = get.allFilenames(this)
            [~,f,e] = cellfun(@(x) filepartsx(x, mlfourd.AbstractImage.FILETYPE_EXT), this.allFqFilenames, 'UniformOutput', false);
             fns    = cellfun(@(x,y) [x y], f, e, 'UniformOutput', false);
        end % get.allFilenames
        function fns  = get.unknownFqFilenames(this)
            fns = this.modalFqFilenames('unknown');
        end  % get.unknownFqFilenames
        function fn   = get.unknownFqFilename(this)
            fn = this.timedepFqFilename('unknown');
        end % get.unknownFqFilename        
        function this = set.modalityPath(this, pth)
            assert(lexist(pth, 'dir'));
            this.modalityPath_ = pth;
        end % set.modalityPath
        function pth  = get.modalityPath(this)
            pth = this.modalityPath_;
            assert(lexist(pth, 'dir'));
        end % get.modalityPath    
        function fld  = get.modalityFolder(this)
            [~,fld] = filepartsx(this.modalityPath, mlfourd.AbstractImage.FILETYPE_EXT);
        end % get.modalityFolder
        function this = set.unpackPath(this, pth)
            this.unpackPath_ = ensureFolderExists(pth);
        end % set.unpackPath
        function pth  = get.unpackPath(this)
            if (isempty(this.unpackPath_))
                this.unpackPath_ = fullfile(this.modalityPath, this.unpackFolder, '');
            end
            pth = this.unpackPath_;
        end % get.unpackPath
        function fld  = get.unpackFolder(this)
            assert(~allempty(this.unpackFolders));
                fld = this.unpackFolders{1};
            for f = 1:length(this.unpackFolders) %#ok<FORFLG>
                fld = this.unpackFolders{f}; 
                if (lexist(fullfile(this.modalityPath, fld))); return; end
            end
        end % get.unpackFolder 
        function this = set.sessionPath(this, pth)
            assert(lstrfind(this.modalityPath, pth));
            if (lexist(pth, 'dir')); this.sessionPath_ = pth; end
        end % set.sessionPath
        function pth  = get.sessionPath(this)
            if (isempty(this.sessionPath_))
                matches = ...
                    cell2logical( ....
                         cellfun(@(x) strfind(this.modalityPath, x), ...
                              this.namingRegistry_.sessionFolderPrefixes, 'UniformOutput', false));
                matches = this.namingRegistry_.sessionFolderPrefixes(matches);                
                this.sessionPath_ = parentfile(this.modalityPath, matches);
            end
            pth = this.sessionPath_;
        end % get.sessionPath   
        function fld  = get.sessionFolder(this)
            [~,fld] = filepartsx(this.sessionPath, mlfourd.AbstractImage.FILETYPE_EXT);
        end % get.sessionFolder
        function this = set.studyPath(  this, pth)
            assert(lstrfind(this.modalityPath, pth));
            if (lexist(pth, 'dir')); this.studyPath_ = pth; end
        end % set.studyPath
        function pth  = get.studyPath(  this)
            if (isempty(this.studyPath_)) 
                this.studyPath_ = parentfile(this.sessionPath, this.namingRegistry_.studyFolderPrefix);  
            end
            pth = this.studyPath_;
        end % get.studyPath
        function fld  = get.studyFolder(this)
            [~,fld] = fileparts(this.studyPath);
        end % get.studyFolder
        function pth  = get.fslPath(this)
            pth = fullfile(this.sessionPath, mlfsl.FslRegistry.instance.fslFolder, '');
        end % get.fslPath
        function pth  = get.tmpPath(this)
            pth = fullfile(this.sessionPath, this.tmpFolder);
        end
        function fld  = get.tmpFolder(this) %#ok<MANU>
            fld = ['Tmp_' datestr(now,1)];
        end     
    end
    
    methods 
        function fns  = timeindFqFilename(this, lbl)
            import mlfourd.*;
            fns = AbstractConverter.mostNegentropy( ...
                  AbstractConverter.smallestVoxels( ...
                  AbstractConverter.timeIndependent(this.([lbl 'FqFilenames']))));            
            assert(~isempty(fns), 'mlfourd:MissingValues', 'timeindFqFilename.fns is empty');
        end % timeindFqFilename
        function fns  = timedepFqFilename(this, lbl)
            import mlfourd.*;
            fns = AbstractConverter.mostNegentropy( ...
                  AbstractConverter.smallestVoxels( ...
                  AbstractConverter.timeDependent(this.([lbl 'FqFilenames']))));            
            assert(~isempty(fns), 'mlfourd:MissingValues', 'timeindFqFilename.fns is empty');
        end % timeindFqFilename        
        function        orientChange2Standard(this, fslpth)
            %% ORIENTCHANGE2STANDARD backups up unoriented .nii, converts to .nii.gz, 
            %  converts to float and fixes listings of orients2fix
            %
            %  Usage:   obj.orientChange2Standard(fsl_path)
            
            import mlfourd.*;  
            assert(lexist(fslpth,'dir')); 
            unoriented = fullfile(fslpth, this.unorientedFolder_, '');
            backupfiles(fullfile(fslpth, '*.nii'), unoriented);
            dt = DirTool(fullfile(fslpth, '*.nii'));
            for n = 1:length(dt.fqfns) %#ok<FORFLG>
                mlbash(['fslchfiletype NIFTI_GZ ' dt.fqfns{n}]);
                fp = fileprefix(dt.fqfns{n});
                this.ensure2Standard(fp);
                this.ensureFloat(fp); 
            end
        end % orientChange2Standard      
        function        cleanAnalyze(this, pth)
            %% CLEANANALYZE
            %  Usage:  obj.cleanAnalyze([full_path]);

            import mlfourd.*;
            if (~exist('pth', 'var')); pth = pwd; end
            toclean = cellfun(@(x) fullfile(pth, x), this.analyzeFiles2Clean_, 'UniformOutput', false);
            bakpth  = ensureFolderExists(fullfile(pth, this.namingRegistry_.backupFolder));
            for f = 1:length(toclean) 
                dirclean = DirTool(toclean{f});
                for d = 1:length(dirclean.fqfns)
                    try
                        movefile(dirclean.fqfns{d}, bakpth, 'f');
                    catch ME
                        handerror(ME);
                    end
                end
            end
        end % cleanAnalyze
    end 
    
    %% PROTECTED
    
    properties (Access = 'protected')
        allFqFilenames_
        modalityPath_
        unpackPath_
        sessionPath_  
        studyPath_
        namingRegistry_       
 		analyzeFiles2Clean_ = ...
            { '*lat*' '*g3*'  '*_xr3d*'      '*_msk*'       '*_sqrt*'      '*_t4' '*.ifh' '*.img.rec' ...
              '*_b100.4dfp.*' '*_b10.4dfp.*' '*_b20.4dfp.*' '*_b30.4dfp.*' '*_b40.4dfp.*' ...
              '*_b50.4dfp.*'  '*_b60.4dfp.*' '*_b70.4dfp.*' '*_b80.4dfp.*' '*_b90.4dfp.*' }; 
        unorientedFolder_   = 'Unoriented';
    end % protected properties

    methods (Access = 'protected')
        function this  = AbstractConverter(modalPth)
            %% ABSTRACTCONVERTER
            %  Usage:  obj = AbstractConverter(modality_path)
            
            this.namingRegistry_ = mlfourd.NamingRegistry.instance;
            assert(lexist(modalPth, 'dir'));
            this.modalityPath = modalPth;
        end % ctor 
        function tf    = islockedFslFolder(this, foldname)
            tf = lexist(fullfile(this.fslPath, foldname, ''));
        end
        function         lockFslFolder(this, foldname)
            try
                r = ''; [~,r] = mlbash( ...
                    sprintf('mkdir %s',  ...
                             fullfile(this.fslPath, foldname, ''))); %#ok<NASGU>
            catch ME
                handexcept(ME, r);
            end
        end
        function fqfns = fqfnsInFslpath(this, patt)
            import mlfourd.* mlfsl.*;
            assert(ischar(patt));
            dt    = DirTool(fullfile(this.fslPath, [patt '*']));
            fqfns = FilenameFilters.notIsFlirted( ...
                    FilenameFilters.notIsBetted(dt.fqfns));
        end
        function fqfns = fqfnsInFslpath0(this, patt)
            import mlfourd.*;
            assert(ischar(patt));
            dt    = DirTool(fullfile(this.fslPath, [patt '*']));
            fqfns = FilenameFilters.notIsFlirted(dt.fqfns);
        end
        function this  = updateFqFilenames_(this, fns)
            %% UPDATEFQFILENAMES_ applies selection rules
            
            if (0 < length(fns))   
                andRules = { (@(x) lexist(x, 'file')) ...
                             (@(x) isempty(strfind(x, '_susan'))) ...
                             (@(x) isempty(strfind(x, '_gauss'))) ...
                             (@(x) isempty(strfind(x, '_on_'  ))) };
                if (1 == length(fns))
                    this = this.updateOneFqfn(fns{1}, andRules);
                else
                    this = this.updateManyFqfns(fns, andRules);                   
                end
            end
        end
        function this  = updateManyFqfns(this, fns, andRules)
            for f = 1:length(fns)
                this = this.updateOneFqfn(fns{f}, andRules);
            end 
        end
        function this  = updateOneFqfn(this, fn, andRules)
            if (all(cell2logical(cellfunDual(andRules, fn))))
                this.allFqFilenames_ = [this.allFqFilenames_ {fn}];
            end
        end
        function         archiveFslFolder(this)
            archive(this.fslPath, mlfourd.NamingRegistry.instance.datestamp); 
            mkdir(fslpth);
        end
    end % protected methods

    %% PRIVATE
        
    methods (Static) %, Access = 'private')
        function         ensureFloat(fp)
            %% ENSUREFLOAT

            try
                import mlfourd.* mlfsl.*;
                [~,datType] = mlbash(['fslinfo  ' fp ' | grep data_type']);
                if (~lstrfind(datType, upper(AbstractConverter.ODT))) 
                    FslBuilder.fslmaths( ...
                        [fp ' ' AbstractConverter.tempFileprefix(fp) ' -odt ' lower(AbstractConverter.ODT)]);
                    AbstractConverter.moveTempBack(fp);
                end
            catch ME
                handwarning(ME);
            end
            
            function fn    = stripexts(fn, exts)
                for e = 1:length(exts)
                    if (lstrfind(fn, exts{e}))
                        fn = fileprefix(fn, exts{e}); end
                end
            end
        end % static ensureFloat
        function         ensure2Standard(fp)
            try
                mlbash( ...
                    stringf('fslreorient2std %s %s',  ...
                             fp, AbstractConverter.tempFileprefix(fp)));
                AbstractConverter.moveTempBack(fp);
            catch ME
                handwarning(ME);
            end
        end
        function [s,r] = moveTempBack(fp, exts)
            tfp = mlfourd.AbstractConverter.tempFileprefix(fp);
            if (~lexist('exts','var'))
                exts = '.nii.gz'; end
            exts = ensureCell(exts);
            for e = 1:length(exts)
                assert(lexist([tfp exts{e}], 'file'));
                [s,r] = mlbash( ...
                    sprintf('mv -f %s%s %s%s', tfp, exts{e}, fp, exts{e}));
            end
        end
        function fp    = tempFileprefix(fp)
            fp = [fp '_' datestr(now,1)];
        end
        function fns   = ensureFilenames(fns)
            fns = mlfourd.ImagingParser.ensureFilenameSuffixes(fns);
            fns = ensureFilenames(fns);
        end
        function fn    = ensureFilename(fn)
            fn = mlfourd.ImagingParser.ensureFilenameSuffix(fn);
            fn = ensureFilename(fn);
        end
        function       reorientByImageInterface(imgint, o2fix)
            import mlfourd.*;
            nii = NIfTI(imgint);
            AbstractConverter.fixImageLeafOrientLeaf(nii, o2fix);
        end
        function       reorientByLocation(fstr, o2fix)
            %% FIXORIENTBYLOCATION
            %  Uses:   AbstractConverter.reorientByLocation(path_to_files) 
            %                                                ^ or filename
            
            import mlfourd.*;
            fstr = filename(fstr, '.nii.gz');
            if (lexist(fstr, 'dir'))
                AbstractConverter.reorientInFolder(fstr, o2fix);
            elseif (lexist(fstr, 'file'))
                AbstractConverter.reorientFile(fstr, o2fix);
            else
                error('mlfourd:UnsupportedType', ...
                      'AbstractConverter.reorientByLocation.fstr->%s, class(fstr)->%s', char(fstr), class(fstr));
            end
        end % static reorientByLocation  
        function       reorientInFolder(fld, o2fix)
            import mlfourd.*;
            dt = DirTool(fullfile(fld, NamingRegistry.instance.allNIfTI));
            for d = 1:length(dt.fqfns) 
                AbstractConverter.reorientFile(dt.fqfns{d}, o2fix); 
            end
        end % static reorientInFolder
        function       reorientFile(fqfn, o2fix)
            import mlfourd.*;
            AbstractConverter.fixImageLeafOrientLeaf(NIfTI.load(fqfn), o2fix);
        end % static reorientFile        
        function       fixImageLeafOrientLeaf(img, o2fix)
            %% FIXIMAGELEAFORIENTLEAF is the final common function
            %  fixImageLeafOrientLeaf(img, o2fix)
            %                         ^ ImageInterface
            %                              ^ struct('img_type', string_pattern, 'orientation', axis_char), may be array
            
            assert(isstruct(o2fix));
            assert(isfield( o2fix, 'img_type'));
            assert(isfield( o2fix, 'orientation'));
            for o = 1:length(o2fix)
                if (~isempty(strfind(img.fileprefix, o2fix(o).img_type)))
                    img = flip4d(img, o2fix(o).orientation);
                    delete(img.fqfilename);
                    img.save;
                end
            end
        end % static reorientNIfTI
        function       changeFiletype(this, fn)
        end  
    end % static private helper methods
    
end % AbstractConverter
