classdef (Abstract) AbstractNIfTId < mlio.AbstractIO & mlfourd.JimmyShenInterface & mlfourd.INIfTI
	%% ABSTRACTNIFTID 
    %  See also:  mlfourd.AbstractNIfTIComponent
    %  Yet abstract:
    %      properties:  descrip, img, mmppix, pixdim
    %      methods:     forceDouble, forceSingle, isequal, isequaln, makeSimilar, clone
    
	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
    
    properties (Constant)
        DESC_LEN_LIM = 512; % limit to #char of desc, as desc may be used for the default fileprefix
        LOAD_UNTOUCHED = true
        OPTIMIZED_PRECISION = false
    end
    
    properties (Dependent)
        
        %% Instantiation of mlfourd.JimmyShenInterface to support struct arguments to NIfTId ctor     
        ext        %   Legacy variable for mlfourd.JimmyShenInterface
        filetype   %   0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr        %   Tip: to change the data type, set nii.hdr.dime.datatype and nii.hdr.dime.bitpix to:
                   %     0 None                     (Unknown bit per voxel)  % DT_NONE, DT_UNKNOWN 
                   %     1 Binary                        (ubit1, bitpix=1)   % DT_BINARY 
                   %     2 Unsigned char        (uchar or uint8, bitpix=8)   % DT_UINT8, NIFTI_TYPE_UINT8 
                   %     4 Signed short                  (int16, bitpix=16)  % DT_INT16, NIFTI_TYPE_INT16 
                   %     8 Signed integer                (int32, bitpix=32)  % DT_INT32, NIFTI_TYPE_INT32 
                   %    16 Floating point    (single or float32, bitpix=32)  % DT_FLOAT32, NIFTI_TYPE_FLOAT32 
                   %    32 Complex, 2 float32      (Use float32, bitpix=64)  % DT_COMPLEX64, NIFTI_TYPE_COMPLEX64
                   %    64 Double precision  (double or float64, bitpix=64)  % DT_FLOAT64, NIFTI_TYPE_FLOAT64 
                   %   128 uint RGB                  (Use uint8, bitpix=24)  % DT_RGB24, NIFTI_TYPE_RGB24 
                   %   256 Signed char           (schar or int8, bitpix=8)   % DT_INT8, NIFTI_TYPE_INT8 
                   %   511 Single RGB              (Use float32, bitpix=96)  % DT_RGB96, NIFTI_TYPE_RGB96
                   %   512 Unsigned short               (uint16, bitpix=16)  % DT_UNINT16, NIFTI_TYPE_UNINT16 
                   %   768 Unsigned integer             (uint32, bitpix=32)  % DT_UNINT32, NIFTI_TYPE_UNINT32 
                   %  1024 Signed long long              (int64, bitpix=64)  % DT_INT64, NIFTI_TYPE_INT64
                   %  1280 Unsigned long long           (uint64, bitpix=64)  % DT_UINT64, NIFTI_TYPE_UINT64 
                   %  1536 Long double, float128   (Unsupported, bitpix=128) % DT_FLOAT128, NIFTI_TYPE_FLOAT128 
                   %  1792 Complex128, 2 float64   (Use float64, bitpix=128) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128 
                   %  2048 Complex256, 2 float128  (Unsupported, bitpix=256) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128 
        img
        originalType
        untouch
        
        %% Instantiation of mlfourd.INIfTI        
        
        bitpix
        creationDate
        datatype
        descrip
        entropy
        hdxml
        label
        machine
        mmppix
        negentropy
        orient
        pixdim
        seriesNumber
        
        %% New for mlfourd.AbstractNIfTId
        
        separator % for descrip & label properties, not for filesystem behaviors
        stack
    end 

 	methods %% SET/GET 
        
        %% Instantiation of mlfourd.JimmyShenInterface
        
        function e    = get.ext(this)
            e = this.ext_;
        end
        function f    = get.filetype(this)
            f = this.filetype_;
        end
        function this = set.filetype(this, ft)
            switch (ft)
                case 0
                    this.filetype_ = ft;
                    this.filesuffix = '.hdr';
                    this.untouch_ = false;
                case 1
                    this.filetype_ = ft;
                    this.filesuffix = '.hdr';
                    this.untouch_ = false;
                case 2
                    this.filetype_ = ft;
                    this.filesuffix = '.nii.gz';
                    this.untouch_ = false;
                otherwise
                    error('mlfourd:unsupportedParamValue', 'AbstractNIfTId.set.filetype.ft->%g', ft);
            end
        end
        function h    = get.hdr(this)
            h = this.hdr_;
        end 
        function im   = get.img(this)
            im = this.img_;
        end        
        function this = set.img(this, im)
            %% SET.IMG sets new image state. 
            %  updates datatype, bitpix, dim
            
            import mlfourd.*;
            assert(isnumeric(im));
            this.img_                         = im;
            this                              = this.optimizePrecision;
            this.hdr_.dime.dim                = ones(1,8);
            this.hdr_.dime.dim(1)             = this.rank;
            this.hdr_.dime.dim(2:this.rank+1) = this.size;
            this.untouch_ = false;
            this.stack_ = [{dbstack} this.stack_];
        end
        function o    = get.originalType(this)
            o = this.originalType_;
        end
        function u    = get.untouch(this)
            u = logical(this.untouch_);
        end
        
        %% Instantiation of mlfourd.INIfTI  
        
        function bp   = get.bitpix(this) 
            %% BIPPIX returns a datatype code as described by the NIfTId specificaitons
            
            switch (class(this.img_))
                case {'uchar', 'uint8'};    bp = 8;
                case  'int16';              bp = 16;
                case  'int32';              bp = 32;
                case {'single', 'float32'}; bp = 32;
                case {'double', 'float64'}; bp = 64;
                case  'schar';              bp = 8;
                case  'uint16';             bp = 16;
                case  'uint32';             bp = 32;
                case  'int64';              bp = 64;
                case  'uint64';             bp = 64;
                otherwise
                    error('mlfourd:unknownSwitchCase', ...
                          'NIfTId.get.bitpix could not recognize the class(img)->%s', class(this.img_));
            end
        end
        function this = set.bitpix(this, bp) 
            assert(isnumeric(bp));
            if (bp >= 64)
                this = this.forceDouble; 
            else
                this = this.forceSingle; 
            end
            this.untouch_ = false;
        end
        function cdat = get.creationDate(this)
            cdat = this.creationDate_;
        end
        function dt   = get.datatype(this)
            %% DATATYPE returns a datatype code as described by the NIfTId specificaitons
            
            switch (class(this.img_))
                case {'uchar', 'uint8'};    dt = 2;
                case  'int16';              dt = 4;
                case  'int32';              dt = 8;
                case {'single', 'float32'}; dt = 16;
                case {'double', 'float64'}; dt = 64;
                case  'schar';              dt = 256;
                case  'uint16';             dt = 512;
                case  'uint32';             dt = 768;
                case  'int64';              dt = 1024;
                case  'uint64';             dt = 1280;
                otherwise
                    error('mlfourd:unknownSwitchCase', ...
                          'NIfTId.get.datatype could not recognize the class(img)->%s', class(this.img_));
            end
        end    
        function this = set.datatype(this, dt)
            if (ischar(dt))
                switch (strtrim(dt))
                    case {'uchar', 'uint8', 'int16',  'int32', 'int', 'single', 'float32', 'float', ...
                          'schar',          'uint16', 'uint32'}
                        this = this.forceSingle;
                    case {'int64', 'uint64' 'double', 'float64'}
                        this = this.forceDouble;
                    otherwise
                        error('mlfourd:unknownSwitchCase', ...
                              'NIfTId.set.datatype could not recognize dt->%s', strtrim(dt));
                end
            elseif (isnumeric(dt))
                if (dt < 64)
                    this = this.forceSingle;
                else
                    this = this.forceDouble;
                end
            else
                error('mlfourd:unsupportedDatatype', 'NIfTId.set.datatype does not support class(dt)->%s', class(dt));
            end            
            this.untouch_ = false;
        end
        function d    = get.descrip(this)
            d = this.hdr_.hist.descrip;
        end        
        function this = set.descrip(this, s)
            %% SET.DESCRIP
            %  do not add separators such as ";" or ","
            
            assert(ischar(s));
            this.hdr_.hist.descrip = this.adjustDescrip(s);
            this.untouch_ = false;
        end   
        function E    = get.entropy(this)
            if (isempty(this.img_))
                E = nan;
            else
                E = entropy(double(this.img_));
            end
        end   
        function x    = get.hdxml(this)
            %% GET.HDXML writes the xml file if this objects exists on disk
            
            if (exist(this.fqfilename, 'file'))
                [~, x] = mlbash(['fslhd -x ' this.fqfileprefix]);
                    x  = regexprep(x, 'sform_ijk matrix', 'sform_ijk_matrix');
            else
                x = '';
            end
            x = strtrim(x);
        end 
        function d    = get.label(this)
            if (isempty(this.label_))
                [~,this.label_] = fileparts(this.fileprefix);
            end
            d = this.label_;
        end     
        function this = set.label(this, s)
            assert(ischar(s));
            this.label_ = strtrim(s);            
            this.untouch_ = false;
        end
        function ma   = get.machine(this) %#ok<MANU>
            ma.arch = computer('arch');
            [~,ma.maxsize ,ma.endian] = computer;
        end
        function mpp  = get.mmppix(this)
            mpp = this.hdr_.dime.pixdim(2:this.rank+1);
        end        
        function this = set.mmppix(this, mpp)
            %% SET.MMPPIX sets voxel-time dimensions in mm, s.
            
            %assert(all(this.rank == length(mpp)));
            this.hdr_.dime.pixdim(2:length(mpp)+1) = mpp;
            this.untouch_ = false;
        end  
        function E    = get.negentropy(this)
            E = -this.entropy;
        end
        function o    = get.orient(this)
            if (exist(this.fqfilename, 'file'))
                [~, o] = mlbash(['fslorient -getorient ' this.fqfileprefix]);
            else
                o = '';
            end
            o = strtrim(o);
        end
        function pd   = get.pixdim(this)
            pd = this.mmppix;
        end        
        function this = set.pixdim(this, pd)
            %% SET.PIXDIM sets voxel-time dimensions in mm, s.
            
            this.mmppix = pd;
        end  
        function num  = get.seriesNumber(this)
            num = mlchoosers.FilenameFilters.getSeriesNumber(this.fileprefix);
        end
        
        %% New for mlfourd.AbstractNIfTId
        
        function s    = get.separator(this)
            s = this.separator_;
        end
        function this = set.separator(this, s)
            if (ischar(s))
                this.separator_ = s;
                this.untouch_ = false;
            end
        end
        function s    = get.stack(this)
            %% GET.STACK
            %  See also:  doc('dbstack')
            
            s = this.stack_;
        end
    end
       
    methods
        
        %% Instantiation of mlfourd.INIfTI  
        
        function ch   = char(this)
            ch = this.fqfilename;
        end 
        function d    = double(this)
            if (~isa(this.img_, 'double'))
                d = double(this.img_);
            else 
                d = this.img_;
            end
        end        
        function d    = duration(this)
            if (this.rank > 3)
                d = this.size(4)*this.mmppix(4);
            else
                d = 1;
            end
        end          
        function o    = ones(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', ['ones(' this.fileprefix ')'], @ischar);
            addOptional(p, 'fp',   ['ones(' this.fileprefix ')'], @ischar);
            parse(p, varargin{:});
            o = this.makeSimilar('img', ones(this.size), 'descrip', p.Results.desc, 'fileprefix', p.Results.fp);
        end    
        function rnk  = rank(this, img)
            %% RANK squeezes this.img before reporting rank of this.img or passed img
            
            if (nargin < 2)
                img = this.img_; end
            rnk = size(size(img),2);
        end
        function this = scrubNanInf(this, varargin)
            p = inputParser;
            addOptional(p, 'obj', this.img_, @isnumeric);
            parse(p, varargin{:});
            img__ = double(p.Results.obj);
            
            if (all(isfinite(img__(:))))
                return; end
            switch (this.rank(img__))
                case 1
                    img__ = this.scrub1D(img__);
                case 2
                    img__ = this.scrub2D(img__);
                case 3
                    img__ = this.scrub3D(img__);
                case 4
                    img__ = this.scrub4D(img__);
                otherwise
                    error('mlfourd:unsupportedParamValue', ...
                          'AbstractNIfTId.scrubNanInf:  this.rank(img) -> %i', this.rank(img__));
            end            
            this.img = img__;
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
        function N    = numel(this)
            N = numel(this.img);
        end
        function N    = prodSize(this)
            N = this.numel;
        end
        function z    = zeros(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', ['zeros(' this.fileprefix ')'], @ischar);
            addOptional(p, 'fp',   ['zeros_' this.fileprefix],     @ischar);
            parse(p, varargin{:});
            z = this.makeSimilar('img', zeros(this.size), 'descrip', p.Results.desc, 'fileprefix', p.Results.fp);
        end
        
        function this = prepend_fileprefix(this, s)
            assert(ischar(s));
            this.fileprefix = [strtrim(s) this.fileprefix];
            this.untouch_ = false;
        end        
        function this = append_fileprefix(this, s)
            assert(ischar(s));
            this.fileprefix = [this.fileprefix strtrim(s)];
            this.untouch_ = false;
        end   
        function this = append_descrip(this, s) 
            %% APPEND_DESCRIP
            %  @param s must not add separators such as ";" or ","
            
            assert(ischar(s));
            this.descrip = [this.descrip this.separator ' ' s];
            this.untouch_ = false;
        end  
        function this = prepend_descrip(this, s) 
            %% PREPEND_DESCRIP
            %  @param s must not add separators such as ";" or ","
            
            assert(ischar(s));
            this.descrip = [s this.separator ' ' this.descrip];
            this.untouch_ = false;
        end
        function this = prod(this, varargin)
            %% PROD overloads prod for INIfTI
            
            this.img        = prod(this.img_, varargin{:});
            this.fileprefix = [this.fileprefix '_prod'];
            this.descrip    = ['prod(' this.descrip ')'];
        end
        function this = sum(this, varargin)
            %% SUM overloads sum for INIfTI
            
            this.img        = sum(this.img_, varargin{:});
            this.fileprefix = [this.fileprefix '_sum'];
            this.descrip    = ['sum(' this.descrip ')'];
        end  
        
        function f3d  = fov(this)
            f3d = this.mmppix .* this.matrixsize;
        end   
        function        freeview(this, varargin)
            %% FREEVIEW
            %  Usage:  this.freeview([additional_filename, ...])
            
            this.launchExternalViewer('freeview', varargin{:});
        end
        function        fslview(this, varargin)
            %% FSLVIEW
            %  Usage:  this.fslview([additional_filename, ...])
            
            this.launchExternalViewer('fslview', varargin{:});
        end   
        function this = imclose(this, varargin)
            if (nargin < 2)
                this.img = imclose(this.img, strel('ball',2,4,0));
            else
                this.img = imclose(this.img, varargin{:});
            end
        end        
        function this = imdilate(this, varargin)
            if (nargin < 2)
                this.img = imdilate(this.img, strel('line',10,0));
            else
                this.img = imdilate(this.img, varargin{:});
            end
        end        
        function this = imerode(this, varargin)
            if (nargin < 2)
                this.img = imerode(this.img, strel('ball',2,4,0));
            else
                this.img = imerode(this.img, varargin{:});
            end
        end
        function this = imopen(this, varargin)
            if (nargin < 2)
                this.img = imopen(this.img, strel('ball',2,4,0));
            else
                this.img = imopen(this.img, varargin{:});
            end
        end
        function himg = imshow(this, slice, varargin)
            %% IMSHOW overloads imshow from Image Processing Toolbox,
            %         displays iamge in handle graphics figure
            %
            %  Usage:  
            %
            %     slice, integer or integer vector, is required.   Specifies dimensions of 
            %     this.img > 2.
            %
            %     imshow(slice) displays the grayscale this.img.
            %
            %     imshow(slice,[LOW HIGH]) displays the grayscale this.img, specifying the display
            %     range for I in [LOW HIGH]. The value LOW (and any value less than LOW)
            %     displays as black, the value HIGH (and any value greater than HIGH) displays
            %     as white. Values in between are displayed as intermediate shades of gray,
            %     using the default number of gray levels. If you use an empty matrix ([]) for
            %     [LOW HIGH], imshow uses [min(I(:)) max(I(:))]; that is, the minimum value in
            %     I is displayed as black, and the maximum value is displayed as white.
            %  
            %     imshow(slice,RGB) displays the truecolor image RGB.
            %  
            %     imshow(slice,BW) displays the binary image BW. imshow displays pixels with the
            %     value 0 (zero) as black and pixels with the value 1 as white.
            %  
            %     imshow(slice,X,MAP) displays the indexed image X with the colormap MAP.
            %  
            %     imshow(slice,FILENAME) displays the image stored in the graphics file FILENAME.
            %     The file must contain an image that can be read by IMREAD or
            %     DICOMREAD. imshow calls IMREAD or DICOMREAD to read the image from the file,
            %     but does not store the image data in the MATLAB workspace. If the file
            %     contains multiple images, the first one will be displayed. The file must be
            %     in the current directory or on the MATLAB path.
            %  
            %     HIMAGE = imshow(...) returns the handle to the image object created by
            %     imshow.
            %  
            %     imshow(...,PARAM1,VAL1,PARAM2,VAL2,...) displays the image, specifying
            %     parameters and corresponding values that control various aspects of the
            %     image display. Parameter names can be abbreviated, and case does not matter.
            %
            %  cf. imshow
            
            assert(logical(exist('slice', 'var')), 'imshow(slice) displays the grayscale of this.img');
            switch (length(slice))
                case 1
                    himg = imshow(flip4d(this.img_(:,:,slice), 'xt'), varargin{:});
                case 2
                    himg = imshow(flip4d(this.img_(:,:,slice(1),slice(2)), 'xt'), varargin{:});
                otherwise
                    paramError(this, 'slice #', num2str(slice));
            end
        end
        function himg = imtool(this, slice, varargin)
            %% IMTOOL overloads imtool from the Image Processing Toolbox.
            %     displays iamge in handle graphics figure
            %
            %  Usage:  
            %
            %     slice, integer or integer vector, is required.   Specifies dimensions of 
            %     this.img > 2.
            %
            %     imtool opens a new Image Tool in an empty state. Use the File menu options
            %     "Open..." or "Import From Workspace..." to choose an image for display.
            %  
            %     imtool(slice) displays the grayscale this.img.
            %  
            %     imtool(slice,[LOW HIGH]) displays the grayscale this.img, specifying the display
            %     range for I in [LOW HIGH]. The value LOW (and any value less than LOW)
            %     displays as black, the value HIGH (and any value greater than HIGH) displays
            %     as white. Values in between are displayed as intermediate shades of gray,
            %     using the default number of gray levels. If you use an empty matrix ([]) for
            %     [LOW HIGH], imtool uses [min(I(:)) max(I(:))]; the minimum value in I
            %     displays as black, and the maximum value displays as white.
            %  
            %     imtool(slice,RGB) displays the truecolor image RGB.
            %  
            %     imtool(slice,BW) displays the binary image BW. Values of 0 display as black, and
            %     values of 1 display as white.
            %  
            %     imtool(slice,X,MAP) displays the indexed image X with colormap MAP.
            %  
            %     imtool(slice,FILENAME) displays the image contained in the graphics file FILENAME.
            %     The file must contain an image that can be read by IMREAD or DICOMREAD or a
            %     reduced resolution dataset (R-Set) created by RSETWRITE. If the file
            %     contains multiple images, the first one will be displayed. The file must
            %     be in the current directory or on the MATLAB path.
            %  
            %     HFIGURE = imtool(slice,...) returns a handle HFIGURE to the figure created by
            %     imtool. CLOSE(HFIGURE) closes the Image Tool.
            %  
            %     imtool CLOSE ALL closes all instances of the Image Tool.
            %  
            %     imtool(slice,...,PARAM1,VAL1,PARAM2,VAL2,...) displays the image, specifying
            %     parameters and corresponding values that control various aspects of the
            %     image display. Parameter names can be abbreviated, and case does not matter.
            %
            %  cf. imtool
            
            assert(logical(exist('slice', 'var')));
            switch (length(slice))
                case 1
                    himg = imtool(flip4d(this.img_(:,:,slice), 'xt'), varargin{:});
                case 2
                    himg = imtool(flip4d(this.img_(:,:,slice(1),slice(2)), 'xt'), varargin{:});
                otherwise
                    paramError(this, 'slice #', num2str(slice));
            end
        end
        function m3d  = matrixsize(this)
            m3d = [this.size(1) this.size(2) this.size(3)];
        end
        function im   = mlimage(this)
            %% MLIMAGE returns this.img in a form suitable for matlab's image processing toolbox
            %          whivh expects rgb data as the 3rd dimension.  Does not change state.
            
            sz = this.size;
            im = reshape(this.img_, [sz(1) sz(2) 1 sz(3)]);
        end
        function h    = montage(this, varargin)
            %% MONTAGE overloads matlab's montage;
            %  cf.  web([docroot '/toolbox/images/ref/montage.html#bq5sla5'])
            %  e.g.  montage('Size', [nrows ncols] ,'Indices',1:4, 'DisplayRange', [low high]);
            %                          [2, NaN]
            
            h    = montage(flip4d(this.mlimage, 'xt'), varargin{:});
        end
    end
    
    %% PROTECTED 

    properties (Access = 'protected')
        creationDate_
        ext_ = []
        filetype_ = 2
        hdr_
        img_ = []
        label_
        originalType_
        separator_ = ';'
        stack_
        untouch_ = true        
    end      
    
    methods (Static, Access = 'protected')
        function im = ensureDble(im, varargin)
            %% ENSUREDBLE tries to return a double-precision array for the passed object
            %  Usage: obj1 = mlfourd.AbstractNIfTId.ensureDble(obj, nosqz)
            %         ^ is guaranteed to be double
            %           obj1, obj may be char, NIfTId, struct or numeric
            %                                                       ^ boolean:  don't squeeze out singleton dims
            
            im = double( ...
                mlfourd.AbstractNIfTId.switchableSqueeze(im, varargin{:}));
        end 
        function im = ensureSing(im, varargin)
            %% ENSURESING tries to return a single-precision array for the passed object
            %  Usage: obj1 = mlfourd.AbstractNIfTId.ensureSing(obj, nosqz)
            %         ^ is guaranteed to be single (all overloaded single(...) calls applied, else error)
            %           obj1, obj may be char, NIfTId, struct or numeric
            %                                                       ^ don't squeeze out singleton dims

            im = single( ...
                mlfourd.AbstractNIfTId.switchableSqueeze(im, varargin{:}));
        end 
        function im = ensureInt16(im, varargin)
            im = int16( ...
                mlfourd.AbstractNIfTId.switchableSqueeze(im, varargin{:}));
        end
        function im = ensureInt32(im, varargin)
            im = int32( ...
                mlfourd.AbstractNIfTId.switchableSqueeze(im, varargin{:}));
        end
        function im = ensureUint8(im, varargin)
            im = uint8( ...
                mlfourd.AbstractNIfTId.switchableSqueeze(im, varargin{:}));
        end
        function im = switchableSqueeze(im, tf)
            assert(isnumeric(im));
            if (~exist('tf', 'var')); tf  = true; end
            if (tf); im = squeeze(im); end
        end
    end
    
    methods (Access = 'protected')
        function this = AbstractNIfTId
            
            %% from Trio mpr & ep2d read by mlniftitools.load_untouch_nii
            
            this.fileprefix = ['instance_' strrep(class(this), '.', '_')];
            this.filesuffix = this.FILETYPE_EXT;
            hk   = struct( ...
                'sizeof_hdr', 348, ...
                'data_type', '', ...
                'db_name', '', ...
                'extents', 0, ...
                'session_error', 0, ...
                'regular', 'r', ...
                'dim_info', 0);
            dime = struct( ...
                'dim', [4 0 0 0 0 1 1 1], ...
                'intent_p1', 0, ... 
                'intent_p2', 0, ... 
                'intent_p3', 0, ... 
                'intent_code', 0, ... 
                'datatype', 64, ... 
                'bitpix', 64, ... 
                'slice_start', 0, ... 
                'pixdim', [1 1 1 1 1 0 0 0], ... 
                'vox_offset', 352, ... 
                'scl_slope', 1, ... 
                'scl_inter', 0, ... 
                'slice_end', 0, ... 
                'slice_code', 0, ... 
                'xyzt_units', 10, ... 
                'cal_max', 0, ... 
                'cal_min', 0, ... 
                'slice_duration', 0, ... 
                'toffset', 0, ... 
                'glmax', 1621, ... 
                'glmin', 0);
            hist = struct( ...
                'descrip', sprintf('instance of %s', class(this)), ...
                'aux_file', '', ...
                'qform_code', 1, ...
                'sform_code', 1, ...
                'quatern_b', 0, ...
                'quatern_c', 0, ...
                'quatern_d', 0, ...
                'qoffset_x', 0, ...
                'qoffset_y', 0, ...
                'qoffset_z', 0, ...
                'srow_x', [1 0 0 0], ...
                'srow_y', [0 1 0 0], ...
                'srow_z', [0 0 1 0], ...
                'intent_name', '', ...
                'magic', 'n+1');
            this.hdr_ = struct('hk', hk, 'dime', dime, 'hist', hist);
            
            %% etc.
            
            this.creationDate_ = datestr(now);
            this.originalType_ = class(this);
            this.stack_ = {this.descrip};
        end
        function this = optimizePrecision(this)
            if (~this.OPTIMIZED_PRECISION); return; end
            try
                import mlfourd.*;
                if (islogical(this.img_))
                    this.img_ = NIfTId.ensureUint8(this.img_);                    
                    this.hdr_.dime.datatype = 2;
                    this.hdr_.dime.bitpix   = 8;
                    return
                end
                if (dipmax(this.img_) < realmax('single') && dipmin(this.img_) > realmin('single'))
                    this.img_ = NIfTId.ensureSing(this.img_);
                    this.hdr_.dime.datatype = 16;
                    this.hdr_.dime.bitpix   = 32;
                    return
                end                              
                this.img_ = NIfTId.ensureDble(this.img_);
                this.hdr_.dime.datatype = 64;
                this.hdr_.dime.bitpix   = 64;
            catch ME
                warning(ME);
            end
        end
    end 
    
    %% PRIVATE
    
    methods (Access = 'private')
        function d  = adjustDescrip(this, d)
            d = strtrim(d);
            if (length(d) > this.DESC_LEN_LIM)
                len2 = floor((this.DESC_LEN_LIM - 5)/2);
                d    = [d(1:len2) ' ... ' d(end-len2+1:end)]; 
            end
        end
        function      launchExternalViewer(this, app, varargin)
            assert(ischar(app));
            try
                fqfn = this.tempFqfilename;
                this.saveas(fqfn);
                s = 0; r = '';
                if (~isempty(varargin))
                    [s,r] = mlbash(sprintf('%s %s %s', app, fqfn, cell2str(varargin, 'AsRow', true)));
                else
                    [s,r] = mlbash(sprintf('%s %s',    app, fqfn));
                end
                deleteExisting(fqfn);
            catch ME
                handexcept(ME, 'mlfourd:viewerError', 'AbstractNIfTId.launchExternalViewer:  s->%i, r->%s', s, r);
            end
        end
        function im = scrub1D(this, im)
            assert(isnumeric(im));
            for x = 1:this.size(1)
                if (~isfinite(im(x)))
                    im(x) = 0; end
            end
        end
        function im = scrub2D(this, im)
            assert(isnumeric(im));
            for y = 1:this.size(2)
                for x = 1:this.size(1)
                    if (~isfinite(im(x,y)))
                        im(x,y) = 0; end
                end
            end
        end
        function im = scrub3D(this, im)
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
        function im = scrub4D(this, im)
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
        function fn = tempFqfilename(this)
            fn = sprintf('%s_%s%s', this.fqfileprefix, datestr(now, 30), this.FILETYPE_EXT);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
    
 end 
