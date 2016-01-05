classdef NIfTId < mlfourd.AbstractNIfTId
    %% NIFTID accepts Jimmy Shen's NIfTI-structs or image arrays.  Ctor w/o args is also allowed.
    %  A minimal NIfTId has hdr.dime.pixdim, hdr.hist.descrip, fileprefix & img.
    
	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.

    properties (Constant)
        ISEQUAL_IGNORES      = {'hdr' 'label' 'descrip' 'hdxml' 'creationDate' 'originalType' 'untouch' 'stack'}
        SUPPORTED_EXTENSIONS = {'.nii.gz' '.nii' '.mgh' '.mgz' '.hdr' '.dcm' '.IMA'} % fist extension is default
        CLEAN_UP_WORK_FILES  = true
    end    
    
    methods (Static) 
        function this = load(fn, varargin)
            %% LOAD loads imaging objects from the filesystem.  In the absence of file extension, LOAD will attempt guesses.
            %  @param fn, a [fully-qualified] fileprefix or filename, specifies imaging objects on the filesystem.
            %  @param [param-name, param-value[, ...]]
            %  @return this, an instance of mlfourd.NIfTId.
            %  See also:  mlfourd.NIfTId.NIfTId
            
            desc0 = ['NIfTId.load read ' fn ' on ' datestr(now)];
            
            p = inputParser;
            addRequired(p, 'fn', @ischar);
            addOptional(p, 'desc', desc0, @ischar);
            parse(p, fn, varargin{:});
            
            import mlfourd.*;  
            fe = NIfTId.findSupportedExtension(fn);
            if (~isempty(fe))
                this = NIfTId.load_known_ext(fn, fe, p.Results.desc);
                return
            else 
                this = NIfTId.load_guessing_ext(fn, p.Results.desc);
                return
            end
        end
        function fe  = findSupportedExtension(fname)
            import mlfourd.*;
            fe = [];
            exts = NIfTId.SUPPORTED_EXTENSIONS;
            for e = 1:length(exts)
                locs = strfind(fname, exts{e});
                if (~isempty(locs))
                    fe = fname(locs(end):end);
                    break
                end
            end
        end      
    end 
    
    methods 
        function niid     = clone(this, varargin)
            %% CLONE
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation
            %  @return niid copy-construction with niid.descrip prepended with 'clone of '
            %  See also:  mlfourd.NIfTId.NIfTId
            
            niid = mlfourd.NIfTId(this, varargin{:});
            niid.descrip = ['clone of ' niid.descrip];
        end
        function this     = forceDouble(this)
            this.img_ = mlfourd.AbstractNIfTId.ensureDble(this.img_);
            this.hdr_.dime.datatype = 64;
            this.hdr_.dime.bitpix   = 64;
        end % forceDouble        
        function this     = forceSingle(this)
            this.img_ = mlfourd.AbstractNIfTId.ensureSing(this.img_);
            this.hdr_.dime.datatype = 16;
            this.hdr_.dime.bitpix   = 32;
        end % forceSingle 
        function [tf,msg] = isequal(this, obj)
            [tf,msg] = this.isequaln(obj);
        end
        function [tf,msg] = isequaln(this, obj)
            [tf,msg] = this.classesequal(obj);
            if (tf)
                [tf,msg] = this.fieldsequaln(obj);
                if (tf)
                    [tf,msg] = this.hdrsequaln(obj);
                end
            end
        end 
        function niid     = makeSimilar(this, varargin)
            %% MAKESIMILAR 
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation
            %  @return niid clone with niid.descrip prepended with 'made similar to '
            %  See also:  mlfourd.NIfTId.NIfTId
    
            niid = this.clone(varargin{:});
            niid.descrip = ['made similar to ' niid.descrip];
        end
        function            save(this)
            %% SAVE saves this NIfTId to this.fileprefix with extension .nii, then compresses with gzip
            
            import mlfourd.* mlniftitools.*;
            if (this.noclobber && lexist(this.fqfilename, 'file'))
                error('mlfourd:IOErr', ...
                      'NIfTId.save.fqfilename->%s already exists; stopping...%s', this.fqfilename); 
            end
            warning('off');  %#ok<WNOFF>
            delete(this.fqfilename);
            if (this.untouch)
                save_untouch_nii(struct(this), [this.fqfileprefix '.nii.gz']);
            else
                this = this.optimizePrecision;
                save_nii(        struct(this), [this.fqfileprefix '.nii.gz']);
            end
            warning('on'); %#ok<WNON>
        end 
        function this     = saveas(this, fqfn)
            this.fqfilename = fqfn;
            this.untouch_ = false;
            this.save;
        end % overloads AbstractSimpleIO.saveas
        
        function this = NIfTId(datobj, fprefix, desc, pixdim, varargin)
            %% NIfTId is a copy ctor & also accepts Jimmy Sheng's NIfTI-structs or image arrays.
            %  It will also convert mlfourd.NIfTI objects to mlfourd.NIfTId.
            %  A minimal NIfTId has img, fileprefix, hdr.hist.descrip, hdr.dime.pixdim.
            %  Usage:  nii = NIfTId([object, fileprefix, descrip, pixdim])
            %                ^ ctor w/o args required by Matlab
            %                       ^ numeric arrays, NIfTId struct, NIfTId object
            %                               ^           ^ strings
            %                                                    ^ row vector of mm/pixel, length matched to
            %                                                      data object
            
            this = this@mlfourd.AbstractNIfTId;            
            
