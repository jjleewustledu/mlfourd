classdef CvlRegistry < mlpatterns.Singleton
	%% CVLREGISTRY registers data for studies at the Cerebrovascular Laboratory
	%  Version $Revision: 1211 $ was created $Date: 2011-07-29 15:43:54 -0500 (Fri, 29 Jul 2011) $ by $Author: jjlee $  
 	%  and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/CvlRegistry.m $ 
 	%  Developed on Matlab 7.12.0.635 (R2011a) 
 	%  $Id: CvlRegistry.m 1211 2011-07-29 20:43:54Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient)
        
        pid       = '';
        sid       = '';
        debugging = false;
        verbosity = 0; %% in range [0,1]\
             
        blockSize = [1 1 1];
        baseBlur  = [0 0 0];
        mrBlur
        petBlur
    end
    
    properties (Dependent)
        cvlPath       % DEPRECATED
        sidPath       % DEPRECATED
        patientFolder % access is private for set.patientFolder; use patientPath
        patientPath
        references
        reference
        averagingSuffixes
        onRefsSuffixes
        onRefSuffix
        mcfSuff
        mcfMeanvolSuff
        rotSuff
        verbose
    end

    properties (Constant)
        
             FILETYPE_EXT = mlfourd.NIfTI.FILETYPE_EXT;        
             FILETYPE     = mlfourd.NIfTI.FILETYPE;
        
          PET_POINTSPREAD = [ 7.31  7.31 5.33]; % [6.92 6.92 5.22];
        TWICE_POINTSPREAD = [10.34 10.34 7.54];
        %% FWHH, (geom.) means of tan. & radial resolution
        %  of ECAT EXACT HR+ 2D mode
        %  N. Karakatsanis et al.,  
        %  Nuclear Instr. & Methods in Physics Research A, 569 (2006) 368--372
        %  Table 1 Spatial resolution for two different radial positions (1 and 10 cm from the center of FOV), 
        %  calculated in accordance with the NEMA NU2-2001 protocol
        %
        %  Experimental results 
        %  Radial position (cm)       1     10     ~5
        %
        %  Orientation FWHH
        %  Radial resolution (mm)     4.82   5.65   5.24
        %  Tangential resolution (mm) 4.39   4.64   4.52
        %  In-plane resolution* (mm)  6.52   7.31   6.92
        %  Axial resolution (mm)      5.10   5.33   5.22
        %
        %  Orientation Sigma
        %  Radial resolution (mm)     2.0469 2.3993 2.2252
        %  Tangential resolution (mm) 1.8643 1.9704 1.9195
        %  In-plane resolution* (mm)  2.7688 3.1043 2.9387
        %  Axial resolution (mm)      2.1658 2.2634 2.2167
        %
        %  *geom. mean
        
    end
    
    properties (Access = protected)
        extFileParts_
        patientPath_
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
    
        function bs   = get.blockSize(this)
            bs = this.blockSize;
        end
        
        function        set.baseBlur(this, blr)
            
            %% SET.BLOCKSIZE adds singleton dimensions as needed to fill 3D
            assert(isnumeric(blr));
            switch (numel(blr))
                case 1
                    if (blr < norm(this.PET_POINTSPREAD))
                        this.baseBlur = this.PET_POINTSPREAD;
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

        function bb   = get.baseBlur(this)
            bb = this.baseBlur;
        end       
           
        function bl   = get.mrBlur(this)
            if (isempty(this.mrBlur) || norm(this.mrBlur) < norm(this.baseBlur))
                this.mrBlur = this.baseBlur;
            end
            bl = this.mrBlur;
        end
        
        function bl   = get.petBlur(this)
            if (isempty(this.petBlur) || norm(this.petBlur) < norm(this.baseBlur))
                this.petBlur = this.baseBlur;
            end
            bl = this.petBlur;
        end
         
        function sfx  = get.onRefsSuffixes(this)
            sfx = this.extFileParts_.onRefsSuffixes;
        end
        
        function sfx  = get.onRefSuffix(this)
            sfx = this.extFileParts_.onRefSuffix;
        end
        
        function suf  = get.mcfSuff(this)
            suf = this.extFileParts_.mcfSuff;
        end
        
        function suf  = get.mcfMeanvolSuff(this)
            suf = this.extFileParts_.mcfMeanvolSuff;
        end
        
        function suf  = get.rotSuff(this)
            suf = this.extFileParts_.rotSuff;
        end
        
        function        set.pid(this, id)
            this.pid = mlfourd.CvlRegistry.ensurePnum(id);
        end
        
        function p    = get.pid(this)
            p = this.pid;
        end
        
        function        set.sid(this, id)
            if (isnumeric(id))
                id = double2str(id);
            end
            this.sid = id;
        end
        
        function s    = get.sid(this)
            s = this.sid;
        end
        
        function pth  = get.cvlPath(this)
            
            %% CVLPATH 
            %  Usage:  pathstring = cvlPath
            %          ^ fully qualified path to 'cvl'            
            pwd0  = pwd;
            found = strfind(lower(pwd0), 'cvl');
            if (numel(found) > 1)
                pth = pwd0(1:found(1)+2);
            elseif (numel(found) == 1)
                pth = pwd0(1:found+2);
            else
                pth = pwd0;
            end
        end
        
        function pth  = get.sidPath(this)
            
            if (isempty(this.sid) || strcmpi('unknown', this.sid))
                pth = pwd;
                return;
            end
            
            pwd0  = pwd;
            found = strfind(lower(pwd0), this.sid);
            diff  = length(this.sid) - 1;
            if (numel(found) > 1)
                pth = pwd0(1:found(1)+diff);
            elseif (numel(found) == 1)
                pth = pwd0(1:found+2);
            else
                pth = pwd0;
            end
        end
        
        function fld  = get.patientFolder(this)
            fld = pathparts(this.patientPath, 1);
        end
        
        function        set.patientPath(this, pth)
            %% SET.PATIENTPATH also adds argument to matlab's path; sets only pwd if argument is empty
            if (isempty(pth) || ~isempty(strfind(pth, 'unknown')))
                this.patientPath_ = pwd;
            else
                this.patientPath_ = pth;
                path(path, pth);
            end
            if (~exist( pth, 'dir'))
                error('mlfourd:IOErr', 'AbstractDBase.set.patientPath could not find %s\n', pth);
            end            
        end        
        
        function pth  = get.patientPath(this)
            
            %% GET.PATIENTPATH always returns a trailing '/'
            if (isempty(this.patientPath_) || ~isempty(strfind(this.patientPath_, 'unknown')))
                pth = pwd;
            else
                pth = this.patientPath_; 
            end    
            if (~strcmp(filesep, pth(end))) % trailing '/'
                pth = [pth filesep];
            end
        end       

        function        set.references(this, refs)
            this.extFileParts_.references = refs;
        end 
    
        function refs = get.references(this)
            refs = this.extFileParts_.references;
        end
        
        function        set.reference(this, ref)
            this.extFileParts_.reference = ref;
        end 
    
        function ref  = get.reference(this)
            ref = this.extFileParts_.reference;
        end
        
        function sf   = get.averagingSuffixes(this)
            sf = this.extFileParts_.averagingSuffixes(this.block2bool, this.blur2bool);
        end
        
        function tf   = get.verbose(this)
            %% GET.VERBOSE returns a logical value based on debugging and verbosity settings
            tf = this.debugging || this.verbosity > 0.5;
        end     

        function fp   = t1(this, varargin)
            fp = this.extFileParts_.t1(varargin{:});
        end
        
        function fp   = t2(this, varargin)
            fp = this.extFileParts_.t2(varargin{:});
        end
        
        function fp   = flair(this, varargin)
            fp = this.extFileParts_.flair(varargin{:});
        end
        
        function fp   = ep2d(this, varargin)
            fp = this.extFileParts_.ep2d(varargin{:});
        end
        
        function fp   = ep2dMean(this, varargin)
            fp = this.extFileParts_.ep2dMean(varargin{:});
        end
        
        function fp   = ho15(this, varargin)
            fp = this.extFileParts_.ho15(varargin{:});
        end
        
        function fp   = o15c(this, varargin)
            fp = this.extFileParts_.o15c(varargin{:});
        end
        
        function fp   = o15o(this, varargin)
            fp = this.extFileParts_.o15o(varargin{:});
        end
        
        function tf   = block2bool(this)
            assert(isnumeric(this.blockSize));
            tf = ~all([1 1 1] == this.blockSize);
        end
        
        function tf   = blur2bool(this)
            assert(isnumeric(this.baseBlur));
            tf = ~all([0 0 0] == this.baseBlur);
        end
        
        function fform   = fileForms(this, label, varargin)
            fform = this.extFileParts_.fileForms(label, varargin{:});
        end
        
        function renamed = renameFiles(this, fold, fold2, filt2keep, filt2toss)
            renamed = this.extFileParts_.renameFiles(this, fold, fold2, filt2keep, filt2toss);
        end
        
        function           disp(this)
            disp@handle(this);
            % displine('extFileParts_', 1, this.extFileParts_); % this should be private
        end
        
        
    end % methods
    
    methods (Static)

        function this = instance(qualifier)
            
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            persistent uniqueInstance
            
            pid1 = '';
            if (exist('qualifier','var') && ischar(qualifier))
                switch (qualifier)
                    case 'initialize'
                        uniqueInstance = [];
                    case 'clear'
                        clear uniqueInstance;
                        return;
                    case 'delete'
                        if (~isempty(uniqueInstance))
                            uniqueInstance.delete;
                            return;
                        end
                    otherwise % assume pnum
                        pid1 = qualifier;
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlfourd.CvlRegistry();
                if (~isempty(pid1)); this.pid = pid1; end
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end

        function pnum = ensurePnum(id)
            
            %% ENSUREPNUM validates & converts to canonical forms as needed
            %  pnum = CvlRegistry.ensurePnum(pnum)
            %  ^ pXXXX, int X                ^ possibly longer string, patient-folder w/ p-number, double
            %    empty if unidentified
            pnum = '';
            switch(class(id))
                case 'char'
                    if (strncmpi('p', id, 1) && isnumeric(str2double(id(2:end))))
                        pnum = id;
                    end
                    s2d = str2double(id);
                    if (~isnan(s2d)) % SPOTRIAS
                        pnum = id;
                    end
                               % regexp for *_pXXXX_*, int X
                    [~, names] = regexpi(id, '[_]+(?<pnum>p[0-9]+)[_]+', 'tokens', 'names', 'once');
                    if (~isempty(struct2cell(names)))
                        pnum = names.pnum;
                    end
                case {'double','single'}
                    pnum = num2str(id);
                otherwise
                    error('mlfourd:InputParamErr', 'ensurePnum could not recognize id->%s\n', char(id));
            end
        end % static function ensurePnum
        
        function fold = ensureFolder(fold)
            try
                if (~exist(fold, 'dir')); mkdir(fold); end
            catch ME
                handwarning(ME, 'CvlFacade.ensureFolder could not access %s; check permissions.\n', fold);
            end
        end % static ensureFolder
    end % static methods
    
    methods (Access = protected)

        function this = CvlRegistry 
            %% CVLREGISTRY (ctor) must be consistent with singleton state/behavior
            this.extFileParts_ = mlfourd.ExtendedFileParts(this.patientPath);
        end % protected ctor
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
