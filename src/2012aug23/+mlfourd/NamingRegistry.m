classdef NamingRegistry < mlpatterns.Singleton
	%% NAMINGCONVENTION is a singleton providing file-naming conventions 
    %  Uses:  NamingDictionary
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/NamingRegistry.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: NamingRegistry.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Constant)
 		
        irNames       = { 'AXFLAIR' 'AX_FLAIR' 'FLAIR' 'FLAIR_AXIAL' 'TRANFLAIR' 'TRANFLAIRT2' ...
                          'spc_ir_ns_sag_p2_iso' 'spc_ir_ns_sag_p2_iso' };
        t1Names       = { 'AXSET1' 'AX_SE_T1' 'AXSET1Post' 'Adult_mprage_1mm_iso' 'CORSET1POST' 'DB_tse_T1w' 'DB_tse_T1w_loc' ...
                          'COR_SE_T1_POST' ...
                          'Fast_MPRAGE_0_9mmiso' 'TRAMPRAGEWHOLEHD'  'SAGMPRAGEWHOLEHD' ...
                          'SAGSET1' 'SAG_SE_T1' 'TRANSSET1POSTGD' 'TRANS_SET1_POST_GD' 'TRASET1' 't1_fl2d_sag' 't1_fl2d_tra' ...
                          't1_mpr_1mm_p2_pos50' 't1_mpr_iso' ...
                          't1_se_sag' 't1_se_tra' 't1_se_tra_POST' 'tse_T1w' 'tse_T1wcor' 'tse_rst_T1w' };
        tofNames      = { 'CORTOFFL2D' 'SAGTOFFL2DOBL' 'ShortTOF' 'Short_TOF' 'TOF_fromBenzinger' 'VERiTASTOF' 'tof3d_multi_slab_704' ...
                          'SAG_TOF_FL2D' 'SAG_TOF_FL2D_OBI' 'COR_TOF_FL2D' };
        pdNames       = { 'DB_tse_PDw' 'tse_PDw' };
        t2Names       = { 'DB_tse_T2w' 'DB_tse_T2w_PDw' 'TRANTSET2' 'TRAN_TSE_T2' ...
                          't2_blade_tra' 't2_blade_tra_320' 't2_fl2d_tra_hemo' 't2_flair_blade_tra' 't2_space_iso' 't2_tse_tra_320_p2' ...
                          'ciss3d' };
        dwiNames      = { 'DIFFEPIiPaT2' 'DIFF_EPI__iPaT_2' 'DiiffIPIiPAT2' };
        irllNames     = { 'IRLLEPI_postcontrast' 'IRLLEPI_precontrast' 'IRLLEPI_seg' 'IRLLEPI_seg_earlyPcor1' };
        localNames    = { 'LOCALIZER' 'LOCALIZERSAG' 'localizer' 'localizer_aligned' 'threeplanelocalizer' 'AAScout' };
        pcNames       = { 'PCSAGMIDLINE' 'PC_SAG_MIDLINE' 'PCSAGSCOUT' 'PC_SAG_SCOUT' 'PCTRANVERSESINUS' 'PC_TRANVERSE_SINUS' };
        swiNames      = { 'T2_Tra_Blood_SWI' };
        dsaNames      = { 'Subtraction' };
        adcNames      = { 'TRANEP2DDIFFUSIONADC' };
        greNames      = { 'TRANGRET2' 'TRAN_GRE_T2' 'gre' };
        fieldMapNames = { 'gre_field_mapping' 'gre_field_mappingV3' 'gre_field_mappingV6' 'gre_field_mapping_for_OEF' 'gre_field_mapping_update' ...
                          'hx_gre_field_map' };
        ep2dNames     = { 'TRANSEPIPERFUSION' 'TRANSEPIPERFUSION_test10meas' 'ep2d_perf' 'ep2d_perf_position' ...
                          'ep2d_perfnocontrast' 'ep2d_perfwithcontrast' };
        aseNames      = { 'ep2d_ase_2e' 'ep2d_ase_2e_OEF' };
        aslNames      = { 'ep2d_bpasl_323_FQII' 'ep2d_bpasl_323_PQ2T' 'ep2d_bpasl_323_PQII' 'ep2d_pasl_414' 'ep2d_pasl_414_Black_Temp' ...
                          'ep2d_pcasl_PHC_1200ms' 'ep2d_tra_pasl' 'ep2d_tra_pasl_TE1' 'ep2d_tra_pasl_TE13' 'ep2d_tra_pasl_TE2' 'ep2d_tra_pasl_TE30' };
        hxoefNames    = { 'hx_OEF_3d_set' 'hx_OEF_short' };
        unknownNames  = { 'unknown' 'HEAD_ROUTINE' 'tse' 'PROTOCOL_UNKOWN' '01HEADSEQUENCE' '1_BRAIN' };
            
        tracers       = { 'oc' 'oo' 'ho' 'tr' };
        tracerPrefixes = { 'p'  'c' };
        
        NAME_LISTS    = { 'irNames'  't1Names'  'tofNames'   'pdNames'  't2Names'  'dwiNames'      'irllNames' 'localNames' ...
                          'pcNames'  'swiNames' 'dsaNames'   'adcNames' 'greNames' 'fieldMapNames' 'ep2dNames' ....
                          'aseNames' 'aslNames' 'hxoefNames' 'unknownNames' };
        FSL_NAMES     = { 'ir'       't1'       'tof'        'pd'       't2'       'dwi'           'irll'      'local' ...
                          'pc'       'swi'      'dsa'        'adc'      'gre'      'fieldmap'      'ep2d' ...
                          'ase'      'asl'      'hxoef'      'unknown' };
        REF_TOKENS    = { 't1_*'     'gre_*'    'pd_*'       'tof_*'    'ir_*' }; % ordered by preference
                      
        SESSION_EXPRESSION    = '[\S*\s*]\/np755\/(?<sessionid>mm\d{2}-\d{3}_p\d{4}_\d{4}\w{3}\d{1,2})\S*';    
 		SESSION_EXPRESSION2   = '[\S*\s*]\/np755\/(?<sessionid>mm\d{2}-\d{3}_\d{4}\w{3}\d{1,2})\S*';  
        DEGENERACY_EXPRESSION = '(?<basename>\D+)(?<index>\d*)';
    end
    
    properties (Dependent)
        tracerIds
        logFilesuffix
    end

    properties (SetAccess = 'private') 
        dict                    % containers.Map object patterns -> canonical word 
        backupFolder          = 'Backups';
        studyFolderPrefix     = 'np';
        sessionFolderPrefixes = {'mm0' 'wu0'};
        allNIfTI              = ['*' mlfourd.NIfTI.FILETYPE_EXT];
    end

    methods (Static)
        function this  = instance(qualifier)
            
            %% INSTANCE uses string qualifiers to switch behaviors 
            persistent uniqueInstance
            
            if (exist('qualifier','var') && ischar(qualifier))
                switch (qualifier)
                    case 'initialize'
                        uniqueInstance = [];
                    otherwise % assume pnum
                        error('mlfourd:UnsupportedParamValue', 'NamingRegistry.instance.qualifier->%s', qualifier);
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlfourd.NamingRegistry;
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end        
        function fname = formFilename(patt, varargin) 
            %% FORMFILENAME returns a canonical form for the passed filename and attributes 
            %  Usage:    canonical_filename = ...
            %                NamingRegistry.formFilename(filename_pattern[, 'fq', complete_path, 'fp', 'betted', 'meanvol', ...])
            %            ^ e.g., /pathtofile/ep2d_020_mcf_meanvol.nii.gz
            %                                            ^ e.g., ep2d_020
            %                                                            ^  'fq' 'fp' 'fn' 'fqfp' 'fqfn'
            %                                                               'betted' 'motioncorrected' 'meanvol'
            %                                                               'fqfilename' requires complete path to be specified 
            %                                                               'average'    requires averaging type
            %                                                               'blur'       requires blur-label
            %                                                               'block'      requires block-label
            %                                                       '                            ^ 'fp', 'betted', ...
            %  See also:  canonicalLabel, renameFiles
            
            import mlfourd.* mlfsl.*;
            if (iscell(patt))
                fname = cell(patt);
                for p = 1:length(patt)
                    fname{p} = NamingRegistry.formFilename(patt{p}, varargin{:});
                end
                return
            end
            assert(ischar(patt));
            if (nargin < 2); varargin = {'fp'}; end
            fpath = fileparts(patt);
            if (isempty(fpath)); fpath = pwd; end
            fname = patt;

            for k = 1:length(varargin) 
                switch (lower(varargin{k}))
                    case {'fq' 'fullqual' 'fullyqualified'}
                        [fpath,fname]     = makeFullyQualified(fname,k);
                    case {'fqfileprefix' 'fqfp'}
                        [fpath,fname]     = makeFullyQualified(fname);
                        [~,    fname,~]   = filepartsx(fname, NIfTI.FILETYPE_EXT); 
                    case {'fqfilename' 'fqfn'}
                        [fpath,fname]     = makeFullyQualified(fname);
                               fname      = NamingRegistry.ensureNIfTIExtension(fname);                                
                    case {'fp' 'fileprefix'}                            
                        [~,    fname,~]   = filepartsx(fname, NIfTI.FILETYPE_EXT); 
                         fpath            = '';
                    case {'fn' 'filename'}                        
                        [~,    fname,~]   = filepartsx(fname, NIfTI.FILETYPE_EXT); 
                               fname      = NamingRegistry.ensureNIfTIExtension(fname); 
                         fpath            = '';
                    case {'bet' 'betted' 'brain' '_brain'}
                        [~,    fname,ext] = filepartsx(fname, NIfTI.FILETYPE_EXT);
                               fname      = BetFacade.bettedNames([fname ext]);
                    case {'motioncorrect' 'motioncorrected' 'mcf' '_mcf'}                        
                        [~,    fname,ext] = filepartsx(fname, NIfTI.FILETYPE_EXT);
                               fname      = [fname FlirtFacade.MCF_SUFFIX ext];
                    case {'meanvol' '_meanvol'}                        
                        [~,    fname,ext] = filepartsx(fname, NIfTI.FILETYPE_EXT);
                               fname      = [fname FlirtFacade.MEANVOL_SUFFIX ext];
                    case {'block'   'blocked'}
                        [~,    fname,ext] = filepartsx(fname, NIfTI.FILETYPE_EXT);
                               fname      = [fname varargin{k+1} ext];
                    case {'blur'    'blurred'}
                        [~,    fname,ext] = filepartsx(fname, NIfTI.FILETYPE_EXT);
                               fname      = [fname varargin{k+1} ext];
                    case {'average' 'averaged' 'aver'}
                        [~,    fname,ext] = filepartsx(fname, NIfTI.FILETYPE_EXT);
                               fname      = [fname varargin{k+1} ext];
                    case {'*'}
                        [~,    fname,ext] = filepartsx(fname, NIfTI.FILETYPE_EXT);
                               fname      = [fname '*' ext];
                    otherwise
                        assert(ischar(varargin{k}));
                end
            end % for k            
            fname = fullfile(fpath, fname);
            
            function x = filenameOnly(x)
                [~,f,g] = fileparts(x);
                 x      = [f g];
            end % inner function
            function [x,y] = makeFullyQualified(y0, kidx)
                y = filenameOnly(y0);
                if (exist('kidx','var') && length(varargin) > kidx && ischar(varargin{kidx+1}))
                    x = varargin{kidx+1};
                else
                    x = fileparts(y0);
                end
            end % inner function
        end % static formFilename 
        function fn    = ensureNIfTIExtension(fn)
            import mlfourd.*;
            if (isempty(strfind(fn, NIfTI.FILETYPE_EXT)))
                fn = [fn NIfTI.FILETYPE_EXT];
            end
        end % static ensureNIfTIExtension  
        
        function nm    = meanvol(nm)
            
            %% MEANVOL returns the mcf-meanvol form of a filename
            %  Usage:  fname = NamingRegistry.meanvol(fname)     
            %         suffix = NamingRegistry.meanvol
            %         suffix = NamingRegistry.meanvol('')
            if (~exist('nm','var')); nm = ''; end
            nm = mlfourd.NamingRegistry.suffixed(nm, '_mcf_meanvol');
        end
        function nm    = mcf(nm)
            if (~exist('nm','var')); nm = ''; end
            nm = mlfourd.NamingRegistry.suffixed(nm, '_mcf');
        end
        function nm    = averaged(nm, bldr)
            
            %% AVERAGED
            %  Usage:   nm = NamingRegistry.averaged(nm, bldr)
            %       suffix = NamingRegistry.averaged
            %       suffix = NamingRegistry.averaged('')
            if (~exist('nm','var')); nm = ''; end
            if ( exist('bldr','var'))
                if (bldr.useBlurSuffix)
                    nm = NamingRegistry.suffixed(nm, bldr.blurSuffix);
                end
            end
        end
        function nm    = suffixed(nm, suf)
            %% SUFFIXED adds suffix-notation to a filename
            %  Usage:  nm = NamingRegistry.suffixed(nm, suffix)
            %          ^                              ^ strings or stringable objects
            %                                             ^ strings
            %      suffix = NamingRegistry.suffixed(~,  suffix)
            if (~exist('nm','var') || isempty(nm)); nm = suf; return; end
            nm       = char(nm);
            nm       = mlfourd.NamingRegistry.notSuffixed(nm, suf);
            [p,nm,e] = niftiparts(nm);
            nm = fullfile(p, [nm suf e]);
        end
        function nm    = notSuffixed(nm, suf)
            
            %% NOTSUFFIXED removes suffix-notations from a filename
            %  Usage:  nm = NamingRegistry.notSuffixed(nm, suffix)
            %          ^                                 ^ strings or other stringable objects
            %                                                 ^ strings
            nm    = char(nm);
            inits = strfind(nm, suf);
            if (~isempty(inits))
                if (1 ~= inits(1));
                    inits = [1-length(suf) inits]; 
                end
                if (inits(end)+length(suf) < length(nm))
                    inits = [inits length(nm)+1]; 
                end
                nm0 = nm; nm = '';
                for n = 1:length(inits)-1 
                    nm = [nm nm0(inits(n)+length(suf):inits(n+1)-1)]; 
                end
            end
        end
    end % static methods
    
    methods

        function       set.allNIfTI(this, str)
            switch (class(str))
                case mlfourd.NIfTI.NIFTI_SUBCLASS
                    this.allNIfTI = [str.fileprefix mlfourd.NIfTI.FILETYPE_EXT];
                case 'char'                    
                    this.allNIfTI = str;
                case 'cell'
                    this.allNIfTI = [str{:}];
                otherwise
                    error('mlfourd:NotImplemented', ...
                          'FilesystemRegistry.set.allNIfTI.str was %s which is not yet supported', class(str));
            end
        end
        function suf = get.logFilesuffix(this)
            suf = ['-' date '.log'];
        end
        function t   = get.tracerIds(this)
            t = {};
            for p = 1:length(this.tracerPrefixes)
                for q = 1:length(this.tracers)
                    t = [t {[this.tracerPrefixes{p} this.tracers{q}]}]; 
                end
            end
        end

        function name     = fslName(this, name)
            %% FSLNAME
            
            for n = 1:length(this.NAME_LISTS)
                if (~isempty( ...
                     matchName(name, this.(this.NAME_LISTS{n}))))
                    name = this.FSL_NAMES{n};
                    break
                end
            end
                        
            function nam = matchName(nam, ca)
                for c = 1:length(ca)
                    if (lstrfind(nam,ca{c}))
                        nam = ca{c};
                        return
                    end
                end
                nam = [];
            end % internal searchName
        end % fslName
        function this     = load(this, matFilename)
            if (nargin < 2 || isempty(matFilename))
                this = this.loadDefault;
            else
                this.dict = load(matFilename, 'dict');
            end
        end % loadDict              
        function            save(this, matFilename) %#ok<MANU>
            save(matFilename, '-struct', 'this', 'dict');
        end % saveDict
        function dmatches = dir(this, dirstr)
            
            dmatches = {};
            dlist = dir(dirstr);
            assert(~isempty(dlist), dirstr);
            for d = 1:length(dlist) 
                if (~dlist(d).isdir && lstrfind(dlist(d).name, '.nii'))
                    dmatches = [dmatches this.definitions(dlist(d).name)]; 
                end
            end
        end % dir 
        function id       = sessionIdentifier(this, str)
            %% SESSIONIDENTIFIER extracts an identifier from a path str
            %  Uses:   NamingRegistry.SESSION_EXPRESSION for regexp
            
            try
                names  = regexp(str, this.SESSION_EXPRESSION, 'names');
                id     = names.sessionid;
            catch ME
                warning(ME.message); fprintf('sessionIdentifier.str->%s\n', str)
                try
                    names  = regexp(str, this.SESSION_EXPRESSION2, 'names');
                    id     = names.sessionid;
                catch ME2
                    warning(ME2.message); fprintf('sessionIdentifier.str->%s\n', str)
                    id = 'undetermined';
                end
            end
            assert(~isempty(id));
        end % sessionsIdentifier
        function this     = loadDefault(this)
            this.dict = containers.Map(this.PATTERNS, this.WORDS);
        end % loadDefault  
        function matches  = definitions(this, str)
            
            %% DEFINITIONS returns a cell-array of canonical words that correspond to the passed string.
            %  Internal patterns are compared against the string and matching patterns & matching 
            %  canonical words are returned in ranked order, best first.
            %  Usage:   matches = obj.definitions(string-to-parse)
            %           ^ struct('pattern', p, 'word', w)
            matches  = {};
            patterns = this.dict.keys;
            for p = 1:length(patterns) 
                indices = strfind(str, patterns{p});
                if (~isempty(indices))
                    matches = [matches struct('string', str, 'pattern', patterns{p}, 'word', this.dict(patterns{p}))];  %#ok<*AGROW>
                end
            end
            if (isempty(matches))
                matches = struct('string', str, 'pattern', '', 'word', '');
            end
            if (numel(matches) > 1)
                pattLengths = zeros(1,numel(matches));
                for p = 1:length(pattLengths)
                    pattLengths(p) = length(matches{p}.pattern);
                end
                [~,ix] = sort(pattLengths, 'descend');
                 matches = matches(ix);
            end
        end % definitions  
    end % methods
       
    %% PRIVATE
    
    properties (Constant, Access = 'private')
        PATTERNS = { ...
         'local'                   'SCOUT' ...
         'IRLLEPI' ...
         '_ADC'                    'Diiff'              'DIFF'          'iPaT_2_ADC' ...
         'mpr'                     'MPRAGE'             't1_mpr'        '_SE_T1'     '_SET1'   't1_se_'   'tfl3d1_t1' 'T1_' ...
         't2_space'                't2space'            't2_tse'        'T2_TSE'     'TSE_T2'  't2_blade' ...
         'Blood_SWI' ...
         'PERFUSION_TTP'           'PERFUSION_PBP'      'PERFUSION_GBP' ...
         'ep2d_perf_with_contrast' ...
         'MoCoSeries'              'Perfusion_Weighted' 'relCBF' ...
         'ep2d_perf'               'mocoPasl'           'pwAsl' ...       
         'pCASL' 'cbfPasl'         'ASL1_black-ances'   'ep2d_pasl'     'pasl' ...
         'FirstECHO'               'SecondECHO'         '_ase_'         'ASE'        '_OEF_' ...
         'EPI_PERFUSION' ...
         'MIP'                     'TOF_FL2D'           'tof3d'         'Short_TOF.' ...
         'field_mapping' ...
         'ciss3d'                  'tse_T1w.'           'tse_PDw.'      'tse_T2w' ...
         'GRE_T2'                  'gre'  ...
         'flair_abs'           'flair'              'FLAIR'         'space_ir'   'spaceir' 'ir' ...
         'lat'                     '-mask' ...
         'oc1'                     'oo1_g3'             'ho1_g3' ...
         'oo1_f'                   'ho1_f'              'oo1_sum'       'ho1_sum' ...
         'oo1'                     'ho1' ...
         'oc2'                     'oo2_g3'             'ho2_g3' ...
         'oo2_f'                   'ho2_f'              'oo2_sum'       'ho2_sum' ...
         'oo2'                     'ho2'                'tr1'           'tr2'};
        WORDS    = { ...
         'local'                   'local' ...
         'irllepi' ...
         'adc'                     'dwi'                'dwi'           'adc' ...
         't1'                      't1'                 't1'            't1'         't1'      't1'       't1'        't1' ...
         't2'                      't2'                 't2'            't2'         't2'      't2' ...
         'swi' ...
         'ttp'                     'pbp'                'gbp' ...
         'ep2d'  ...
         'paslmoco'                'pwPasl'             'cbfPasl' ...
         'ep2d'                    'paslmoco'           'pwAsl' ...
         'pcasl'                   'cbfPasl'            'pasl'                       'pasl'    'pasl' ...
         'ase'                     'ase2nd'             'ase'           'ase'        'oef' ...
         'ep2d' ...
         'mip'                     'tof'                'tof'           'tof' ...
         'fieldmap' ...
         'ciss'                    't1Hires'            'pdHires'       't2Hires' ...
         'gre'                     'gre' ...
         'flair_abs'           'flair'              'flair'         'flair'      'flair'   'flair' ...
         'lat'                     'mask' ...
         'oc'                      'oog3'               'hog3' ...
         'oosum'                   'hosum'              'oosum'         'hosum' ...
         'oo'                      'ho' ...
         'oc'                      'oog3'               'hog3' ...
         'oosum'                   'hosum'              'oosum'         'hosum' ...
         'oo'                      'ho'                 'tr'            'tr'};
    end % DEPRECATED
    
	methods (Access = 'private')
 		function this = NamingRegistry()            
            this = this@mlpatterns.Singleton;
            this.loadDefault;
 		end % NamingRegistry (ctor) 
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
