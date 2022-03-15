classdef (Abstract) ImagingFormatTool < handle & mlfourd.ImagingFormatState2
    %% IMAGINGFORMATTOOL defines an abstraction for encapsulating specifics of imaging formats.
    %  It provides finer granularity of data representation than its superclass.  It supports behavior common
    %  to all imaging formats, such as adjusting numerical type or precision, adjusting the field-of-view of data
    %  (zoom*), viewing data, saving data.
    %  N.B.:  select*Tool() overrides superclass, generating imagingInfo from existing ImagingFormatTool.
    %  N.B.:  ctor accepts arguments for imagingInfo and useCase.
    %
    %  ImagingFormatTool manages saving data.  See also adjustHdr(), adjustHdrForImg(), 
    %  ensureHist(), imagingFormatToHdr(), which manage hdr.  Subclasses call flip(img,).
    %
    %  See also ImagingInfo, which manages loading data.  See also adjustHdr(), createFromImagingFormat(), 
    %  ensureLoadingOrientation(), ensureSavingOrientation(), which manage qfac and hdr.  Subclasses call flip(img,).
    %  
    %  Created 08-Dec-2021 22:27:36 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.

    methods (Static)
        function [hdr,orig] = imagingFormatToHdr(iform)
            %% From ImagingFormatTool create nifti hdr for internal representation as LAS.  
            %  See also {Nifti,Fourdfp,Mgh}Tool.createFromImagingFormat()

            iinfo = iform.imagingInfo();
            if isanalyze(iinfo)
                % From analyze hdr build nifti hdr in LAS.  
                % Retain original analyze hdr, which is always LAS.
                jimmy = iform.make_nii();
                hdr = jimmy.hdr;
                if isfield(jimmy, 'original')
                    orig = jimmy.original;
                else
                    orig = [];
                end
                return
            end
            if strcmp(iform.hdr.hist.descrip, 'ImagingInfo.initialHdr') && ...
                    isfile(iform.fqfilename)
                % Replace uninformative initial hdr with nifti hdr from filesystem.
                % Retain original hdr, which may be LAS or RAS.
                jimmy = iinfo.load_nii(); 
                hdr = jimmy.hdr;
                if isfield(jimmy, 'original')
                    orig = jimmy.original;
                else
                    orig = [];
                end
                return
            end

            % base case
            hdr = iform.hdr;
            if ~isempty(iform.original)
                orig = iform.original;
            else
                orig = [];
            end
        end
    end

    properties (Constant)
        DESC_LEN_LIM = 1024; % limit to #char of desc; accumulate extended descriptions with logging features.
    end

    properties (Dependent) 

        %% required by mlniftitools.{save_nii,save_untouch_nii}

        datatype
        ext
        filetype
        hdr % required by mlniftitools.{save_nii,save_untouch_nii}
        hdxml
        json_metadata
        machine
        orient % external representation from fslorient:  RADIOLOGICAL | NEUROLOGICAL
        original
        qfac % internal representation from this.hdr.dime.pixdim(1)
        stateTypeclass
        untouch

        %% important for 4dfp

        mmppix
        originator
        N % logical: suppress mmppix and center for 4dfp
    end

    methods

        %% GET/SET
              
        function g = get.datatype(this)
            %% DATATYPE returns a datatype code as described by the INIfTI specificaitons
            
            g = this.hdr.dime.datatype;
        end
        function     set.datatype(this, dt)
            if (ischar(dt))
                switch (strtrim(dt))
                    case {'uchar', 'uint8'} 
                        this = this.ensureUint8; %#ok<NASGU>
                    case {'int16'}
                        this = this.ensureInt16; %#ok<NASGU>
                    case {'int32', 'int'} 
                        this = this.ensureInt32; %#ok<NASGU>                      
                    case {'single', 'float32', 'float'}
                        this = this.ensureSingle; %#ok<NASGU>
                    case {'int64'}
                        this = this.ensureInt64; %#ok<NASGU>
                    case {'double', 'float64'}
                        this = this.ensureDouble; %#ok<NASGU>
                    otherwise
                        error('mlfourd:unknownSwitchCase', ...
                              'InnerNIfTI.set.datatype could not recognize dt->%s', strtrim(dt));
                end
            elseif (isnumeric(dt))
                if (dt < 64)
                    this = this.ensureSingle; %#ok<NASGU>
                else
                    this = this.ensureDouble; %#ok<NASGU>
                end
            else
                error('mlfourd:ValueError', 'InnerNIfTI.set.datatype does not support class(dt)->%s', class(dt));
            end            
        end
        function g = get.ext(this)
            g = this.imagingInfo_.ext;
        end
        function     set.ext(this, s)
            this.imagingInfo_.ext = s;
        end
        function g = get.filetype(this)
            g = this.imagingInfo_.filetype;
        end
        function     set.filetype(this, ft)
            switch (ft)
                case {0 1}
                    this.imagingInfo_.filetype = ft;
                    this.filesuffix = '.hdr';
                case 2
                    this.imagingInfo_.filetype = ft;
                    this.filesuffix = this.imagingInfo_.defaultFilesuffix;
                otherwise
                    error('mlfourd:unsupportedParamValue', 'InnerNIfTI.set.filetype.ft->%g', ft);
            end
        end 
        function g = get.hdr(this)
            %% includes KLUDGE for mlniftitools.save_nii_hdr line28

            g = this.imagingInfo_.hdr;
            if (~isfield(g.hist, 'originator') || ...
                 isempty(g.hist.originator))                
                g.hist.originator = zeros(1,3); 
            end
        end 
        function     set.hdr(this, s) 
            %% KLUDGE for mlniftitools.save_nii_hdr line28

            assert(isstruct(s));
            this.imagingInfo_.hdr = s;
        end        
        function x = get.hdxml(this)
            if ~isfile(this.fqfilename)
                x = '';
                return
            end
            [~,x] = mlbash(['fslhd -x ' this.fqfilename]);
            x = strtrim(regexprep(x, 'sform_ijk matrix', 'sform_ijk_matrix'));
        end
        function g = get.json_metadata(this)
            g = this.imagingInfo_.json_metadata;
        end
        function g = get.machine(this)
            g = this.imagingInfo_.machine;
        end
        function g = get.orient(this)
            g = this.imagingInfo_.orient;
        end
        function g = get.original(this)
            g = this.imagingInfo_.original;
        end 
        function g = get.qfac(this)
            g = this.imagingInfo_.qfac;
        end
        function g = get.stateTypeclass(this)
            g = class(this.imagingInfo_);
        end 
        function g = get.untouch(this)
            g = this.imagingInfo_.untouch;
        end
        function     set.untouch(this, s)
            this.imagingInfo_.untouch = s;
        end

        function     set.mmppix(this, s)
            %% SET.MMPPIX sets uniform voxel-time measures in mm and s.  
            
            assert(isnumeric(s))
            this.imagingInfo_.hdr.dime.pixdim(2:length(s)+1) = s;
            for si = 1:length(s)
                this.imagingInfo_.hdr.hist.srow_x(si) = s(si);
            end
        end
        function g = get.mmppix(this)
            g = this.hdr.dime.pixdim(2:this.ndims+1);
            if (length(g) > 3)
                g = g(1:3);
            end
        end
        function     set.originator(this, s)
            %% SET.ORIGINATOR sets ImagingInfo.originator voxel position in mm.

            assert(isnumeric(s))
            this.imagingInfo_.hdr.hist.originator = s;
            if this.imagingInfo_.hdr.hist.qform_code > 0
                this.imagingInfo_.hdr.hist.qoffset_x = 1 - s(1);
                this.imagingInfo_.hdr.hist.qoffset_y = 1 - s(2);
                this.imagingInfo_.hdr.hist.qoffset_z = 1 - s(3);
            end
            if this.imagingInfo_.hdr.hist.sform_code > 0
                this.imagingInfo_.hdr.hist.srow_x(4) = 1 - s(1);
                this.imagingInfo_.hdr.hist.srow_y(4) = 1 - s(2);
                this.imagingInfo_.hdr.hist.srow_z(4) = 1 - s(3);
            end
        end
        function g = get.originator(this)
            g = this.hdr.hist.originator;
        end
        function g = get.N(this)
            g = this.imagingInfo_.N;
        end
        function     set.N(this, s)
            assert(islogical(s));
            this.imagingInfo_.N = s;
        end

        %% select states
        
        function that = selectMatlabFormatTool(this, contexth)
            if ~isa(this, 'mlfourd.MatlabFormatTool')
                if isempty(this.filesystem_.filesuffix)
                    this.filesystem_.filesuffix = '.mat';
                end
                this.addLog('ImagingFormatTool.selectMatlabFormatTool()');
                that = mlfourd.MatlabFormatTool.createFromImagingFormat(this); % & imagingInfo
                contexth.changeState(that);
            else
                that = this;
            end            
        end
        function that = selectFourdfpTool(this, contexth)
            if ~isa(this, 'mlfourd.FourdfpTool')
                this.filesystem_.filesuffix = '.4dfp.hdr';
                this.addLog('ImagingFormatTool.selectFourdfpTool()');
                that = mlfourd.FourdfpTool.createFromImagingFormat(this); % & imagingInfo
                contexth.changeState(that);
            else
                that = this;
            end            
        end
        function that = selectMghTool(this, contexth)
            if ~isa(this, 'mlfourd.MghTool')
                this.filesystem_.filesuffix = '.mgz';
                this.addLog('ImagingFormatTool.selectMghTool()');
                that = mlfourd.MghTool.createFromImagingFormat(this); % & imagingInfo
                contexth.changeState(that);
            else
                that = this;
            end            
        end
        function that = selectNiftiTool(this, contexth)
            if ~isa(this, 'mlfourd.NiftiTool')
                if ~contains(this.filesystem_.filesuffix, '.nii')
                    this.filesystem_.filesuffix = '.nii.gz';
                end
                this.addLog('ImagingFormatTool.selectNiftiTool()');
                that = mlfourd.NiftiTool.createFromImagingFormat(this); % & imagingInfo
                contexth.changeState(that);
            else
                that = this;
            end            
        end

        %%

        function this = append_descrip(this, varargin) 
            %% APPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with separator and appended string.
            %  @throws MATLAB:printf:invalidInputType
            
            this.imagingInfo_.append_descrip(varargin{:});
        end
        function this = ensureComplex(this)
            if (this.hdr.dime.datatype ~= 1792)
                this.imagingInfo_.hdr.dime.datatype = 1792;
            end
            if (this.hdr.dime.bitpix ~= 128)
                this.imagingInfo_.hdr.dime.bitpix = 128;
            end
            rimg = real(this.img_);
            iimg = imag(this.img_);
            if ~isa(rimg, 'double')
                rimg = double(rimg);
            end
            if ~isa(iimg, 'double')
                iimg = double(iimg);
            end
            this.img_ = complex(rimg, iimg);
        end   
        function this = ensureDouble(this)
            if (this.hdr.dime.datatype ~= 64)
                this.imagingInfo_.hdr.dime.datatype = 64;
            end
            if (this.hdr.dime.bitpix ~= 64)
                this.imagingInfo_.hdr.dime.bitpix = 64;
            end
            if (~isa(this.img_, 'double'))
                this.img_ = double(this.img_);
            end
        end 
        function this = ensureInt8(this)
            if (this.hdr.dime.datatype ~= 256)
                this.imagingInfo_.hdr.dime.datatype = 256;
            end
            if (this.hdr.dime.bitpix ~= 8)
                this.imagingInfo_.hdr.dime.bitpix = 8;
            end
            if (~isa(this.img_, 'int8'))
                this.img_ = int8(this.img_);
            end
        end
        function this = ensureInt16(this)
            if (this.hdr.dime.datatype ~= 4)
                this.imagingInfo_.hdr.dime.datatype = 4;
            end
            if (this.hdr.dime.bitpix ~= 16)
                this.imagingInfo_.hdr.dime.bitpix = 16;
            end
            if (~isa(this.img_, 'int16'))
                this.img_ = int16(this.img_);
            end
        end
        function this = ensureInt32(this)
            if (this.hdr.dime.datatype ~= 8)
                this.imagingInfo_.hdr.dime.datatype = 8;
            end
            if (this.hdr.dime.bitpix ~= 32)
                this.imagingInfo_.hdr.dime.bitpix = 32;
            end
            if (~isa(this.img_, 'int32'))
                this.img_ = int32(this.img_);
            end
        end
        function this = ensureInt64(this)
            if (this.hdr.dime.datatype ~= 1024)
                this.imagingInfo_.hdr.dime.datatype = 1024;
            end
            if (this.hdr.dime.bitpix ~= 64)
                this.imagingInfo_.hdr.dime.bitpix = 64;
            end
            if (~isa(this.img_, 'int64'))
                this.img_ = int64(this.img_);
            end
        end
        function this = ensureNoclobber(this)
            %% ENSURENOCLOBBER ensures that there is no clobbering.
            %  @throws mlfourd:IOError:noclobberPreventedSaving if this.noclobber and isfile(this.fqfilename).
            
            if (this.noclobber && isfile(this.fqfilename))
                error('mlfourd:IOError:noclobberPreventedSaving', ...
                    'ImagingFormatTool.ensureNoclobber->%i but the file %s already exists; please check intentions', ...
                    this.noclobber, this.fqfilename);
            end
        end   
        function this = ensureSingle(this)
            if (this.hdr.dime.datatype ~= 16)
                this.imagingInfo_.hdr.dime.datatype = 16;
            end
            if (this.hdr.dime.bitpix ~= 32)
                this.imagingInfo_.hdr.dime.bitpix = 32;
            end
            if (~isa(this.img_, 'single'))
                this.img_ = single(this.img_);
            end
        end
        function this = ensureUint8(this)
            if (this.hdr.dime.datatype ~= 2)
                this.imagingInfo_.hdr.dime.datatype = 2;
            end
            if (this.hdr.dime.bitpix ~= 8)
                this.imagingInfo_.hdr.dime.bitpix = 8;
            end
            if (~isa(this.img_, 'uint8'))
                this.img_ = uint8(this.img_);
            end
        end
        function this = ensureUint16(this)
            if (this.hdr.dime.datatype ~= 512)
                this.imagingInfo_.hdr.dime.datatype = 512;
            end
            if (this.hdr.dime.bitpix ~= 16)
                this.imagingInfo_.hdr.dime.bitpix = 16;
            end
            if (~isa(this.img_, 'uint16'))
                this.img_ = uint16(this.img_);
            end
        end
        function this = ensureUint32(this)
            if (this.hdr.dime.datatype ~= 768)
                this.imagingInfo_.hdr.dime.datatype = 768;
            end
            if (this.hdr.dime.bitpix ~= 32)
                this.imagingInfo_.hdr.dime.bitpix = 32;
            end
            if (~isa(this.img_, 'uint32'))
                this.img_ = uint32(this.img_);
            end
        end
        function this = ensureUint64(this)
            if (this.hdr.dime.datatype ~= 1280)
                this.imagingInfo_.hdr.dime.datatype = 1280;
            end
            if (this.hdr.dime.bitpix ~= 64)
                this.imagingInfo_.hdr.dime.bitpix = 64;
            end
            if (~isa(this.img_, 'uint64'))
                this.img_ = uint64(this.img_);
            end
        end
        function fsleyes(this, varargin)
            %% FSLEYES
            %  @param [filename[, ...]]
            
            this.viewExternally('fsleyes', varargin{:});
        end
        function freeview(this, varargin)
            %% FREEVIEW
            %  @param [filename[, ...]]
            
            this.viewExternally('freeview', varargin{:});
        end
        function fslview(this, varargin)
            %% FSLVIEW
            %  @param [filename[, ...]]
            
            this.viewExternally('fslview_deprecated', varargin{:});
        end        
        function tf = hasFourdfp(this)
            %% identifies whether the current imaging format is fourdfp

            tf = isa(this.imagingInfo_, 'mlfourd.FourdfpInfo') || ...
                strcmp(this.filesuffix, '.4dfp.hdr') || ...
                strcmp(this.filesuffix, '.4dfp.img');
        end
        function tf = hasMgh(this)
            %% identifies whether the current imaging format is mgh

            tf = isa(this.imagingInfo_, 'mlfourd.MghInfo') || ...
                strcmp(this.filesuffix, '.mgz') || ...
                strcmp(this.filesuffix, '.mgh');
        end
        function tf = hasNifti(this)
            %% identifies whether the current imaging format is nifti

            tf = isa(this.imagingInfo_, 'mlfourd.NIfTIInfo') || ...
                strcmp(this.filesuffix, '.nii') || ...
                strcmp(this.filesuffix, '.nii.gz');
        end
        function imgi = imagingInfo(this)
            %  Returns:
            %      imgi: the most informative imagingInfo available to the object instance

            if isa(this.imagingInfo_, 'mlfourd.ImagingInfo') % trivial
                imgi = this.imagingInfo_; % internal state must share handles
                return
            end
            if ~isfile(this.fqfilename) % defer to defaults from mlfourd.ImagingInfo()
                this.imagingInfo_ = mlfourd.ImagingInfo(this.filesystem_);
                imgi = this.imagingInfo_; % internal state must share handles
                return
            end
            if contains(this.filesuffix, '.4dfp') % specifiy 4dfp, seek filesystem
                this.imagingInfo_ = mlfourd.FourdfpInfo(this.filesystem_);
                imgi = this.imagingInfo_; % internal state must share handles
                return
            end
            if contains(this.filesuffix, '.mgz') || contains(this.filesuffix, '.mgh')
                % specify mgz|mgh, seek filesystem
                this.imagingInfo_ = mlfourd.MGHInfo(this.filesystem_);
                imgi = this.imagingInfo_; % internal state must share handles
                return
            end
            if strcmp(this.filesuffix, '.nii.gz') || strcmp(this.filesuffix, '.nii') || strcmp(this.filesuffix, '.hdr')
                % specify nifti, seek filesystem
                this.imagingInfo_ = mlfourd.NIfTIInfo(this.filesystem_);
                imgi = this.imagingInfo_; % internal state must share handles
                return
            end
            imgi = [];
        end
        function this = optimizePrecision(this)
            % ensures bitpix, datatype
            % @return possibly conflicts with mlfourdfp.FourdfpVisitor.nift_4dfp_4

            if isempty(this.img_)
                this = this.ensureDouble;
                return
            end
            switch class(this.img_)
                case 'logical'
                    this = this.ensureUint8;
                case 'uint8'
                    this = this.ensureUint8;
                case 'uint16'
                    this = this.ensureSingle;
                case 'uint32'
                    this = this.ensureSingle;
                case 'uint64'
                    this = this.ensureDouble;
                case 'int16'
                    this = this.ensureInt16;
                case 'int32'
                    this = this.ensureInt32;
                case 'int64'
                    this = this.ensureInt64;
                case 'single'
                    this = this.ensureSingle;
                case 'double'
                    this = this.ensureDouble;
                    if ~isreal(this.img_)
                        return
                    end
                    if (isempty(this.img_(this.img_ ~= 0)))
                        return
                    end
                    if ((dipmin(abs(this.img_(this.img_ ~= 0))) >= eps('single')) && ...
                        (dipmax(abs(this.img_(this.img_ ~= 0))) <= realmax('single')))
                        this = this.ensureSingle;
                    end
                otherwise
                    error('mlfourd:ValueError', ...
                        'AbstractImagingFormat.optimizePrecision.this.img_ has typeclass %s', class(this.img_))
            end
        end 
        function this = prepend_descrip(this, varargin) 
            %% PREPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with prepended string and separator.
            %  @throws MATLAB:printf:invalidInputType            
            
            this.imagingInfo_.prepend_descrip(varargin{:});
        end
        function this = reset_scl(this)
            this.imagingInfo_ = this.imagingInfo_.reset_scl;
        end
        function save(this)
            %% SAVE 
            
            if this.hasFourdfp()
                that = this.selectFourdfpTool(this.contexth_);
                save(that);
                return
            end
            if this.hasMgh()
                that = this.selectMghTool(this.contexth_);
                save(that);
                return
            end
            if this.hasNifti()
                that = this.selectNiftiTool(this.contexth_);
                save(that);
                return
            end
            that = this.selectMatlabFormatTool(this.contexth_);
            save_mat(that);
        end
        function [ext,esize_total] = verify_nii_ext(~, ext)
            %  Verify NIFTI header extension to make sure that each extension section
            %  must be an integer multiple of 16 byte long that includes the first 8
            %  bytes of esize and ecode. If the length of extension section is not the
            %  above mentioned case, edata should be padded with all 0.
            %
            %  Usage: [ext, esize_total] = verify_nii_ext(ext)
            %
            %  ext - Structure of NIFTI header extension, which includes num_ext,
            %       and all the extended header sections in the header extension.
            %       Each extended header section will have its esize, ecode, and
            %       edata, where edata can be plain text, xml, or any raw data
            %       that was saved in the extended header section.
            %
            %  esize_total - Sum of all esize variable in all header sections.
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
            %

            [ext,esize_total] = mlniftitools.verify_nii_ext(ext);
        end
        function [s,r] = view(this, varargin)
            s = []; r = '';
            
            if isvector(this.img)
                this.viewvec(varargin{:});
                return
            end

            try
                % confirm viewer
                v = mlfourd.Viewer();
                assert(0 == mlbash(sprintf('which %s', v.app)), ...
                    'mlfourd:RuntimeError', ...
                    'ImagingFormatTool.viewExternally could not find %s', v.app);

                % save tempfiles of imaging currently in memory which may be inconsistent with filesystem
                temp = copy(this); % no side effects 
                tempname1 = tempname; % filestem for temp
                temp.fqfilename = strcat(tempname1, '_', temp.filename);
                temp.save();

                % parse addtional imaging to add to filelist of overlayed comparisons
                additional = varargin; % varargin is read-only
                for ai = 1:length(additional)
                    if isa(additional{ai}, 'mlio.IOInterface')
                        additional{ai} = copy(additional{ai}); % prevent side effects 
                        additional{ai}.fqfilename = strcat(tempname1, '_', additional{ai}.filename);
                        additional{ai}.save();
                        additional{ai} = additional{ai}.fqfilename; % reduce to fqfn
                    end
                end
                filelist = horzcat({temp.fqfilename}, additional);

                % do view
                [s,r] = v.aview(filelist{:});
                for fi = 1:length(filelist)
                    if contains(filelist{fi}, tempname1)
                        deleteExisting(filelist{fi});
                    end
                end
            catch ME
                dispexcept(ME, 'mlfourd:RuntimeError', ...
                    'ImagingFormatTool.view called %s, which returned:\n\t%s', v.app, r);
            end
        end
        function viewvec(this, varargin)
            plot(this.img, varargin{:});
        end
        function this = zoomed(this, varargin)
            %% ZOOMED parameters resembles fslroi; indexing starts with 0 and passing -1 for a size will set it to 
            %  the full image extent for that dimension.
            %  @param xmin|fac is required.  Solitary fac symmetrically sets Euclidean (not time) size := fac*size and
            %                                symmetrically sets all min.
            %  @param xsize is optional.
            %  @param ymin  is optional.
            %  @param ysize is optional.
            %  @param zmin  is optional.
            %  @param zsize is optional.
            %  @param tmin  is optional.  Solitary tmin with tsize is supported.
            %  @param tsize is optional.
            
            assert(3 == ndims(this) || 4 == ndims(this));
            
            ip = inputParser;
            addRequired(ip, 'xmin',      @isscalar);
            addOptional(ip, 'xsize', [], @isscalar);
            addOptional(ip, 'ymin',  [], @isscalar);
            addOptional(ip, 'ysize', [], @isscalar);
            addOptional(ip, 'zmin',  [], @isscalar);
            addOptional(ip, 'zsize', [], @isscalar);
            addOptional(ip, 'tmin',  [], @isscalar);
            addOptional(ip, 'tsize', [], @isscalar);
            parse(ip, varargin{:});            
            ipr = this.adjustIpresultsForNegSize(ip.Results);
            switch (nargin - 1)
                case 1
                    this = this.zoomFac(ipr.xmin);
                case 2
                    rmin  = [0 0 0 ipr.tmin];
                    rsize = [size(this,1) size(this,2) size(this,3) ipr.tsize];
                    this = this.zoom4D(rmin, rsize);
                case 6
                    rmin  = [ipr.xmin  ipr.ymin  ipr.zmin ];
                    rsize = [ipr.xsize ipr.ysize ipr.zsize];
                    switch (ndims(this))
                        case 3
                            this = this.zoom3D(rmin, rsize);
                        case 4
                            this = this.zoom4D(rmin, rsize);
                        otherwise 
                            error('mlfourd:unsupportedNargin', 'ImagingFormatTool.zoom');
                    end
                case 8
                    rmin  = [ipr.xmin  ipr.ymin  ipr.zmin  ipr.tmin];
                    rsize = [ipr.xsize ipr.ysize ipr.zsize ipr.tsize];
                    this = this.zoom4D(rmin, rsize);
                otherwise
                    error('mlfourd:unsupportedNargin', 'ImagingFormatTool.zoom');
            end
            tag = this.tupleTag([ipr.xmin ipr.xsize ipr.ymin ipr.ysize ipr.zmin ipr.zsize ipr.tmin ipr.tsize]);
            this.fileprefix = sprintf('%s_zoom_%s', this.fileprefix, tag);
            this.addLog('ImagingFormatTool.zoom %s', tag);               
        end
        function this = zoomFac(this, fac)
            s     = size(this);
            rmin  = [floor([s(1) s(2) s(3)]*fac/2 - 1) 0];
            rsize = [floor([s(1) s(2) s(3)]*fac) s(4)];            
            switch (ndims(this))
                case 3
                    this = this.zoom3D(rmin, rsize);
                case 4
                    this = this.zoom4D(rmin, rsize);
                otherwise 
                    error('mlfourd:unsupportedNargin', 'ImagingFormatTool.zoomFac');
            end
        end   
    end

    %% PROTECTED

    properties (Access = protected)
        imagingInfo_ % contains hdr, ext, filetype, fqfileprefix, machine, original, untouch
    end

    methods (Access = protected)
        function this = ImagingFormatTool(contexth, img, varargin)
            %% IMAGINGFORMATTOOL provides points of entry for building img objects.  
            %  It supports the following use cases:
            %  1. Receive written filesystem; read filesystem; return consistent imagingInfo, img, and logger.
            %     E.g., reading pre-existing data.
            %  2. Receive unwritten filesystem; return non-trivial and consistent img, imagingInfo, and logger.
            %     E.g., conversions:  nifti -> 4dfp.
            %  3. Receive unwritten filesystem and unwritten img; return consistent imagingInfo and logger.
            %     E.g., de novo Matlab objects destined for nifti that is written to the filesystem.
            %
            %  Args:
            %      contexth (ImagingContext2 required):  handle to ImagingContexts of the state design pattern.
            %      img (numeric option):  provides numerical imaging data.  Default := [].
            %      filesystem (HandleFilesystem):  Default := mlio.HandleFilesystem().
            %      imagingInfo (ImagingInfo):  Default := ImagingInfo(this.filesystem_).
            %      logger (mlpipeline.ILogger):  Default := log on filesystem | mlpipeline.Logger2(filesystem.fqfileprefix).
            %      viewer (IViewer):  Default := mlfourd.Viewer().
            %      useCase (numeric|text):  described above, used for logging.  Default := 1.

            this = this@mlfourd.ImagingFormatState2(contexth, img, varargin{:});

            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'imagingInfo', [], @(x) isempty(x) || isa(x, 'mlfourd.ImagingInfo'))
            addParameter(ip, 'useCase', 'unknown', @(x) isnumeric(x) || istext(x))
            parse(ip, varargin{:})
            ipr = ip.Results;
            if isa(ipr.imagingInfo, 'mlfourd.ImagingInfo')
                % reuse existing
                this.imagingInfo_ = ipr.imagingInfo;
                this.imagingInfo_.filesystem = this.filesystem_;
            else
                % de novo
                this.imagingInfo_ = mlfourd.ImagingInfo.createFromFilesystem(this.filesystem_);
            end % imagingInfo_ needs adjusting

            % ================= common point of entry for building img objects =================
            if isfile(this.filesystem_) && isempty(this.img_) 
                jimmy = this.imagingInfo_.load_nii(); % also updates imagingInfo_.hdr
                this.img_ = jimmy.img;
                this.adjustHdrForImg(this.img_);
                ipr.useCase = 1;
            end
            if isfile(this.filesystem_) && ~isempty(this.img_)
                this.adjustHdrForImg(this.img_);
                ipr.useCase = 2;
            end
            if ~isfile(this.filesystem_) && isempty(this.img_)
                ipr.useCase = 3;
            end
            if ~isfile(this.filesystem_) && ~isempty(this.img_)
                this.adjustHdrForImg(this.img_);
                ipr.useCase = 3;
            end

            this.addLog('ImagingFormatTool.ctor.ipr.useCase ~ %s', ensureString(ipr.useCase));
        end

        function        adjustHdrForImg(this, img)
            %% updates imagingInfo_.hdr using characteristics of img

            import mlfourd.ImagingInfo.datatype2bitpix
            import mlfourd.ImagingInfo.img2datatype

            ndims_ = ndims(img);
            this.imagingInfo_.hdr.dime.dim = ones(1,8);
            this.imagingInfo_.hdr.dime.dim(1) = ndims_;
            this.imagingInfo_.hdr.dime.dim(2:ndims_+1) = size(img);
            this.imagingInfo_.hdr.dime.datatype = img2datatype(img);
            this.imagingInfo_.hdr.dime.bitpix = datatype2bitpix(this.imagingInfo_.hdr.dime.datatype);
            this.imagingInfo_.hdr.dime.glmax = int32(dipmax(img));
            this.imagingInfo_.hdr.dime.glmin = int32(dipmin(img));

            this.imagingInfo_.hdr = this.imagingInfo_.adjustHdr(this.imagingInfo_.hdr);

            %this.addLog(clientname(false, 2))
        end
        function ipr_ = adjustIpresultsForNegSize(this, ipr_)
            fields_ = circshift(fields(ipr_), -2, 1);
            for i = 2:2:length(fields_)
                if (ipr_.(fields_{i}) < 0)
                    ipr_.(fields_{i-1}) = 0;
                    ipr_.(fields_{i})   = size(this, i/2);
                end
            end
        end
        function this = assertNonemptyImg(this)
            assert(~isempty(this.img), ...
                'mlfourd:IOError', ...
                'ImagingFormatTool.assertNonemptyImg: empty img are incompatible with ImagingFormatTool');
        end
        function that = copyElement(this)
            that = copyElement@matlab.mixin.Copyable(this);
            that = copyElement@mlfourd.ImagingFormatState2(that);
            that.imagingInfo_ = copy(this.imagingInfo_);
            that.imagingInfo_.filesystem = that.filesystem_; % imagingInfo := hande, not copy, from external filesystem
        end
        function d    = delimitDescrip(this, d)
            d = strtrim(d);
            if (length(d) > this.DESC_LEN_LIM)
                len2 = floor((this.DESC_LEN_LIM - 5)/2);
                d    = [d(1:len2) ' ... ' d(end-len2+1:end)]; 
            end
        end
        function nii  = make_nii(this, varargin)
            %  Make NIfTI structure specified by an N-D matrix. Usually, N is 3 for 
            %  3D matrix [x y z], or 4 for 4D matrix with time series [x y z t]. 
            %  Optional parameters can also be included, such as: voxel_size, 
            %  origin, datatype, and description. 
            %  
            %  Once the NIfTI structure is made, it can be saved into NIfTI file 
            %  using "save_nii" command (for more detail, type: help save_nii). 
            %  
            %  Usage: nii = make_nii(img, [voxel_size], [origin], [datatype], [description])
            %
            %  Where:
            %
            %	img:		Usually, img is a 3D matrix [x y z], or a 4D
            %			matrix with time series [x y z t]. However,
            %			NIfTI allows a maximum of 7D matrix. When the
            %			image is in RGB format, make sure that the size
            %			of 4th dimension is always 3 (i.e. [R G B]). In
            %			that case, make sure that you must specify RGB
            %			datatype, which is either 128 or 511.
            %
            %	voxel_size (optional):	Voxel size in millimeter for each
            %				dimension. Default is [1 1 1].
            %
            %	origin (optional):	The AC origin. Default is [0 0 0].
            %
            %	datatype (optional):	Storage data type:
            %		2 - uint8,  4 - int16,  8 - int32,  16 - float32,
            %		32 - complex64,  64 - float64,  128 - RGB24,
            %		256 - int8,  511 - RGB96,  512 - uint16,
            %		768 - uint32,  1792 - complex128
            %			Default will use the data type of 'img' matrix
            %			For RGB image, you must specify it to either 128
            %			or 511.
            %
            %	description (optional):	Description of data. Default is ''.
            %
            %  e.g.:
            %     origin = [33 44 13]; datatype = 64;
            %     nii = make_nii(img, [], origin, datatype);    % default voxel_size
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
            %            

            ip = inputParser;
            addOptional(ip, 'img', this.img, @(x) isnumeric(x) || islogical(x))
            addOptional(ip, 'voxel_size', this.mmppix, @isnumeric)
            addOptional(ip, 'origin', this.originator(1:3), @isnumeric)
            addOptional(ip, 'datatype', this.datatype, @isscalar)
            addOptional(ip, 'descrip', this.hdr.hist.descrip, @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;

            nii = mlfourd.JimmyShen.make_nii( ...
                ipr.img, ipr.voxel_size, ipr.origin, ipr.datatype, ipr.descrip);
            nii.fileprefix = this.fqfileprefix;
            nii.filetype = this.filetype;
            nii.machine = this.machine;
            nii.original = this.original;
        end
        function        save_json_metadata(this)
            if isempty(this.json_metadata)
                return
            end
            txt = jsonencode(this.json_metadata, 'PrettyPrint', true);
            txt = strrep(txt, "%", "_"); % interferes with fprintf()
            if isempty(txt)
                return
            end
            x = this.imagingInfo_.json_metadata_filesuffix;
            fid = fopen(strcat(this.fqfileprefix, x), 'w');
            fprintf(fid, txt);
            fclose(fid)
        end
        function        save_nii(this)
            %% Save NIFTI dataset. Support both *.nii and *.hdr/*.img file extension.
            %  If file extension is not provided, *.hdr/*.img will be used as default.
            %  
            %  Usage: save_nii(nii, filename, [old_RGB])
            %  
            %  nii.hdr - struct with NIFTI header fields (from load_nii.m or make_nii.m)
            %
            %  nii.img - 3D (or 4D) matrix of NIFTI data.
            %
            %  filename - NIFTI file name.
            %
            %  old_RGB    - an optional boolean variable to handle special RGB data 
            %       sequence [R1 R2 ... G1 G2 ... B1 B2 ...] that is used only by 
            %       AnalyzeDirect (Analyze Software). Since both NIfTI and Analyze
            %       file format use RGB triple [R1 G1 B1 R2 G2 B2 ...] sequentially
            %       for each voxel, this variable is set to FALSE by default. If you
            %       would like the saved image only to be opened by AnalyzeDirect 
            %       Software, set old_RGB to TRUE (or 1). It will be set to 0, if it
            %       is default or empty.
            %  
            %  Tip: to change the data type, set nii.hdr.dime.datatype,
            %	and nii.hdr.dime.bitpix to:
            % 
            %     0 None                     (Unknown bit per voxel) % DT_NONE, DT_UNKNOWN 
            %     1 Binary                         (ubit1, bitpix=1) % DT_BINARY 
            %     2 Unsigned char         (uchar or uint8, bitpix=8) % DT_UINT8, NIFTI_TYPE_UINT8 
            %     4 Signed short                  (int16, bitpix=16) % DT_INT16, NIFTI_TYPE_INT16 
            %     8 Signed integer                (int32, bitpix=32) % DT_INT32, NIFTI_TYPE_INT32 
            %    16 Floating point    (single or float32, bitpix=32) % DT_FLOAT32, NIFTI_TYPE_FLOAT32 
            %    32 Complex, 2 float32      (Use float32, bitpix=64) % DT_COMPLEX64, NIFTI_TYPE_COMPLEX64
            %    64 Double precision  (double or float64, bitpix=64) % DT_FLOAT64, NIFTI_TYPE_FLOAT64 
            %   128 uint RGB                  (Use uint8, bitpix=24) % DT_RGB24, NIFTI_TYPE_RGB24 
            %   256 Signed char            (schar or int8, bitpix=8) % DT_INT8, NIFTI_TYPE_INT8 
            %   511 Single RGB              (Use float32, bitpix=96) % DT_RGB96, NIFTI_TYPE_RGB96
            %   512 Unsigned short               (uint16, bitpix=16) % DT_UNINT16, NIFTI_TYPE_UNINT16 
            %   768 Unsigned integer             (uint32, bitpix=32) % DT_UNINT32, NIFTI_TYPE_UNINT32 
            %  1024 Signed long long              (int64, bitpix=64) % DT_INT64, NIFTI_TYPE_INT64
            %  1280 Unsigned long long           (uint64, bitpix=64) % DT_UINT64, NIFTI_TYPE_UINT64 
            %  1536 Long double, float128  (Unsupported, bitpix=128) % DT_FLOAT128, NIFTI_TYPE_FLOAT128 
            %  1792 Complex128, 2 float64  (Use float64, bitpix=128) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128 
            %  2048 Complex256, 2 float128 (Unsupported, bitpix=256) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128 
            %  
            %  Part of this file is copied and modified from:
            %  http://www.mathworks.com/matlabcentral/fileexchange/1878-mri-analyze-tools
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
            %  - "old_RGB" related codes in "save_nii.m" are added by Mike Harms (2006.06.28) 
            %

            if this.untouch
                this.save_untouch_nii;
                return
            end          
            warning('off', 'MATLAB:structOnObject');
            try
                this = this.optimizePrecision;
                nii = struct(this);
                nii = this.imagingInfo.ensureSavingOrientation(nii);
                nii.fileprefix = this.fqfileprefix;
                mlfourd.JimmyShen.save_nii(nii, this.fqfilename);
                this.addLog("mlniftitools.save_nii(nii, " + this.fqfilename + ")");
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError', ...
                    'ImagingFormatTool.save_nii could not save %s', this.fqfilename);
            end
            warning('on', 'MATLAB:structOnObject');
        end
        function        save_untouch_header_only(~, hdr, hdr_filename)
            %  This function is only used to save Analyze or NIfTI header that is
            %  ended with .hdr and loaded by load_untouch_header_only.m. If you 
            %  have NIfTI file that is ended with .nii and you want to change its
            %  header only, you can use load_untouch_nii / save_untouch_nii pair.
            %  
            %  Usage: save_untouch_header_only(hdr, new_header_file_name)
            %  
            %  hdr - struct with NIfTI / Analyze header fields, which is obtained from:
            %        hdr = load_untouch_header_only(original_header_file_name)
            %  
            %  new_header_file_name - NIfTI / Analyze header name ended with .hdr.
            %        You can either copy original.img(.gz) to new.img(.gz) manually,
            %        or simply input original.hdr(.gz) in save_untouch_header_only.m
            %        to overwrite the original header.
            %  
            %  - Jimmy Shen (jshen@research.baycrest.org)
            %    

            mlniftitools.save_untouch_header_only(hdr, hdr_filename);
            this.addLog("mlniftitools.save_untouch_header_only(hdr, " + hdr_filename + ")");
        end
        function        save_untouch_nii(this)
            %  Save NIFTI or ANALYZE dataset that is loaded by "load_untouch_nii.m".
            %  The output image format and file extension will be the same as the
            %  input one (NIFTI.nii, NIFTI.img or ANALYZE.img). Therefore, any file
            %  extension that you specified will be ignored.
            %
            %  Usage: save_untouch_nii(nii, filename)
            %  
            %  nii - nii structure that is loaded by "load_untouch_nii.m"
            %
            %  filename  - 	NIFTI or ANALYZE file name.
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
            %

            if isfile(this.fqfilename)
                warning('mlfourd:IOError', ...
                    ['ImagingFormatTool.save_untouch_nii: ' ...
                     'this object has untouch->%i, but fqfilename->%s already exists, ' ...
                     'therefor mlniftitools.save_untouch_nii will not support saving.'], ...
                    this.untouch, this.fqfilename);
                return
            end      
            warning('off', 'MATLAB:structOnObject');
            try
                nii = struct(this);
                nii.fileprefix = this.fqfileprefix;
                mlniftitools.save_untouch_nii(nii, this.fqfilename);
                this.addLog("mlniftitools.save_untouch_nii(nii, " + this.fqfilename + ")");
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError', ...
                    'ImagingFormatTool.save_untouch_nii could not save %s', this.fqfilename);
            end
            warning('on', 'MATLAB:structOnObject');
        end
        function        saveLogger(this)
            if (~isempty(this.logger_))
                this.logger_.fqfileprefix = this.fqfileprefix;
                this.logger_.save;
            end
        end
        function fn   = tempFqfilename(this, varargin)
            ip = inputParser;
            addOptional(ip, 'fqfp', this.fqfileprefix, @ischar);
            parse(ip, varargin{:});
            
            fn = strcat(myfileprefix(ip.Results.fqfp), this.imagingInfo_.defaultFilesuffix);
            fn = tempFqfilename(fn);
        end
        function this = zoom3D(this, rmin, rsize)
            %% indexes starting from 0
            
            sz0 = size(this);
            im  = zeros(rsize, 'like', this.img);
            
            if (all(rsize == sz0))
                return
            elseif (all(rsize <= sz0)) % zoom in
                x1 = rmin(1):rmin(1)+rsize(1)-1;
                y1 = 1:rsize(1);
                for x3 = rmin(3):rmin(3)+rsize(3)-1
                    for x2 = rmin(2):rmin(2)+rsize(2)-1
                        im(y1, x2-rmin(2)+1, x3-rmin(3)+1) = this.img(x1+1, x2+1, x3+1); % x1-rmin(1)+1
                    end
                end
            elseif (all(rsize >= sz0)) % zoom out
                x1 = 0:sz0(1)-1;
                y1 = 1-rmin(1):sz0(1)-rmin(1);
                for x3 = 0:sz0(3)-1
                    for x2 = 0:sz0(2)-1
                        im(y1, x2-rmin(2)+1, x3-rmin(3)+1) = this.img(x1+1, x2+1, x3+1); % x1-rmin(1)+1
                    end
                end
            else
                error('mlfourd:unsupportedArrayShape', 'ImagingFormatTool.zoom3D')
            end
            this.img = im;
            this.imagingInfo_ = this.imagingInfo_.zoomed(rmin, rsize);
        end
        function this = zoom4D(this, rmin, rsize)
            
            sz0 = size(this);
            im  = zeros(rsize, 'like', this.img);
            
            if (all(rsize == sz0))
                return
            elseif (all(rsize <= sz0)) % zoom in
                x1 = rmin(1):rmin(1)+rsize(1)-1;
                y1 = 1:rsize(1);
                for x4 = rmin(4):rmin(4)+rsize(4)-1
                    for x3 = rmin(3):rmin(3)+rsize(3)-1
                        for x2 = rmin(2):rmin(2)+rsize(2)-1
                            im(y1, x2-rmin(2)+1, x3-rmin(3)+1, x4-rmin(4)+1) = ...
                                this.img(x1+1, x2+1, x3+1, x4+1); % x1-rmin(1)+1
                        end
                    end
                end
            elseif (all(rsize >= sz0)) % zoom out
                x1 = 0:sz0(1)-1;
                y1 = 1-rmin(1):sz0(1)-rmin(1);
                for x4 = 0:sz0(4)-1
                    for x3 = 0:sz0(3)-1
                        for x2 = 0:sz0(2)-1
                            im(y1, x2-rmin(2)+1, x3-rmin(3)+1, x4-rmin(4)+1) = ...
                                this.img(x1+1, x2+1, x3+1, x4+1); % x1-rmin(1)+1
                        end
                    end
                end
            else
                error('mlfourd:unsupportedArrayShape', 'ImagingFormatTool.zoom3D')
            end
            this.img = im;
            this.imagingInfo_ = this.imagingInfo_.zoomed(rmin, rsize);
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
