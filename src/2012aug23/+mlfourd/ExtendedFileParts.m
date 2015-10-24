classdef ExtendedFileParts 
    
	%% EXTENDEDFILEPARTS  provides data & methods for generating common filename parts 
	%  Version $Revision: 1211 $ was created $Date: 2011-07-29 15:43:54 -0500 (Fri, 29 Jul 2011) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2011-07-29 15:43:54 -0500 (Fri, 29 Jul 2011) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/ExtendedFileParts.m $ 
 	%  Developed on Matlab 7.12.0.635 (R2011a) 
 	%  $Id: ExtendedFileParts.m 1211 2011-07-29 20:43:54Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
    properties
        allNIfTI               = ['*' mlfourd.NIfTI.FILETYPE_EXT];
        allAffineTransforms    = '*.mat';
        allNonlinearTransforms = '*_warpcoeff*.nii.gz';
        preferDatatype         = 'FLOAT';
        bettedReference        = true;
        references             = {};
        fslFolder              = 'fsl';
        transformationsFolder  = 'matrices';
        backupFolder           = 'Backups';
    end
    
    properties (Dependent)
        mrPath
        mrPaths
        petPath
        stdPath
        atlasPath
        
        onRefsSuffixes
        onRefSuffix
        onFolder
        onFolders
        reference                     
    end
    
    properties (SetAccess = private)
        moyamoyaIdMap
        northwesternIdMap
        dateMap
        jessyFileMap
        mcfSuff        = '_mcf';
        rotSuff        = '_rot';
        mcfMeanvolSuff = '_mcf_meanvol';
        FSL_HOME       = '/opt/fsl';
    end
    
	properties (Access = private)
        
        pnumNp755         = ...
        {'p7429'  'p7457'  'p7239'   'p6995'  'p6938'  'p7436'     'p7456'  ...
         'p7663'  'p7375'  'p7660'   'p7691'  'p7398'  'p7429'     'p7507'  'p7510'     'p7377'  'p7653' ...
         'p7564'  'p7577'  'p7604'   'p7610'  'p7646'  'p7671'     'p7698'  'p7719'     'p7384'  'p7527' ...
         'p7730'  ...
         'p6938'  'p7239'  'p7248'   'p7627'  'p7243'  'p7605'     'p7257'  'p7270'     'p7260'  'p7686' ...
         'p7267'  'p7153'  'p7266'   'p7118'  'p7189'  'p7414'     'p7217'  'p7216'     'p7457'  'p7309' ...
         'p7335'  'p7338'  'p7413'   'p7631'  'p7446'  'p7470'     'p7540'  'pXXXX'     'p7542'  'p7624' ...
         'p7629'  'p7630'  'p7665'   'p7684'  'p7733'  'p7740'     'p7740'  'p7749'     'p7146'  'p7475' ...
         'p7229'  'p7499'  'p7321'};
        pnumNp797         = ...
        {'p7118'  'p7153'  'p7146'   'p7189'  'p7191'  'p7194'     'p7217'  'p7219'     'p7229'  'p7230'  ...
         'p7243'  'p7248'  'p7257'   'p7260'  'p7266'  'p7267'     'p7270'  'p7309'     'p7321'  'p7335'  ...
         'p7336'  'p7338'  'p7377'   'p7395'  'p7216'}; 
        moyamoyaIdNp797   = ...
        {'mm01-010_'       'mm01-008_'        'mm02-001_'          'mm01-011_'          ''          ...
         ''                'mm01-012_'        ''                   'mm03-001_'          ''          ...
         'mm01-003_'       'mm01-002_'        'mm01-004_'          'mm01-006_'          'mm01-009_' ...
         'mm01-007_'       'mm01-005_'        ''                   'mm06-001_'          'mm01-018_' ...
         ''                'mm01-019_'        ''                   ''                   'mm01-014_'};
        prefixNp797       = ...
        {'wu001_'          'wu002_'           'wu003_'             'wu005_'             'wu006_' ...
         'wu007_'          'wu009_'           'wu010_'             'wu011_'             'wu012_' ...
         'wu014_'          'wu015_'           'wu016_'             'wu017_'             'wu018_' ...
         'wu019_'          'wu021_'           ''                   'wu024_'             'wu026_' ...
         'wu027_'          'wu028_'           '01-020_'            'wu029_'             ''};
        suffixNp797       = ...
        {'_2007oct16'      '_2008jan16'       '_2008jan4'          '_2008mar12'         '_2008mar13' ...
         '_2008mar14'      '_2008apr14'       '_2008apr23'         '_2008apr28'         '_2008apr29' ...
         '_2008may21'      '_2008may23'       '_2008jun4'          '_2008jun9'          '_2008jun16' ...
         '_2008jun16'      '_2008jun18'       '_2008aug20'         '_2008sep8'          '_2008oct21' ...
         '_2008oct21'      '_2008oct30'       '_2009feb5'          '_2009mar12'         '_2008apr11'};
        jessyFilenameStem = ...
        {''                'P003GE_MSS-1.mat' 'P002GE_M.mat'       'P004GE_A_SVD.mat'   'P005GE_A.mat'    ...
         'P006GE_A.mat'    'P008GE_A.mat'     'P009GE_A.mat'       'P010GE_A.mat'       'P011GE_A_FS.mat' ...
         'P012GE_A_FS.mat' 'P013GE_A_FS.mat'  'P013GE_A_p7257.mat' 'P014GE_A_p7260.mat' 'P003GE_A.mat'    ...
         'P004GE_A.mat'    'P005GE_A.mat'     'P006GE_M.mat'       'P007GE_A.mat'       'P007GE_A.mat'    ...
         'P003GE_A.mat'    'P013GE_A.mat'     ''                   'P014GE_MSS.mat'     'P007GE_A.mat'};
     
        niftiPattern      = ... 
        {'local', 'IRLLEPI', ...
         '_ADC',  'Diiff',    '_DIFF_' ...
         'mpr',   'MPRAGE',    't1_mpr',       't2_space',     't2space',    't2_tse',             'TSE_T2', ...
         't2_blade',          'Blood_SWI', ...
         'PERFUSION_TTP',     'PERFUSION_PBP', 'PERFUSION_GBP', ...
         'ep2d_perf_with_contrast',            'MoCoSeries',    'Perfusion_Weighted',   'relCBF', ...
         'ep2d_perf',         'mocoPasl',      'pwAsl', ...       
         'pCASL', 'cbfPasl',  'ASL1_black-ances',               'ep2d_pasl', 'pasl',      ...
         'FirstECHO',         'SecondECHO',    '_ase_',         'ASE',       'EPI_PERFUSION.', ...
         'MIP',               'Short_TOF.',    'field_mapping', 'ciss3d',    'tse_T1w.',           'tse_PDw.', 'tse_T2w', ...
         'gre',   'FLAIR',    'space_ir',      'spaceir'        'ir', ...
         'lat',   '-mask',    'tr', ...
         'oc1',   'oo1_g3',   'ho1_g3',        'oo1_f',         'ho1_f',     'oo1_sum', 'ho1_sum', 'oo1',      'ho1', ...
         'oc2',   'oo2_g3',   'ho2_g3',        'oo2_f',         'ho2_f',     'oo2_sum', 'ho2_sum', 'oo2',      'ho2'};
        niftiNames        = ...
        {'local', 'irllepi', ...
         'adc',   'dwi',      'dwi', ...
         't1',    't1',       't1',            't2',        't2',         't2',                 't2', ...
         't2',                'swi', ...
         'ttp',   'pbp',      'gbp', ...
         'ep2d',                               'paslmoco',  'pwPasl',                'cbfPasl' ...
         'ep2d',              'paslmoco',      'pwAsl', ...
         'pcasl', 'cbfPasl',  'pasl',                       'pasl',       'pasl', ...
         'ase',               'ase2nd',        'ase',       'ase',        'ep2d', ...
         'mip',               'tof',           'fieldmap',  'ciss',       't1Hires',            'pdHires', 't2Hires', ...
         'gre',   'flair'     'flair',         'flair',     'flair', ...
         'lat',   'mask',     'tr', ...
         'oc',    'oog3',     'hog3',          'oosum',     'hosum',      'oosum',   'hosum',   'oo',      'ho', ...
         'oc',    'oog3',     'hog3',          'oosum',     'hosum',      'oosum',   'hosum',   'oo',      'ho'};        
        irreducibleNames % map container with irreducible names as keys, integer instances as values       
        
        useBlurSuffix     = false; % for backwards compatibility
        useBlockSuffix    = false;
                
        patientPath
        mrFolders         = {'Trio', 'Avanto', 'OutsideMR'};
        dcmFolders        = {'CDR_OFFLINE', 'CDROM', 'DICOM'};
        ecatFolder        =  'ECAT_EXACT';
        folder962         =  '962_4dfp';
        
        MNIstd_           = 'MNI152_T1_2mm';
        MNIatlas_         = 'MNI-maxprob-thr0-2mm';
        
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
    end 
    
    

	methods 

 		function this = ExtendedFileParts(ppath) 
            
 			%% EXTENDEDFILEPARTS (ctor) 
 			%  Usage:  obj = ExtendedFileParts([patientPath])
            if (exist('ppath','var'))
                this.patientPath = ppath;
            else
                this.patientPath = pwd;
            end
            
			this.moyamoyaIdMap     = containers.Map;
            this.northwesternIdMap = containers.Map;
            this.dateMap           = containers.Map;
            this.jessyFileMap      = containers.Map;
            
            for p = 1:length(this.pnumNp797) %#ok<FORFLG,PFUNK>
                this.moyamoyaIdMap(    this.pnumNp797{p}) = this.moyamoyaIdNp797{p}; %#ok<PFPIE>
                this.northwesternIdMap(this.pnumNp797{p}) = this.prefixNp797{p};
                this.dateMap(          this.pnumNp797{p}) = this.suffixNp797{p};
                this.jessyFileMap(     this.pnumNp797{p}) = this.jessyFilenameStem{p};
            end
            
            this.irreducibleNames = containers.Map;
            for ni = 1:length(this.niftiNames)                              %#ok<FORFLG,PFUNK>
                if (~isKey(this.irreducibleNames, this.niftiNames{ni}))     %#ok<PFPIE>
                           this.irreducibleNames( this.niftiNames{ni}) = 0; % cf. this.rename() for the rationale
                end
            end
            
            this.references = {this.t1};
 		end % ExtendedFileParts (ctor) 
        
        
        
        function this = set.allNIfTI(this, str)
            switch (class(str))
                case mlfourd.NIfTI.NIFTI_SUBCLASS
                    this.allNIfTI = [str.fileprefix str.filesuffix];
                case 'char'                    
                    this.allNIfTI = str;
                case 'cell'
                    this.allNIfTI = [str{:}];
                otherwise
                    error('mlfourd:NotImplemented', ...
                          'ExtendedFileParts.set.allNIfTI.str was %s which is not yet supported', class(str));
            end
        end
        
        function this = set.allAffineTransforms(this, str)
            switch (class(str))
                case mlfourd.NIfTI.NIFTI_SUBCLASS
                    this.allAffineTransforms = [str.fileprefix str.filesuffix];
                case 'char'                    
                    this.allAffineTransforms = str;
                case 'cell'
                    this.allAffineTransforms = [str{:}];
                otherwise
                    error('mlfourd:NotImplemented', ...
                          'ExtendedFileParts.set.allAffineTransforms.str was %s which is not yet supported', class(str));
            end
        end
        
        function this = set.allNonlinearTransforms(this, str)
            switch (class(str))
                case mlfourd.NIfTI.NIFTI_SUBCLASS
                    this.allNonlinearTransforms = [str.fileprefix str.filesuffix];
                case 'char'                    
                    this.allNonlinearTransforms = str;
                case 'cell'
                    this.allNonlinearTransforms = [str{:}];
                otherwise
                    error('mlfourd:NotImplemented', ...
                          'ExtendedFileParts.set.allNonlinearTransforms.str was %s which is not yet supported', class(str));
            end
        end
        
        function this = set.preferDatatype(this, dt)
            assert(ischar(dt));
            this.preferDatatype = dt;
        end
        
        function fps  = get.references(this)
            if (iscell(this.references) && ~isempty(this.references) && ischar(this.references{1}))
                fps = this.references;
                for f = 1:length(fps) %#ok<FORFLG>
                    if (this.bettedReference) %#ok<PFBNS>
                        fps{f} = mlfsl.BetFacade.betted_fp(fps{f});
                    end
                end
            end
        end
        
        function this = set.references(this, fps)
            if (ischar(fps)); fps = {fps}; end
            if (iscell(fps) && ~isempty(fps) && ischar(fps{1}))
                this.references = fps;
            end
        end
        
        function fp   = get.reference(this)
            if (~isempty(this.references) && ischar(this.references{1}))
                fp = this.references{1};                
                if (this.bettedReference)
                    fp = mlfsl.BetFacade.betted_fp(fp);
                end
            else
                throw(MException('mlfourd:ReferencingEmptyVariable', 'ExtendedFileParts.get.reference'));
            end
        end
        
        function this = set.reference(this, fp)
            if (ischar(fp) && ~isempty(fp))
                this.references = [fp this.references];
            end
        end
        
        function suf  = get.onRefsSuffixes(this)
            suf = cell(size(this.references));
            for s = 1:length(this.references) %#ok<FORFLG>
                suf{s} = ['_on_' this.references{s}]; %#ok<PFBNS>
            end
        end
        
        function suf  = get.onRefSuffix(this)
            suf = ['_on_' this.reference];
        end
        
        function pths = get.mrPaths(this)
            pths = cell(size(this.mrFolders));
            for p = 1:length(this.mrFolders) %#ok<FORFLG>
                pths{p} = fullfile(this.patientPath, this.mrFolders{p}, ''); %#ok<PFBNS>
            end
        end
        
        function pth  = get.mrPath(this)
            pth = fullfile(this.patientPath, this.mrFolders{1}, '');
        end
        
        function pth  = get.petPath(this)
            pth = fullfile(this.patientPath, this.ecatFolder, '');
        end
        
        function this = set.fslFolder(this, ff)
            this.fslFolder = mlfsl.CvlFacade.ensureFolder(ff);
        end
        
        function this = set.transformationsFolder(this, tf)
            this.transformationsFolder = mlfsl.CvlFacade.ensureFolder(tf);
        end
        
        function this = set.backupFolder(this, bf)
            this.backupFolder = mlfsl.CvlFacade.ensureFolder(bf);
        end
        
        function flds = get.onFolders(this)
            flds = cell(size(this.references));
            for f = 1:length(flds) %#ok<FORFLG>
                flds{f} = ['on' upper(this.references{f}(1)) this.references{f}(2:end)]; %#ok<PFBNS>
            end
        end
        
        function fld  = get.onFolder(this)
            fld = ['on' upper(this.reference(1)) this.reference(2:end)];
        end
        
        function p    = get.stdPath(this)
            p = fullfile(this.FSL_HOME, 'data/standard', '');
        end
        
        function p    = get.atlasPath(this)
            p = fullfile(this.FSL_HOME, 'data/atlases/MNI', '');
        end
              
        
        
        
        function fp   = MNIstd(this, varargin)
             fp = this.fileForms(fullfile(this.stdPath, this.MNIstd_), varargin{:});
        end
        
        function fp   = MfNIatlas(this, varargin)
             fp = this.fileForms(fullfile(this.atlasPath, this.MNIatlas_), varargin{:});
        end
        
        function fp   = t1(this, varargin)
             fp = this.fileForms('t1_rot', varargin{:});
        end
        
        function fp   = t2(this, varargin)
            fp = this.fileForms('t2_rot', varargin{:});
        end
        
        function fp   = flair(this, varargin)
            fp = this.fileForms('flair_rot', varargin{:});
        end
        
        function fp   = flair_abs(this, varargin)
            fp = this.fileForms('flair_abs_rot', varargin{:});
        end
        
        function fp   = ep2d(this, varargin)
            fp = this.fileForms(['ep2d_rot' this.mcfSuff], varargin{:});
        end
        
        function fp   = ep2dMean(this, varargin)
            fp = this.fileForms(['ep2d_rot' this.mcfMeanvolSuff], varargin{:});
        end
        
        function fp   = ho15(this, varargin)
            fp = this.fileForms('ho15_rot', varargin{:});
        end
        
        function fp   = o15c(this, varargin)
            fp = this.fileForms('o15c_rot', varargin{:});
        end
        
        function fp   = o15o(this, varargin)
            fp = this.fileForms('o15o_rot', varargin{:});
        end
        
        % following get* and len* methods are deprecated; designed for backwards compatibility
        
        function p = getPnumNp755(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.pnumNp755)); idx = length(this.pnumNp755); end
            p = this.pnumNp755{idx};
        end
        
        function p = getPnumNp797(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.pnumNp797)); idx = length(this.pnumNp797); end
            p = this.pnumNp797{idx};
        end
        
        function p = getMoyamoyaIdNp797(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.moyamoyaIdNp797)); idx = length(this.moyamoyaIdNp797); end
            p = this.moyamoyaIdNp797{idx};
        end
        
        function p = getPrefixNp797(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.prefixNp797)); idx = length(this.prefixNp797); end
            p = this.prefixNp797{idx};
        end
        
        function p = getSuffixNp797(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.suffixNp797)); idx = length(this.suffixNp797); end
            p = this.suffixNp797{idx};
        end
        
        function p = getJessyFilenameStem(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.jessyFilenameStem)); idx = length(this.jessyFilenameStem); end
            p = this.jessyFilenameStem{idx};
        end
        
        function l = lenPnumNp755(this)
            l = length(this.pnumNp755);
        end
        
        function l = lenPnumNp797(this)
            l = length(this.pnumNp797);
        end
        
        function l = lenMoyamoyaIdNp797(this)
            l = length(this.moyamoyaIdNp797);
        end
        
        function l = lenPrefixNp797(this)
            l = length(this.prefixNp797);
        end
        
        function l = lenSuffixNp797(this)
            l = length(this.suffixNp797);
        end
        
        function l = lenJessyFilenameStem(this)
            l = length(this.jessyFilenameStem);
        end
        
        
        
        
        function fform   = fileForms(this, label, varargin)
            
            %% FILEFORMS is a wrapper that returns for the passed label the canonical fileprefix/filename,
            %            with/out it's complete path
            %  Usage:   canonical_form = obj.fileForms(label_in, [varargin, ..., 'fq', complete_path])
            %           ^ e.g., ep2d_rot_mcf_meanvol.nii.gz
            %                                          ^ label including all suffices but '.nii.gz', e.g., ep2d_rot_mcf_meanvol
            %                                                    ^ string or cell-array:
            %                                                      'fp', 'fn'; 'fps', 'fns' for cell-arrayed label;
            %                                                      'fq', followed by path
            %  See also:  canonicalLabel, renameFiles
            import mlfourd.*;
            switch (nargin)
                case 1
                    error('mlfsl:InsufficientParams', 'FslFacade.fileForms.nargin->%i; at least a label is needed\n', nargin);
                case 2
                    varargin = {'fp'};
                otherwise
            end
            assert(ischar(label) || iscell(label));
            fpath = '';
            fform = '';
            isblk = false;
            isblr = false;
                    
            % build canonical forms as requested in varargin 
            
            for k = 1:length(varargin) %#ok<FORFLG>
                try
                    switch (lower(varargin{k}))
                        case {'fp' 'fileprefix'}

                            if (iscell(label)); label = label{1}; end %#ok<PFTIN>
                            assert(ischar(label));

                            [p,fform,e] = fileparts(label); %#ok<PFTUS>
                               fform    = [this.canonicalLabel(fform) this.averagingSuffixes(isblk, isblr)]; %#ok<PFTIN,PFBNS>
                            if (~isempty(p)); fpath = p; end          %#ok<PFTUS>
                        case {'fn' 'filename'}

                            if (iscell(label)); label = label{1}; end
                            assert(ischar(label));

                            [p,fform,e] = fileparts(label);
                               fform    = [this.canonicalLabel(fform) this.averagingSuffixes(isblk, isblr)];
                            if (~isempty(e))
                                fform   = [fform e];
                            else
                                fform = [fform mlfourd.NIfTI.FILETYPE_EXT];
                            end
                            if (~isempty(p)); fpath = p; end

                        case {'fps' 'fileprefixes'}

                            if (ischar(label)); label = {label}; end
                            assert(iscell(label));

                            fform = cell(size(label));
                            for f = 1:length(label) 
                                [p,fform{f},~] = fileparts([this.canonicalLabel(label{f}) this.averagingSuffixes(isblk, isblr)]);  
                                if (~isempty(p)); fpath = p; end 
                            end

                        case {'fns' 'filenames'}

                            if (ischar(label)); label = {label}; end
                            assert(iscell(label));

                            fform = cell(size(label));
                            for f = 1:length(label) 
                                [p,fform{f},e] = fileparts([this.canonicalLabel(label{f}) this.averagingSuffixes(isblk, isblr)]); 
                                if (~isempty(e))
                                    fform{f}   = [fform{f} e];
                                else
                                    fform{f}   = [fform{f} mlfourd.NIfTI.FILETYPE_EXT];
                                end
                            end
                            if (~isempty(p)); fpath = p; end
                        case {'block' 'blocked'}
                            
                            isblk = true;
                        case {'blur'  'blurred'}
                            
                            isblr = true;
                        case {'fq' 'fullqual' 'fullyqualified'}
                            
                            % overrides paths specified in label
                            if (~isempty(varargin{k+1}))
                                fpath = varargin{k+1};  %#ok<PFBNS>
                            end
                        case 'fqfp'
                            
                            if (iscell(label)); label = label{1}; end
                            assert(ischar(label));

                            [p,fform,e] = fileparts(label);
                               fform    = [this.canonicalLabel(fform) this.averagingSuffixes(isblk, isblr)];
                            if (~isempty(e))
                                fform   = [fform e];
                            else
                                fform = fform;
                            end
                            if (~isempty(p)); fpath = p; end
                            
                            if (~isempty(varargin{k+1}))
                                fpath = varargin{k+1};  %#ok<PFBNS>
                            end
                        case 'fqfn'
                            
                            if (iscell(label)); label = label{1}; end
                            assert(ischar(label));

                            [p,fform,e] = fileparts(label);
                               fform    = [this.canonicalLabel(fform) this.averagingSuffixes(isblk, isblr)];
                            if (~isempty(e))
                                fform   = [fform e];
                            else
                                fform = [fform mlfourd.NIfTI.FILETYPE_EXT];
                            end
                            if (~isempty(p)); fpath = p; end
                            
                            if (~isempty(varargin{k+1}))
                                fpath = varargin{k+1};  %#ok<PFBNS>
                            end
                        case {'_brain' 'brain'}
                            
                            assert(~isempty(fform));
                            [~,fform,e] = fileparts(fform);
                               fform    = [fform '_brain' e];
                        otherwise
                            assert(ischar(varargin{k}));
                    end % switch lower(varargin{k})
                catch ME
                    error('mlfsl:UnsupportedParamValue', 'FslFacade.fileForms: varargin{%i}->%s, exception->%s\n', ...
                           k, varargin{k}, ME.getReport);
                end
            end % for k
            
            if (~iscell(fform))
                fform = fullfile(fpath, fform);
            else
                for f = 1:length(fform) %#ok<FORPF>
                    fform{f} = fullfile(fpath, fform{f});
                end
            end
        end % fileForms
        
        function renamed = renameFiles(this, fold, fold2, filt2keep, filt2toss)
            
            %% RENAMEFILES acts on files on the filesystem, renaming according to niftiPattern & niftiNames; 
            %              do not wrap in parfor!
            %  Usage:   renamed = renameFiles([fold, fold2, filt2keep, filt2toss])
            %                                  ^          ori folder, default pwd
            %                                        ^ target folder, default pwd
            %                                               ^ filter strings for use with dir2cell
            %           ^ cell-array of new filenames (*.nii.gz)
            %  See Also:  dir2cell
            import mlfsl.*;
            if (~exist('fold',      'var')); fold  = pwd;               end
            if (~exist('fold2',     'var')); fold2 = fold;              end
            if (~exist( fold2,      'dir')); mkdir(fold2);              end
            if (~exist('filt2keep', 'var')); filt2keep = this.allNIfTI; end
            if (~exist('filt2toss', 'var')); filt2toss = '';            end
            assert(7 == exist(fold,  'dir')); 
            assert(7 == exist(fold2, 'dir')); 
            if (~strcmp(filesep, fold(1)));  fold  = fullfile(pwd, fold,  ''); end
            if (~strcmp(filesep, fold2(1))); fold2 = fullfile(pwd, fold2, ''); end
            
            pwd0     = pwd;
            this.cd(fold);
            theFiles = dir2cell(filt2keep, filt2toss);  % filename selection/exclusion
            renamed  = {};
            u        = 0;                               % for tally of renamed files
            for t    = 1:length(theFiles)               %#ok<FORFLG,PFUNK>
                for p = 1:length(this.niftiPattern)     %#ok<PFPIE>
                    
                    if (~isempty(strfind(lower(theFiles{t}), ...
                                         lower(this.niftiPattern{p}))))                      % % pattern matched
                        newName                        = this.canonicalLabel(this.niftiNames{p});
                        this.irreducibleNames(newName) = this.irreducibleNames(newName) + 1; % tallys the instances 
                                                                                             % of the irreducibles
                        u              = u + 1;
                        if (this.irreducibleNames(newName) < 2)
                            renamed{u} = fullfile(fold2, newName); %#ok<PFPIE>
                        else
                            renamed{u} = fullfile(fold2, sprintf('%s%i%s', ...
                                                  fileprefix(newName), this.irreducibleNames(newName), ...
                                                  mlfourd.NIfTI.FILETYPE_EXT));
                        end
                            renamed{u} = filename(renamed{u});
                        try
                            copyfiles(theFiles{t}, renamed{u}, 'f');
                        catch ME 
                            handwarning(ME, 'mlfsl:UnexpectedException', ...
                                           ['FslFacade.rename could not copy ' theFiles{t} ' to ' renamed{u}]);
                        end
                        break;
                    end % if pattern match
                end % for p
            end % for t
                      this.cd(fold2);
                      this.cd(pwd0);
        end % renameFiles
        
        function fld     = abinitioPatientFolder(this, pid)
            
            if (~exist('pid','var') || isempty(pid) || strcmp('unknown',pid));
                fld = '.';
            else
                pid = mlfourd.CvlRegistry.ensurePnum(pid);
                fld = [this.moyamoyaIdMap(pid) ...
                       this.northwesternIdMap(pid) ...
                       pid ...
                       this.dateMap(pid)];
            end
        end
        
        function sff     = averagingSuffixes(this, isblk, isblr)
            
            %% AVERAGINGSUFFIXES
            %  Usage:   suffix = obj.averagingSuffixes(isBlocked, isBlurred)
            %           ^ string
            %                                          ^          ^ boolean
            switch (nargin)
                case 2
                    isblr = false;
                case 1
                    isblr = false;
                    isblk = false;
            end
            sff = [this.blockSuffix(isblk) this.blurSuffix(isblr)];
        end
 	end 

	methods (Access = private)
                
        function suff = blockSuffix(this, isblk)
            
            %% BLOCKSUFFIX
            %  Usage:   suff = this.blockSuffix([isblk])
            %                                    ^ bool forces adding block status to suffix
            if (isblk && this.useBlockSuffix)
                bS   = this.blockSize;
                suff = ['_' num2str(bS(1)) 'x' num2str(bS(2)) 'x' num2str(bS(3)) 'blocks'];
            else
                suff = '';
            end
        end
        
        function suff = blurSuffix(this, isblr)
            
            %% BLURSUFFIX
            %  Usage:   suff = this.blurSuffix([isblr])
            %                                   ^ bool forces adding blur status to suffix
            if (isblr && this.useBlurSuffix)
                bB   = this.baseBlur;
                suff = ['_' num2str(bB(1),1) 'x' num2str(bB(2),1) 'x' num2str(bB(3),1) 'blur'];
            else
                suff = '';
            end
        end   
        
        function lbl  = canonicalLabel(this, lbl)
            
            %% CANONICALLABEL
            %  Usage:   no cell-arrays
            assert(ischar(lbl));
            for p = 1:length(this.niftiPattern) %#ok<FORFLG,PFUNK>

                if (~isempty(strfind(lower(lbl), ...
                                     lower(this.niftiPattern{p})))) %#ok<PFBNS,PFTUS,PFTIN,PFPIE> % pattern matched
                                           lbl = fileprefix(this.niftiNames{p});
                                           break; 
                end
                if ( isempty(strfind(lbl, this.rotSuff)))
                    lbl = [lbl this.rotSuff];
                end
            end % for p
        end % canonicalLabel
 	end 
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
