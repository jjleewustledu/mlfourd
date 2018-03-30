classdef CvlDBase < mlfourd.AbstractDBase
	%% CVLDBASE provides common data aggregates for CVL studies 
    %  Usage:  cdb = Cvlmlfsl.Np797Registry.instance
	%  Version $Revision$ was created $Date$ by $Author$  
 	%  and checked into svn repository $URL$ 
 	%  Developed on Matlab 7.12.0.635 (R2011a) 
 	%  $Id$ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Abstract)
        ref_fp
        ep2d_fps
    end
    
    properties (Constant)
        pnumNp755         = ...
        {'p7429'  'p7457'  'p7239'   'p6995'  'p6938'  'p7436'     'p7456'  ...
         'p7663'  'p7375'  'p7660'   'p7691'  'p7398'  'p7429'     'p7507'  'p7510'     'p7377'  'p7653' ...
         'p7564'  'p7577'  'p7604'   'p7610'  'p7646'  'p7671'     'p7698'  'p7719'     'p7384'  'p7527' ...
         'p7730'  ...
         'p6938'  'p7239'  'p7248'   'p7627'  'p7243'  'p7605'     'p7257'  'p7270'     'p7260'  'p7686' ...
         'p7267'  'p7153'  'p7266'   'p7118'  'p7189'  'p7414'     'p7217'  'p7216'     'p7457'  'p7309' ...
         'p7335'  'p7338'  'p7413'   'p7631'  'p7446'  'p7470'     'p7540'  'pXXXX'     'p7542'  'p7624' ...
         'p7629'  'p7630'  'p7665'   'p7684'  'p7733'  'p7740'     'p7740'  'p7749'     'p7146'  'p7475' ...
         'p7229'  'p7499'  'p7321'}; % MROMI, ToBluearc
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
        choiceNp797       = ...
        {0 1 1 1 1 1 1 1 1 1 ...
         1 1 1 1 1 1 1 0 1 1 ...
         1 1 0 1 1};        
    end

	properties 
        onReference = ''; % ['_on_' this.ref_fp]
        
                
        blockSize      = [1 1 1];
        baseBlur       = [0 0 0];
        mrBlur         = [0 0 0]; 
        petBlur        = [0 0 0];        
        useBlurSuffix  = false;
        useBlockSuffix = false;
        
        whiteMatterAverage  = false;
        rescaleWhiteMatter  = false;
        assumedWhiteAverage = 22;
        
        confidenceInterval = 95;
    end 
    
    properties (Dependent) 
        pnumIndex
    end

	methods 
        function        set.blockSize(this, blk)
            
            %% SET.BLOCKSIZE adds singleton dimensions as needed to fill 3D
            assert(isnumeric(blk));
            switch (numel(blk))
                case 1
                    switch (blk)
                        case 0
                            this.blockSize = [1 1 1]; % no blocks
                        otherwise
                            this.blockSize = [blk 1 1];
                    end
                case 2
                    this.blockSize = [blk(1) blk(2) 1];
                case 3
                    this.blockSize = [blk(1) blk(2) blk(3)];
                otherwise
                    this.blockSize = [1 1 1];
            end
        end % set.blockSize
        function        set.baseBlur(this, blr)
            
            %% SET.BLOCKSIZE adds singleton dimensions as needed to fill 3D
            assert(isnumeric(blr));
            switch (numel(blr))
                case 1
                    if (blr < sqrt(eps))
                        this.baseBlur = [0 0 0];
                    else
                        this.baseBlur = [blr blr blr];
                    end
                case 2
                    this.baseBlur = [blr(1) blr(2) 1];
                case 3
                    this.baseBlur = [blr(1) blr(2) blr(3)];
                otherwise
                    this.baseBlur = [0 0 0];
            end
        end % set.baseBlur
        function tf   = block2bool(this)
            assert(isnumeric(this.blockSize));
            tf = ~all([1 1 1] == this.blockSize);
        end
        function tf   = blur2bool(this)
            assert(isnumeric(this.baseBlur));
            tf = ~all([0 0 0] == this.baseBlur);
        end
        function suff = block_suffix(this, isblk)
            
            %% BLOCK_SUFFIX
            %  Usage:   suff = obj.block_suffix([isblk])
            %                                    ^ bool forces adding block status to suffix
            %
            if (nargin < 2); isblk = this.block2bool; end
            if (isblk && this.useBlockSuffix)
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
            if (isblr && this.useBlurSuffix)
                bB   = this.baseBlur;
                suff = ['_' num2str(bB(1),1) 'x' num2str(bB(2),1) 'x' num2str(bB(3),1) 'blur'];
            else
                suff = '';
            end
        end
        function idx  = get.pnumIndex(this)
            switch (this.sid)
                case 'np755'
                    list = 'pnumNp755';
                case 'np797'
                    list = 'pnumNp797';
                otherwise
                    idx = []; return;
            end
            idx  = -1;
            idxs = strncmp(this.pid, this.(list), length(this.pid));
            for s = 1:length(idxs) %#ok<FORFLG>
                if (idxs(s)); idx = s; break; end %#ok<PFTUS>
            end
        end % get.pnumIndex
        function fld  = abinitioPatientFolder(this)
            if (~isempty(this.pnumIndex) && ~isempty(this.pid))
                switch (lower(this.sid))
                    case 'np797'                            
                        idx = this.pnumIndex;
                        fld = [this.moyamoyaIdNp797{idx} this.prefixNp797{idx} this.pid this.suffixNp797{idx}];
                    otherwise 
                        error('mlfourd:NotImplemented', 'CvlDBase.abinitioPatientFolder.sid->%s\n', this.sid);
                end
            else
                % best guess
                fld = '.';
            end
        end
        function fp   = cvlFileprefix(this, fp, pth)
            
            %% CVLFILEPREFIX
            %  Usage:  fp = db.cvlFileprefix(file-string, [path-string])
            %                                ^ any file descriptor, NIfTI
               fp    = fileprefix(fp);
            [~,fp,~] = filepartsx(fp, mlfourd.INIfTI.FILETYPE_EXT);
            if (this.useBlurSuffix)
                fp   = [fp this.blur_suffix];
            end
            if (this.useBlockSuffix)
                fp   = [fp this.block_suffix];
            end
            if (exist('pth','var'))
                fp = fullfile(pth, fp);
            end
        end % cvlFileprefix
        function fn   = cvlFilename(this, fn, pth)
            
            %% CVLFILENAME
            %  Usage:  fn = db.cvlFilename(file-string, [path-string])
            %                              ^ any file descriptor, NIfTI
            switch (nargin)
                case {0,1}
                    error('mlfourd:InsufficientParams', 'CvlDBase.cvlFilename.nargin->%i\n', nargin);
                case 2
                    fn = this.cvlFileprefix(fn);
                otherwise
                    fn = this.cvlFileprefix(fn, pth);
            end
            fn = [fn mlfourd.INIfTI.FILETYPE_EXT];
        end % cvlFilename        
        function fld  = onFolder(this)
            fld = ['on' upper(this.ref_fp(1)) this.ref_fp(2:end)];
        end
    end 

    methods (Static)

        function this = getInstance(pid, sid) 
            %% GETINSTANCE
            %  Usage:  obj = mlfourd.Cvlmlfsl.Np797Registry.instance([pid, sid])
            %                                              ^    ^ strings or numeric
            
			import mlfourd.*;
            persistent  mycdb;
            if (isempty(mycdb) || ~isvalid(mycdb))
                mycdb = mlfourd.CvlDBase;
                mycdb.counter = 1;
                if (mycdb.verbose); 
                    disp('mlfourd.CvlDBase:  new, persistent instance created'); 
                end
            else
                mycdb.counter = mycdb.counter + 1;
            end
            switch (nargin)
                case 0
                    pnum = mlfourd.DBase.ensurePnum(pwd);
                    if (~isempty(pnum))
                        mydb.pid = pnum;
                        warning('mlfourd:guessingParamValue', 'Gusssing mlfsl.Np797Registry.instance.pid->%s\n', mydb.pid);
                    end
                case 1
                    mycdb.pid = pid;
                case 2
                    mycdb.pid = pid;
                    mycdb.sid = sid;
            end
			this = mycdb;
        end
    end % static methods
    
    methods (Access = protected)
        function this = CvlDBase 
            % CTOR must be consistent with singleton behavior in subclasses
            this = this@mlfourd.AbstractDBase;
        end % protected ctor
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
