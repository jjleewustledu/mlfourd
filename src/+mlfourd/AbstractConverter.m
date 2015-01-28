classdef AbstractConverter < mlfourd.ConverterInterface
	%% ABSTRACTCONVERTER is the interface for concrete strategies such as SurferDicomConverter, MRIConverter
    %  Abstract properties:       allFileprefixes, modalityFolder, unpackFolders, orients2fix
    %  Abstract static methods:   createFromSessionPath 
    %                             createFromModalityPath
    %                             convertStudy(studyPth, patt)  
    %                             convertSession(sessionPth)  
    %                             convertModalityPath(modalPth)
    %                             orientRepair(this, sourcePth, targetPth) 
    %  Abstract methods:   copyUnpacked(this)  
    %                      modalFqFilenames(this, lbl)  
    %  
    %  Version $Revision: 2627 $ was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AbstractConverter.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: AbstractConverter.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    properties (Constant)
        ODT = 'float';
    end
    
    properties (Dependent)
        allFilenames
        allFqFilenames
        fslPath                       
        modalityFolder     
        modalityPath % rootpath for AbstractConverter objects 
        sessionId
        sessionPath
        studyFolder
        studyPath
        tmpFolder
        tmpPath
        unpackFolder      
        unpackPath  
    end
    
    methods (Static)
        function          parconvertStudy(studyPth, patt)
            if (~exist('patt', 'var'))
                patt = '*'; end
            dt  = mlsystem.DirTool(fullfile(studyPth, patt));
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
            dt  = mlsystem.DirTool(fullfile(studyPth, patt));
            dns = dt.fqdns;
            for d = 1:length(dns)
                try
                    mlfourd.AbstractConverter.convertSession(dns{d}, varargin{:});
                catch ME
                    handwarning(ME);
                end
            end
        end % static convertStudy  
        function          orientRepair(obj, o2fix)
            %% ORIENTCHANGESTRATEGY flips image-objects along requested orientations
            %  Usage:  nifti = AbstractConverter.orientRepair(imgObj, o2fix)
            %                                                 ^ fileprefix, filename, numerics, NIfTIInterface, cell-array
            %                                                         ^ struct
            
            import mlfourd.*;
            if (iscell(obj))
                for b = 1:length(obj)
                    AbstractConverter.orientRepair(obj{b}, o2fix)
                end
            else
                AbstractConverter.reorientByLocation(imcast(obj, 'fqfilename'), o2fix);
            end
        end % static orientRepair 
        function          analyze2nifti(pth)
            %% ANALYZE2NIFTI
            %  Usage:  AbstractConverter.analyze2nifti([full_path])
            
            if (~exist('pth', 'var')); pth = pwd; end
            dt = mlsystem.DirTool(fullfile(pth, '*.hdr'));
            for n = 1:length(dt.fqfns)  %#ok<FORFLG>
                mlbash(['fslchfiletype ' mlfourd.NIfTIInterface.FILETYPE ' ' dt.fqfns{n}]);  
            end
        end % static analyze2nifti       
        
        %% Calls to ImagingChoosers
        
        function fn     = lowestSeriesNumber(fns)
            fn = mlchoosers.ImagingChoosers.lowestSeriesNumber(AbstractConverter.chooseFilename(fns));
        end
        function fns    = mostEntropy(fns)
            fns = mlchoosers.ImagingChoosers.mostEntropy(AbstractConverter.chooseFilenames(fns));
        end
        function fns    = smallestVoxels(fns)
            fns = mlchoosers.ImagingChoosers.smallestVoxels(AbstractConverter.chooseFilenames(fns));
        end
        function fns    = longestDuration(fns)
            fns = mlchoosers.ImagingChoosers.longestDuration(AbstractConverter.chooseFilenames(fns));
        end
        function fns    = timeDependent(fns)
            fns = mlchoosers.ImagingChoosers.timeDependent(AbstractConverter.chooseFilenames(fns));
        end % static timeDependent
        function fns    = notMcf(fns)
            import mlfourd.*;
            fns = FlirtBuilder.notMcf(AbstractConverter.chooseFilenames(fns));
        end % static notMcf
        function fns    = notFlirted(fns)
            import mlfourd.*;
            fns = FlirtBuilder.notFlirted(AbstractConverter.chooseFilenames(fns));
        end % static notFlirted
        function fns    = notBetted(fns)
            import mlfourd.*;
            fns = FlirtBuilder.notBetted(AbstractConverter.chooseFilenames(fns));
        end % static notBetted
        function fns    = isPet(fns)
            fns = mlchoosers.ImagingChoosers.isPet(AbstractConverter.chooseFilenames(fns));
        end % static isPet
        function fns    = notIsPet(fns)
            fns = mlchoosers.ImagingChoosers.notIsPet(AbstractConverter.chooseFilenames(fns));
        end % static notIsPet
    end % static methods

    methods %% GET/SET, increasing order of dependency
        function this = set.allFqFilenames(this, fns)
            fns = ensureCell(fns);
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
                    dt   = mlsystem.DirTool(fullfile(this.fslPath, [this.allFileprefixes{p} '*']));
                    this = this.updateFqFilenames_(dt.fqfns);
                end
            end
            fns = this.allFqFilenames_;
        end % get.allFqFilenames        
        function this = set.allFilenames(this, fns)
            this.allFqFilenames = cellfun(@(x) fullfile(this.fslPath, x), fns, 'UniformOutput', false);
        end % set.allFilenames
        function fns  = get.allFilenames(this)
            [~,f,e] = cellfun(@(x) filepartsx(x, mlfourd.NIfTIInterface.FILETYPE_EXT), this.allFqFilenames, 'UniformOutput', false);
             fns    = cellfun(@(x,y) [x y], f, e, 'UniformOutput', false);
        end % get.allFilenames    
        function this = set.modalityPath(this, pth)
            assert(lexist(pth, 'dir'));
            this.modalityPath_ = pth;
        end % set.modalityPath
        function pth  = get.modalityPath(this)
            pth = this.modalityPath_;
            assert(lexist(pth, 'dir'));
        end % get.modalityPath    
        function fld  = get.modalityFolder(this)
            [~,fld] = filepartsx(this.modalityPath, mlfourd.NIfTIInterface.FILETYPE_EXT);
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
                              this.namingRegistry_.sessionIdPrefixes, 'UniformOutput', false));
                matches = this.namingRegistry_.sessionIdPrefixes(matches);                
                this.sessionPath_ = parentfile(this.modalityPath, matches);
            end
            pth = this.sessionPath_;
        end % get.sessionPath   
        function fld  = get.sessionId(this)
            [~,fld] = filepartsx(this.sessionPath, mlfourd.NIfTIInterface.FILETYPE_EXT);
        end % get.sessionId
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
    
    %% PROTECTED
    
    properties (Access = 'protected') 
 		analyzeFiles2Clean_ = ...
            { '*lat*' '*g3*'  '*_xr3d*'      '*_msk*'       '*_sqrt*'      '*_t4' '*.ifh' '*.img.rec' ...
              '*_b100.4dfp.*' '*_b10.4dfp.*' '*_b20.4dfp.*' '*_b30.4dfp.*' '*_b40.4dfp.*' ...
              '*_b50.4dfp.*'  '*_b60.4dfp.*' '*_b70.4dfp.*' '*_b80.4dfp.*' '*_b90.4dfp.*' }; 
        allFqFilenames_
        modalityPath_
        namingRegistry_   
        sessionPath_  
        studyPath_  
        unorientedFolder_ = 'Unoriented';
        unpackPath_ 
    end 

    methods (Static)
        function mpth = findModalityPath(fhandle, mfolds, pth, varargin)
            p = inputParser;
            addRequired(p, 'pth', @(x) lexist(x,'dir'));
            addOptional(p, 'depth', 0, @isnumeric);
            parse(p, pth, varargin{:});
            pth1 = p.Results.pth;
            depth1 = p.Results.depth;
            
            mpth = searchWithinPath(mfolds, pth1);
            if (~isempty(mpth))
                return; end
            if (depth1 > 0)
                searching = mlsystem.DirTool(fullfile(pth1, '*', ''));
                for s = 1:length(searching.fqdns)
                    mpth = fhandle( ...
                        searching.fqdns{s}, depth1 - 1);
                    if (~isempty(mpth))
                        break; end
                end
            end
            
            function mpth = searchWithinPath(mfolds, pth)
                mpth = '';           
                for m = 1:length(mfolds)
                    idxfound = strfind(pth, mfolds{m});
                    if (length(idxfound) > 1)
                        idxfound = idxfound(1); end
                    if (~isempty(idxfound))
                        mpth = fullfile(pth(1:idxfound-1), mfolds{m}, ''); 
                        break
                    end
                end
            end
        end         
    end
    
    methods (Static, Access = 'protected') 
        function ff   = folders2files(ff)
            if (lexist(ff, 'dir'))
                dt = mlpatterns.DirTool(fullfile(ff, '*'));
                ff = dt.fqfns;
            end
        end
        function fns  = chooseFilenames(fns)
            fns = mlchoosers.ImagingChoosers.ensureFilenameSuffixes(fns);
            fns = chooseFilenames(fns);
        end
        function fn   = chooseFilename(fn)
            fn = mlchoosers.ImagingChoosers.ensureFilenameSuffix(fn);
            fn = chooseFilename(fn);
        end
    end
    
    methods (Access = 'protected')
        function this = AbstractConverter(modalPth)
            %% ABSTRACTCONVERTER
            %  Usage:  obj = AbstractConverter(modality_path)
            
            assert(lexist(modalPth, 'dir'), 'mlfourd.AbstractConverter could not find modality path %s', modalPth);
            this.modalityPath = modalPth;
            this.namingRegistry_ = mlfourd.NamingRegistry.instance;
        end % ctor   
        function        cleanAnalyze(this, pth)
            %% CLEANANALYZE
            %  Usage:  obj.cleanAnalyze([full_path]);

            if (~exist('pth', 'var')); pth = pwd; end
            toclean = cellfun(@(x) fullfile(pth, x), this.analyzeFiles2Clean_, 'UniformOutput', false);
            bakpth  = ensureFolderExists(fullfile(pth, this.namingRegistry_.backupFolder));
            for f = 1:length(toclean) 
                dirclean = mlsystem.DirTool(toclean{f});
                for d = 1:length(dirclean.fqfns)
                    try
                        movefile(dirclean.fqfns{d}, bakpth, 'f');
                    catch ME
                        handerror(ME);
                    end
                end
            end
        end % cleanAnalyze
        function tf   = islockedFslFolder(this, foldname)
            tf = lexist(fullfile(this.fslPath, foldname, ''));
        end
        function        lockFslFolder(this, foldname)
            try
                r = ''; [~,r] = mlbash( ...
                    sprintf('mkdir %s',  ...
                             fullfile(this.fslPath, foldname, ''))); %#ok<NASGU>
            catch ME
                handexcept(ME, r);
            end
        end
        function        archiveFslFolder(this)
            archive(this.fslPath, mlfourd.NamingRegistry.instance.datestamp); 
            mkdir(fslpth);
        end
        function        removePreviouslyUnpacked(this)
            if (lexist(this.unpackPath))
                mlbash(sprintf('rm -rf %s', this.unpackPath)); end
        end
        function        orientChange2Standard(this, fslpth)
            %% ORIENTCHANGE2STANDARD backups up unoriented .nii, converts to .nii.gz, 
            %  converts to float and fixes listings of orients2fix
            %
            %  Usage:   obj.orientChange2Standard(fsl_path)
            
            assert(lexist(fslpth,'dir')); 
            unoriented =                fullfile(fslpth,  this.unorientedFolder_, '');
            backupfiles(                fullfile(fslpth, '*.nii'), unoriented);
            dobusiness(mlsystem.DirTool(fullfile(fslpth, '*.nii')));       
            
            function dobusiness(dt)
                for n = 1:length(dt.fqfns) %#ok<FORFLG>
                    mlbash(['fslchfiletype NIFTI_GZ ' dt.fqfns{n}]);
                    fp = fileprefix(dt.fqfns{n});
                    this.ensureFloat(fp);
                    this.ensureOriented2Standard(fp);
                end
            end
        end % orientChange2Standard  
    end 
    
    %% PRIVATE
    
    methods (Static, Access = 'private')
        function ensureFloat(fstr)
            %% ENSUREFLOAT

            EXTS = { '.nii.gz' '.nii' }; 
            fstr = stripexts(fstr, EXTS);
            import mlfourd.* mlfsl.*;
            try
                [~,datType] = mlbash(['fslinfo  ' fstr ' | grep data_type']);
                if (~lstrfind(datType, upper(AbstractConverter.ODT))) 
                    FslBuilder.fslmaths([fstr ' ' tempfp(fstr) ' -odt ' lower(AbstractConverter.ODT)]);
                    moveTempBack(tempfp(fstr), fstr, EXTS);
                end
            catch ME
                handwarning(ME);
            end
            
            function [s,r] = moveTempBack(tfn, fn, exts)
                exts = ensureCell(exts);
                for e = 1:length(exts)
                    [s,r] = mlbash( ...
                        sprintf('mv -f %s%s %s%s', tfn, exts{e}, fn, exts{e}));
                end
            end
            function fn    = stripexts(fn, exts)
                for e = 1:length(exts)
                    if (lstrfind(fn, exts{e}))
                        fn = fileprefix(fn, exts{e}); end
                end
            end
            function fp    = tempfp(fp)
                fp = [fp '_' datestr(now,1)];
            end
        end % static ensureFloat
        function ensureOriented2Standard(fp)
            try
                r = ''; [~,r] = mlbash( ...
                    sprintf('fslreorient2std %s %s', fp, fp)); %#ok<NASGU>
            catch ME
                handwarning(ME,r);
            end
        end   
        function reorientByLocation(fstr, o2fix)
            %% FIXORIENTBYLOCATION
            %  Uses:   AbstractConverter.reorientByLocation(file_location, orientations_to_fix) 
            %                                               ^ path to files or filenames
            %                                                              ^ struct
            
            import mlfourd.*;
            fstr = ensureCell( ...
                   AbstractConverter.folders2files(fstr));
            cellfun(@(x) AbstractConverter.reorientFile(x, o2fix), fstr, 'UniformOutput', false);

        end % static reorientByLocation  
        function reorientFile(fqfn, o2fix)
            import mlfourd.*;
            AbstractConverter.fixImageLeafOrientLeaf( ...
                NIfTI.load(fqfn), o2fix);
        end % static reorientFile        
        function fixImageLeafOrientLeaf(imobj, o2fix)
            %% FIXIMAGELEAFORIENTLEAF is the final common function
            %  fixImageLeafOrientLeaf(img, o2fix)
            %                         ^ NIfTIInterface
            %                              ^ struct('img_type', string_pattern, 'orientation', axis_char), may be array
            
            assert(isa(imobj, 'mlfourd.NIfTIInterface'));
            assert(isstruct(o2fix));
            assert(isfield( o2fix, 'img_type'));
            assert(isfield( o2fix, 'orientation'));
            for o = 1:length(o2fix)
                try
                    if (~isempty(strfind(imobj.fileprefix, o2fix(o).img_type)))
                        imobj = imcast( ...
                                    flip4d( ...
                                        imcast(imobj, 'mlfourd.NIfTI'), o2fix(o).orientation), 'mlfourd.NIfTI');
                        mlbash(sprintf('rm -f %s.nii*', imobj.fqfileprefix));
                        imobj.save;
                    end
                catch ME
                    handwarning(ME);
                end
            end
        end 
    end 
    
    methods (Access = 'private')
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
    end
    
end % AbstractConverter
