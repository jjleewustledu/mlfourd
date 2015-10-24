classdef NamingRegistry < mlpatterns.Singleton 
	%% NAMINGCONVENTION is a singleton providing file-naming conventions 
    %  Uses:  NamingDictionary
	%  Version $Revision: 2318 $ was created $Date: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/NamingRegistry.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: NamingRegistry.m 2318 2013-01-20 06:52:48Z jjlee $ 
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
        mniNames      = { 'MNI152_T1_2mm' 'MNI152_T1_1mm' 'MNI152_T1_0.5mm' };
        mniAtlases    = { 'HarvardOxford-sub-maxprob-thr25-2mm' 'HarvardOxford-sub-maxprob-thr25-1mm' };            
        tracers       = { 'oc' 'oo' 'ho' 'tr' };
        TRACER_PREFIXES = { 'p'  'c' };        
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
        DATE_FORMAT           = 'mm-dd-yyyy_HHMM-SS.FFF';
    end
    
    properties (SetAccess = 'private') 
        dict                    % containers.Map object patterns -> canonical word 
        backupFolder          = 'Backups';
        studyFolderPrefix     = 'np';
        sessionFolderPrefixes = {'mm0' 'wu0'};
        allNIfTI              = ['*' mlfourd.NIfTI.FILETYPE_EXT];
    end

    properties (Dependent)
        tracerIds
        datestamp
        logFilesuffix
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
        function nm    = averagedName(nm, bldr)
            
            %% AVERAGED
            %  Usage:   nm = NamingRegistry.averaged(nm, bldr)
            %       suffix = NamingRegistry.averaged
            %       suffix = NamingRegistry.averaged('')
            if (~exist('nm','var')); nm = ''; end
            if ( exist('bldr','var'))
                nm = NamingRegistry.suffixed(nm, bldr.blurSuffix);
            end
        end
        function nm    = suffixed(nm, suf)
            %% SUFFIXED adds suffix-notation to a filename
            %  Usage:  nm = NamingRegistry.suffixed(nm, suffix)
            %          ^                              ^ strings or stringable objects
            %                                             ^ strings
            %      suffix = NamingRegistry.suffixed(~,  suffix)
            if (nargin < 2 || isempty(nm)); nm = suf; return; end
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
    end 
    
    methods %% set/get
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
        function ds  = get.datestamp(this)
            ds = datestr(now, this.DATE_FORMAT);
        end
        function suf = get.logFilesuffix(this)
            suf = ['_' this.datestamp '.log'];
        end
        function t   = get.tracerIds(this)
            t = {'oc_preratio' 'oobin'};
            for p = 1:length(this.TRACER_PREFIXES)
                for q = 1:length(this.tracers)
                    t = [t {[this.TRACER_PREFIXES{p} this.tracers{q}]}]; 
                end
            end
        end
    end
    
    methods
        function fn       = logFilename(this, str)
            %% LOGFILENAME 
            %  unqualified_filename = instance.logFilename(name_string)
            
            fn = strtok(str);
            if (~lstrfind(fn, this.logFilesuffix))
                fn = [fn this.logFilesuffix];
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
    end
       
    %% PRIVATE
    
	methods (Access = 'private')
 		function this = NamingRegistry() 
            this = this@mlpatterns.Singleton;
 		end % NamingRegistry (ctor) 
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
