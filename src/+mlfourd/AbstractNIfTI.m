classdef AbstractNIfTI < mlio.AbstractIO & mlfourd.NIfTIInterface
	%% ABSTRACTNIFTI 
    %  Yet abstract:
    %      properties:  descrip, img, mmppix, pixdim
    %      methods:     forceDouble, forceSingle, makeSimilar, clone
    
	%  Version $Revision: 2627 $ was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ by $Author: jjlee $  
 	%  and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AbstractNIfTI.m $ 
 	%  Developed on Matlab 7.11.0.584 (R2010b) 
 	%  $Id: AbstractNIfTI.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    properties (Constant)
        GUNZIP_FOLDER        = '.gunzip';
        SUPPORTED_EXTENSIONS = {'.nii.gz' '.nii'};
        DESC_LEN_LIM         = 128; % limit to #char of desc, as desc may be used for the default fileprefix
    end
    
    properties (Dependent)
        bitpix
        creationDate
        datatype
        entropy
        hdxml
        label
        machine
        negentropy
        orient
        separator   % for comments, not filesystem
        seriesNumber
        squareWidth % used by imerode, imdilate, etc.
    end 

 	methods %% setters/getters  
        function this = set.bitpix(this, bp) 
            assert(isnumeric(bp));
            if (bp >= 64)
                this = this.forceDouble; 
            else
                this = this.forceSingle; 
            end
        end   
        function bp   = get.bitpix(this) 
            %% BIPPIX returns a datatype code as described by the NIfTI specificaitons
            
            switch (class(this.img))
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
                    throw(MException('mlfourd:UnknownParamType', ...
                        ['NIfTI.get.bitpix:  class(img) -> ' class(this.img)]));
            end
        end      
        function cdat = get.creationDate(this)
            cdat = this.creationDate_;
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
                        throw(MException('mlfourd:UnknownParamType', ...
                            ['NIfTI.set.datatype:  class(img) -> ' class(this.img)]));
                end
            elseif (isnumeric(dt))
                if (dt < 64)
                    this = this.forceSingle;
                else
                    this = this.forceDouble;
                end
            else
                paramError('UnsupportedType for NIfTI.set.datatype.dt', class(dt));
            end
        end  
        function dt   = get.datatype(this)
            %% DATATYPE returns a datatype code as described by the NIfTI specificaitons
            
            switch (class(this.img))
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
                    throw(MException('mlfourd:UnknownParamType', ...
                        ['NIfTI.get.datatype:  class(img) -> ' class(this.img)]));
            end
        end             
        function E    = get.entropy(this)
            if (isempty(this.img))
                E = nan;
            else
                E = entropy(double(this.img));
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
            
        end
        function this = set.label(this, s)
            assert(ischar(s));
            this.label_ = strtrim(s);
            this.untouch = 0;
        end   
        function d    = get.label(this)
            if (isempty(this.label_))
                [~,this.label_] = fileparts(this.fileprefix);
            end
            d = this.label_;
        end              
        function ma   = get.machine(this) %#ok<MANU>
            [~,~,ma] = computer;
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
        end
        function s    = get.separator(this)
            s = this.separator_;
        end
        function num  = get.seriesNumber(this)
            num = mlchoosers.FilenameFilters.getSeriesNumber(this.fileprefix);
        end 
        function sw   = get.squareWidth(this)
            sw = this.squareWidth_;
        end
    end
       
    methods
        
        %% Implemented mlfourd.NIfTIInterface methods
        
        function this = imclose(this, varargin)
            if (nargin < 2)
                this.img = imclose(this.img, strel('square',this.squareWidth));
            else
                this.img = imclose(this.img, varargin{:});
            end
        end        
        function this = imdilate(this, varargin)
            if (nargin < 2)
                this.img = imdilate(this.img, strel('square',this.squareWidth));
            else
                this.img = imdilate(this.img, varargin{:});
            end
        end        
        function this = imerode(this, varargin)
            if (nargin < 2)
                this.img = imerode(this.img, strel('square',this.squareWidth));
            else
                this.img = imerode(this.img, varargin{:});
            end
        end
        function this = imopen(this, varargin)
            if (nargin < 2)
                this.img = imopen(this.img, strel('square',this.squareWidth));
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
                    himg = imshow(flip4d(this.img(:,:,slice), 'xt'), varargin{:});
                case 2
                    himg = imshow(flip4d(this.img(:,:,slice(1),slice(2)), 'xt'), varargin{:});
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
                    himg = imtool(flip4d(this.img(:,:,slice), 'xt'), varargin{:});
                case 2
                    himg = imtool(flip4d(this.img(:,:,slice(1),slice(2)), 'xt'), varargin{:});
                otherwise
                    paramError(this, 'slice #', num2str(slice));
            end
        end % imtool   
        function im   = mlimage(this)
            %% MLIMAGE returns this.img in a form suitable for matlab's image processing toolbox
            %          whivh expects rgb data as the 3rd dimension.  Does not change state.
            
            sz = this.size;
            im = reshape(this.img, [sz(1) sz(2) 1 sz(3)]);
        end % mlimage        
        function h    = montage(this, varargin)
            %% MONTAGE overloads matlab's montage;
            %  cf.  web([docroot '/toolbox/images/ref/montage.html#bq5sla5'])
            %  e.g.  montage('Size', [nrows ncols] ,'Indices',1:4, 'DisplayRange', [low high]);
            %                          [2, NaN]
            
            h    = montage(flip4d(this.mlimage, 'xt'), varargin{:});
        end
        function m3d  = matrixsize(this)
            m3d = [this.size(1) this.size(2) this.size(3)];
        end
        function f3d  = fov(this)
            f3d = this.mmppix .* this.matrixsize;
        end       
               
        function ch   = char(this)
            ch = this.fqfilename;
        end 
        function d    = double(this)
            d = double(this.img);
        end        
        function d    = duration(this)
            if (this.rank > 3)
                d = this.size(4);
            else
                d = 1;
            end
        end          
        function o    = ones(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', ['ones(' this.fileprefix ')'], @ischar);
            addOptional(p, 'fp',   ['ones_' this.fileprefix],     @ischar);
            parse(p, varargin{:});
            o = this.makeSimilar(ones(this.size), p.Results.desc, p.Results.fp);
        end
        function M    = prod(this)
            
            %% PROD overloads prod for NIfTI
            Mimg  = prod(this.img);
            M     = this.makeSimilar(Mimg, ...
                     '', ['(prod)' this.fileprefix]);
            M.descrip = [  'prod(' M.descrip ')'];
        end
        function ps   = prodSize(this)
            ps = prod(this.matrixsize);
        end        
        function rnk  = rank(this, img)
            %% RANK squeezes this.img before reporting rank of this.img or passed img
            
            if (nargin < 2)
                img = this.img; end
            rnk = size(size(squeeze(double(img))),2);
        end
        function this = scrubNanInf(this, varargin)
            p = inputParser;
            addOptional(p, 'obj', this.img, @isnumeric);
            parse(p, varargin{:});
            img = double(p.Results.obj);
            
            if (all(isfinite(img(:))))
                return; end
            switch (this.rank(img))
                case 1
                    img = this.scrub1D(img);
                case 2
                    img = this.scrub2D(img);
                case 3
                    img = this.scrub3D(img);
                case 4
                    img = this.scrub4D(img);
                otherwise
                    error('mlfourd:unsupportedParamValue', ...
                          'AbstractNIfTI.scrubNanInf:  this.rank(img) -> %i', this.rank(img));
            end            
            this.img = img;
        end
        function s    = single(this)
            s = single(this.img);
        end   
        function sz   = size(this, varargin)
            %% SIZE overloads Matlab's size
            
            if (nargin > 1)
                sz = size(this.img, varargin{:});
            else
                sz = size(this.img);
            end
        end
        function M    = sum(this)
            %% SUM overloads sum for NIfTI
            
            Mimg  = sum(this.img);
            M     = this.makeSimilar(Mimg, ...
                     '', ['(sum)' this.fileprefix]);
            M.descrip =  [ 'sum(' M.descrip ')'];
        end   
        function z    = zeros(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', ['zeros(' this.fileprefix ')'], @ischar);
            addOptional(p, 'fp',   ['zeros_' this.fileprefix],     @ischar);
            parse(p, varargin{:});
            z = this.makeSimilar(zeros(this.size), p.Results.desc, p.Results.fp);
        end
        
        function this = prepend_fileprefix(this, s)
            assert(ischar(s));
            this.fileprefix = [strtrim(s) this.fileprefix];
        end        
        function this = append_fileprefix(this, s)
            assert(ischar(s));
            this.fileprefix = [this.fileprefix strtrim(s)];
        end   
        function this = prepend_descrip(this, s) 
            %% PREPEND_DESCRIP
            %  do not add separators such as ";" or ","
            
            assert(ischar(s));
            this.descrip = [s this.separator this.descrip];
        end
        function this = append_descrip(this, s) 
            %% APPEND_DESCRIP
            %  do not add separators such as ";" or ","
            
            assert(ischar(s));
            this.descrip = [this.descrip this.separator s];
        end   
              
        %% Implemented mlanalysis.NumericalInterface methods
        
        function c    = bsxfun(this, pfun, b)
            %% BSXFUN overloads bsxfun for NIfTI
            %  obj = mlfourd.NIfTI
            %  c   = obj.bsxfun(fun_handle, b)
            %  ^                            ^ NIfTI objects or numeric
            
            this.separator_ = '';
            funname = func2str(pfun);
            if (isa(b, 'mlfourd.NIfTIInterface'))
                cimg = bsxfun(pfun, double(this.img), double(b.img));
                c    = this.makeSimilar(cimg, ...
                      ['bsxfun(' funname ',' this.fileprefix ',' b.fileprefix ')'], ...
                      ['bsxfun(' funname ',' this.fileprefix ',' b.fileprefix ')']);
            elseif (isnumeric(b))
                cimg  = bsxfun(pfun, double(this.img), double(b));
                bname = sprintf('%s%dx%dx%d', class(b), size(b));
                c     = this.makeSimilar(cimg, ...
                      ['bsxfun(' funname ',' this.fileprefix ',' strrep(bname, '.', '_') ')'], ...
                      ['bsxfun(' funname ',' this.fileprefix ',' strrep(bname, '.', '_') ')']);
            else
                error('mlfourd:UnsupportedParamType', ...
                     ['NIfTI.bsxfun:  fun->' funname ' b->' class(b)]);
            end
        end
        function c    = plus(this, b)
            if (1 == numel(b) && isnumeric(b))
                this.img = this.img + b;
                c = this;
                c.fileprefix = [this.fileprefix '(+)' num2str(b)];
            else
                c = this.bsxfun(@plus, b);                
                c.fileprefix = [this.fileprefix '(+)' b.fileprefix];
            end
        end
        function c    = minus(this, b)
            if (1 == numel(b) && isnumeric(b))
                this.img = this.img - b;
                c = this;
                c.fileprefix = [this.fileprefix '(-)' num2str(b)];
            else
                c = this.bsxfun(@minus, b);
                c.fileprefix = [this.fileprefix '(-)' b.fileprefix];
            end
        end
        function c    = mtimes(a, b)
            if (isa(a, 'mlfourd.NIfTIInterface'))
                this = a; 
            end
            if (isa(b, 'mlfourd.NIfTIInterface'))
                if (~isa(a, 'mlfourd.NIfTIInterface'))
                    this = b; b = a;
                end
            end
            if (1 == numel(b) && isnumeric(b))
                this.img = this.img .* b;
                c = this;
                c.fileprefix = [this.fileprefix '(x)' num2str(b)];
            else
                c = this.bsxfun(@mtimes, b);
                c.fileprefix = [this.fileprefix '(x)' b.fileprefix];
            end
        end
        function c    = times(this, b)
            if (1 == numel(b) && isnumeric(b))
                this.img = this.img * b;
                c = this;
                c.fileprefix = [this.fileprefix '(x)' num2str(b)];
            else
                c = this.bsxfun(@times, b);
                c.fileprefix = [this.fileprefix '(x)' b.fileprefix];
            end
        end
        function c    = rdivide(this, b)
            if (1 == numel(b) && isnumeric(b))
                this.img = this.img ./ b;
                c = this;
                c.fileprefix = [this.fileprefix '(rdiv)' num2str(b)];
            else
                c = this.bsxfun(@rdivide, b);
                c.fileprefix = [this.fileprefix '(rdiv)' b.fileprefix];
            end
            c = this.scrubNanInf;
        end
        function c    = ldivide(this, b)
            if (1 == numel(b) && isnumeric(b))
                this.img = b ./ this.img;
                c = this;
                c.fileprefix = [num2str(b) '(ldiv)' this.fileprefix];
            else
                c = this.bsxfun(@ldivide, b);
                c.fileprefix = [b.fileprefix '(ldiv)' this.fileprefix];
            end            
            c = this.scrubNanInf;
        end
        function c    = power(this, b)
            if (1 == numel(b) && isnumeric(b))
                this.img = this.img .^ b;
                c = this;
                c.fileprefix = [this.fileprefix '(^)' num2str(b)];
            else
                c = this.bsxfun(@power, b);
                c.fileprefix = [this.fileprefix '(^)' b.fileprefix];
            end
        end
        function c    = max(this, b)
            b = this.ensureSpannedNIfTI(b);
            c = this.bsxfun(@max, b);
            c.fileprefix = [this.fileprefix '(max)' b.fileprefix];
        end
        function c    = min(this, b)
            b = this.ensureSpannedNIfTI(b);
            c = this.bsxfun(@min, b);
            c.fileprefix = [this.fileprefix '(min)' b.fileprefix];
        end
        function c    = rem(this, b)
            b = this.ensureSpannedNIfTI(b);
            c = this.bsxfun(@rem, b);
            c.fileprefix = [this.fileprefix '(rem)' b.fileprefix];
        end
        function c    = mod(this, b)
            b = this.ensureSpannedNIfTI(b);
            c = this.bsxfun(@mod, b);
            c.fileprefix = [this.fileprefix '(mod)' b.fileprefix];
        end
        
        function c    = eq(this, b)
            c = this.isequal(b);
            c.fileprefix = [this.fileprefix '(==)' b.fileprefix];
        end
        function c    = ne(this, b)
            c = ~this.eq(b);
            c.fileprefix = [this.fileprefix '(~=)' b.fileprefix];
        end
        function c    = lt(this, b)
            b = this.ensureSpannedNIfTI(b);
            c = this.bsxfun(@lt, b);
            c.fileprefix = [this.fileprefix '(<)' b.fileprefix];
        end
        function c    = le(this, b)
            b = this.ensureSpannedNIfTI(b);
            c = this.bsxfun(@le, b);
            c.fileprefix = [this.fileprefix '(<=)' b.fileprefix];
        end
        function c    = gt(this, b)
            b = this.ensureSpannedNIfTI(b);
            c = this.bsxfun(@gt, b);
            c.fileprefix = [this.fileprefix '(>)' b.fileprefix];
        end
        function c    = ge(this, b)
            b = this.ensureSpannedNIfTI(b);
            c = this.bsxfun(@ge, b);
            c.fileprefix = [this.fileprefix '(>=)' b.fileprefix];
        end
        function this = and(this, b)
            assert(isa(b, 'mlfourd.NIfTIInterface'));
            this.img = this.img & b.img;
            this.fileprefix = [this.fileprefix '(and)' b.fileprefix];
            this.descrip    = [this.descrip    ' and ' b.fileprefix];
        end
        function this = or(this, b)
            assert(isa(b, 'mlfourd.NIfTIInterface'));
            this.img = this.img | b.img;
            this.fileprefix = [this.fileprefix '(or)' b.fileprefix];
            this.descrip    = [this.descrip    ' or ' b.fileprefix];
        end
        function this = xor(this, b)
            assert(isa(b, 'mlfourd.NIfTIInterface'));
            this.img = xor(this.img, b.img);
            this.fileprefix = [this.fileprefix '(xor)' b.fileprefix];
            this.descrip    = [this.descrip    ' xor ' b.fileprefix];
        end
        function this = not(this)
            this.img = not(this.img);
            this.fileprefix = ['(~)' this.fileprefix];
            this.descrip    = [ '~'  this.descrip];
        end
        
        function this = norm(this)
            for z = 1:this.size(3)
                this.img(:,:,z) = norm(squeeze(this.img(:,:,z)), 2);
            end
            this.fileprefix = ['(norm)' this.fileprefix];
            this.descrip    = [ 'norm '  this.descrip];
        end
        function this = abs(this)
            this.img = abs(this.img);
            this.fileprefix = ['(abs)' this.fileprefix];
            this.descrip    = [ 'abs '  this.descrip];
        end
        function c    = atan2(this, b)
            b = this.ensureSpannedNIfTI(b);
            c = this.bsxfun(@atan2, b);
            c.fileprefix = [this.fileprefix '(atan2)' b.fileprefix];
        end
        function c    = hypot(this, b)
            b = this.ensureSpannedNIfTI(b);
            c = this.bsxfun(@hypot, b);
            c.fileprefix = [this.fileprefix '(hypot)' b.fileprefix];
        end
        function M    = diff(this)
            
            %% DIFF overloads diff for NIfTI
            Mimg  = diff(this.img);
            M     = this.makeSimilar(Mimg, ...
                     '', ['(diff)' this.fileprefix]);
            M.descrip = [  'diff(' M.descrip ')'];
        end       
        
        %% Implemented mlanalysis.DipInterface methods
        
        function di   = dip_image(this)
            di = dip_image(this.img);
        end    
        function h    = dipshow(this, varargin)
            %% DIPSHOW overrides diplib's dipshow
            %  Usage:  nii.dipshow([range, colmap, ...])
            %                       ^ 'lin', 'percentile', [0 130]
            %                              ^'grey', 'zerobased', 'jet'
            %  cf. help dipshow
            
            d      = flip4d(dip_image(this.img), 'yt');                          
            hreqst = 1;
            h      = dipfig(hreqst, 'd');
            if (1 == nargin) 
                dipshow(d, 'lin', colormap('grey'));
            else
                dipshow(d, varargin{:});
            end
        end 
        function mxi  = dipmax(this)
            mxi = dipmax(this.img);
        end        
        function m    = dipmean(this)
            m = dipmean(this.img);
        end        
        function m    = dipmedian(this)
            m = dipmedian(this.img);
        end        
        function mni  = dipmin(this)
            mni = dipmin(this.img);
        end        
        function prd  = dipprod(this)
            prd = dipprod(this.img);
        end        
        function s    = dipstd(this)
            s = dipstd(this.img);
        end                
        function sm   = dipsum(this)
            sm = dipsum(this.img);
        end              
 	end 
    
    %% PROTECTED 

    properties (Access = 'protected')
        label_
        separator_   = ';';
        squareWidth_ = 2.5;
    end
    
    methods (Static, Access = 'protected')
        function fns = gunzip(fqfn)
            gdir = fullfile(fileparts(fqfn), mlfourd.NIfTI.GUNZIP_FOLDER);
            ensureFolderExists(gdir);
            fns = gunzip(fqfn, gdir); 
            if (iscell(fns))
                if (length(fns) > 1)
                    error('mlfourd:GunzipError', 'NIfTI.gunzip was not expecting archive contents:   %s', cell2str(fns)); 
                end
                fns = fns{1}; 
            end
        end
        function       cleanDotGunzip(filenames)
            import mlfourd.*;
            if (~lstrfind(filenames, NIfTI.GUNZIP_FOLDER))
                warning('mlfourd:IOErr', 'NIfTI.cleanDotGunzip was called for files not in a %s directory:  %s', ...
                    NIfTI.GUNZIP_FOLDER, cell2str(filenames)); 
            end
            try
                delete(filenames); 
            catch ME
                handexcept(ME); 
            end
        end
        function str = cleanDotnii(str)
            idx = regexp(str, '\.nii_');
            if (~isempty(idx))
                str0 = str;
                for x = 1:length(idx)
                    str = [str(1:idx(x)-1) '_' str(idx(x)+5:end)];
                end
                try
                    movefile(str0, str, 'f');
                catch ME
                    handexcept(ME);
                end
            end
        end
        function obj = ensureDble(obj, varargin)
            %% ENSUREDBLE tries to return a double-precision array for the passed object
            %  Usage: obj1 = mlfourd.AbstractNIfTI.ensureDble(obj, nosqz)
            %         ^ is guaranteed to be double
            %           obj1, obj may be char, NIfTI, struct or numeric
            %                                              ^ boolean:  don't squeeze out singleton dims
            
            obj = double( ...
                mlfourd.AbstractNIfTI.switchableSqueeze(obj, varargin{:}));
        end 
        function obj = ensureSing(obj, varargin)
            %% ENSURESING tries to return a single-precision array for the passed object
            %  Usage: obj1 = mlfourd.AbstractNIfTI.ensureSing(obj, nosqz)
            %         ^ is guaranteed to be single (all overloaded single(...) calls applied, else error)
            %           obj1, obj may be char, NIfTI, struct or numeric
            %                                              ^ don't squeeze out singleton dims

            obj = single( ...
                mlfourd.AbstractNIfTI.switchableSqueeze(obj, varargin{:}));
        end 
        function obj = ensureInt16(obj, varargin)
            obj = int16( ...
                mlfourd.AbstractNIfTI.switchableSqueeze(obj, varargin{:}));
        end
        function obj = ensureInt32(obj, varargin)
            obj = int32( ...
                mlfourd.AbstractNIfTI.switchableSqueeze(obj, varargin{:}));
        end
        function obj = ensureUint8(obj, varargin)
            obj = uint8( ...
                mlfourd.AbstractNIfTI.switchableSqueeze(obj, varargin{:}));
        end
        function obj = switchableSqueeze(obj, tf)
            assert(isnumeric(obj));
            if (~exist('tf', 'var')); tf  = true; end
            if (tf);                  obj = squeeze(obj); end
        end
    end
    
    methods (Access = 'protected')
        function this = AbstractNIfTI
            this.creationDate_ = datestr(now);
        end % ctor
        function im   = ensureNumeric(this, im)
            if (iscell(im))
                im = im{1}; 
            end
            if (isstruct(im))
                assert(isfield(im, 'img'));
                im = im.img; 
            end            
            if (isa(im, 'mlfourd.NIfTIInterface'))
                im = im.img; 
            end
            if (isa(im, 'dip_image'))
                im = double(im); 
            end
            if (islogical(im))
                im = double(im); 
            end
            if (isnan(im))
                this.save; 
            end
            assert(isnumeric(im));
        end   
    end 
    
    %% PRIVATE 
    
    properties (Access = 'private')
        creationDate_
    end
    
    methods (Access = 'private')
        function x   = ensureSpanningScalar(this, x)
            assert(isnumeric(x));
            if (1 == size(x))
                x = x * ones(this.size); end
        end
        function x   = ensureSpannedNIfTI(this, x)
            %% ENSURESPANNEDNIFTI ensures arg is returned as an AbstractNIfTI;
            %  if arg is a numeric scalar, it is returned as an AbstractNIfTI with 
            %  this.img = arg.this.ones
            %  Usage:   x = this.ensureSpannedNIfTI(x)
            %           ^ AbstractNIfTI
            %                                       ^ AbstractNIfTI or scalar
            
            if (1 == numel(x) && isnumeric(x))
                x0    = x;
                x     = this.ones;
                x.img = x0 * x.img;
            elseif (isa(x, 'mlfourd.NIfTIInterface'))
            else
                error('mlfourd:UnsupportedType', 'class(AbstractNIfTI.ensureSpannedNIfTI.x) -> %s', class(x));
            end
        end % ensureSpannedNIfTI
        function obj = scrub1D(this, obj)
            assert(isnumeric(obj));
            for x = 1:this.size(1)
                if (~isfinite(obj(x)))
                    obj(x) = 0; end
            end
        end
        function obj = scrub2D(this, obj)
            assert(isnumeric(obj));
            for y = 1:this.size(2)
                for x = 1:this.size(1)
                    if (~isfinite(obj(x,y)))
                        obj(x,y) = 0; end
                end
            end
        end
        function obj = scrub3D(this, obj)
            assert(isnumeric(obj));
            for z = 1:this.size(3)
                for y = 1:this.size(2)
                    for x = 1:this.size(1)
                        if (~isfinite(obj(x,y,z)))
                            obj(x,y,z) = 0; end
                    end
                end
            end
        end
        function obj = scrub4D(this, obj)
            assert(isnumeric(obj));
            for t = 1:this.size(4)
                for z = 1:this.size(3)
                    for y = 1:this.size(2)
                        for x = 1:this.size(1)
                            if (~isfinite(obj(x,y,z,t)))
                                obj(x,y,z,t) = 0; end
                        end
                    end
                end
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