%             ip = inputParser;
%             addParameter(ip, 'bitpix',     this.bitpix,     @isnumeric);
%             addParameter(ip, 'datatype',   'double',        @(x) ischar(x) || isnumeric(x));
%             addParameter(ip, 'descrip',    ['made similar to ' this.descrip],  @ischar);
%             addParameter(ip, 'fileprefix', this.fileprefix, @ischar);
%             addParameter(ip, 'img',        this.img,        @isnumeric);
%             addParameter(ip, 'label',      this.label,      @ischar);
%             addParameter(ip, 'mmppix',     this.mmppix,     @isnumeric);
%             addParameter(ip, 'pixdim',     this.pixdim,     @isnumeric);
%             parse(ip, varargin{:});             
%             
%             this.img        = ip.Results.img;
%             this.datatype   = ip.Results.datatype;
%             this.label      = ip.Results.label;
%             this.bitpix     = ip.Results.bitpix;
%             this            = this.append_descrip(ip.Results.descrip);   
%             this.fileprefix = this.adjustFileprefix(ip.Results.fileprefix);
%             this.mmppix     = ip.Results.mmppix;
%             this.pixdim     = ip.Results.pixdim;

            this = this.assignDefaults;
            
            %% Manage nargin 
            
            if (nargin > 4)
                error('mlfourd:InputParamErr', 'NIfTId could not process %i input args', nargin); end
            
            if (nargin > 0)
                this.originalType_ = class(datobj);

                import mlfourd.*;
                switch (this.originalType)
                    case 'char'
                        this = NIfTId.load(datobj);
                        switch (nargin)
                            case 2
                                this.fqfileprefix = fprefix;
                            case 3
                                this.fqfileprefix = fprefix;
                                this.descrip      = desc;
                            case 4
                                this.fqfileprefix = fprefix;
                                this.descrip      = desc;
                                this.pixdim       = pixdim;
                        end 
                    case 'struct'
                        this.img_         = datobj.img;
                        this.hdr_         = datobj.hdr;
                        this.filetype_    = datobj.filetype;
                        this.fqfileprefix = datobj.fileprefix;
                        this.ext_         = datobj.ext;
                        this.untouch_     = datobj.untouch;
                        switch (nargin)
                            case 2
                                this.fileprefix   = fprefix;
                            case 3
                                this.fileprefix   = fprefix;
                                this.descrip      = desc;
                            case 4
                                this.fileprefix   = fprefix;
                                this.descrip      = desc;
                                this.pixdim       = pixdim;
                        end
                    otherwise
                        if (isnumeric(datobj))
                            rank                                 = length(size(datobj));
                            this.img_                            = double(datobj);
                            this.hdr_.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                            this.hdr_.dime.dim                   = ones(1,8);
                            this.hdr_.dime.dim(1)                = rank;
                            this.hdr_.dime.dim(2:rank+1)         = size(datobj);
                            this.hdr_.dime.datatype              = 64;
                            this.hdr_.dime.bitpix                = 64;
                            switch (nargin)
                                case 2
                                    this.fqfileprefix = fprefix;
                                case 3
                                    this.fqfileprefix = fprefix;
                                    this.descrip      = desc;
                                case 4                              
                                    this.fqfileprefix = fprefix;
                                    this.descrip      = desc;
                                    this.pixdim       = pixdim;
                            end
                        elseif (isa(datobj, 'mlfourd.NIfTIInterface')) % convert to NIfTId                            
                            warning('off'); %#ok<WNOFF>
                            this = NIfTId(struct(datobj));
                            warning('on'); %#ok<WNON>
                            this.img_ = double(this.img);
                            switch (nargin)
                                case 2
                                    this.fileprefix = fprefix;
                                case 3
                                    this.fileprefix = fprefix;
                                    this.descrip    = desc;
                                case 4
                                    this.fileprefix = fprefix;
                                    this.descrip    = desc;
                                    this.pixdim     = pixdim;
                            end
                        elseif (isa(datobj, 'mlfourd.INIfTI')) % copy ctor
                            this.img_         = datobj.img;
                            this.hdr_         = datobj.hdr;
                            this.filetype_    = datobj.filetype;
                            this.fqfileprefix = datobj.fqfileprefix;
                            this.ext_         = datobj.ext;
                            this.untouch_     = datobj.untouch;
                            this.label        = datobj.label;
                            this.separator    = datobj.separator;
                            switch (nargin)
                                case 2
                                    this.fileprefix = fprefix;
                                case 3
                                    this.fileprefix = fprefix;
                                    this.descrip    = desc;
                                case 4
                                    this.fileprefix = fprefix;
                                    this.descrip    = desc;
                                    this.pixdim     = pixdim;
                            end
                        else
                            error('mlfourd:NotImplemented', ...
                                 ['NIfTId could not recognize datob with class->' class(datobj)]);
                        end
                end
            end
            if (~this.LOAD_UNTOUCHED)
                this = this.optimizePrecision; end
            this.stack = {this.descrip};
        end 
    end
   
    %% PRIVATE
 
    methods (Static, Access = 'private')
        function nii      = load_guessing_ext(fp, varargin)
            import mlfourd.*;
            exts = NIfTId.SUPPORTED_EXTENSIONS;
            desc0 = ['NIfTId.load_guessing_ext read ' fp ' on ' datestr(now)];
            p = inputParser;
            addRequired(p, 'fp',           @ischar);
            addOptional(p, 'desc', desc0,  @ischar)
            parse(p, fp, varargin{:});
            
            for e = 1:length(exts)
                if (lexist([fp exts{e}], 'file'))
                    nii = NIfTId.load_known_ext([fp exts{e}], exts{e}, p.Results.desc);
                    return
                end
            end
            error('mlfourd:malformedFilename', 'NIfTId.load_guessing_ext could not identify format of %s', fp);
        end
        function nii      = load_known_ext(fn, varargin)
            %% LOAD_KNOWN_EXT loads image formats listed in NIfTId.SUPPORTED_EXTENSIONS
            %  Usage:  nii = NIfTId.load_known_ext(filename[, extension, description])
            %                                      ^ filename with extension
            %                                                 ^ explicit extension, defaults to '.nii.gz'
            %                                                            ^ defaults to filename & time-stamp
            %  See also:  Jimmy Shen's load_untouch_nii
            
            import mlfourd.* mlniftitools.*;
            exts = NIfTId.SUPPORTED_EXTENSIONS;
            desc0 = ['NIfTId.load_known_ext read ' fn ' on ' datestr(now)];
            p = inputParser;
            addRequired(p, 'fn',           @ischar);
            addOptional(p, 'ext', exts{1}, @(x) any(strcmp(x, exts)));
            addOptional(p, 'desc', desc0,  @ischar)
            parse(p, fn, varargin{:});
            
            [pth,fp] = filepartsx(fn, p.Results.ext);
            s = false;
            try
                if (lstrfind(p.Results.ext, {'.nii.gz' '.nii'}))
                    nii = NIfTId(load_untouch_nii(fn));
                    nii.filepath = pth;
                    nii.fileprefix = fp;
                    nii.filesuffix = p.Results.ext;
                    nii.hdr_.hist.descrip = p.Results.desc;
                else
                    niiFqfn = fullfile(pth, [fp exts{1}]);                    
                    if (lstrfind(p.Results.ext, '.hdr'))
                        [s,r] = mlbash(sprintf('mri_convert -it analyze4d %s %s', fp, niiFqfn));
                    else
                        [s,r] = mlbash(sprintf('mri_convert %s %s', fn, niiFqfn));
                    end
                    nii = NIfTId.load_known_ext(niiFqfn, exts{1}, p.Results.desc); % will divert to first clause of if-else
                    if (NIfTId.CLEAN_UP_WORK_FILES)
                        mlbash(sprintf('rm %s', niiFqfn)); end
                end
            catch ME
                if (s); fprintf(r); end
                handexcept(ME);
            end
        end 
        function [tf,msg] = checkFields(obj1, obj2, evalIgnore)
            tf = true; 
            msg = '';
            flds = fieldnames(obj1);
            for f = 1:length(flds)
                if (~evalIgnore(flds{f}))
                    if (~isequaln(obj1.(flds{f}), obj2.(flds{f})))
                        tf = false;
                        msg = sprintf('NIfTId.checkFields:  mismatch at field %s.', flds{f});
                        break
                    end
                end
            end
        end
    end 
    
    methods (Access = 'private')
        function fp       = adjustFileprefix(this, fp)
            if ('_' == fp(1))
                fp = [this.fileprefix fp]; return; end
            if ('_' == fp(end))
                fp = [fp this.fileprefix]; return; end
        end
        function this     = assignDefaults(this)
            this.img_                     = zeros(3,3,3);
            this.fileprefix               = ['NIfTId_D' datestr(now,30)];
            this.filesuffix_              = mlfourd.INIfTI.FILETYPE_EXT;
            
            this.hdr_.hist                = struct;
            this.hdr_.hist.descrip        = ['NIfTId(' num2str(nargin) ' argin)'];
            this.hdr_.hist.originator     = [0 0 0];
            this.hdr_.hist.aux_file       = '';
            this.hdr_.hist.qform_code     = 0;
            this.hdr_.hist.sform_code     = 0;
            this.hdr_.hist.quatern_b      = 0;
            this.hdr_.hist.quatern_c      = 0;
            this.hdr_.hist.quatern_d      = 0;
            this.hdr_.hist.qoffset_x      = 0;
            this.hdr_.hist.qoffset_y      = 0;
            this.hdr_.hist.qoffset_z      = 0;
            this.hdr_.hist.srow_x         = zeros(1,4);
            this.hdr_.hist.srow_y         = zeros(1,4);
            this.hdr_.hist.srow_z         = zeros(1,4);
            this.hdr_.hist.intent_name    = '';
            this.hdr_.hist.magic          = 'n+1';          
          
            this.hdr_.dime                = struct;
            this.hdr_.dime.dim            = [3 3 3 3 1 1 1 1];
            this.hdr_.dime.intent_p1      = 0;
            this.hdr_.dime.intent_p2      = 0;
            this.hdr_.dime.intent_p3      = 0;
            this.hdr_.dime.intent_code    = 0;
            this.hdr_.dime.datatype       = 64;
            this.hdr_.dime.bitpix         = 64;
            this.hdr_.dime.slice_start    = 0;
            this.hdr_.dime.pixdim         = [-1 1 1 1 1 0 0 0];
            this.hdr_.dime.vox_offset     = 0;
            this.hdr_.dime.scl_slope      = 1;
            this.hdr_.dime.scl_inter      = 0;
            this.hdr_.dime.slice_end      = 0;
            this.hdr_.dime.slice_code     = 0;
            this.hdr_.dime.xyzt_units     = 1;
            this.hdr_.dime.cal_max        = 0;
            this.hdr_.dime.cal_min        = 0;
            this.hdr_.dime.slice_duration = 0;
            this.hdr_.dime.toffset        = 0;
            this.hdr_.dime.glmax          = 0;
            this.hdr_.dime.glmin          = 0;
            
            this.hdr_.hk                  = struct;
            this.hdr_.hk.sizeof_hdr       = 348;
            this.hdr_.hk.data_type        = '';
            this.hdr_.hk.db_name          = '';
            this.hdr_.hk.extents          = 0;
            this.hdr_.hk.session_error    = 0;
            this.hdr_.hk.regular          = 'r';
            this.hdr_.hk.diminfo          = 0;            
            this.hdr_.hk.dim_info         = 0;
            
            this.originalType_            = 'mlfourd.NIfTId';
        end
        function [tf,msg] = classesequal(this, c)
            tf  = true; 
            msg = '';
            if (~isa(c, class(this)))
                tf  = false;
                msg = sprintf('class(this)-> %s but class(compared)->%s', class(this), class(c));
            end
            if (~tf)
                warning(msg);
            end
        end
        function [tf,msg] = fieldsequaln(this, obj)
            [tf,msg] = mlfourd.NIfTId.checkFields( ...
                this, obj, @(x) lstrfind(x, this.ISEQUAL_IGNORES));            
            if (~tf)
                warning(msg);
            end
        end
        function [tf,msg] = hdrsequaln(this, obj)
            tf = true; 
            msg = '';
            if (isempty(this.hdr) && isempty(obj.hdr)); return; end
            import mlfourd.*;
            [tf,msg] = NIfTId.checkFields(this.hdr.hk, obj.hdr.hk,  @(x) false);
            if (tf)
                [tf,msg] = NIfTId.checkFields(this.hdr.dime, obj.hdr.dime, @(x) false);
                if (tf)
                    [tf,msg] = NIfTId.checkFields(this.hdr.hist, obj.hdr.hist, @(x) lstrfind(x, 'descrip'));
                end
            end
            if (~tf)
                warning(msg);
            end
        end
    end 
    
end

