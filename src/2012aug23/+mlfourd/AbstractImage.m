classdef AbstractImage < mlfourd.ImageInterface
	%% ABSTRACTIMAGE defines intterfaces and common properties, get/setters, method overloads for image types 
	%  Version $Revision$ was created $Date$ by $Author$  
 	%  and checked into svn repository $URL$ 
 	%  Developed on Matlab 7.11.0.584 (R2010b) 
 	%  $Id$ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    %% ABSTRACTIONS
    
    properties (Abstract, Constant)
        FILETYPE_EXT
    end % constant properties
    
	properties (Abstract)
        datatype
        pixdim
    end % abstract properties
    
    properties (Abstract, SetAccess = 'protected')
        originalType
    end % abstract, set-protected properties
    
    %% IMPLEMENTATIONS
    
    properties (Constant)
        ISEQUAL_IGNORES = {'untouch' 'noclobber' 'debugging' 'filesuffix'   'label' ...
                           'descrip' 'machine'   'hdxml'     'creationDate' 'originalType' 'hdr'}; 
        %ISEQUAL_IGNORES = {'fileprefix' 'filepath' 'untouch' 'noclobber'    'debugging'  'filesuffix'   'filename' 'label' ...
        %                   'descrip'    'fqfp'     'fqfn'    'fqfileprefix' 'fqfilename' 'machine'      'hdxml'    'creationDate' 'originalType' ...
        %                   'hdr'}; 
    end
    
    properties
        filename
        filesuffix
        forceRadiologic = false;
        noclobber       = false;
        squareWidth     = 2.5; % used by imerode, imdilate, etc.
    end
 
    properties (SetAccess = 'protected')
        creationDate
        untouch = true;
    end 
    
    properties (Dependent)
        debugging
        entropy
        fqfilename
        fqfileprefix
        fqfn
        fqfp
        label
        machine
        negentropy
    end
    
 	methods 
        
        %% Getters/Setters
        function dbg  = get.debugging(this) %#ok<MANU>
            preg = mlpipeline.PipelineRegistry.instance;
            dbg  = preg.debugging;
        end   
        function E    = get.entropy(this)
            E = entropy(imcast(this.img, 'double'));
        end   
        function fn   = get.filename(this)
            fn = [this.fileprefix this.FILETYPE_EXT];
        end                 
        function this = prepend_fileprefix(this, s)
            assert(ischar(s));
            this.fileprefix = [strtrim(s) this.fileprefix];
        end        
        function this = append_fileprefix(this, s)
            assert(ischar(s));
            this.fileprefix = [this.fileprefix strtrim(s)];
        end        
        function sf   = get.filesuffix(this)
            sf = this.FILETYPE_EXT;
        end
        function this = set.untouch(this, ~)
            
            %% SET.UNTOUCH
            %  setter assumes this has been touched
            this.untouch = 0;
        end        
        function fn   = get.fqfilename(this)
            fn = fullfile(this.filepath, this.filename);
        end
        function fp   = get.fqfileprefix(this)
            fp = fullfile(this.filepath, this.fileprefix);
        end
        function fn   = get.fqfn(this)
            fn = this.fqfilename;
        end     
        function fp   = get.fqfp(this)
            fp = this.fqfileprefix;
        end        
        function this = set.label(this, s)
            assert(ischar(s));
            this.label_internal = strtrim(s);
            this.untouch = 0;
        end   
        function d    = get.label(this)
            if (isempty(this.label_internal))
                this.label_internal = this.fileprefix;
            end
            d = this.label_internal;
        end              
        function ma   = get.machine(this) %#ok<MANU>
            [~,~,ma] = computer;
        end      
        function E    = get.negentropy(this)
            E = -this.entropy;
        end
                       
        %% Overloaded numerical methods
        function c    = bsxfun(this, pfun, b)
            %% bsxfun overloads bsxfun for NIfTI
            %  obj = mlfourd.ConcreteImage
            %  c   = obj.bsxfun(fun_handle, b)
            %  ^                            ^ ConcreteImage objects
            this.separator = '';
            inname = func2str(pfun);
            if (isa(b, 'mlfourd.AbstractImage'))
                cimg = bsxfun(pfun, this.img, b.img);
                c    = this.makeSimilar(cimg, ...
                      ['bsxfun(' inname ',' this.fileprefix ',' b.fileprefix ')'], ...
                      ['bsxfun(' inname ',' this.fileprefix ',' b.fileprefix ')']);
            elseif (isnumeric(b))
                cimg  = bsxfun(pfun, this.img, b);
                bname = sprintf('%s%dx%dx%d', class(b), size(b));
                c     = this.makeSimilar(cimg, ...
                      ['bsxfun(' inname ',' this.fileprefix ',' strrep(bname, '.', '_') ')'], ...
                      ['bsxfun(' inname ',' this.fileprefix ',' strrep(bname, '.', '_') ')']);
            else
                error('mlfourd:UnsupportedParamType', ...
                     ['NIfTI.bsxfun:  fun->' inname ' b->' class(b)]);
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
                this.img = this.img / b;
                c = this;
                c.fileprefix = [this.fileprefix '(/)' num2str(b)];
            else
                c = this.bsxfun(@rdivide, b);
                c.fileprefix = [this.fileprefix '(/)' b.fileprefix];
            end
        end
        function c    = ldivide(this, b)
            if (1 == numel(b) && isnumeric(b))
                this.img = b ./ this.img;
                c = this;
                c.fileprefix = [num2str(b) '(/)' this.fileprefix];
            else
                c = this.bsxfun(@ldivide, b);
                c.fileprefix = [b.fileprefix '(/)' this.fileprefix];
            end
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
            b = this.ensureSpan(b);
            c = this.bsxfun(@max, b);
            c.fileprefix = [this.fileprefix '(max)' b.fileprefix];
        end
        function c    = min(this, b)
            b = this.ensureSpan(b);
            c = this.bsxfun(@min, b);
            c.fileprefix = [this.fileprefix '(min)' b.fileprefix];
        end
        function c    = rem(this, b)
            b = this.ensureSpan(b);
            c = this.bsxfun(@rem, b);
            c.fileprefix = [this.fileprefix '(rem)' b.fileprefix];
        end
        function c    = mod(this, b)
            b = this.ensureSpan(b);
            c = this.bsxfun(@mod, b);
            c.fileprefix = [this.fileprefix '(mod)' b.fileprefix];
        end
        function c    = atan2(this, b)
            b = this.ensureSpan(b);
            c = this.bsxfun(@atan2, b);
            c.fileprefix = [this.fileprefix '(atan2)' b.fileprefix];
        end
        function c    = hypot(this, b)
            b = this.ensureSpan(b);
            c = this.bsxfun(@hypot, b);
            c.fileprefix = [this.fileprefix '(hypot)' b.fileprefix];
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
            b = this.ensureSpan(b);
            c = this.bsxfun(@lt, b);
            c.fileprefix = [this.fileprefix '(<)' b.fileprefix];
        end
        function c    = le(this, b)
            b = this.ensureSpan(b);
            c = this.bsxfun(@le, b);
            c.fileprefix = [this.fileprefix '(<=)' b.fileprefix];
        end
        function c    = gt(this, b)
            b = this.ensureSpan(b);
            c = this.bsxfun(@gt, b);
            c.fileprefix = [this.fileprefix '(>)' b.fileprefix];
        end
        function c    = ge(this, b)
            b = this.ensureSpan(b);
            c = this.bsxfun(@ge, b);
            c.fileprefix = [this.fileprefix '(>=)' b.fileprefix];
        end
        function this = and(this, b)
            assert(isa(b, 'mlfourd.ImageInterface'));
            this.img = this.img & b.img;
            this.fileprefix = [this.fileprefix '(and)' b.fileprefix];
            this.descrip    = [this.descrip    ' and ' b.fileprefix];
        end
        function this = or(this, b)
            assert(isa(b, 'mlfourd.ImageInterface'));
            this.img = this.img | b.img;
            this.fileprefix = [this.fileprefix '(or)' b.fileprefix];
            this.descrip    = [this.descrip    ' or ' b.fileprefix];
        end
        function this = xor(this, b)
            assert(isa(b, 'mlfourd.ImageInterface'));
            this.img = xor(this.img, b.img);
            this.fileprefix = [this.fileprefix '(xor)' b.fileprefix];
            this.descrip    = [this.descrip    ' xor ' b.fileprefix];
        end
        function this = not(this)
            this.img = not(this.img);
            this.fileprefix = ['(~)' this.fileprefix];
            this.descrip    = [ '~'  this.descrip];
        end
        function M    = diff(this)
            
            %% DIFF overloads diff for NIfTI
            Mimg  = diff(this.img);
            M     = this.makeSimilar(Mimg, ...
                     '', ['(diff)' this.fileprefix]);
            M.descrip = [  'diff(' M.descrip ')'];
        end       
        
        %% Other overloaded methods        
        function ch   = char(this)
            ch = this.fqfilename;
        end 
        function di   = dip_image(this)
            di = dip_image(this.img);
        end % dip_image       
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
        end % dipshow  
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
        function d    = double(this)
            d = double(this.img_internal);
        end
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
            assert(logical(exist('slice', 'var')));
            switch (length(slice))
                case 1
                    himg = imshow(flip4d(this.img(:,:,slice), 'xt'), varargin{:});
                case 2
                    himg = imshow(flip4d(this.img(:,:,slice(1),slice(2)), 'xt'), varargin{:});
                otherwise
                    paramError(this, 'slice #', num2str(slice));
            end
        end % imshow            
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
        function ln   = length(this) %#ok<MANU>
            %% LENGTH should be overridden by mlfourd.ImagingComponents
            
            ln = 1;  
        end
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
        function o    = ones(this)
            o = this.makeSimilar(ones(this.size), ['ones(' num2str(this.size) ')'], 'ones');
        end
        function M    = prod(this)
            
            %% PROD overloads prod for NIfTI
            Mimg  = prod(this.img);
            M     = this.makeSimilar(Mimg, ...
                     '', ['(prod)' this.fileprefix]);
            M.descrip = [  'prod(' M.descrip ')'];
        end
        function rnk  = rank(this, img)
            %% RANK squeezes this.img before reporting rank of this.img or passed img
            if (nargin > 1)
                rnk = size(size(squeeze(     img)),2); 
            else
                rnk = size(size(squeeze(this.img)),2);
            end
        end      
        function s    = single(this)
            s = single(this.img_internal);
        end   
        function sz   = size(this, dim)
            %% SIZE overloads Matlab's size
            
            if (exist('dim','var'))
                sz = size(this.img, dim);
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
        function z    = zeros(this)
            z = this.makeSimilar(zeros(this.size), ['zeros(' num2str(this.size) ')'], 'zeros');
        end
        
        function img = ensureNumericImage(this, img)
            if (iscell(img))
                %assert(1 == length(img));
                img = img{1};
            end
            if (isstruct(img))
                assert(isfield(img, 'img'));
                img = img.img;
            end            
            if (isa(img, 'mlfourd.ImageInterface'))
                img = img.img;
            end
            if (isa(img, 'dip_image'))
                img = double(img);
            end
            if (islogical(img))
                img = double(img);
            end
            if (isnan(img))
                this.save;
            end
            assert(isnumeric(img));
        end
 	end % methods
    
    %% PROTECTED 
    
    properties (Access = 'protected')
        img_internal
        label_internal
    end
    
    methods (Access = 'protected')
        function tf   = fieldsequal(this, imobj)
            try
                tf  = true;
                fns = fieldnames(this);
                for f = 1:length(fns)
                    if (~any(strcmp(fns{f}, this.ISEQUAL_IGNORES)))
                        tf = tf && isequal(this.(fns{f}), imobj.(fns{f}));
                        if (~tf); break; end
                    end
                end
            catch ME
                if (mlpipeline.PipelineRegistring.instance.verbosity > 0.95)
                    handwarning(ME);
                end
                tf = false;
            end
        end
        function this = AbstractImage
            this.creationDate = datestr(now);
        end % ctor
    end % protected methods
    
    %% PRIVATE 
    
    methods (Access = 'private')
        function x = ensureSpansImage(this, x)
            %% ENSURESPANSIMAGE ensures arg is returned as an AbstractImage;
            %  if arg is a numeric scalar, it is returned as an AbstractImage with 
            %  this.img = arg.this.ones
            %  Usage:   x = this.ensureSpan(x)
            %           ^ AbstractImage
            %                               ^ AbstractImage or scalar
            
            if (1 == numel(x) && isnumeric(x))
                x0    = x;
                x     = this.ones;
                x.img = x0 * x.img;
            elseif (isa(x, 'mlfourd.AbstractImage'))
            else
                error('mlfourd:UnsupportedType', 'class(AbstractImage.ensureSpan.x) -> %s', class(x));
            end
        end % ensureSpan
    end % private methods
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
