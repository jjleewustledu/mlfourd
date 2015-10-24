classdef ImagingParser
	%% IMAGINGPARSER parses filenames, persistent imaging objects and retrieves them in canonical forms;
    %  Imaging studies must already have been converted/extracted.
    %
	%  Version $Revision: 2318 $ was created $Date: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingParser.m $
 	%  Developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: ImagingParser.m 2318 2013-01-20 06:52:48Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Constant)
        IMAGING_SUFFIXES = {'.nii.gz' '.nii' '.hdr'};
    end
    
    properties (Dependent)
        fslPath
        t1
        t2
        flair
        flair_abs
        gre
        tof
        ep2d
        ep2dMeanvol
        h15o
        o15o
        h15oMeanvol
        o15oMeanvol
        c15o
        tr
    end
    
	methods (Static) 
        function  p    = inputParser(varargin)
            import mlfourd.*;
            p = inputParser;
            addParamValue(p, 'returnType', 'fileprefix', @ImagingParser.validReturnType);
            addParamValue(p, 'fileprefix', '', @ischar);
            addParamValue(p, 'path', ImagingParser.guessFslPath, @ImagingParser.validPath); % defers to any path in fileprefix
            addParamValue(p, 'ensureExists', false);
            addParamValue(p, 'fullyQualified', false);
            addParamValue(p, 'meanvol', false);
            addParamValue(p, 'averaged', '', @ImagingParser.validAveraging);            
            addParamValue(p, 'blocked', 1, @isnumeric);
            addParamValue(p, 'blurred', 0, @isnumeric);            
            addParamValue(p, 'modality', 'mr', @ImagingParser.validModality);
            addParamValue(p, 'brightest', true);
            addParamValue(p, 'lowestSeriesNumber', true);
            addParamValue(p, 'mostNegentropy', true);
            addParamValue(p, 'smallestVoxels', true);
            addParamValue(p, 'longestDuration', false); 
            addParamValue(p, 'timeDependent', false); 
            addParamValue(p, 'isMcf', false);
            addParamValue(p, 'isFlirted', '', @ischar);
            addParamValue(p, 'isBetted', false);
            parse(p, varargin{:});    
        end
        function [pth,fp,e] = decoratedFileparts(p)
            import mlfsl.*;
            [pth,fp,e] = filepartsx(p.Results.fileprefix, mlfourd.AbstractImage.FILETYPE_EXT);
            if (isempty(pth))
                pth = p.Results.path;
            end
            if (p.Results.ensureExists)
                ensureFilenameExists(fullfilename(pth, fp));
            end
            if (p.Results.meanvol)
                fp = FlirtBuilder.ensureMeanvolFilename(fp);
            end
            if (~isempty(p.Results.averaged))
                fp = [fp '_' p.Results.averaged];
            end
            if (prod(p.Results.blocked) > 1)
                fp = FlirtBuilder.blockedFilename(fp, p.Results.blocked);
            end
            if (sum(p.Results.blurred) > 0)
                fp = FlirtBuilder.blurredFilename(fp, p.Results.blurred);
            end
            if (p.Results.isMcf)
                fp = FlirtBuilder.ensureMcfFilename(fp);
            end
            if (~isempty(p.Results.isFlirted))
                fp = FlirtBuilder.flirtedFilename(fp, p.Results.isFlirted);
            end
            if (p.Results.isBetted)
                fp = BetBuilder.bettedFilename(fp);
            end    
            if (isempty(e))
                e = mlfourd.NIfTI.FILETYPE_EXT;
            end
        end
        function obj   = createReturnType(p)
            import mlfourd.*;
            switch (lower(p.Results.returnType))
                case {'fileprefix' 'fp'}
                    obj = ImagingParser.createFileprefix(p);
                case {'filename' 'fn'}
                    obj = ImagingParser.createFilename(p);
                case {'fqfileprefix' 'fqfp'}   
                    obj = ImagingParser.createFqFilename(p);
                case {'fqfilename' 'fqfn'} 
                    obj = ImagingParser.createFqFilename(p);
                case  'nifti'  
                    obj = ImagingParser.createNIfTI(p);
                case {'imagingseries' 'imagingcomposite' 'imagingcomponent'} 
                    obj = ImagingParser.createImagingComponent(p);
                otherwise
                    error('mlfourd:UnsupportedType', 'ImagingParser.createReturnType; p.Results.returnType->%s', ...
                           p.Results.returnType);    
            end 
            if (iscell(obj) && 1 == length(obj))
                obj = obj{1}; 
            end  
        end
        function fps   = createFileprefix(p)
            fps = fileprefixes( ...
                  mlfourd.ImagingParser.createFilename(p));
        end        
        function fns   = createFilename(p)
            import mlfourd.*;            
            fns = ensureCell(ImagingParser.createFqFilename(p));
            if (~p.Results.fullyQualified)
                for f = 1:length(fns)
                    [~,fp,e] = filepartsx(fns{f}, mlfourd.AbstractImage.FILETYPE_EXT);
                    fns{f} = [fp e];
                end
            end
        end
        function fqfps = createFqFileprefix(p)
            import mlfourd.*;
            fqfps = fileprefixes( ...
                    ImagingParser.createFqFilename(p), NIfTI.FILETYPE_EXT, true);
        end
        function fqfns = createFqFilename(p)
            import mlfourd.*;
            [pth,fp,e] = ImagingParser.decoratedFileparts(p);
            fqfns      = ImagingParser.selectModality(fullfilenames(pth, [fp e]), p);
            fqfns      = ImagingParser.applyFiltersByType(fqfns, p);
        end
        function nii   = createNIfTI(p)
            import mlfourd.*;
            imser = ImagingParser.createImagingComponent(p);
            assert(1 == imser.length);
            nii = imser.cachedNext;
        end
        function imcmp = createImagingComponent(p)
            import mlfourd.*;
            imcmp = ImagingComponent.createFromObjects( ...
                    ImagingParser.createFqFilename(p));
        end        
        function fname = formFilename(fname, varargin) 
            %% FORMFILENAME returns a canonical form for the passed filename and attributes 
            %  Usage:    canonical_filename = ...
            %                ImagingParser.formFilename(filename_pattern[, 'fq', complete_path, 'fp', 'betted', 'meanvol', ...])
            %            ^ e.g., /pathtofile/ep2d_020_mcf_meanvol.nii.gz
            %                                           ^ e.g., ep2d_020
            %                                                            ^  'fq' 'fp' 'fn' 'fqfp' 'fqfn'
            %                                                               'betted' 'motioncorrected' 'meanvol'
            %                                                               'fqfilename' requires complete path to be specified 
            %                                                               'average'    requires averaging type
            %                                                               'blur'       requires blur-label
            %                                                               'block'      requires block-label
            %                                                       '                            ^ 'fp', 'betted', ...
            
            import mlfourd.*;
            assert(ischar(fname));
            sname = struct('path', '', 'stem', '', 'ext', '');
            [sname.path,sname.stem,sname.ext] = filepartsx(fname, mlfourd.AbstractImage.FILETYPE_EXT);
            varargin = cellfun(@ensureChar, varargin, 'UniformOutput', false);
            for k = 1:length(varargin) 
                sname = buildFilename(sname, varargin{k});
            end
            fname = fullfile(sname.path, [sname.stem sname.ext]);
            
            function sn = buildFilename(sn, arg)
                import mlfourd.* mlfsl.*;
                switch (lower(arg))
                    case {'fq' 'fullqual' 'fullyqualified'}
                        sn      = makeFullyQualified(sn,k);
                    case {'fqfileprefix' 'fqfp'}
                        sn      = makeFullyQualified(sn,k);
                        sn.ext  = '';
                    case {'fqfilename' 'fqfn'}
                        sn      = makeFullyQualified(sn,k);
                        sn.ext  = NIfTI.FILETYPE_EXT;
                    case {'fp' 'fileprefix'} 
                        sn.path = '';
                        sn.ext  = '';
                    case {'fn' 'filename'}                        
                        sn.path = '';
                    case {'bet' 'betted' 'brain' '_brain'}
                        sn.stem = fileprefix(BetBuilder.bettedFilename(sn.stem));
                    case {'motioncorrect' 'motioncorrected' 'mcf' '_mcf'} 
                        sn.stem = [sn.stem FlirtBuilder.MCF_SUFFIX];
                    case {'meanvol' '_meanvol'} 
                        sn.stem = [sn.stem FlirtBuilder.MEANVOL_SUFFIX];
                    case {'block'   'blocked'}
                        sn.stem = [sn.stem '_' varargin{k+1}];
                    case {'blur'    'blurred'}
                        sn.stem = [sn.stem '_' varargin{k+1}];
                    case {'average' 'averaged' 'aver'}
                        sn.stem = [sn.stem '_' varargin{k+1}];
                    case {'*'}
                        sn.stem = [sn.stem '*'];
                    otherwise
                end
            end
            function sname = makeFullyQualified(sname, kidx)
                if (exist('kidx','var') && ...
                        length(varargin) > kidx && ...
                            ischar(varargin{kidx+1}))
                    sname.path = varargin{kidx+1};
                end
            end % inner function
        end % static formFilename 
        function prts  = splitFilename(name, varargin)
            %% SPLITFILENAME retuns an array of the parts of a filename separated by sep
            %  Usage:   prts = obj.splitFilename(name[, sep]);
            %                                           ^ default '_on_'; try '_to_'
            %           ^ cell-array of strings
            
            p = inputParser;
            addRequired(p, 'name', @ischar);
            addOptional(p, 'sep', mlfsl.FlirtBuilder.FLIRT_TOKEN, @ischar);
            parse(p, name, varargin{:});
            
            [~,fp] = filepartsx(p.Results.name, mlfourd.AbstractImage.FILETYPE_EXT);
            if (isempty(fp))
                prts = {};  return; end
            sepsFound = strfind(fp, p.Results.sep);
            if (isempty(sepsFound))
                prts = {fp}; return; end
            prts = cell(1, length(sepsFound) + 1);
            prts = splitBySep(prts, p.Results.sep);
            
            function prts = splitBySep(prts, sep)
                lastIndex = 1;
                for d = 1:length(sepsFound)
                    prts{d} = fp(lastIndex:sepsFound(d)-1); 
                    lastIndex = sepsFound(d) + length(sep);
                end
                prts{end} = fp(lastIndex:end);
            end
            
        end % static splitFilename   
        
        %% calls to FilenameFilters, ImageFilters
        
        function obj   = brightest(obj)
            obj = mlfourd.FilenameFilters.brightest(obj);
        end
        function obj   = lowestSeriesNumber(obj)
            obj = mlfourd.FilenameFilters.lowestSeriesNumber(obj);
        end
        function obj   = mostEntropy(obj)
            obj = mlfourd.FilenameFilters.mostEntropy(obj);
        end
        function obj   = mostNegentropy(obj)
            obj = mlfourd.FilenameFilters.mostNegentropy(obj);
        end
        function obj   = smallestVoxels(obj)
            obj = mlfourd.FilenameFilters.smallestVoxels(obj);
        end
        function obj   = longestDuration(obj)
            obj = mlfourd.FilenameFilters.longestDuration(obj);
        end
        function obj   = isPet(obj)
            obj = mlfourd.FilenameFilters.isPet(obj);
        end
        function obj   = notIsPet(obj)
            obj = mlfourd.FilenameFilters.notIsPet(obj);
        end
        function obj   = maximum(obj)
            obj = mlfourd.FilenameFilters.maximum(obj);
        end
        function obj   = minimum(obj)
            obj = mlfourd.FilenameFilters.minimum(obj);
        end
        function fns   = ensureFilenameSuffixes(fns0)
            fns  = {}; g = 1;
            fns0 = ensureCell(fns0);
            for f = 1:length(fns0)
                if (lstrfind(fns0{f}, mlfourd.AbstractImage.FILETYPE_EXT))
                    fns{g} = fns0{f}; %#ok<AGROW>
                    g = g + 1;
                end
            end
        end
        function fn    = ensureFilenameSuffix(fn0)
            if (lstrfind(fn0, mlfourd.AbstractImage.FILETYPE_EXT))
                fn = fn0;
            else
                fn = '';
            end
        end
        function fqfn  = xfmName(varargin)
            fqfn = [mlfourd.ImagingParser.nlxfmName(varargin{:}) '.mat']; 
        end
        function fqfn  = nlxfmName(varargin)
            namstr = mlfourd.ImagingParser.coregNameStruct(varargin{:});
            fqfn = fullfile(namstr.path, [namstr.pre mlfsl.FlirtBuilder.FLIRT_TOKEN namstr.post]);
        end
        function obj   = imageObject(varargin)
            %% IMAGEOBJECT returns an object with the typeclass of the last varargin
            
            namstr  = mlfourd.ImagingParser.coregNameStruct(varargin{:});
            obj     = fullfilename(namstr.path, [namstr.pre mlfsl.FlirtBuilder.FLIRT_TOKEN namstr.post]);
            lastArg = varargin{length(varargin)};
            obj     = imcast(obj, class(lastArg));
        end
    end % static methods
    
    methods %% set/get
        function pth  = get.fslPath(this)
            if (lexist(this.fslPath_, 'dir'))
                pth = this.fslPath_; return; end
            pth = mlfourd.ImagingParser.guessFslpath;
        end
        function obj  = get.t1(this)
            if (isempty(this.t1_))
                this = this.choose_t1; end
            obj = this.t1_;
        end
        function obj  = get.t2(this)
            if (isempty(this.t2_))
                this = this.choose_t2; end
            obj = this.t2_;
        end
        function obj  = get.flair(this)
            if (isempty(this.flair_))
                this = this.choose_flair; end
            obj = this.flair_;
        end
        function obj  = get.flair_abs(this)
            if (isempty(this.flair_abs_))
                this = this.choose_flair_abs; end
            obj = this.flair_abs_;
        end
        function obj  = get.gre(this)
            if (isempty(this.gre_))
                this = this.choose_gre; end
            obj = this.gre_;
        end
        function obj  = get.tof(this)
            if (isempty(this.tof_))
                this = this.choose_tof; end
            obj = this.tof_;
        end
        function obj  = get.ep2d(this)
            if (isempty(this.ep2d_))
                this = this.choose_ep2d; end
            obj = this.ep2d_;
        end
        function obj  = get.ep2dMeanvol(this)
            if (isempty(this.ep2dMeanvol_))
                this = this.choose_ep2dMeanvol; end
            obj = this.ep2dMeanvol_;
        end
        function obj  = get.h15o(this)
            if (isempty(this.h15o_))
                this = this.choose_h15o; end
            obj = this.h15o_;
        end
        function obj  = get.o15o(this)
            if (isempty(this.o15o_))
                this = this.choose_o15o; end
            obj = this.o15o_;
        end
        function obj  = get.h15oMeanvol(this)
            if (isempty(this.h15oMeanvol_))
                this = this.choose_h15oMeanvol; end
            obj = this.h15oMeanvol_;
        end
        function obj  = get.o15oMeanvol(this)
            if (isempty(this.o15oMeanvol_))
                this = this.choose_o15oMeanvol; end
            obj = this.o15oMeanvol_;
        end
        function obj  = get.c15o(this)
            if (isempty(this.c15o_))
                this = this.choose_c15o; end
            obj = this.c15o_;
        end
        function obj  = get.tr(this)
            if (isempty(this.tr_))
                this = this.choose_tr; end
            obj = this.tr_;
        end
    end
    
    methods 
        function this = choose_t1(this, varargin)
            try
                this.t1_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 't1_*', 'mostNegentropy', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end        
        function this = choose_t2(this, varargin)
            try
                this.t2_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 't2_*', varargin{:}));
            catch ME
                handwarning(ME);
            end
        end
        function this = choose_flair(this, varargin)
            try
                this.flair_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'ir_*', varargin{:}));
            catch ME
                handwarning(ME);
            end
        end        
        function this = choose_flair_abs(this, varargin)
            try
                this.flair_abs_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'ir_*_abs*', varargin{:}));
            catch ME
                handwarning(ME);
            end
        end
        function this = choose_gre(this, varargin)
            try
                this.gre_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'gre_*', 'mostNegentropy', true, 'timeDependent', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end        
        function this = choose_tof(this, varargin)
            try
                this.tof_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'tof_*', 'mostNegentropy', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end 
        function this = choose_ep2d(this, varargin)
            try
                this.ep2d_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'ep2d_*_mcf*', 'timeDependent', true, 'isMcf', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end        
        function this = choose_ep2dMeanvol(this, varargin)
            try
                this.ep2dMeanvol_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'ep2d_*_meanvol*', 'meanvol', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end        
        function this = choose_h15o(this, varargin)
            try
                this.h15o_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'cho_*', 'modality', 'pet', 'brightest', true, 'timeDependent', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end        
        function this = choose_o15o(this, varargin)
            try
                this.o15o_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'coo_*', 'modality', 'pet', 'brightest', true, 'timeDependent', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end  
        function this = choose_h15oMeanvol(this, varargin)
            try
                this.h15oMeanvol_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'cho_blindd*', 'modality', 'pet', 'brightest', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end
        function this = choose_o15oMeanvol(this, varargin)
            try
                this.o15oMeanvol_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'coo_blindd*', 'modality', 'pet', 'brightest', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end
        function this = choose_c15o(this, varargin)
            try
                this.c15o_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'poc*', 'modality', 'pet', 'brightest', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end 
        function this = choose_tr(this, varargin)
            try
                this.tr_ = this.createReturnType( ...
                    this.inputParser('fileprefix', 'ptr*', 'mostNegentropy', true, 'modality', 'pet', 'brightest', true, varargin{:}));
            catch ME
                handwarning(ME);
            end
        end 
        function this = clearCache(this)
            this.t1_          = [];
            this.t2_          = [];
            this.flair_       = [];
            this.flair_abs_   = [];
            this.gre_         = [];
            this.tof_         = [];
            this.ep2d_        = [];
            this.ep2dMeanvol_ = [];
            this.h15o_        = [];
            this.o15o_        = [];
            this.h15oMeanvol_ = [];
            this.o15oMeanvol_ = [];
            this.c15o_        = [];
            this.tr_          = [];
        end 
 		function this = ImagingParser(fslPth)
 			%% IMAGINGPARSER 
 			%  Usage:  this = ImagingParser(fsl_path)

            assert(lexist(fslPth, 'dir'));
            this.fslPath_ = fslPth;
            this = this.choose_t1;
            this = this.choose_t2;
            this = this.choose_flair;
            this = this.choose_flair_abs;
            this = this.choose_gre;
            this = this.choose_tof;
            this = this.choose_ep2d;
            this = this.choose_ep2dMeanvol;
            this = this.choose_h15o;
            this = this.choose_o15o;
            this = this.choose_h15oMeanvol;
            this = this.choose_o15oMeanvol;
            this = this.choose_c15o;
            this = this.choose_tr;
 		end %  ctor 
    end 
    
    %% PRIVATE
    
    properties (Access='private')
        fslPath_
        t1_
        t2_
        flair_
        flair_abs_
        gre_
        tof_
        ep2d_
        ep2dMeanvol_
        h15o_
        o15o_
        h15oMeanvol_
        o15oMeanvol_
        c15o_
        tr_
 	end

    methods (Static, Access = 'private')  
        function pth      = guessFslPath
            pth = pwd;
            if ( lstrfind(pth, 'fsl'))
                lastchar = strfind(pth, 'fsl') + 2;
                pth = pth(1:lastchar);
                return
            end
            try
                pth = fullfile(pth, 'fsl', '');
                assert(lexist(pth, 'dir'));
            catch ME
                handexcept(ME);
            end
        end
        function rt       = validReturnType(val)
            VALID = {'fileprefix' 'fp' 'filename' 'fn' 'fqfileprefix' 'fqfp' 'fqfilename' 'fqfn' ...
                     'imagingcomponent' 'imagingseries' 'imagingcomposite' 'nifti'};
            rt = lstrfind(lower(val), VALID);
        end
        function rt       = validAveraging(val)
            VALID = {'lucy' 'blindd' 'gauss' 'susan'};
            if (isempty(val))
                rt = true; 
                return
            end
            rt = lstrfind(lower(val), VALID);
        end
        function rt       = validModality(val)
            VALID = {'mr' 'trio' 'avanto' 'allegra' 'sonata' 'pet' 'ecat_exact'};
            rt = lstrfind(lower(val), VALID);
        end     
        function rt       = validPath(val)
            ensureFolderExists(val);
            rt = true;
        end
        function fns      = selectModality(fns, p)
            import mlfourd.*;
            if (~isempty(fns))
                switch (lower(p.Results.modality))
                    case {'mr' 'trio' 'avanto' 'allegra' 'sonata'}
                        fns = FilenameFilters.notIsPet(fns);
                    case {'pet' 'ecat_exact'}
                        fns = FilenameFilters.isPet(fns);
                    otherwise
                        error('mlfourd:UnsupportedParam', 'ImagingParser.selectModality.p.Results.modality->%s', ...
                               p.Results.modality);
                end
            end
        end
        function obj      = applyNiftiFilters(obj, varargin)
            import mlfourd.*;
            if (~isempty(obj))
                imser = ImagingSeries.createFromObjects(obj);
                imser = ImagingParser.applyImageFilters(imser, varargin{:});
                obj   = imser.cachedNext;
            end
        end
        function obj      = applyImageFilters(obj, varargin)
            %% APPLYIMAGEFILTERS
            %  Usage:  obj = ImagingParser.applyImageFilters(obj, constraint[, constraint2, ...])
            %          ^                                     ^ ImagingComponent object
            %                                                     ^ string, name of method from ImageFilters
            
            import mlfourd.*;
            if (~isempty(obj))
                if (isa(obj, 'mlfourd.NIfTI')) % KLUDGE
                    obj = ImagingParser.applyNiftiFilters(obj, varargin{:});
                    return
                end
                for v = 1:length(varargin)
                    try
                        obj = ImageFilters.(varargin{v})(obj);
                    catch ME
                        handexcept(ME);
                    end
                end
            end
        end
        function fns      = applyFilenameFilters(fns, varargin)
            %% APPLYFILENAMEFILTERS
            %  Usage:  obj = ImagingParser.applyFilenameFilters(obj, constraint[, constraint2, ...])
            %          ^                                        ^ ImagingComponent object
            %                                                        ^ string, name of method from ImageFilters
            
            import mlfourd.*;
            if (~isempty(fns))
                assert(iscell(fns) || ischar(fns));
                for v = 1:length(varargin)
                    try
                        fns = ImagingParser.ensureFilenameSuffixes(fns);
                        fns = FilenameFilters.(varargin{v})(fns);
                    catch ME
                        handwarning(ME);
                    end
                end
            end
        end
        function obj      = applyFiltersByType(obj, p)
            import mlfourd.*;
            if (~isempty(obj))
                filtList = ImagingParser.globParsed(p);
                if (~isempty(filtList))
                    if     (ischar(obj))
                        obj = ImagingParser.applyFilenameFilters(obj, filtList{:});
                    elseif (iscell(obj) && ischar(obj{1}))
                        obj = ImagingParser.applyFilenameFilters(obj, filtList{:});
                    elseif (isa(obj, 'mlfourd.ImagingComponent'))
                        obj = ImagingParser.applyImageFilters(obj, filtList{:});
                    else
                        error('mlfourd:unsupportedClass', 'ImagingParser.applyFiltersByType.obj has unsupported type->%s', ...
                               class(obj));
                    end
                end
            end
        end
        function filtList = globParsed(p)
            filtList = {};
            if (p.Results.brightest)
                filtList = [filtList 'brightest']; end
            if (p.Results.lowestSeriesNumber)
                filtList = [filtList 'lowestSeriesNumber']; end
            if (p.Results.mostNegentropy)
                filtList = [filtList 'mostNegentropy']; end
            if (p.Results.smallestVoxels)
                filtList = [filtList 'smallestVoxels']; end
            if (p.Results.longestDuration)
                filtList = [filtList 'longestDuration']; end
            if (p.Results.timeDependent)
                filtList = [filtList 'timeDependent']; end
        end
        function str      = beforeToken(str, tok)
            %% BEFORETOKEN returns the substring in front of the first token, 
            %  excluding filename suffixes .mat/.nii.gz; default is TOKEN
            
            str = fileprefix(fileprefix(str, '.mat'));
            if (~exist('tok', 'var')); tok = mlfsl.FlirtBuilder.FLIRT_TOKEN; end
            locs = strfind(str, tok);
            if (~isempty(locs))
                str = str(1:locs(1)-1);
            end
        end % static beforeToken
        function str      = afterToken(str, tok)
            %% AFTERTOKEN returns the substring after the last token, 
            %  excluding filename suffixes .mat/.nii.gz; default is TOKEN
            
            str = fileprefix(fileprefix(str, '.mat'));
            if (~exist('tok', 'var')); tok = mlfsl.FlirtBuilder.FLIRT_TOKEN; end
            locs = strfind(str, tok);
            if (~isempty(locs))
                str = str(locs(end)+length(tok):end);
            end
        end % static afterToken

        function nameStruct = coregNameStruct(varargin)
            %% COREGNAME accepts char, cell, CellArrayList, struct, AbstractImage and
            %  returns a struct-array with string fields path, pre, post;
            %  dispatches to *2coregNameStruct methods that update path, pre, post so that 
            %  varargin{1} updates path, pre and varargin{N}, N = length(varargin), updates post.
            %  the coregistered name will have the form:   [char(varargin{1}) '_on_' char(varargin{N})]
            
            nameStruct = struct('path', '', 'pre', '', 'post', '');
            import mlfourd.*;
            for v = 1:length(varargin)
                assert(~isempty(varargin{v}));
                switch (class(varargin{v}))
                    case 'char'
                        nameStruct = ImagingParser.char2coregNameStruct(nameStruct, varargin{v});
                    case 'cell'
                        nameStruct = ImagingParser.cell2coregNameStruct(nameStruct, varargin{v});
                    case mlpatterns.CellArrayList
                        nameStruct = ImagingParser.cal2coregNameStruct(nameStruct, varargin{v});
                    case 'struct'
                        nameStruct = ImagingParser.struct2coregNameStruct(nameStruct, varargin{v});
                    otherwise
                        if (isa(varargin{v}, 'mlfourd.AbstractImage'))
                            nameStruct = ImagingParser.abstractImage2coregNameStruct(nameStruct, varargin{v});
                        else
                            error('mlfourd:unsupportedTypeclass', ...
                                  'class(ImagingParser.xfmName.varargin{%i})->%s', v, class(varargin{v}));
                        end
                end
            end
            nameStruct = ImagingParser.finalizeNameStruct(nameStruct);
        end
        function nameStruct = char2coregNameStruct(nameStruct, strng)
            import mlfourd.*;
            [pth,strng] = filepartsx(strng, mlfourd.AbstractImage.FILETYPE_EXT);
            if (isempty(nameStruct.path))
                nameStruct.path = pth; end
            if (isempty(nameStruct.pre))
                nameStruct.pre  = ImagingParser.beforeToken(strng); end
                nameStruct.post = ImagingParser.afterToken( strng);
        end
        function nameStruct = cell2coregNameStruct(nameStruct, cll)
            nameStruct = mlfourd.ImagingParser.coregFirstLastNameStructs( ...
                nameStruct, cll{1}, cll{length(cll)});
        end
        function nameStruct = cal2coregNameStruct(nameStruct, cal)
            nameStruct = mlfourd.ImagingParser.coregFirstLastNameStructs( ...
                nameStruct, cal.get(1), cal.get(length(cal)));
        end
        function nameStruct = struct2coregNameStruct(nameStruct, strct)
            import mlfourd.*;
            if (1 == length(strct))
                fields = fieldnames(mlfsl.FslProduct);
                for f = 1:length(fields)
                    if (isfield(strct, fields{f}))
                        nameStruct = ImagingParser.char2coregNameStruct( ...
                            nameStruct, imcast(strct.(fields{f}), 'char'));
                    end
                end
                return
            end
            nameStruct = mlfourd.ImagingParser.coregFirstLastNameStructs( ...
                nameStruct, strcts(1), strcts(length(strcts)));
        end
        function name       = abstractImage2coregNameStruct(name, imobj)
            import mlfourd.*;
            if (isempty(name))
                return; 
            end
            if (length(imobj) > 1)
                name = ImagingParser.cal2coregNameStruct(name, imobj);
                return
            end
            name = ImagingParser.char2coregNameStruct(name, imobj.fqfileprefix);
            
        end
        function nameStruct = coregFirstLastNameStructs(nameStruct, obj0, objf)
            import mlfourd.*;
            first = ImagingParser.coregNameStruct(obj0);
            last  = ImagingParser.coregNameStruct(objf);
            if (isempty(nameStruct.path))
                nameStruct.path = first.path; end
            if (isempty(nameStruct.pre))
                nameStruct.pre  = first.pre; end
                nameStruct.post = last.post;
        end
        function nameStruct = finalizeNameStruct(nameStruct)
            if (~isempty(nameStruct.path))
                assert(lexist(nameStruct.path, 'dir')); end
            nameStruct.pre  = fileprefix(nameStruct.pre);
            nameStruct.post = fileprefix(nameStruct.post);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

