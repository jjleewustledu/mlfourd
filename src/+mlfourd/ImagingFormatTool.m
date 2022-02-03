classdef (Abstract) ImagingFormatTool < handle & mlfourd.ImagingFormatState2
    %% IMAGINGFORMATTOOL defines an abstraction for encapsulating specifics of imaging formats.
    %  It provides finer granularity of data representation than its superclass.  It supports behavior common
    %  to all imaging formats, such as adjusting numerical type or precision, adjusting the field-of-view of data
    %  (zoom*), viewing data, saving data.
    %  N.B.:  select*Tool() overrides superclass, generating imagingInfo from existing ImagingFormatTool.
    %  N.B.:  ctor accepts arguments for imagingInfo and useCase.
    %  
    %  Created 08-Dec-2021 22:27:36 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.

    methods (Static)
        function [hdr,orig] = imagingFormatToHdr(iform)
            %% from ImagingFormatTool create nifti hdr for internal representations

            iinfo = iform.imagingInfo();
            if isanalyze(iinfo)
                % from non-nifti hdr build nifti hdr
                jimmy = iform.make_nii();
                hdr = jimmy.hdr;
                if isfield(jimmy, 'original')
                    orig = jimmy.original;
                else
                    orig = [];
                end
                return
            end
            if isnifti(iinfo)
                if strcmp(iform.hdr.hist.descrip, 'ImagingInfo.initialHdr') && ...
                        isfile(iform.fqfilename)
                    % replace uninformative hdr with hdr from filesystem
                    jimmy = iinfo.load_nii(); 
                    hdr = jimmy.hdr;
                    hdr.dime.pixdim(1) = -1;
                    hdr.hist.qform_code = 1;
                    hdr.hist.sform_code = 1;
                    if isfield(jimmy, 'original')
                        orig = jimmy.original;
                    else
                        orig = [];
                    end
                    return
                end
                if ~isempty(iinfo.original) && ...
                        (iinfo.original.hdr.hist.qform_code > 0 || ...
                         iinfo.original.hdr.hist.sform_code > 0)
                    hdr = iform.hdr;
                    hdr.dime.pixdim(1) = -1;
                    hdr.hist.qform_code = iform.original.hdr.hist.qform_code;
                    hdr.hist.sform_code = iform.original.hdr.hist.sform_code;
                    orig = iform.original;
                    return
                end
                hdr = iform.hdr;
                hdr.dime.pixdim(1) = -1;
                hdr.hist.qform_code = 1;
                hdr.hist.sform_code = 1;
                orig = iform.original;
                return
            end
            hdr = iform.hdr;
            orig = iform.original;
        end
    end

    properties (Constant)
        DESC_LEN_LIM = 1024; % limit to #char of desc; accumulate extended descriptions with logging features.
    end

    properties (Dependent) 

        %% required by mlniftitools.{save_nii,save_untouch_nii}

        hdxml
        orient % RADIOLOGICAL, NEUROLOGICAL
        untouch

        datatype
        ext
        filetype
        hdr % required by mlniftitools.{save_nii,save_untouch_nii}
        machine
        stateTypeclass

        %% important for 4dfp

        mmppix
        originator
        N % logical: suppress mmppix and center for 4dfp
    end

    methods

        %% GET/SET
                      
        function x = get.hdxml(this)
            if ~isfile(this.fqfilename)
                x = '';
                return
            end
            [~,x] = mlbash(['fslhd -x ' this.fqfilename]);
            x = strtrim(regexprep(x, 'sform_ijk matrix', 'sform_ijk_matrix'));
        end
        function o = get.orient(this)
            if ~isempty(this.orient_)
                o = this.orient_;
                return
            end
            if isfile(this.fqfilename)
                [~, o] = mlbash(['fslorient -getorient ' this.fqfilename]);
                o = strtrim(o);
                this.orient_ = o;
                return
            end
            o = '';
        end 
        function u = get.untouch(this)
            u = this.imagingInfo_.untouch;
        end
        function     set.untouch(this, s)
            this.imagingInfo_.untouch = logical(s);
        end

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
                error('mlfourd:unsupportedDatatype', 'InnerNIfTI.set.datatype does not support class(dt)->%s', class(dt));
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
            %% KLUDGE for mlniftitools.save_nii_hdr line28

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
        function g = get.machine(this)
            g = this.imagingInfo_.machine;
        end
        function g = get.stateTypeclass(this)
            g = class(this.imagingInfo_);
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
            assert(3 == length(s))
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
                this.addLog('ImagingFormatTool.selectMatlabFormatTool');
                that = mlfourd.MatlabFormatTool.createFromImagingFormat(this); % & imagingInfo
                contexth.changeState(that);
            else
                that = this;
            end            
        end
        function that = selectFourdfpTool(this, contexth)
            if ~isa(this, 'mlfourd.FourdfpTool')
                this.filesystem_.filesuffix = '.4dfp.hdr';
                this.addLog('ImagingFormatTool.selectFourdfpTool');
                that = mlfourd.FourdfpTool.createFromImagingFormat(this); % & imagingInfo
                contexth.changeState(that);
            else
                that = this;
            end            
        end
        function that = selectMghTool(this, contexth)
            if ~isa(this, 'mlfourd.MghTool')
                this.filesystem_.filesuffix = '.mgz';
                this.addLog('ImagingFormatTool.selectMghTool');
                that = mlfourd.MghTool.createFromImagingFormat(this); % & imagingInfo
                contexth.changeState(that);
            else
                that = this;
            end            
        end
        function that = selectNiftiTool(this, contexth)
            if ~isa(this, 'mlfourd.NiftiTool')
                this.filesystem_.filesuffix = '.nii.gz';
                this.addLog('ImagingFormatTool.selectNiftiTool');
                that = mlfourd.NiftiTool.createFromImagingFormat(this); % & imagingInfo
                contexth.changeState(that);
            else
                that = this;
            end            
        end

        %%

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
        function fsleyes(this, varargin)
            %% FSLVIEW
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
            tf = isa(this.imagingInfo_, 'mlfourd.FourdfpInfo') || ...
                strcmp(this.filesuffix, '.4dfp.hdr') || ...
                strcmp(this.filesuffix, '.4dfp.img');
        end
        function tf = hasMgh(this)
            tf = isa(this.imagingInfo_, 'mlfourd.MghInfo') || ...
                strcmp(this.filesuffix, '.mgz') || ...
                strcmp(this.filesuffix, '.mgh');
        end
        function tf = hasNifti(this)
            tf = isa(this.imagingInfo_, 'mlfourd.NIfTIInfo') || ...
                strcmp(this.filesuffix, '.nii') || ...
                strcmp(this.filesuffix, '.nii.gz');
        end
        function imgi = imagingInfo(this)
            if isa(this.imagingInfo_, 'mlfourd.ImagingInfo') 
                imgi = this.imagingInfo_; % internal state must share handles
                return
            end
            if ~isfile(this.fqfilename)
                this.imagingInfo_ = mlfourd.ImagingInfo(this.filesystem_);
                imgi = this.imagingInfo_; % internal state must share handles
                return
            end
            if contains(this.filesuffix, '.4dfp')
                this.imagingInfo_ = mlfourd.FourdfpInfo(this.filesystem_);
                imgi = this.imagingInfo_; % internal state must share handles
                return
            end
            if contains(this.filesuffix, '.mgz') || contains(this.filesuffix, '.mgh')
                this.imagingInfo_ = mlfourd.MGHInfo(this.filesystem_);
                imgi = this.imagingInfo_; % internal state must share handles
                return
            end
            if strcmp(this.filesuffix, '.nii.gz') || strcmp(this.filesuffix, '.nii') || strcmp(this.filesuffix, '.hdr')
                this.imagingInfo_ = mlfourd.NIfTIInfo(this.filesystem_);
                imgi = this.imagingInfo_; % internal state must share handles
                return
            end
            imgi = [];
        end
        function this = reset_scl(this)
            this.imagingInfo_ = this.imagingInfo_.reset_scl;
        end
        function        save(this)
            %% SAVE 
            %  If this.noclobber == true,  it will never overwrite files.
            %  If this.noclobber == false, it may overwrite files. 
            %  If this.untouch   == true,  it will never overwrite files.
            %  If this.untouch   == false, it may saving imaging data with modified state.
            %  @return saves this to this.fqfilename.  
            %  @return this may have mutated.
            %  @throws mlfourd.IOError:noclobberPreventedSaving, mlfourd:IOError:untouchPreventedSaving, 
            %  mlfourd.IOError:unsupportedFilesuffix, mfiles:unixException, MATLAB:assertion:failed   
            
            this.ensureImg();
            this.ensureNoclobber();
            this.ensureFilesuffix();
            ensuredir(this.filepath);

            if this.hasFourdfp()
                that = this.selectFourdfpTool(this.contexth_);
                that.save__();
                that.saveLogger();
                return
            end
            if this.hasMgh()
                that = this.selectMghTool(this.contexth_);
                that.save__();
                that.saveLogger();
                return
            end
            if this.hasNifti()
                that = this.selectNiftiTool(this.contexth_);
                that.save__();
                that.saveLogger();
                return
            end

            this.save__();
            this.saveLogger();
        end 
        function [s,r] = view(this, varargin)
            if isvector(this.img)
                this.viewvec(varargin{:});
                return
            end

            s = []; r = '';
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
                        additional{ai}.fqfilename = [tempname1 '_' additional{ai}.filename];
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
            %  @throws .
            
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
        imagingInfo_ % contains hdr, ext, filetype, N, untouch
        orient_
    end

    methods (Access = protected)
        function this = ImagingFormatTool(contexth, img, varargin)
            %% IMAGINGFORMATTOOL supports the following use cases.
            %  1. Receive written filesystem; read filesystem; return consistent imagingInfo, img, and logger.
            %     E.g., reading data de novo.
            %  2. Receive unwritten filesystem; return consistent img, imagingInfo, and logger.
            %     E.g., conversions:  nifti -> 4dfp.
            %  3. Receive unwritten filesystem and unwritten img; return consistent imagingInfo and logger.
            %     E.g., de novo Matlab objects destined for written nifti.
            %
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      img (numeric): option provides numerical imaging data.  Default := [].
            %      filesystem (HandleFilesystem): Default := mlio.HandleFilesystem().
            %      imagingInfo (ImagingInfo): Default := ImagingInfo(this.filesystem_).
            %      logger (mlpipeline.ILogger): Default := log on filesystem | mlpipeline.Logger2(filesystem.fqfileprefix).
            %      viewer (IViewer): Default := mlfourd.Viewer().
            %      useCase (numeric): described above.  Default := 1.

            this = this@mlfourd.ImagingFormatState2(contexth, img, varargin{:});

            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'imagingInfo', [], @(x) isempty(x) || isa(x, 'mlfourd.ImagingInfo'))
            addParameter(ip, 'useCase', 1, @isnumeric)
            parse(ip, varargin{:})
            ipr = ip.Results;
            if isa(ipr.imagingInfo, 'mlfourd.ImagingInfo')
                % reuse existing
                this.imagingInfo_ = ipr.imagingInfo;
                this.imagingInfo_.filesystem = this.filesystem_;
            else                
                this.imagingInfo_ = mlfourd.ImagingInfo.createFromFilesystem(this.filesystem_);
            end  

            if isfile(this.filesystem_) && isempty(this.img_) 

                % use case 1
                nii_ = this.imagingInfo_.make_nii;
                this.imagingInfo_.hdr = nii_.hdr;
                this.imagingInfo_.untouch = false;
                this.img_ = nii_.img;
            end

            % all use cases
            this.adjustHdrForImg(this.img_);
            this.addLog('ImagingFormatTool.ctor.ipr.useCase ~ %i', ipr.useCase);
        end

        function        adjustHdrForImg(this, imgobj)
            %% updates imagingInfo_.hdr

            assert(isnumeric(imgobj) || islogical(imgobj))
            ndims_ = ndims(imgobj);
            this.img_                                  = imgobj;
            this.imagingInfo_.hdr.dime.dim             = ones(1,8);
            this.imagingInfo_.hdr.dime.dim(1)          = ndims_;
            this.imagingInfo_.hdr.dime.dim(2:ndims_+1) = size(imgobj);
            this.imagingInfo_.hdr                      = this.imagingInfo_.adjustHdr(this.imagingInfo_.hdr);
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
        function this = ensureFilesuffix(this)
            if (isempty(this.filesuffix))
                this.filesuffix = this.imagingInfo_.defaultFilesuffix;
            end
        end
        function this = ensureImg(this)
            if (isempty(this.img))
                error('mlfourd:IOError:attemptToSaveEmptyObject', ...
                    'ImagingFormatTool.ensureImg:  %s', ...
                    'the request is incompatible with mlnifittools.save_[untouch]_nii');
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
        function tf   = hasJimmyShenExtension(this)
            tf = lstrfind(this.filesuffix, {'.hdr' '.nii' '.nii.gz'});
        end      
        function        save_nii(this)
            if (this.untouch)
                this.save_untouch_nii;
                return
            end
            this = this.optimizePrecision;            
            warning('off', 'MATLAB:structOnObject');
            try
                mlniftitools.save_nii(struct(this), this.fqfilename);
                this.addLog("mlniftitools.save_nii(struct(this), " + this.fqfilename + ")");
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError:from_mlniftitools', ...
                    'ImagingFormatTool.save_nii could not save %s', this.fqfilename);
            end
            warning('on', 'MATLAB:structOnObject');
        end
        function        save_untouch_nii(this)
            if isfile(this.fqfilename)
                warning('mlfourd:IOError:for_mlniftitools', ...
                    ['ImagingFormatTool.save_untouch_nii:  ' ...
                     'the imaging object has untouch->%i, but fqfilename->%s already exists.  ' ...
                     'mlniftitools.save_untouch_nii doesn''t support saving in these circumstances.'], ...
                    this.untouch, this.fqfilename);
                return
            end            
            try
                assert(this.hasJimmyShenExtension, ...
                    'mlfourd:unsupportedInternalState', ...
                    ['ImagingFormatTool.save_untouch_nii ' ...
                     'received a request to save imaging using a filesuffix that isn''t supported.']);
                warning('off', 'MATLAB:structOnObject');
                mlniftitools.save_untouch_nii(struct(this), this.fqfilename);
                this.addLog("mlniftitools.save_untouch_nii(struct(this), " + this.fqfilename + ")");
                warning('on', 'MATLAB:structOnObject');
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError:from_mlniftitools', ...
                    'ImagingFormatTool.save_untouch_nii could not save %s', this.fqfilename);
            end
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

    %% DEPRECATED
    
    methods (Hidden)
        function this = append_descrip(this, varargin) 
            %% APPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with separator and appended string.
            %  @throws MATLAB:printf:invalidInputType
            
            this.imagingInfo_.append_descrip(varargin{:});
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
                    if (isempty(this.img_(this.img_ ~= 0)))
                        return
                    end
                    if ((dipmin(abs(this.img_(this.img_ ~= 0))) >= eps('single')) && ...
                        (dipmax(abs(this.img_(this.img_ ~= 0))) <= realmax('single')))
                        this = this.ensureSingle;
                    end
                otherwise
                    error('mlfourd:NotImplementedError', ...
                        'class(AbstractImagingFormat.optimizePrecision.this.img_) is %s', class(this.img_))
            end
        end 
        function this = prepend_descrip(this, varargin) 
            %% PREPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with prepended string and separator.
            %  @throws MATLAB:printf:invalidInputType            
            
            this.imagingInfo_.prepend_descrip(varargin{:});
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
