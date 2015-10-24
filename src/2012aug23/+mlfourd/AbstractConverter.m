classdef AbstractConverter < mlfourd.ConverterInterface
	%% ABSTRACTCONVERTER is the interface for concrete strategies such as SurferDicomConverter, MRIConverter
    %  Abstract properties:  allFileprefixes, modalityFolders, unpackFolders, orients2fix
    %  Abstract static methods:   creation(modalPth) createFromSessionPath createFromModalityPath
    %                             convertStudy(studyPth, patt)  
    %                             convertSession(sessionPth)  
    %                             fixOrient(obj, o2fix)  
    %  Abstract methods:   unpack(this)  
    %                      rename(this, sourcePth, targetPth) 
    %                      modalFqFilenames(this, lbl)  
    %  
    %  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/AbstractConverter.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: AbstractConverter.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Constant)
        FSL_FOLDER = 'fsl';
        ODT        = 'float';
    end
    
    properties (Dependent)
        allFilenames
        allFqFilenames
        unknownFqFilenames        
        unknownFqFilename                      
        modalityPath % rootpath for AbstractConverter objects   
        modalityFolder     
        unpackPath  
        unpackFolder      
        sessionPath
        sessionFolder
        studyPath
        studyFolder
        fslFolder
        fslPath
        tmpFolder
        tmpPath
    end % dependent properties
    
    methods (Static)
        function fns    = brightest(fns)
            fns = ensureFilenames(mlfourd.ImageBuilder.brightest(fns));
        end
        function fn     = lowestSeriesNumber(fns)
            fn = ensureFilename(mlfourd.ImageBuilder.lowestSeriesNumber(fns));
        end
        function fns    = mostEntropy(fns)
            fns = ensureFilenames(mlfourd.ImageBuilder.mostEntropy(fns));
        end
        function fns    = mostNegentropy(fns)
            fns = ensureFilenames(mlfourd.ImageBuilder.mostNegentropy(fns));
        end
        function fns    = smallestVoxels(fns)
            fns = ensureFilenames(mlfourd.ImageBuilder.smallestVoxels(fns));
        end
        function fns    = longestDuration(fns)
            fns = ensureFilenames(mlfourd.ImageBuilder.longestDuration(fns));
        end
        function fns    = timeDependent(fns)
            fns = ensureFilenames(mlfourd.ImageBuilder.timeDependent(fns));
        end % static timeDependent
        function fns    = timeIndependent(fns)
            fns = ensureFilenames(mlfourd.ImageBuilder.timeIndependent(fns));
        end % static timeIndependent
        function fns    = notMcf(fns)
            fns = ensureFilenames(mlfourd.FlirtFacade.notMcf(fns));
        end % static notMcf
        function fns    = notFlirted(fns)
            fns = ensureFilenames(mlfourd.FlirtFacade.notFlirted(fns));
        end % static notFlirted
        function fns    = notBetted(fns)
            fns = ensureFilenames(mlfourd.FlirtFacade.notBetted(fns));
        end % static notBetted
        function fns    = notPet(fns)
            fns = ensureFilenames(mlfourd.ImageBuilder.notPet(fns));
        end % static notPet
     
        function spth   = findsubpath( pth, patts)
            %% FINDSUBPATH
            %  Usage:   subpath = AbstractConverter.findsubpath(path_string, patterns)
            %           ^ substring of path_string that contains pattern
            %                                                                ^ string or cell-array of             
            
            assert(ischar(pth));
            patts   = ensureCell(patts);            
            ca      = regexp(pth, filesep, 'split');
            for p   = 1:length(patts) %#ok<FORFLG>
                idx = findindex(ca, patts{p}); 
                if (~isempty(idx))
                    spth = filenparts(pth, idx-1);  
                    break
                else
                    spth = pth;
                end
            end
            if (strcmp(filesep, spth(end))); spth = spth(1:end-1); end
        end % static findsubpath
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
        function          fixOrient(obj, o2fix)
            %% FIXORIENT flips image-objects along requested orientations
            %  Usage:  nifti = AbstractConverter.fixOrient(imgObj, o2fix)
            %                                              ^ fileprefix, numerics, ImageInterface, cell-array
            %                                                      ^ struct
            
            import mlfourd.*;
            if (iscell(obj))
                for b = 1:length(obj)
                    AbstractConverter.fixOrient(obj{b}, o2fix)
                end
            elseif (isa(obj, 'mlfourd.ImageInterface'))
                AbstractConverter.fixOrientByImageInterface(obj, o2fix);
            elseif (isnumeric(obj))
                AbstractConverter.fixImageLeafOrientLeaf(NIfTI(obj), o2fix);
            elseif (ischar(obj))
                AbstractConverter.fixOrientByLocation(obj, o2fix);
            else                
                handwarning(ME1, ['AbstractConverter.fixOrient failed for ' char(obj) ' oriented ' char(o2fix)]);
            end       
        end % static fixOrient 
    end % static methods
    
    methods (Static, Access = 'private')
        function          fixOrientByImageInterface(imgint, o2fix)
            import mlfourd.*;
            nii = NIfTI(imgint);
            AbstractConverter.fixImageLeafOrientLeaf(nii, o2fix);
        end
        function          fixOrientByLocation(fstr, o2fix)
            %% FIXORIENTBYLOCATION
            %  Uses:   AbstractConverter.fixOrientByLocation(path_to_files) 
            %                                                ^ or filename
            
            import mlfourd.*;
            if (lexist(fstr, 'dir'))
                AbstractConverter.fixOrientInFolder(fstr, o2fix);
            elseif (lexist(fstr, 'file'))
                AbstractConverter.fixOrientOfFile(fstr, o2fix);
            else
                error('mlfourd:UnsupportedType', ...
                      'AbstractConverter.fixOrientByLocation.fstr->%s, class(fstr)->%s', char(fstr), class(fstr));
            end
        end % static fixOrientByLocation  
        function          fixOrientInFolder(fld, o2fix)
            import mlfourd.*;
            dt = DirTool(fullfile(fld, NamingRegistry.instance.allNIfTI));
            for d = 1:length(dt.fqfns) 
                AbstractConverter.fixOrientOfFile(dt.fqfns{d}, o2fix); 
            end
        end % static fixOrientInFolder
        function          fixOrientOfFile(fqfn, o2fix)
            mlfourd.AbstractConverter.fixImageLeafOrientLeaf(mlfourd.NIfTI.load(fqfn), o2fix);
        end % static fixOrientOfFile        
        function          fixImageLeafOrientLeaf(img, o2fix)
            %% FIXIMAGELEAFORIENTLEAF is the final common function
            %  fixImageLeafOrientLeaf(img, o2fix)
            %                         ^ mlfourd.ImageInterface
            %                              ^ struct('img_type', string_pattern, 'orientation', axis_char), may be array
            
            assert(isa(img, 'mlfourd.ImageInterface'));
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
        end % static fixOrientOfNIfTI
    end % static private helper methods
    
    methods
        
        %% Getters/setters, increasing order of dependency

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
            [~,f,e] = cellfun(@(x) fileparts(x), this.allFqFilenames, 'UniformOutput', false);
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
            [~,fld] = fileparts(this.modalityPath);
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
                              this.namereg_.sessionFolderPrefixes, 'UniformOutput', false));
                matches = this.namereg_.sessionFolderPrefixes(matches);                
                this.sessionPath_ = mlfourd.AbstractConverter.findsubpath( ...
                                    this.modalityPath, matches);
            end
            pth = this.sessionPath_;
        end % get.sessionPath   
        function fld  = get.sessionFolder(this)
            [~,fld] = fileparts(this.sessionPath);
        end % get.sessionFolder
        function this = set.studyPath(  this, pth)
            assert(lstrfind(this.modalityPath, pth));
            if (lexist(pth, 'dir')); this.studyPath_ = pth; end
        end % set.studyPath
        function pth  = get.studyPath(  this)
            if (isempty(this.studyPath_)) 
                this.studyPath_ = mlfourd.AbstractConverter.findsubpath( ...
                                  this.sessionPath, this.namereg_.studyFolderPrefix);  
            end
            pth = this.studyPath_;
        end % get.studyPath
        function fld  = get.studyFolder(this)
            [~,fld] = fileparts(this.studyPath);
        end % get.studyFolder
        function pth  = get.fslPath(this)
            pth = fullfile(this.sessionPath, this.FSL_FOLDER, '');
        end % get.fslPath
        function fld  = get.fslFolder(this)
            fld = this.FSL_FOLDER;
        end % get.fslFolder
        function pth  = get.tmpPath(this)
            pth = fullfile(this.sessionPath, this.tmpFolder);
        end
        function fld  = get.tmpFolder(this) %#ok<MANU>
            fld = ['Tmp_' datestr(now,1)];
        end     
        
        %% Useful methods        
        
        function        ensureFloat(this, fstr, ext)
            %% ENSUREFLOAT
            
            import mlfourd.*;
            if (~exist('ext', 'var')); ext = NIfTI.FILETYPE_EXT; end
            pwd0 = fileparts( fstr);
            fp   = fileprefix(fstr, ext);
            fn   =   filename(fp,   ext);
            assert(lexist(fn, 'file')); 
            [~,datType] = mlbash(['fslinfo  ' fp ' | grep data_type']);
            try
                mkdir(this.tmpPath);
                tmpFn = fullfile(this.tmpPath, fn);
                if (~lstrfind(datType, 'FLOAT')) 
                    mlfsl.FslFacade.fslmaths([fn ' ' tmpFn ' -odt ' AbstractConverter.ODT]);
