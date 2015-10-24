classdef (Sealed) DBase < mlfourd.CvlDBase
    
    %% DBASE is a wrapper for simple database queries.
    %
    %  Instantiation:  instance = mlfsl.Np797Registry.instance;
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
        ref_fp       = 'bt1_rot';
        t1     = 't1_rot';
        t2     = 't2_rot';
        flair  = 'flair_rot_abs';
        ep2d   = 'ep2d2_rot';
        h15o     = 'hosum_rot';
        c15o     = 'oc_rot';
        o15o     = 'oosum_rot';
        pv_variant   = '';        % naming convention
        t1_variant   = 't1_rot';  % naming convention
        timepoint    = 'tp1';
        bookendsFolder = 'qCBF';
        useQBOLD     = false;
        metricThresh = [eps 1e7]; % refine in MR/PETconverter    
        iscomparator = false;
        
        % N.B. near duplication in FslBuilder
        
        fsldir            = '/opt/fsl';
        timeseriesPattern = {'ep2d', 'pasl', 'pcasl', 'ase'}; 
        petTracers        = {'ho' 'oo' 'oc' 'tr' 'mask'};
        petTries          = {'' '2' '3' '4'};
        rotSuff           = '_rot';
        allNIfTI          = '*.nii.gz';
        allAffine         = '*.mat';
        preferDataType   = 'FLOAT';
        force             =  'f';
    end % properties
    
    properties (Dependent)
        fslbinPath
        standardPath
        atlasPath
        ep2d_fps
        ep2d_meanvol_fps
    end
    
    
    
    %% MEMBER METHODS
    
    methods
        
        function fnam = betted(this, fnam)
            
            %% BETTED is a convenience wrapper
            import mlfsl.* mlfourd.*;
            [~,f, e] =  filepartsx(fnam, AbstractImage.FILETYPE_EXT);
                fnam = [BetBuilder.BET_PREFIX f BetBuilder.BET_SUFFIX e];
        end
        
        
        
        
        function p   = get.fslbinPath(this)
            p = fullfile(this.fsldir, 'bin', '');
        end
        
        function p   = get.standardPath(this)
            p = fullfile(this.fsldir, 'data/standard', '');
        end
        
        function p   = get.atlasPath(this)
            p = fullfile(this.fsldir, 'data/atlases/MNI', '');
        end
               
        function fps = get.ep2d_fps(this)
            
            % KLUDGE!
            
            fps0 = dir2cell(['*ep2d*' '_rot' mlfsl.FslBuilder.MCF_SUFF '*' mlfourd.NIfTI.FILETYPE_EXT]);
            fps0 = fileprefixes(fps0);
            if (~iscell(fps0)); fps0 = {fps0}; end
            f      = 0;
            fps    = {[]};
            for f0 = 1:length(fps0) %#ok<FORFLG,PFUNK>
                if (isempty(strfind(fps0{f0}, '_mask')) && ...
                    isempty(strfind(fps0{f0}, '_on_')))
                    f      = f + 1;
                    fps{f} = fps0{f0}; %#ok<PFPIE>
                end
            end
        end
        
        function fps = get.ep2d_meanvol_fps(this)
            tmp = this.ep2d_fps;
            fps = {[]};
            for t = 1:numel(tmp) %#ok<FORFLG>
                if (~isempty(strfind(tmp{t}, mlfsl.FslBuilder.MCF_MEANVOL_SUFF))) %#ok<PFBNS>
                    fps{t} = tmp{t};
                end
            end
        end
        
        
        
        
        
		function tf  = hasFsl(this)
			tf = (7 == exist(fullfile(this.patientPath, 'fsl'), 'dir'));
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
                                     ['DBase.jessy_filename:  could not recognize ' this.sid]));
            end
            if (isfq); fn = fullfile(this.patientPath, 'Trio', this.bookendsFolder, char(fn)); end
        end % jessy_filename
        
        function pth  = petPath(this)
            pth = fullfile(this.patientPath, 'fsl', '');
        end
        
          
        function fn  = ho_filename(this, isfq, isblk, isblr)
            
            %% HO_FILENAME  
            %  isfq:  true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq  = 1; end
            if (nargin < 3); isblk = this.block2bool; end
            if (nargin < 4); isblr = this.blur2bool; end

            fn = [this.h15o this.onReference this.blur_suffix(isblr) this.block_suffix(isblk)];

            switch (double(isfq))
                case 1
                    fn = fullfile(this.petPath, filename(fn));
                case 0
                    fn =                        filename(fn);
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

            fn = [this.c15o  this.onReference this.blur_suffix(isblr) this.block_suffix(isblk)];

            switch (double(isfq))
                case 1
                    fn = fullfile(this.petPath, filename(fn));
                case 0
                    fn =                         filename(fn);
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
            
            fn = [this.o15o  this.onReference this.blur_suffix(isblr) this.block_suffix(isblk)];
            
            switch (double(isfq))
                case 1
                    fn = fullfile(this.petPath, filename(fn));
                case 0
                    fn =                         filename(fn);
                otherwise
            end
        end % oo_filename
    
        function pth = hdrinfo_path(this, pid)
            
            %% HDRINFO_PATH
            %
            if (nargin > 1); this.pid = mlfourd.DBase.ensurePnum(pid); end
            pth = fullfile(this.patientPath, 'ECAT_EXACT', 'hdr_backup','');
        end % hdrinfo_path

        function fn  = hdrinfo_filename(this, tracer, isfq)
            
            %% HDRINFO_FILENAME
            %  Usage:  fn = mlfourd.DBase.hdrinfo_filename(tracer, isfq)
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
                     ['DBase.hdrinfo_filename:  could not recognize tracer->' tracer]);
            end
            if (isfq); fn = fullfile(this.hdrinfo_path, fn); end
        end % hdrinfo_filename
        
        function fn  = pet_filename(this, metric, isfq, isblk, isblr)
            
            %% PET_FILENAME 
            %  Usage:  fn = mlfsl.Np797Registry.instance.pet_filename(metric, isfq, isblk, isblr)
            %  isfq:   bool   -> fully-qualified name
            %          ~0, ~1 -> fileprefix only
            if (nargin < 2); metric = 'cbf'; end
            if (nargin < 3); isfq   = true; end
            if (nargin < 4); isblk  = this.block2bool; end
            if (nargin < 5); isblr  = this.blur2bool; end
            fn = filename(this.pet_fileprefix(metric, isblk, isblr));
            if (isfq)
                fn = fullfile(this.petPath, fn);
            end
        end
        
        function fn  = pet_fileprefix(this, metric, isblk, isblr)
            
            %% PET_FILEPREFIX
            %  Usage:  fn = mlfsl.Np797Registry.instance.pet_filename(metric, isfq, isblk, isblr)
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
                    fn = ['p' metric '_rot' this.onReference this.blur_suffix(isblr) this.block_suffix(isblk)];
            end       
        end % pet_filename
        
        function pth = mr_path(this, pid)
            
            if (nargin > 1)
                this.pid = mlfourd.DBase.ensurePnum(pid); 
            end
            pth = fullfile(this.patientPath, 'fsl', '');
        end 
        
        
        
        
        
        
        function fp  = t1_fp(this, pth)
            if (exist('pth','var'))
                fp = this.cvlFileprefix(this.t1, pth);
            else
                fp = this.cvlFileprefix(this.t1);
            end
        end
        
        function fn  = t1_fn(this, pth)
            if (exist('pth','var'))
                fn = this.cvlFilename(this.t1, pth);
            else
                fn = this.cvlFilename(this.t1);
            end
        end
        
        function fn  = oldFilename(this, fh, isfq, isblk, isblr)
            
            %% OLDFILENAME
            %  Usage:  filename = obj.oldFilename(func-handle, is-fq, is-block, is-blur)
            blksuf0 = this.useBlockSuffix;
            blrsuf0 = this.useBlurSuffix;
            switch (nargin)
                case {0,1}
                    error('mlfourd:InsufficientParams', 'DBase.t1_filename.nargin->%i\n', nargin);
                case 2
                    isfq = true;
                case 3
                case 4
                    this.useBlockSuffix = isblk;
                otherwise
                    this.useBlockSuffix = isblk;
                    this.useBlurSuffix  = isblr;
            end
            if (isfq)
                fn = fh(fullfile(this.patientPath, 'fsl'));
            else
                fn = fh;
            end
            this.useBlockSuffix = blksuf0;
            this.useBlurSuffix  = blrsuf0;
        end % oldFilename  
        
        function fn  = t1_filename(this, isfq, isblk, isblr)
            
            %% T1_FILENAME
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            fh = @this.t1_fn;
            switch (nargin)
                case 1
                    fn = this.oldFilename(fh);
                case 2
                    fn = this.oldFilename(fh, isfq);
                case 3
                    fn = this.oldFilename(fh, isfq, isblk);
                otherwise
                    fn = this.oldFilename(fh, isfq, isblk, isblr);
            end
        end
 
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
                fn = [    metric                                                    this.block_suffix(isblk)];
            otherwise
                fn = ['s' metric this.onReference this.blur_suffix(isblr) this.block_suffix(isblk)];
            end
            switch (double(isfq))
                case 1
                    fn = fullfile(this.mr_path, filename(fn));
                case 0
                    fn =                        filename(fn);
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

            fn = ['q' metric this.onReference this.blur_suffix(isblr) this.block_suffix(isblk)];
                
            switch (double(isfq))
                case 1
                    fn = fullfile(this.mr_path, filename(fn));
                case 0
                    fn =                        filename(fn);
                otherwise
            end
        end % mr1_filename
        
        function pth = epi_path(this, pid)
            
            %% EPI_PATH
            %
            if (nargin > 1); this.pid = mlfourd.DBase.ensurePnum(pid); end
            pth = this.mr_path;
        end % epi_path

        function fn  = epi_filename(this, isfq)
            
            %% EPI_FILENAME
            %  isfq:  bool true -> return fully qualified filename
            % 
            if (nargin < 2); isfq = 1; end

            fn = ['b' this.ep2d '_mcf_meanvol'];
            
            switch (double(isfq))
                case 1
                    fn = fullfile(this.epi_path, [fn this.onReference this.FILETYPE_EXT]);
                case 0
                    fn =                         [fn this.onReference this.FILETYPE_EXT];
                otherwise
            end
        end % epi_filename
        
        function pth = roi_path(this, pid)
            
            %% ROI_PATH
            %  Usage:  id:  string to identify patient, e.g., 'p5777' or 'vc4437'.  Updates this.pid.  Optional.
            %
            if (nargin > 1); this.pid = mlfourd.DBase.ensurePnum(pid); end
            pth = this.mr_path;
        end % roi_path

        function pth = fg_path(this, pid)
            
            %% FG_PATH
            %  Usage:  id:  string to identify patient, e.g., 'p5777' or 'vc4437'.  Updates this.pid.  Optional.
            %
			if (nargin > 1); this.pid = mlfourd.DBase.ensurePnum(pid); end
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

            if (this.useQBOLD)
                fstem = 'mask';
            else
                fstem = 'bt1_rot_mask';
            end
            fn = [fstem this.blur_suffix(isblr) this.block_suffix(isblk)];

            switch (double(isfq))
                case 1
                    fn = fullfile(this.fg_path, filename(fn));
                case 0
                    fn =                        filename(fn);
                otherwise
            end
        end % fg_filename
        
        function fn  = seg_filename(this, filestem)

            if (1 == nargin); filestem = 'newseg'; end
            fn = fullfile(this.patientPath, [filestem '_' this.pid '.hdr']);
        end
        
        function fn  = art_filename(this, isfq, isblocked)
            
            %% ART_FILENAME 		
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq = 1; end
            if (nargin < 3); isblocked = false; end
            fn = ['arteries' this.onReference this.block_suffix(isblocked)];
            switch (double(isfq))
                case 1
                    fn = fullfile(this.roi_path, filename(fn));
                case 0
                    fn =                         filename(fn);
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
            fn = ['rois_seg_csf' this.onReference this.block_suffix(isblocked)];
            switch (double(isfq))
                case 1
                    fn = fullfile(this.roi_path, filename(fn));
                case 0
                    fn =                         filename(fn);
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
            fn = ['grey' this.onReference this.block_suffix(isblocked)];
            switch (double(isfq))
                case 1
                    fn = fullfile(this.roi_path, filename(fn));
                case 0
                    fn =                         filename(fn);
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
            fn = ['white' this.onReference this.block_suffix(isblocked)];
            switch (double(isfq))
                case 1
                    fn = fullfile(this.roi_path, filename(fn));
                case 0
                    fn =                         filename(fn);
                otherwise
            end
        end % white_filename       
        
        function mn  = minVoxelsPerBlock(this) %#ok<MANU>
            
            %% MINVOXELSPERBLOCK
            %%nvxl = prod(this.blockSize);
            %%mn   = nvxl/2;
            mn   = 1;
        end
        
        function       dbfind(~)
            error('mlfourd:notImplemented', 'DBase.dbfind');
        end
        
        function       delete(~)
            error('mlfourd:notImplemented', 'DBase.delete');
        end
        
        function disp(this)
            
            %% DISP overrides superclasses
            WHITE_SPACE = 25;
            
            disp@handle(this);
            fprintf(1, 'Methods:\n');
            frmt = ['%' num2str(WHITE_SPACE) 's%s\n'];
            fprintf(1, frmt, this.method_label(@this.block_suffix),        this.block_suffix);
            fprintf(1, frmt, this.method_label(@this.blur_suffix),         this.blur_suffix);
            fprintf(1, frmt, this.method_label(@this.csf_filename),        this.csf_filename);
            fprintf(1, frmt, this.method_label(@this.disp),                    'disp');
            fprintf(1, frmt, this.method_label(@this.epi_filename),        this.epi_filename);
            fprintf(1, frmt, this.method_label(@this.epi_path),            this.epi_path);
            fprintf(1, frmt, this.method_label(@this.fg_filename),         this.fg_filename);
            fprintf(1, frmt, this.method_label(@this.fg_path),             this.fg_path);
            fprintf(1, frmt, this.method_label(@this.grey_filename),       this.grey_filename);            
            fprintf(1, frmt, this.method_label(@this.hdrinfo_filename),    this.hdrinfo_filename);
            fprintf(1, frmt, this.method_label(@this.hdrinfo_path),        this.hdrinfo_path);
            fprintf(1, frmt, this.method_label(@this.ho_filename),         this.ho_filename);
            %%fprintf(1, frmt, this.method_label(@this.jessy_filename),  this.jessy_filename);
            fprintf(1, frmt, this.method_label(@this.mr0_filename),        this.mr0_filename);
            fprintf(1, frmt, this.method_label(@this.mr1_filename),        this.mr1_filename);
            fprintf(1, frmt, this.method_label(@this.mrBlur),      num2str(this.mrBlur));
            fprintf(1, frmt, this.method_label(@this.mr_path),             this.mr_path);
            fprintf(1, frmt, this.method_label(@this.oc_filename),         this.oc_filename);
            fprintf(1, frmt, this.method_label(@this.oo_filename),         this.oo_filename);
            fprintf(1, frmt, this.method_label(@this.patientPath),         this.patientPath);
            fprintf(1, frmt, this.method_label(@this.petBlur),     num2str(this.petBlur));
            fprintf(1, frmt, this.method_label(@this.pet_filename),        this.pet_filename);
            fprintf(1, frmt, this.method_label(@this.petPath),            this.petPath);
            fprintf(1, frmt, this.method_label(@this.roi_path),            this.roi_path);
            fprintf(1, frmt, this.method_label(@this.sid),                 this.sid);
            fprintf(1, frmt, this.method_label(@this.t1_filename),         this.t1_filename);
            if (this.hasFsl); hasfsl = 'true'; else hasfsl = 'false'; end
            fprintf(1, frmt, this.method_label(@this.hasFsl),                   hasfsl);
            fprintf(1, frmt, this.method_label(@this.white_filename),      this.white_filename);
        end
    end % public methods

    
    
    %% STATIC METHODS
    
    methods (Static)

        function this = getInstance(pid, sid)
            
            %% GETINSTANCE
            %  Usage  obj = mlfsl.Np797Registry.instance(pid [, sid])
            %               mlfsl.Np797Registry.instance('delete') deletes the singleton
			import mlfourd.*;
            persistent  mydb;
            if (isempty(mydb) || ~isvalid(mydb))
                mydb         = mlfourd.DBase;
                mydb.counter = 1;
                if (mydb.verbose)                    
                    fprintf('\nmlfourd.DBase:   new, persistent instance created; counter = 1\n\n');
                end
            else
                mydb.counter = mydb.counter + 1;
            end
            switch (nargin)
                case 0
                    pnum = mlfourd.DBase.ensurePnum(pwd);
                    if (~isempty(pnum))
                        mydb.pid = pnum;
                        warning('mlfourd:guessingParamValue', 'Gusssing mlfsl.Np797Registry.instance.pid->%s\n', mydb.pid);
                    end
                case 1
                    mydb.pid = pid;
                case 2
                    mydb.pid = pid;
                    mydb.sid = sid;
            end
			this = mydb;
        end % static function getInstance
    end % static methods

    
    
    %% PRIVATE METHODS
    
    methods (Access = private)

        function this = DBase
            
            %% CTOR is private and empty to ensure getInstance is the only entry into the class
            this = this@mlfourd.CvlDBase;
        end % private ctor
        
        function fn0  = jessy_filename0(this, pid)
            
            if (nargin > 1); this.pid = mlfourd.DBase.ensurePnum(pid); end
           	for i = 1:length(    this.pnumNp797) %#ok<FORFLG>
                if (strcmpi(pid, this.pnumNp797{i})) %#ok<PFBNS>
                    fn0 = this.jessyFilenameStem{i}; %#ok<PFTUS>
                    return;
                end
            end
			error('mlfourd:DataNotFoundErr', ...
                 ['DBase.jessy_filename0:  could not recognize this.pid -> ' this.pid]);
        end % private jessy_filename0
        
        function fold = qcbf_folder(this, pid)
            
            %% QCBF_FOLDER
            if (nargin > 1); this.pid = mlfourd.DBase.ensurePnum(pid); end
           	idx  = strmatch(pid, this.pnumNp797);
            fold = [this.prefixNp797{idx} this.pnumNp797{idx} this.suffixNp797{idx}];
        end % private qcbf_folder
    end % private methods 
end % classdef DBase
