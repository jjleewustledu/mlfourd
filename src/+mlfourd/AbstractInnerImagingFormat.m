classdef AbstractInnerImagingFormat < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable & mlfourd.HandleINIfTI & mlfourd.InnerNIfTIIO
	%% ABSTRACTINNERIMAGINGFORMAT supports imaging formats through concrete subclasses such as InnerNIfTI,  
    %  mlfourdfp.InnerFourdfp, mlsurfer.InnerMGH.  Altering property filesuffix is a convenient way to change states 
    %  for formats.
    %
	%  $Revision$
 	%  was created 22-Jul-2018 01:31:58 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%  It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
    properties (Abstract)
        hdxml
        orient % RADIOLOGICAL, NEUROLOGICAL
        untouch
    end
    
    methods (Abstract, Static)
        this = create(fn, varargin) % abstract factory design pattern
        info = createImagingInfo(fn, varargin)
        s    = imagingInfo2struct(fn, varargin)
    end
    
    properties (Constant)
        DESC_LEN_LIM = 1024; % limit to #char of desc; accumulate extended descriptions with logging features.
        VIEWER = fullfile(getenv('FREESURFER_HOME'), 'bin', 'freeview')
    end  
    
	properties (Dependent)
        noclobber
        
        ext
        filetype
        hdr          % See also:  mlfourd.ImagingInfo
        img
        
        bitpix
        creationDate
        datatype
        descrip
        entropy
        label
        machine
        mmppix       % [mm mm mm]
        negentropy
        originalType % useful for AbstractInnerImagingFormat that is a state or strategy
        originator
        pixdim       % [mm mm mm sec]
        seriesNumber
        
        imagingInfo
        imgrec
        logger
        N
        separator % for descrip & label properties, not for filesystem behaviors
        stack % add descrip to stack at every call to set.img
        viewer
    end
    
    methods (Abstract)
        this = mutateInnerImagingFormatByFilesuffix(this)
    end
    
	methods 
        
        %% GET/SET
        
        function tf   = get.noclobber(this)
            tf = this.filesystemRegistry_.noclobber;
        end
        function        set.noclobber(this, nc)
            nc = logical(nc);
            this.filesystemRegistry_.noclobber = nc;
        end
        
        function g    = get.ext(this)
            g = this.imagingInfo_.ext;
        end
        function        set.ext(this, s)
            this.imagingInfo_.ext = s;
        end
        function f    = get.filetype(this)
            f = this.imagingInfo_.filetype;
        end
        function        set.filetype(this, ft)
            switch (ft)
                case {0 1}
                    this.imagingInfo_.filetype = ft;
                    this.filesuffix = '.hdr';
                case 2
                    this.imagingInfo_.filetype = ft;
                    this.filesuffix = this.imagingInfo.defaultFilesuffix;
                otherwise
                    error('mlfourd:unsupportedParamValue', 'InnerNIfTI.set.filetype.ft->%g', ft);
            end
        end  
        function h    = get.hdr(this)
            h = this.imagingInfo_.hdr;
            if (~isfield(h.hist, 'originator') || ...
                 isempty(h.hist.originator))                
                h.hist.originator = zeros(1,3); % KLUDGE for mlniftitools.save_nii_hdr line28
            end
        end 
        function        set.hdr(this, h) % KLUDGE
            assert(isstruct(h));
            this.imagingInfo_.hdr = h;
        end
        function im   = get.img(this)
            im = this.img_;
        end        
        function        set.img(this, im)
            %% SET.IMG sets new image state. 
            %  @param im is the incoming imaging array; converted to single if data bandwidth is appropriate.
            %  @return updates img, datatype, bitpix, dim.
            
            this.img_                                  = im;
            ndims_                                     = ndims(this.img_);
            this                                       = this.optimizePrecision;
            this.imagingInfo_.hdr.dime.dim             = ones(1,8);
            this.imagingInfo_.hdr.dime.dim(1)          = ndims_;
            this.imagingInfo_.hdr.dime.dim(2:ndims_+1) = this.size;
            this.imagingInfo_.hdr                      = this.imagingInfo_.adjustHdr(this.imagingInfo_.hdr);
            this.stack_                                = [this.stack_ {this.descrip}];
        end
        
        function bp   = get.bitpix(this) 
            %% BITPIX returns a datatype code as described by the INIfTI specifications
            
            bp = this.hdr.dime.bitpix;
        end
        function        set.bitpix(this, bp)
            assert(isnumeric(bp));
            if (bp >= 64)
                this = this.ensureDouble;  %#ok<NASGU>
            else
                this = this.ensureSingle;  %#ok<NASGU>
            end
        end
        function cdat = get.creationDate(this)
            cdat = this.creationDate_;
        end
        function dt   = get.datatype(this)
            %% DATATYPE returns a datatype code as described by the INIfTI specificaitons
            
            dt = this.hdr.dime.datatype;
        end
        function        set.datatype(this, dt)
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
        function d    = get.descrip(this)
            d = this.hdr.hist.descrip;
        end        
        function        set.descrip(this, s)
            %% SET.DESCRIP
            %  @param s:  do not add separators such as ";" or ","
            
            assert(ischar(s));
            this.imagingInfo_.hdr.hist.descrip = this.delimitDescrip(s);
        end 
        function E    = get.entropy(this)
            if (isempty(this.img_))
                E = nan;
            else
                E = entropy(double(this.img_)); %#ok<CPROP>
            end
        end
        function d    = get.label(this)
            if (isempty(this.label_))
                [~,this.label_] = fileparts(this.fileprefix);
            end
            d = this.label_;
        end     
        function        set.label(this, s)
            assert(ischar(s));
            this.label_ = strtrim(s);
        end
        function ma   = get.machine(this)
            ma = this.imagingInfo_.machine;
        end           
        function mpp  = get.mmppix(this)
            mpp = this.pixdim;
            if (length(mpp) > 3)
                mpp = mpp(1:3);
            end
        end        
        function        set.mmppix(this, mpp)
            %% SET.MMPPIX sets voxel-time dimensions in mm, s.
            
            this.pixdim = mpp;
        end  
        function E    = get.negentropy(this)
            E = -this.entropy;
        end
        function o    = get.originator(this)
            o = this.hdr.hist.originator;
        end
        function        set.originator(this, o)
            %% SET.ORIGINATOR sets originator position in mm and this.N := false.
            
            this.hdr.hist.originator = o;
            this.imagingInfo_.hdr.hist.qoffset_x = 1 - o(1);
            this.imagingInfo_.hdr.hist.qoffset_y = 1 - o(2);
            this.imagingInfo_.hdr.hist.qoffset_z = 1 - o(3);
            this.imagingInfo_.hdr.hist.srow_x(4) = 1 - o(1);
            this.imagingInfo_.hdr.hist.srow_y(4) = 1 - o(2);
            this.imagingInfo_.hdr.hist.srow_z(4) = 1 - o(3);
            this.N = false;
        end
        function o    = get.originalType(this)
            o = this.originalType_;
        end
        function pd   = get.pixdim(this)
            ndims_ = this.ndims;
            pd = this.hdr.dime.pixdim(2:ndims_+1);
        end        
        function        set.pixdim(this, pd)
            %% SET.PIXDIM sets voxel-time dimensions in mm, s; and this.N := false.
            
            this.imagingInfo_.hdr.dime.pixdim(2:length(pd)+1) = pd;
            this.imagingInfo_.hdr.hist.srow_x(1) = pd(1);
            this.imagingInfo_.hdr.hist.srow_y(2) = pd(2);
            this.imagingInfo_.hdr.hist.srow_z(3) = pd(3);
            this.N = false;
        end 
        function s    = get.seriesNumber(this)
            s = this.seriesNumber_;
        end
        function        set.seriesNumber(this, s)
            assert(isnumeric(s));
            this.seriesNumber_ = s;
        end
        
        function ii   = get.imagingInfo(this)
            ii = this.imagingInfo_;
        end
        function        set.imagingInfo(this, s)
            assert(isa(s, 'mlfourd.ImagingInfo'));
            this.imagingInfo_ = s;
        end
        function g    = get.imgrec(this)
            if (~isprop(this.imagingInfo_, 'imgrec'))
                g = [];
                return
            end
            g = this.imagingInfo_.imgrec;
        end
        function        set.imgrec(this, s)
            if (~isprop(this.imagingInfo_, 'imgrec'))
                return
            end
            assert(isa(s, mlfourdfp.ImgRecLogger));
            this.imagingInfo_.imgrec = s;
        end
        function g    = get.logger(this)
            g = this.logger_;
        end
        function g    = get.N(this)
            g = this.imagingInfo_.N;
        end
        function        set.N(this, s)
            assert(islogical(s));
            this.imagingInfo_.N = s;
        end
        function s    = get.separator(this)
            s = this.separator_;
        end
        function        set.separator(this, s)
            if (ischar(s))
                this.separator_ = s;
            end
        end
        function s    = get.stack(this)
            s = this.stack_;
        end
        function v    = get.viewer(this)
            v = this.viewer_;
        end
        function        set.viewer(this, v)
            this.viewer_ = v;
        end
        
        %% mlfourd.INIfTI
        
        function this = append_descrip(this, varargin) 
            %% APPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with this.separator and appended string.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            this.descrip = sprintf('%s%s %s', this.descrip, this.separator, astring);
            this.addLog(astring);
        end  
        function this = prepend_descrip(this, varargin) 
            %% PREPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with prepended string and this.separator.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            this.descrip = sprintf('%s%s %s', astring, this.separator, this.descrip);
            this.addLog(astring);
        end
        function d    = double(this)
            if (~isa(this.img_, 'double'))
                d = double(this.img_);
            else 
                d = this.img_;
            end
        end        
        function d    = duration(this)
            if (this.ndims > 3)
                d = this.size(4)*this.pixdim(4);
            else
                d = 0;
            end
        end   
        function this = append_fileprefix(this, varargin)
            %% APPEND_FILEPREFIX
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates fileprefix with this.separator and appended string.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            this.fileprefix = sprintf('%s%s', this.fileprefix, astring);
            this.addLog('AbstractInnerImagingFormat.append_fileprefix:  %s', astring);
        end   
        function this = prepend_fileprefix(this, varargin)
            %% PREPEND_FILEPREFIX
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates fileprefix with prepended string and this.separator.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            this.fileprefix = sprintf('%s%s', astring, this.fileprefix);
            this.addLog('AbstractInnerImagingFormat.prepend_fileprefix:  %s', astring);
        end             
        function f3d  = fov(this)
            f3d = this.mmppix .* this.matrixsize;
        end   
        function        freeview(this, varargin)
            %% FREEVIEW
            %  @param [filename[, ...]]
            
            this.viewExternally('freeview', varargin{:});
        end
        function e    = fslentropy(this)
            if (~lexist(this.fqfilename, 'file'))
                e = nan;
                return
            end
            [~,e] = mlbash(sprintf('fslstats %s -e', this.fqfileprefix));
            e = str2double(e);
        end
        function E    = fslEntropy(this)
            if (~lexist(this.fqfilename, 'file'))
                E = nan;
                return
            end
            [~,E] = mlbash(sprintf('fslstats %s -E', this.fqfileprefix));
            E = str2double(E);
        end
        function        fsleyes(this, varargin)
            %% FSLVIEW
            %  @param [filename[, ...]]
            
            try
                this.viewExternally('fsleyes', varargin{:});
            catch ME
                handwarning(ME);
                this.fslview(varargin{:});
            end
        end 
        function        fslview(this, varargin)
            %% FSLVIEW
            %  @param [filename[, ...]]
            
            try
                this.viewExternally('fslview_deprecated', varargin{:});
            catch ME
                handwarning(ME);
                this.viewExternally('fslview', varargin{:});
            end
        end
        function        hist(this, varargin)
            histogram(reshape(this.img, [1, numel(this.img)]), varargin{:});
        end 
        function d    = logical(this)
            if (~isa(this.img_, 'logical'))
                d = logical(this.img_);
            else 
                d = this.img_;
            end
        end 
        function m3d  = matrixsize(this)
            m3d = [this.size(1) this.size(2) this.size(3)];
        end   
        function n    = ndims(this, img)
            %% NDIMS effectively squeezes img (this.img) before reporting number of dimensions.
            
            if (nargin < 2)
                img = this.img_; end
            n = ndims(img);
        end
        function n    = numel(this, img)
            %% NUMEL
            
            if (nargin < 2)
                img = this.img_; end
            n = numel(img);
        end
        function this = prod(this, varargin)
            %% PROD overloads prod for INIfTI
            
            this.img = prod(this.img_, varargin{:});
            this = this.append_fileprefix('_prod');
            this = this.append_descrip('prod');
        end
        function r    = rank(this, varargin)
            %% DEPRECATED; use ndims.
            
            r = this.ndims(varargin{:});
        end
        function this = reset_scl(this)
            this.imagingInfo_ = this.imagingInfo_.reset_scl;
        end
        function this = roi(this, varargin)
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
            
            this = this.ensureImg;
            this = this.ensureNoclobber;
            this = this.ensureFilesuffix;
            if strcmp(this.filesuffix, '.mat')
                save(this.fqfilename, 'this')
                return
            end
            this = this.mutateInnerImagingFormatByFilesuffix; 
            ensuredir(this.filepath);
            this.save__;
            this.saveLogger;
        end 
        function this = saveas(this, fn)
            %% SAVEAS
            %  @param fn updates internal filename
            %  @return this updates internal filename; sets this.untouch to false; serializes object to filename
            %  @return this may have mutated by this.save.mutateInnerImagingFormatByFilesuffix.
            %  See also:  mlfourd.InnerNIfTI.save
            
            [p,f,e] = myfileparts(fn);
            if (isempty(e))
                e = this.imagingInfo.defaultFilesuffix;
            end
            this.imagingInfo.fqfilename = fullfile(p, [f e]);
            this.imagingInfo.untouch = false;
            this.logger.fqfileprefix = fullfile(p, f);
            this.save;
        end
        function this = scrubNanInf(this, varargin)
            %% SCRUBNANINF sets to zero non-finite elements of its argument
            %  @param obj := this.img_ by default.
            %  @return this.
            %  See also mlfourd.AbstractNIfTIComponent and mlfourd.NIfTIdecorator.
            
            p = inputParser;
            addOptional(p, 'obj', this.img_, @isnumeric);
            parse(p, varargin{:});
            img__ = double(p.Results.obj);
            
            if (all(isfinite(img__(:))))
                return; end
            switch (ndims(img__))
                case 1
                    img__ = scrub1D(this, img__);
                case 2
                    img__ = scrub2D(this, img__);
                case 3
                    img__ = scrub3D(this, img__);
                case 4
                    img__ = scrub4D(this, img__);
                otherwise
                    error('mlfourd:unsupportedParamValue', ...
                          'InnerNIfTI.scrubNanInf:  ndims(img) -> %i', ndims(img__));
            end            
            this.img = img__;
            
            function im   = scrub1D(this, im)
                assert(isnumeric(im));
                for x = 1:this.size(1)
                    if (~isfinite(im(x)))
                        im(x) = 0; end
                end
            end
            function im   = scrub2D(this, im)
                assert(isnumeric(im));
                for y = 1:this.size(2)
                    for x = 1:this.size(1)
                        if (~isfinite(im(x,y)))
                            im(x,y) = 0; end
                    end
                end
            end
            function im   = scrub3D(this, im)
                assert(isnumeric(im));
                for z = 1:this.size(3)
                    for y = 1:this.size(2)
                        for x = 1:this.size(1)
                            if (~isfinite(im(x,y,z)))
                                im(x,y,z) = 0; end
                        end
                    end
                end
            end
            function im   = scrub4D(this, im)
                assert(isnumeric(im));
                for t = 1:this.size(4)
                    for z = 1:this.size(3)
                        for y = 1:this.size(2)
                            for x = 1:this.size(1)
                                if (~isfinite(im(x,y,z,t)))
                                    im(x,y,z,t) = 0; end
                            end
                        end
                    end
                end
            end 
        end
        function s    = single(this)
            if (~isa(this.img, 'single'))
                s = single(this.img_);
            else 
                s = this.img_;
            end
        end   
        function sz   = size(this, varargin)
            %% SIZE overloads Matlab's size
            
            if (nargin > 1)
                sz = size(this.img_, varargin{:});
            else
                sz = size(this.img_);
            end
        end
        function this = sum(this, varargin)
            %% SUM overloads sum for INIfTI
            
            this.img = sum(this.img_, varargin{:});
        end  
        function fn   = tempFqfilename(this, varargin)
            ip = inputParser;
            addOptional(ip, 'fqfp', this.fqfileprefix, @ischar);
            parse(ip, varargin{:});
            
            fn = [myfileprefix(ip.Results.fqfp) this.imagingInfo.defaultFilesuffix];
            fn = tempFqfilename(fn);
        end
        function        view(this, varargin)
            this.viewExternally(this.viewer, varargin{:});
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
                            error('mlfourd:unsupportedNargin', 'AbstractInnerImagingFormat.zoom');
                    end
                case 8
                    rmin  = [ipr.xmin  ipr.ymin  ipr.zmin  ipr.tmin];
                    rsize = [ipr.xsize ipr.ysize ipr.zsize ipr.tsize];
                    this = this.zoom4D(rmin, rsize);
                otherwise
                    error('mlfourd:unsupportedNargin', 'AbstractInnerImagingFormat.zoom');
            end
            tag = this.tupleTag([ipr.xmin ipr.xsize ipr.ymin ipr.ysize ipr.zmin ipr.zsize ipr.tmin ipr.tsize]);
            this.fileprefix = sprintf('%s_zoom_%s', this.fileprefix, tag);
            this.addLog('AbstractInnerImagingFormat.zoom %s', tag);               
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
                    error('mlfourd:unsupportedNargin', 'AbstractInnerImagingFormat.zoomFac');
            end
        end
        
        %%
        
        function        addImgrec(this, varargin)
            %% ADDIMGREC
            %  @param lg is a textual log entry; it is entered into an internal logger which is a handle.
            
            if (isempty(this.imgrec))
                return
            end
            if (ischar(varargin{1}))
                this.imgrec.add(varargin{:});
                return
            end
            this.imgrec.add(ensureString(varargin{:}));
        end
        function        addLog(this, varargin)
            %% ADDLOG
            %  @param lg is a textual log entry; it is entered into an internal logger which is a handle.
            
            if (isempty(this.logger_))
                return
            end
            if (ischar(varargin{1}))
                this.addImgrec(varargin{:});
                this.logger_.add(varargin{:});
                return
            end
            this.logger_.add(ensureString(varargin{:}));
        end    
        function s    = asStruct(this) 
            info = this.imagingInfo; % updated with make_nii in AbstractInnerImagingFormat.ctor
            s = struct( ...
                'hdr', info.hdr, ...
                'filetype', info.filetype, ...
                'fileprefix', this.fqfilename, ...
                'machine', info.machine, ...
                'ext', info.ext, ...
                'img', this.img, ...
                'untouch', this.untouch);
        end
        function fn   = defaultFqfilename(this)
            fn = sprintf('instance_%s_%s%s', ...
                myclass(this), ...
                mydatetimestr(now), ...
                mlfourd.ImagingInfo.defaultFilesuffix);
        end
        function        deleteExisting(~, fn)
            deleteExisting(fn);
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
        function this = ensureFilesuffix(this)
            if (isempty(this.filesuffix))
                this.filesuffix = this.imagingInfo.defaultFilesuffix;
            end
        end
        function this = ensureImg(this)
            if (isempty(this.img))
                error('mlfourd:IOError:attemptToSaveEmptyObject', ...
                    'AbstractInnerImagingFormat.ensureImg:  %s', ...
                    'the request is incompatible with mlnifittools.save_[untouch]_nii');
            end
        end
        function this = ensureNoclobber(this)
            %% ENSURENOCLOBBER ensures that there is no clobbering.
            %  @throws mlfourd:IOError:noclobberPreventedSaving if this.noclobber and lexist(this.fqfilename).
            
            if (this.noclobber && lexist(this.fqfilename, 'file'))
                error('mlfourd:IOError:noclobberPreventedSaving', ...
                    'AbstractInnerImagingFormat.ensureNoclobber->%i but the file %s already exists; please check intentions', ...
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
        function fqfn = fqfileprefix_4dfp_hdr(this)
            fqfn = [this.fqfileprefix '.4dfp.hdr'];
        end
        function fqfn = fqfileprefix_4dfp_ifh(this)
            fqfn = [this.fqfileprefix '.4dfp.ifh'];
        end
        function fqfn = fqfileprefix_4dfp_img(this)
            fqfn = [this.fqfileprefix '.4dfp.img'];
        end
        function fqfn = fqfileprefix_4dfp_imgrec(this)
            fqfn = [this.fqfileprefix '.4dfp.img.rec'];
        end
        function fqfn = fqfileprefix_nii(this)
            fqfn = [this.fqfileprefix '.nii'];
        end
        function fqfn = fqfileprefix_nii_gz(this)
            fqfn = [this.fqfileprefix '.nii.gz'];
        end
        function fqfn = fqfileprefix_mgz(this)
            fqfn = [this.fqfileprefix '.mgz'];
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
        
 		function this = AbstractInnerImagingFormat(varargin)
 			%% ABSTRACTINNERIMAGINGFORMAT
 			%  @param imagingInfo is an mlfourd.ImagingInfo object and is required; it may be an aufbau object.
            
            import mlfourd.*;
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addOptional( ip, 'imagingInfo', ImagingInfo(this.defaultFqfilename), @(x) isa(x, 'mlfourd.ImagingInfo'));
            addParameter(ip, 'creationDate', datestr(now), @ischar);
            addParameter(ip, 'img', [], @isnumeric);
            addParameter(ip, 'label', '', @ischar);
            addParameter(ip, 'logger', [], @(x) isempty(x) || isa(x, 'mlpipeline.ILogger'));
            addParameter(ip, 'orient', '');
            addParameter(ip, 'originalType', class(this), @ischar);
            addParameter(ip, 'seriesNumber', nan, @isnumeric);
            addParameter(ip, 'separator', ';', @ischar);
            addParameter(ip, 'stack', {}, @iscell);
            addParameter(ip, 'viewer', mlfourd.Viewer);  
            addParameter(ip, 'circshiftK', 0, @isnumeric);                                       % see also mlfourd.ImagingInfo
            addParameter(ip, 'N', mlpipeline.ResourcesRegistry.instance().defaultN, @islogical); % 
            parse(ip, varargin{:});
            
            this.filesystemRegistry_ = mlio.FilesystemRegistry.instance;
            this.imagingInfo_ = copy(ip.Results.imagingInfo);
            %this.imagingInfo_.circshiftK = ip.Results.circshiftK;
            this.imagingInfo_.N = ip.Results.N;
            
            this.creationDate_ = ip.Results.creationDate;
            this.img_ = ip.Results.img;
            this.label_ = ip.Results.label;
            this.logger_ = ip.Results.logger;
            this.orient_ = ip.Results.orient;
            this.originalType_ = ip.Results.originalType;
            this.seriesNumber_ = ip.Results.seriesNumber;
            this.separator_ = ip.Results.separator;
            this.stack_ = ip.Results.stack;
            this.viewer_ = ip.Results.viewer;              

            if (lexist(this.fqfilename, 'file'))
                nii = mlniftitools.make_nii(ip.Results.img, this.mmppix, this.originator, this.datatype, this.descrip);
                this.imagingInfo_.hdr = nii.hdr;
                this.img_ = nii.img;
                this.imagingInfo_.untouch = nii.untouch;
            end
            if (isempty(this.stack_))
                this.stack_ = this.initialStack;
            end 
            
            if isa(ip.Results.logger, 'mlpipeline.ILogger')
                this.logger_ = ip.Results.logger;
            else
                this.logger_ = mlpipeline.Logger2(this.fqfileprefix, this);
            end
 		end
 	end 
    
    %% HIDDEN
    
    properties (Hidden) 
        creationDate_
        img_ = []
        label_
        logger_
        orient_ = ''
        originalType_
        seriesNumber_
        separator_ = ';'
        stack_   
        viewer_
    end
    
    %% PROTECTED
    
    properties (Access = protected)
        filesystemRegistry_
        imagingInfo_ % See also mlfourd.ImagingInfo        
    end
    
    methods (Static, Access = protected)
        function tag = tupleTag(tup)
            assert(isnumeric(tup));
            tag = mat2str(tup);
            tag = strrep(tag, ' ', '_');
            tag = strrep(tag, '.', 'p');
            tag = strrep(tag, '[', '');
            tag = strrep(tag, ']', '');
        end
    end
    
    methods (Access = protected)
        function ipr_ = adjustIpresultsForNegSize(this, ipr_)
            fields_ = circshift(fields(ipr_), -2, 1);
            for i = 2:2:length(fields_)
                if (ipr_.(fields_{i}) < 0)
                    ipr_.(fields_{i-1}) = 0;
                    ipr_.(fields_{i})   = size(this, i/2);
                end
            end
        end
        function d    = delimitDescrip(this, d)
            d = strtrim(d);
            if (length(d) > this.DESC_LEN_LIM)
                len2 = floor((this.DESC_LEN_LIM - 5)/2);
                d    = [d(1:len2) ' ... ' d(end-len2+1:end)]; 
            end
        end   
        function tf   = hasJimmyShenExtension(this)
            tf = lstrfind(this.filesuffix, {'.hdr' '.nii' '.nii.gz'});
        end
        function s    = initialStack(this)
            assert(isfield(this.imagingInfo_.hdr.hist, 'descrip'), ...
                'mlfourd:initializationOrderError', 'AbstractInnerImagingFormat.initialStack');
            s = {this.imagingInfo_.hdr.hist.descrip};
        end
        function hdr  = recalculateHdrHistOriginator(this, hdr)
            hdr = this.imagingInfo_.recalculateHdrHistOriginator(hdr);
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
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError:from_mlniftitools', ...
                    'AbstractInnerImagingFormat.save_nii could not save %s', this.fqfilename);
            end
            warning('on', 'MATLAB:structOnObject');
        end
        function        save_untouch_nii(this)
            if (lexist(this.fqfilename, 'file'))
                warning('mlfourd:IOError:for_mlniftitools', ...
                    ['AbstractInnerImagingFormat.save_untouch_nii:  ' ...
                     'the imaging object has untouch->%i, but fqfilename->%s already exists.  ' ...
                     'mlniftitools.save_untouch_nii doesn''t support saving in these circumstances.'], ...
                    this.untouch, this.fqfilename);
                return
            end            
            try
                assert(this.hasJimmyShenExtension, ...
                    'mlfourd:unsupportedInternalState', ...
                    ['AbstractInnerImagingFormat.save_untouch_nii ' ...
                     'received a request to save imaging using a filesuffix that isn''t supported.']);
                warning('off', 'MATLAB:structOnObject');
                mlniftitools.save_untouch_nii(struct(this), this.fqfilename);
                warning('on', 'MATLAB:structOnObject');
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError:from_mlniftitools', ...
                    'AbstractInnerImagingFormat.save_untouch_nii could not save %s', this.fqfilename);
            end
        end
        function        saveLogger(this)
            if (~isempty(this.logger_))
                this.logger_.fqfileprefix = this.fqfileprefix;
                this.logger_.save;
            end
        end   
        function [s,r] = viewExternally(this, app, varargin)
            s = []; r = '';
            try
                that = copy(this); % avoid side effects
                assert(0 == mlbash(sprintf('which %s', app)), ...
                    'mlfourd:RuntimeError', ...
                    'AbstractInnerImagingFormat.viewExternally could not find %s', app);

                that.fqfilename = that.tempFqfilename;
                that.filepath = tempdir;
                that.save; % always save temp; internal img likely has changed from img on filesystem
                v = mlfourd.Viewer(app);
                files = [that.fqfilename varargin];
                [s,r] = v.aview(files{:});
                that.deleteExisting(that.fqfilename);
            catch ME
                dispexcept(ME, 'mlfourd:RuntimeError', ...
                    'AbstractInnerImagingFormat.viewExternally called mlbash with %s; \nit returned r->%s', ...
                    app, r);
            end
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
                error('mlfourd:unsupportedArrayShape', 'AbstractInnerImagingFormat.zoom3D')
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
                error('mlfourd:unsupportedArrayShape', 'AbstractInnerImagingFormat.zoom3D')
            end
            this.img = im;
            this.imagingInfo_ = this.imagingInfo_.zoomed(rmin, rsize);
        end
        
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
            %that.filesystemRegistry_ = copy(this.filesystemRegistry_);
            that.imagingInfo_ = copy(this.imagingInfo_);
            %that.creationDate_ = copy(this.creationDate_);
            %that.img_ = copy(this.img_);
            %that.label_ = copy(this.label_);
            that.logger_ = copy(this.logger_);
            %that.orient_ = copy(this.orient_);
            %that.originalType_ = copy(this.originalType_);
            %that.seriesNumber_ = copy(this.seriesNumber_);
            %that.separator_ = copy(this.separator_);
            %that.stack_ = copy(this.stack_);
            %that.viewer_ = copy(this.viewer_);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