%                     if (~lstrfind(tmpFn, '.gz'))
%                         tmpFn = gzip(tmpFn);
%                     end
                    movefile(tmpFn, pwd0, 'f');
                end
            catch ME
                handwarning(ME);
            end
        end % ensureFloat
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
        function        reorient2std(this, fslpth)
            %% REORIENT2STD backups up unoriented .nii, converts to float and fixes orients2fix
            %  Usage:   obj.reorient2std(fsl_path)
            
            import mlfourd.*;            
            assert(lexist(fslpth,'dir'), 'reorient2std.fslpth->%s', fslpth); 
            unorientedPth = ensureFolderExists(fullfile(fslpth, this.unorientedFolder_, ''));
            copyfiles(fullfile(fslpth, '*.nii'), unorientedPth);            
            niis          = DirTool(fullfile(fslpth, '*.nii'));
            for n = 1:length(niis.fqfns) %#ok<FORFLG>
                fp = fileprefix(niis.fqfns{n}, '.nii'); 
                fn = [fp '.nii'];
                fz = [fn '.gz'];
                try
                    this.ensureFloat(fn, '.nii');
                    try
                        mlbash(['fslreorient2std ' fz ' ' fz]);
                    catch ME2
                        handwarning(ME2);
                    end
                    try
                        AbstractConverter.fixOrientByLocation(fz, this.orients2fix); 
                    catch ME3
                        handwarning(ME3);
                    end
                catch ME
                    handwarning(ME);
                end
            end
        end % reorient2std  
        function        cleanAnalyze(this, pth)
            %% CLEANANALYZE
            %  Usage:  obj.cleanAnalyze([full_path]);

            import mlfourd.*;
            if (~exist('pth', 'var')); pth = pwd; end
            toclean = cellfun(@(x) fullfile(pth, x), this.analyzeFiles2Clean_, 'UniformOutput', false);
            bakpth  = ensureFolderExists(fullfile(pth, this.namereg_.backupFolder));
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
    end % methods
    
    %% PROTECTED
    
    properties (Access = 'protected')
        allFqFilenames_
        modalityPath_
        unpackPath_
        sessionPath_  
        studyPath_
        namereg_       
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
            
            this.namereg_ = mlfourd.NamingRegistry.instance;
            assert(lexist( modalPth,  'dir'));
            this.modalityPath = modalPth;
        end % ctor        
        function fn    = formFilename(patt, varargin)
            fn = mlfourd.NamingRegistry.instance.formFilename(patt, varargin{:});
        end
        function fqfns = fqfnsInFslpath(this, patt)
            import mlfourd.*;
            assert(ischar(patt));
            dt    = DirTool(fullfile(this.fslPath, [patt '*']));
            fqfns = this.smallestVoxels( ...
                    FlirtFacade.notFlirted( ...
                    this.notBetted(dt.fqfns)));
        end
        function fqfns = fqfnsInFslpath0(this, patt)
            import mlfourd.*;
            assert(ischar(patt));
            dt    = DirTool(fullfile(this.fslPath, [patt '*']));
            fqfns = FlirtFacade.notFlirted( ...
                    this.notBetted(dt.fqfns));
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
    end % protected methods

end % AbstractConverter
