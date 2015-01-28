classdef (Sealed) DBase_ori < mlfourd.AbstractDBase
    %% DBase_ori is a wrapper for simple database queries.
    %
    %  Instantiation:  instance = mlfourd.DBase_ori.getInstance;
    %                  info     = instance.getter_info(param0, param1, ...)
    %                  info     = instance.macro(macro_name)
    %                  sqlout   = instance.sql(cmd)
    %
    %                  instance:     singleton instance
    %                  info:         data object
    %                  getter_info:  convenience getter
    %                  macro:        convenience macro
    %
    %  Singleton design pattern after the GoF and Petr Posik; cf. 
    %  http://www.mathworks.de/matlabcentral/newsreader/view_thread/170056
    %  Revised according to Matlab R2008b help topic "Controlling the Number of Instances"
    %
    %  Created by John Lee on 2009-02-15.
    %  Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
    %  Report bugs to <email="bugs.perfusion.neuroimage.wustl.edu@gmail.com"/>.
    
    properties
		cvl_path       = '/Volumes/LLBQuadra';
        patient_path   = '/Volumes/LLBQuadra/np755/MROMI/Avanto_mm01-014_p7429_2009may26';
        ref_fp         = 'base_rot_mcf_meanvol';
        h15o       = 'hosum_rot';
        c15o       = 'oc_rot';
        o15o       = 'oosum_rot';
        timepoint      = 'tp1';
        pv_variant     = '';            % naming convention
        t1_variant     = 't1_rot';      % naming convention
        img_format     = mlfourd.NIfTIInterface.FILETYPE_EXT;
        useQBOLD       = false;
        metricThresh   = [eps 1e7]; % refine in MR/PETconverter    
        iscomparator   = false;
    end % properties
    
    properties (Constant)
        pnumNp287         = ...
        {'p5696'  'p5702'  'p5723'  'p5740'  'p5743'  'p5760'  'p5761'  'p5771'  'p5772'  'p5774' ...
         'p5777'  'p5780'  'p5781'  'p5784'  'p5792'  'p5807'  'p5842'  'p5846'  'p5850'  'p5856'};
        vnumNp287         = ...
        {'vc1535' 'vc1563' 'vc1645' 'vc4103' 'vc4153' 'vc4336' 'vc4354' 'vc4405' 'vc4420' 'vc4426' ...
         'vc4437' 'vc4497' 'vc4500' 'vc4520' 'vc4634' 'vc4903' 'vc5591' 'vc5625' 'vc5647' 'vc5821'};
        choiceNp797       = ...
        {0 1 1 1 1 1 1 1 1 1 ...
         1 1 1 1 1 1 1 0 1 1 ...
         1 1 0 1};
        pnumNp755         = ...
        {'p7429'  'p7457'  'p7239'   'p6995'  'p6938'  'p7436'  'p7456'  ...
         'p7663'  'p7375'  'p7660'   'p7691'  'p7398'  'p7429'  'p7507'  'p7510'  'p7377'  'p7653' ...
         'p7564'  'p7577'  'p7604'   'p7610'  'p7646'  'p7671'  'p7698'  'p7719'  'p7384'  'p7527' ...
         'p7730'  ...
         'p6938'  'p7239'  'p7248'   'p7627'  'p7243'  'p7605'  'p7257'  'p7270'  'p7260'  'p7686' ...
         'p7267'  'p7153'  'p7266'   'p7118'  'p7189'  'p7414'  'p7217'  'p7216'  'p7457'  'p7309' ...
         'p7335'  'p7338'  'p7413'   'p7631'  'p7446'  'p7470'  'p7540'  'pXXXX'  'p7542'  'p7624' ...
         'p7629'  'p7630'  'p7665'   'p7684'  'p7733'  'p7740'  'p7740'  'p7749'  'p7146'  'p7475' ...
         'p7229'  'p7499'  'p7321'}; % MROMI, ToBluearc
        pnumNp797         = ...
        {'p7118'  'p7153'  'p7146'   'p7189'  'p7191'  'p7194'  'p7217'  'p7219'  'p7229'  'p7230'  ...
         'p7243'  'p7248'  'p7257'   'p7260'  'p7266'  'p7267'  'p7270'  'p7309'  'p7321'  'p7335'  ...
         'p7336'  'p7338'  'p7377'   'p7395'}; 
        prefixNp797       = ...
        {'wu001_' 'wu002_' 'wu003_'  'wu005_' 'wu006_' 'wu007_' 'wu009_' 'wu010_' 'wu011_' 'wu012_' ...
         'wu014_' 'wu015_' 'wu016_'  'wu017_' 'wu018_' 'wu019_' 'wu021_' ''       'wu024_' 'wu026_' ...
         'wu027_' 'wu028_' '01-020_' 'wu029_'};
        suffixNp797       = ...
        {'_2007oct16'      '_2008jan16'      '_2008jan4'       '_2008mar12'      '_2008mar13' ...
         '_2008mar14'      '_2008apr14'      '_2008apr23'      '_2008apr28'      '_2008apr29' ...
         '_2008may21'      '_2008may23'      '_2008jun4'       '_2008jun9'       '_2008jun16' ...
         '_2008jun16'      '_2008jun18'      '_2008aug20'      '_2008sep8'       '_2008oct21' ...
         '_2008oct21'      '_2008oct30'      '_2009feb5'       '_2009mar12'};
        jessyFilenameStem = ...
        {''                'P003GE_MSS-1.mat' 'P002GE_M.mat'       'P004GE_A_SVD.mat'   'P005GE_A.mat'    ...
         'P006GE_A.mat'    'P008GE_A.mat'     'P009GE_A.mat'       'P010GE_A.mat'       'P011GE_A_FS.mat' ...
         'P012GE_A_FS.mat' 'P013GE_A_FS.mat'  'P013GE_A_p7257.mat' 'P014GE_A_p7260.mat' 'P002GE_A.mat'    ...
         'P004GE_A.mat'    'P005GE_A.mat'     'P006GE_M.mat'       'P007GE_A.mat'       'P012GE_A.mat'    ...
         'P003GE_A.mat'    'P013GE_A.mat'     ''                   'P014GE_MSS.mat'};
    end % const properties

    methods (Static)

        function this = getInstance(pid)
            
            %% GETINSTANCE
            %  Usage:  obj = mlfourd.DBase_ori.getInstance(pid [, sid])
            %
			import mlfourd.*;
            persistent myoriobj;
            if (isempty(myoriobj) || ~isvalid(myoriobj))
                disp('mlfourd.DBase_ori:  new, persistent instance created');
                myoriobj = mlfourd.DBase_ori;
                myoriobj.counter = 1;
				if (nargin > 0); myoriobj.pid = pid; end
                if (nargin > 1); myoriobj.sid = sid; end
            else
                myoriobj.counter = myoriobj.counter + 1;
				if (nargin > 0), myoriobj.pid = pid; end
                if (nargin > 1); myoriobj.sid = sid; end
            end
			if (strncmpi('vc', myoriobj.pid, 2))
                myoriobj.pid = myoriobj.vnum2pnum(pid);
			end
			this = myoriobj;
        end % static function getInstance

        function pnum = ensurePnum(id)
            
            %% ENSUREPNUM validates & converts to canonical forms as needed
            assert(ischar(id));
            if (strncmpi('vc', id, 2))
                try
                    db   = mlfourd.DBase_ori.getInstance;
                    pnum = db.vnum2pnum(id);
                    return;
                catch ME
                    handerror(ME, ['DBase_ori.ensurePnum:  ensurePnum could not find p-number for identifier ' id]);
                end
            end
            if (strncmpi('p', id, 1) || numel(id) == 3)
                pnum = id;
                return;
            end
            throw(MException('mlfourd:InputParamErr', ...
                            ['ensurePnum could not recognize identifier ' id]));
        end % static function ensurePnum
    end % static methods

    methods
                
        function pth = get.patient_path(this)
        
            %% GET.PATIENT_PATH
            import mlfourd.*; 
            if (~isempty(this.patient_path))
                pth = this.patient_path;
            elseif (~isempty(this.sid) && ~isempty(this.pid))
                switch (this.sid)
                case 'np287'
                    pth = fullfile(this.cvl_path, this.sid, this.pnum2vnum(  this.pid), '');
                case 'qBOLD'
                    pth = fullfile(this.cvl_path, this.sid, this.qcbf_folder(this.pid), '');
                case 'MROMI'
                    pth = fullfile(this.cvl_path, this.sid,                  this.pid,  '');
                case 'ICH'
                    assert (~isempty(this.timepoint));
                    pth = fullfile(this.cvl_path, 'MROMI', 'ICH', this.pid, [this.pid '_raw'], [this.timepoint '_raw'], 'betted', '');
                otherwise
                    pth = this.patient_path;
                end
            else
                pth = pwd;
            end
                    
        end % function get.patient_path
        
        function id = sid(this, pid)
            
            %% SID
            %  Usage:  instance = mlfourd.DBase_ori.getInstance;
            %          sid      = instance.sid([pid]);
            %          pid:       string to identify patient, e.g., 'p5777' or 'vc4437'.  
            %                     Updates singleton instance.pid.  
            if (nargin > 1)
                this.pid = mlfourd.DBase_ori.ensurePnum(pid);
            end % if
            switch (numel(this.pid))
                case 0
                    handerror(MException('mlfourd:UnassignedVariable', ...
                                         'DBase_ori.sid:  pid was empty')); 
                case 3
                    id = 'MROMI';
                    return;
                case 5
                    assert(strcmp('p', this.pid(1)), ['unexpected pid: ' this.pid]);
                    if     (any(strcmp(this.pid, this.pnumNp287)))
                        id = 'np287';
                    elseif (any(strcmp(this.pid, this.pnumNp755)))
                        id = 'np755';
                    elseif (any(strcmp(this.pid, this.pnumNp797)))
                        id = 'np797';
                    else
                        id = '';
                    end
                case 6
                    if     (any(strcmp(this.pid, this.vcnumNp287)))
                        id = 'np287';
                    else
                        handerror(MException('mlfourd:InputParamErr', ...
                                            ['DBase_ori.sid:  input param was unrecognizable:  pid->' this.pid]));
                    end
                otherwise
                    henderror(MException('mlfourd:InputParamErr', ...
                                        ['DBase_ori.sid:  input param was unrecognizable:  pid->' this.pid]));
            end % switch  
        end % function sid

		function tf   = hasFsl(this)
            
			tf = (7 == exist(fullfile(this.patient_path, 'fsl'), 'dir'));
        end
        
        function fld  = onFolder(this)
            fld = ['on' upper(this.ref_fp(1)) this.ref_fp(2:end)];
        end
        
        function suff = ref_series(this)
            suff = ['_on_' this.ref_fp]; % '_xr3d'; % '_on_t1'; % '_on_oef
        end
        
        function suff = pet_ref_series(this)
            suff = ['_on_' this.ref_fp]; % '_xr3d'; % '_susan10mm';
        end
        
        function pth  = petPath(this, pid)
            
            %% PET_PATH
            %
            if (nargin > 1); this.pid = mlfourd.DBase_ori.ensurePnum(pid); end
            switch (this.sid)
            case 'np287'
                if (~this.hasFsl)
                    pth = fullfile(this.patient_path, '962_4dfp');
                else
                    pth = fullfile(this.patient_path, 'fsl', '');
                end
            otherwise
                pth = fullfile(this.patient_path, 'fsl', 'bet', this.onFolder, '');
            end
        end % petPath
        
        function suff = block_suffix(this, isblk)
            
            %% BLOCK_SUFFIX
            %  Usage:   suff = obj.block_suffix([isblk])
            %                                    ^ bool forces adding block status to suffix
            %
            if (nargin < 2); isblk = this.block2bool; end
            if (isblk)
                bS   = this.blockSize;
                suff = ['_' num2str(bS(1)) 'x' num2str(bS(2)) 'x' num2str(bS(3)) 'blocks'];
            else
                suff = '';
            end
        end
        
        function suff = blur_suffix(this, isblr)
            
            %% BLUR_SUFFIX
            %  Usage:   suff = this.blur_suffix([isblr])
            %                                   ^ bool forces adding blur status to suffix
            %
            if (nargin < 2); isblr = this.blur2bool; end
            if (isblr)
                bB   = this.baseBlur;
                suff = ['_' num2str(bB(1),1) 'x' num2str(bB(2),1) 'x' num2str(bB(3),1) 'blur'];
            else
                suff = '';
            end
        end
        
        function fn  = jessy_filename(this, isfq)
            
            %% JESSY_FILENAME  
            %  isfq:  bool true -> return fully qualified filename
            %
            if (nargin < 2); isfq = true; end
            switch (this.sid)
            case 'np797'
                fn = this.jessy_filename0(this.pid);
            otherwise
                handexcept(MException('mlfourd:InternalStateErr', ...
                                     ['DBase_ori.jessy_filename:  could not recognize ' this.sid]));
            end
            if (isfq); fn = fullfile(this.patient_path, 'qCBV', char(fn)); end
        end % jessy_filename
          
        function fn  = ho_filename(this, isfq, isblk, isblr)
            
            %% HO_FILENAME  
            %  isfq:  true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq  = 1; end
            if (nargin < 3); isblk = this.block2bool; end
            if (nargin < 4); isblr = this.blur2bool; end
            switch (this.sid)
                case 'np287'
                    if(~this.hasFsl)
                        fn = [this.pid 'ho1' this.pet_ref_series                       this.block_suffix(isblk) '.4dfp'];
                    else
                        fn = [this.h15o this.pet_ref_series                        this.block_suffix(isblk)];
                    end
                otherwise
                    fn =     [this.h15o this.pet_ref_series this.blur_suffix(isblr) this.block_suffix(isblk)];
            end
            switch (double(isfq))
                case 1
                    fn = fullfile(this.petPath, [fn this.img_format]);
                case 0
                    fn =                         [fn this.img_format];
                otherwise
            end
        end % ho_filename
    
        function fn  = oc_filename(this, isfq, isblk, isblr)
            
            %% OC_FILENAME  
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq  = 1; end
            if (nargin < 3); isblk = this.block2bool; end
            if (nargin < 4); isblr = this.blur2bool; end
            switch (this.sid)
                case 'np287'
                    if(~this.hasFsl)
                        fn = [this.pid 'oc1' this.pet_ref_series                        this.block_suffix(isblk) '.4dfp'];
                    else
                        fn = [this.c15o  this.pet_ref_series                        this.block_suffix(isblk)];
                    end
                otherwise
                    fn =     [this.c15o  this.pet_ref_series this.blur_suffix(isblr) this.block_suffix(isblk)];
            end
            switch (double(isfq))
                case 1
                    fn = fullfile(this.petPath, [fn this.img_format]);
                case 0
                    fn =                         [fn this.img_format];
                otherwise
            end
        end % oc_filename
    
        function fn  = oo_filename(this, isfq, isblk, isblr)
            
            %% OO_FILENAME 
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq  = 1; end
            if (nargin < 3); isblk = this.block2bool; end
            if (nargin < 4); isblr = this.blur2bool; end
            switch (this.sid)
                case 'np287'
                    if(~this.hasFsl)
                        fn = [this.pid 'oo1' this.pet_ref_series                         this.block_suffix(isblk) '.4dfp'];
                    else
                        fn = [this.o15o  this.pet_ref_series                         this.block_suffix(isblk) this.img_format];
                    end
                otherwise
                    fn =     [this.o15o  this.pet_ref_series this.blur_suffix(isblr) this.block_suffix(isblk)];
            end
            switch (double(isfq))
                case 1
                    fn = fullfile(this.petPath, [fn this.img_format]);
                case 0
                    fn =                         [fn this.img_format];
                otherwise
            end
        end % oo_filename
    
        function pth = hdrinfo_path(this, pid)
            
            %% HDRINFO_PATH
            %
            if (nargin > 1); this.pid = mlfourd.DBase_ori.ensurePnum(pid); end
            pth = fullfile(this.patient_path, 'ECAT_EXACT', 'hdr_backup','');
        end % hdrinfo_path

        function fn  = hdrinfo_filename(this, tracer, isfq)
            
            %% HDRINFO_FILENAME
            %  Usage:  fn = mlfourd.DBase_ori.hdrinfo_filename(tracer, isfq)
            %          isfq:  bool true -> return fully qualified filename
            %
            if (nargin < 3); isfq = true; end
            if (nargin < 2); tracer = 'ho1'; end
            switch (tracer)
            case {'ho','ho1','ho2'}
                fn = [this.pid tracer '_g3.hdr.info'];
            case {'oc','oc1','oc2'}
                fn = [this.pid tracer '_g3.hdr.info'];
            case {'oo','oo1','oo2'}
                fn = [this.pid tracer '_g3.hdr.info'];
            case {'ho1_g3',  'ho2_g3',  'oc1_g3',  'oc2_g3',     'oo1_g3',     'oo2_g3',...
                  'ho1_rot', 'oo1_rot', 'oc1_rot', 'ho1_rot_g3', 'oo1_rot_g3', 'oc1_rot_g3', ...
                  'ho2_rot', 'oo2_rot', 'oc2_rot', 'ho2_rot_g3', 'oo2_rot_g3', 'oc2_rot_g3'}
                fn = [this.pid tracer '.hdr.info'];
            otherwise
                error('mlfourd:InternalStateErr', ...
                     ['DBase_ori.hdrinfo_filename:  could not recognize tracer->' tracer]);
            end
            if (isfq); fn = fullfile(this.hdrinfo_path, fn); end
        end % hdrinfo_filename
        
        function fn = pet_filename(this, metric, isfq, isblk, isblr)
            
            %% PET_FILENAME 
            %  Usage:  fn = DBase_ori.getInstance.pet_filename(metric, isfq, isblk, isblr)
            %  isfq:   bool   -> fully-qualified name
            %          ~0, ~1 -> fileprefix only
            if (nargin < 2); metric = 'cbf'; end
            if (nargin < 3); isfq   = true; end
            if (nargin < 4); isblk  = this.block2bool; end
            if (nargin < 5); isblr  = this.blur2bool; end
            fn = [this.pet_fileprefix(metric, isblk, isblr) this.img_format];
            if (isfq)
                fn = fullfile(this.petPath, fn);
            end
        end
        
        function fn = pet_fileprefix(this, metric, isblk, isblr)
            
            %% PET_FILEPREFIX
            %  Usage:  fn = DBase_ori.getInstance.pet_filename(metric, isfq, isblk, isblr)
            %  isfq:   bool   -> fully-qualified name
            %          ~0, ~1 -> fileprefix only
            if (nargin < 2); metric = 'cbf'; end
            if (nargin < 3); isblk  = this.block2bool; end
            if (nargin < 4); isblr  = this.blur2bool; end
            switch (metric)
                case {'ho','ho1','ho2','petho','petho1'}
                    fn = ho_filename(isfq, isblk, isblr);
                case {'oo','oo1','oo2','petoo','petoo1'}
                    fn = oo_filename(isfq, isblk, isblr);
                case {'oc','oc1','oc2','petoc','petoc1'}
                    fn = oc_filename(isfq, isblk, isblr);
                otherwise
                    fn = ['p' metric '_rot' this.pet_ref_series this.blur_suffix(isblr) this.block_suffix(isblk)];
            end       
        end % pet_filename
        
        function pth = mr_path(this, pid)
            
            if (nargin > 1); this.pid = mlfourd.DBase_ori.ensurePnum(pid); end
            switch (this.sid)
            case 'np287'
                if (~this.hasFsl)
					pth = fullfile(this.patient_path, '4dfp', '');
				else
                	pth = fullfile(this.patient_path, 'fsl',  '');
                end
            otherwise
                pth = fullfile(this.patient_path, 'fsl', 'bet', this.onFolder, '');
            end
        end 
        
        function fn  = t1_filename(this, isfq, isblk, isblr)
            
            %% T1_FILENAME
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq  = 1; end
            if (nargin < 3); isblk = false; end
            if (nargin < 4); isblr = false; end
            switch (this.sid)
                case 'np287'
                    if(~this.hasFsl)
                        fn = [this.t1_variant '_xr3d' this.block_suffix(isblk) '.4dfp'];
                    else
                        fn = [this.t1_variant         this.block_suffix(isblk)];
                    end
                otherwise
                        fn = ['t1_rot'                this.blur_suffix(isblr) this.block_suffix(isblk)];
            end
            switch (double(isfq))
                case 1
                    fn = fullfile(this.patient_path, 'fsl', [fn this.img_format]);
                case 0
                    fn =                                    [fn this.img_format];
                otherwise
            end
        end % t1_filename      
 
        function fn  = mr_filename( this, metric, isfq, isblk, isblr)
            
            %% MR_FILENAME
            %  if
            if (nargin < 2); metric = 'cbf'; end
            if (nargin < 3); isfq   = 1; end
            if (nargin < 4); isblk  = this.block2bool; end            
            if (nargin < 5); isblr  = this.blur2bool; end
            if (this.iscomparator)
                fn = this.mr0_filename(metric, isfq, isblk, isblr);
            else
                fn = this.mr1_filename(metric, isfq, isblk, isblr);
            end
        end
        
        function fn  = mr0_filename(this, metric, isfq, isblk, isblr)
            
            %% MR0_FILENAME
            %  metric:  string
            %  isfq:    bool true -> return fully qualified filename
            %
            if (nargin < 2); metric = 'cbf'; end
            if (nargin < 3); isfq   = 1; end
            if (nargin < 4); isblk  = this.block2bool; end            
            if (nargin < 5); isblr  = this.blur2bool; end
            this.iscomparator        = true;
            switch (this.sid)
            case 'np287'
                fn = [    metric                                this.block_suffix(isblk)];
            otherwise
                fn = ['s' metric '_rot' this.blur_suffix(isblr) this.block_suffix(isblk)];
            end
            switch (double(isfq))
                case 1
                    fn = fullfile(this.mr_path, [fn this.img_format]);
                case 0
                    fn =                        [fn this.img_format];
                otherwise
            end
        end %  mr0_filename

        function fn  = mr1_filename(this, metric, isfq, isblk, isblr)
            
            %% MR1_FILENAME
            %  metric:  string
            %  isfq:    bool true -> return fully qualified filename
            %
            if (nargin < 2); metric = 'cbf'; end
            if (nargin < 3); isfq   = 1;  end
            if (nargin < 4); isblk  = this.block2bool; end
            if (nargin < 5); isblr  = this.blur2bool; end
            this.iscomparator        = false;
            switch (this.sid)
            case 'np287'
                fn = [    metric                         this.block_suffix(isblk)];
            otherwise
                fn = ['q' metric '_rot' this.blur_suffix(isblr) this.block_suffix(isblk)];
            end
            switch (double(isfq))
                case 1
                    fn = fullfile(this.mr_path, [fn this.img_format]);
                case 0
                    fn =                        [fn this.img_format];
                otherwise
            end
        end % mr1_filename
        
        function pth = epi_path(this, pid)
            
            %% EPI_PATH
            %
            if (nargin > 1); this.pid = mlfourd.DBase_ori.ensurePnum(pid); end
            pth = this.mr_path;
        end % epi_path

        function fn  = epi_filename(this, isfq)
            
            %% EPI_FILENAME
            %  isfq:  bool true -> return fully qualified filename
            % 
            if (nargin < 2); isfq = 1; end
            switch (this.sid)
            case  'np287'
               	fn = ['perfusion' this.pv_variant '_xr3d'];
            otherwise
                fn = 'bep2d_rot_mcf_meanvol';
            end
            switch (double(isfq))
                case 1
                    fn = fullfile(this.epi_path, [fn this.pet_ref_series this.img_format]);
                case 0
                    fn =                         [fn this.pet_ref_series this.img_format];
                otherwise
            end
        end % epi_filename
        
        function pth = roi_path(this, pid)
            
            %% ROI_PATH
            %  Usage:  id:  string to identify patient, e.g., 'p5777' or 'vc4437'.  Updates this.pid.  Optional.
            %
            if (nargin > 1); this.pid = mlfourd.DBase_ori.ensurePnum(pid); end
            switch (this.sid)
            case 'np287'
                pth = fullfile(this.patient_path, 'ROIs/Xr3d');
            otherwise
                pth = this.mr_path;
            end
        end % roi_path

        function pth = fg_path(this, pid)
            
            %% FG_PATH
            %  Usage:  id:  string to identify patient, e.g., 'p5777' or 'vc4437'.  Updates this.pid.  Optional.
            %
			if (nargin > 1); this.pid = mlfourd.DBase_ori.ensurePnum(pid); end
            pth = this.roi_path(this.pid);
        end % fg_path
                 
        function fn  = fg_filename(this, isfq, isblk, isblr)
            
            %% FG_FILENAME 
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq  = 1; end
            if (nargin < 3); isblk = false; end
            if (nargin < 4); isblr = false; end
            switch (this.sid)
                case 'np287'
                    fn = ['fg' this.ref_series this.block_suffix(isblk)];
                case 'np797'
                    if (this.useQBOLD)
                        fstem = 'mask';
                    else
                        fstem = 'bt1_rot_mask';
                    end
                    fn = [fstem this.blur_suffix(isblr) this.block_suffix(isblk)];
                otherwise
                    fn = 'base_rot_mcf_meanvol_mask.nii.gz';
            end
            switch (double(isfq))
                case 1
                    fn = fullfile(this.fg_path, [fn this.img_format]);
                case 0
                    fn =                        [fn this.img_format];
                otherwise
            end
        end % fg_filename
        	
        function fn  = seg_filename(this, filestem)

            if (1 == nargin); filestem = 'newseg'; end
            fn = fullfile(this.patient_path, [filestem '_' this.pid '.hdr']);
        end
        
        function idx = pnumIndex(this)
            
            switch (this.sid)
                case 'np287'
                    list = 'pnumNp287';
                case 'np797'
                    list = 'pnumNp797';
                case {'MROMI','ICH'}
                    idx = this.pid;
                otherwise
                    error('mlfourd:ParamValueErr', ['DBase_ori.pnumIndex.sid -> ' this.sid]);
            end
            idx = strmatch(this.pid, this.(list));
        end
        
        function fn  = art_filename(this, isfq, isblocked)
            
            %% ART_FILENAME 		
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq = 1; end
            if (nargin < 3); isblocked = false; end
            fn = ['arteries' this.ref_series this.block_suffix(isblocked)];
            switch (double(isfq))
                case 1
                    fn = fullfile(this.roi_path, [fn this.img_format]);
                case 0
                    fn =                         [fn this.img_format];
                otherwise
            end
        end % art_filename
        		
        function fn  = csf_filename(this, isfq, isblocked)
            
            %% CSF_FILENAME 		
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq = 1; end
            if (nargin < 3); isblocked = false; end
            fn = ['csf' this.ref_series this.block_suffix(isblocked)];
            switch (double(isfq))
                case 1
                    fn = fullfile(this.roi_path, [fn this.img_format]);
                case 0
                    fn =                         [fn this.img_format];
                otherwise
            end
        end % csf_filename
        
        function fn  = grey_filename(this, isfq, isblocked)
            
            %% GREY_FILENAME 		
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq = 1; end
            if (nargin < 3); isblocked = false; end
            fn = ['grey' this.ref_series this.block_suffix(isblocked)];
            switch (double(isfq))
                case 1
                    fn = fullfile(this.roi_path, [fn this.img_format]);
                case 0
                    fn =                         [fn this.img_format];
                otherwise
            end
        end % grey_filename
        
        function fn  = white_filename(this, isfq, isblocked)
            
            %% WHITE_FILENAME 		
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq = true; end
            if (nargin < 3); isblocked = false; end
            fn = ['white' this.ref_series this.block_suffix(isblocked)];
            switch (double(isfq))
                case 1
                    fn = fullfile(this.roi_path, [fn this.img_format]);
                case 0
                    fn =                         [fn this.img_format];
                otherwise
            end
        end % white_filename
        			
        function pnum = vnum2pnum(this, vnum)
            
            %% VNUM2PNUM
            %
            if (strcmp('np287', this.sid))
                pnum = this.pnumNp287{strmatch(vnum, this.vnumNp287)};
            else
                pnum = vnum;
            end
        end % vnum2pnum
        
        function vnum = pnum2vnum(this, pnum)
            
            %% PNUM2VNUM
            %
            if (strcmp('np287', this.sid))
                vnum = this.vnumNp287{strmatch(pnum, this.pnumNp287)};
            else
                vnum = pnum;
            end
        end % pnum2vnum
        
        function mn = minVoxelsPerBlock(this) %#ok<MANU>
            
            %% MINVOXELSPERBLOCK
            %%nvxl = prod(this.blockSize);
            %%mn   = nvxl/2;
            mn   = 10;
        end
        
        function disp(this)
            
            %% DISP overrides superclasses
            PRECOLON_LEN = 25;
            pnum         = this.pid;
            vnum         = this.pnum2vnum(pnum);
            
            disp@handle(this);
            fprintf(1, 'Methods:\n');
            frmt = ['%' num2str(PRECOLON_LEN) 's%s\n'];
            fprintf(1, frmt, this.method_label(@this.block_suffix), this.block_suffix);
            fprintf(1, frmt, this.method_label(@this.csf_filename), this.csf_filename);
            fprintf(1, frmt, this.method_label(@this.disp), 'disp');
            fprintf(1, frmt, this.method_label(@this.epi_filename), this.epi_filename);
            fprintf(1, frmt, this.method_label(@this.epi_path), this.epi_path);
            fprintf(1, frmt, this.method_label(@this.fg_filename), this.fg_filename);
            fprintf(1, frmt, this.method_label(@this.fg_path), this.fg_path);
            fprintf(1, frmt, this.method_label(@this.grey_filename), this.grey_filename);            
            fprintf(1, frmt, this.method_label(@this.hdrinfo_filename), this.hdrinfo_filename);
            fprintf(1, frmt, this.method_label(@this.hdrinfo_path), this.hdrinfo_path);
            fprintf(1, frmt, this.method_label(@this.ho_filename), this.ho_filename);
            %%fprintf(1, frmt, this.method_label(@this.jessy_filename), this.jessy_filename);
            fprintf(1, frmt, this.method_label(@this.mr0_filename), this.mr0_filename);
            fprintf(1, frmt, this.method_label(@this.mr1_filename), this.mr1_filename);
            fprintf(1, frmt, this.method_label(@this.mrBlur), num2str(this.mrBlur));
            fprintf(1, frmt, this.method_label(@this.mr_path), this.mr_path);
            fprintf(1, frmt, this.method_label(@this.oc_filename), this.oc_filename);
            fprintf(1, frmt, this.method_label(@this.oo_filename), this.oo_filename);
            fprintf(1, frmt, this.method_label(@this.patient_path), this.patient_path);
            fprintf(1, frmt, this.method_label(@this.petBlur), num2str(this.petBlur));
            fprintf(1, frmt, this.method_label(@this.pet_filename), this.pet_filename);
            fprintf(1, frmt, this.method_label(@this.petPath), this.petPath);
            fprintf(1, frmt, this.method_label(@this.pnum2vnum), pnum);
            fprintf(1, frmt, this.method_label(@this.roi_path), this.roi_path);
            fprintf(1, frmt, this.method_label(@this.sid), this.sid);
            fprintf(1, frmt, this.method_label(@this.t1_filename), this.t1_filename);
            if (this.hasFsl); hasfsl = 'true'; else hasfsl = 'false'; end
            fprintf(1, frmt, this.method_label(@this.hasFsl), hasfsl);
            fprintf(1, frmt, this.method_label(@this.vnum2pnum), vnum);
            fprintf(1, frmt, this.method_label(@this.white_filename), this.white_filename);
        end
    end % public methods

    methods (Access = private)

        function this = DBase_ori
            
            %% CTOR is private and empty to ensure getInstance is the only entry into the class
        end % private ctor
        
        function fn0 = jessy_filename0(this, pid)
            
            %% JESSY_FILENAME0
            if (nargin > 1); this.pid = mlfourd.DBase_ori.ensurePnum(pid); end
           	for i = 1:length(    this.pnumNp797) %#ok<FORFLG>
                if (strcmpi(pid, this.pnumNp797{i})) %#ok<PFBNS>
                    fn0 = this.jessyFilenameStem{i}; %#ok<PFTUS>
                    return;
                end
            end
			error('mlfourd:DataNotFoundErr', ...
                 ['DBase_ori.jessy_filename0:  could not recognize this.pid -> ' this.pid]);
        end % private jessy_filename0
        
        function s = method_label(this, fhandle) %#ok<MANU>
            
            %% METHOD_LABEL pads methodnames so that all possible methodnames from DBase_ori
            %  will be returned in char array s, right-justified, ending with ': '.
            %  Usage:  s = method_label(@functionname)
            fname    = func2str(fhandle);
            idx      = findstr('.', fname);
            if (~isempty(idx));  fname = strtrim(fname(idx+1:end)); end
            idx2     = findstr('(varargin{:})', fname);
            if (~isempty(idx2)); fname = strtrim(fname(1:idx2-1)); end
            s        = sprintf('%s: ', fname);
        end
        
        function fold = qcbf_folder(this, pid)
            
            %% QCBF_FOLDER
            if (nargin > 1); this.pid = mlfourd.DBase_ori.ensurePnum(pid); end
           	idx  = strmatch(pid, this.pnumNp797);
            fold = [this.prefixNp797{idx} this.pnumNp797{idx} this.suffixNp797{idx}];
        end % private qcbf_folder
    end % private methods 
end % classdef DBase_ori
