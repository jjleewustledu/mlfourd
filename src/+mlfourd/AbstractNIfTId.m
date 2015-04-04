classdef (Abstract) AbstractNIfTId < mlio.AbstractIO & mlfourd.JimmyShenInterface & mlfourd.NIfTIdInterface
	%% ABSTRACTNIFTID 
    %  Yet abstract:
    %      properties:  descrip, img, mmppix, pixdim
    %      methods:     forceDouble, forceSingle, makeSimilar, clone
    
	%  Version $Revision: 2627 $ was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ by $Author: jjlee $  
 	%  and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AbstractNIfTId.m $ 
 	%  Developed on Matlab 7.11.0.584 (R2010b) 
 	%  $Id: AbstractNIfTId.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    properties (Constant)
        DESC_LEN_LIM = 128; % limit to #char of desc, as desc may be used for the default fileprefix
    end
    
    properties (Dependent)
        creationDate
        datatype
        entropy
        hdxml
        label
        machine
        negentropy
        orient
        separator % for descrip & label properties, not for filesystem behaviors
        seriesNumber        
        bitpix
    end 

 	methods %% setters/getters 
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
                            ['NIfTId.set.datatype:  class(img) -> ' class(this.img)]));
                end
            elseif (isnumeric(dt))
                if (dt < 64)
                    this = this.forceSingle;
                else
                    this = this.forceDouble;
                end
            else
                paramError('UnsupportedType for NIfTId.set.datatype.dt', class(dt));
            end
        end  
        function dt   = get.datatype(this)
            %% DATATYPE returns a datatype code as described by the NIfTId specificaitons
            
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
                        ['NIfTId.get.datatype:  class(img) -> ' class(this.img)]));
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
            ma.arch = computer('arch');
            [~,ma.maxsize ,ma.endian] = computer;
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
        function this = set.separator(this, s)
            if (ischar(s))
                this.separator_ = s; end
        end
        function s    = get.separator(this)
            s = this.separator_;
        end
        function num  = get.seriesNumber(this)
            num = mlchoosers.FilenameFilters.getSeriesNumber(this.fileprefix);
        end         
        function this = set.bitpix(this, bp) 
            assert(isnumeric(bp));
            if (bp >= 64)
                this = this.forceDouble; 
            else
                this = this.forceSingle; 
            end
        end   
        function bp   = get.bitpix(this) 
            %% BIPPIX returns a datatype code as described by the NIfTId specificaitons
            
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
                        ['NIfTId.get.bitpix:  class(img) -> ' class(this.img)]));
            end
        end     
    end
       
    methods
        function ch   = char(this)
            ch = this.fqfilename;
        end 
        function d    = double(this)
            if (~isdouble(this.img))
                d = double(this.img);
            else 
                d = this.img;
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
                img = this.img; end
            rnk = size(size(squeeze(img)),2);
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
                          'AbstractNIfTId.scrubNanInf:  this.rank(img) -> %i', this.rank(img));
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
        
        function        freeview(this)
            this.launchExternalViewer('freeview');
        end
        function        fslview(this)
            this.launchExternalViewer('fslview');
        end
 	end 
    
    %% PROTECTED 

    properties (Access = 'protected')
        label_
        separator_ = ';';
        creationDate_
    end
    
    methods (Static, Access = 'protected')
        function obj = ensureDble(obj, varargin)
            %% ENSUREDBLE tries to return a double-precision array for the passed object
            %  Usage: obj1 = mlfourd.AbstractNIfTId.ensureDble(obj, nosqz)
            %         ^ is guaranteed to be double
            %           obj1, obj may be char, NIfTId, struct or numeric
            %                                              ^ boolean:  don't squeeze out singleton dims
            
            obj = double( ...
                mlfourd.AbstractNIfTId.switchableSqueeze(obj, varargin{:}));
        end 
        function obj = ensureSing(obj, varargin)
            %% ENSURESING tries to return a single-precision array for the passed object
            %  Usage: obj1 = mlfourd.AbstractNIfTId.ensureSing(obj, nosqz)
            %         ^ is guaranteed to be single (all overloaded single(...) calls applied, else error)
            %           obj1, obj may be char, NIfTId, struct or numeric
            %                                              ^ don't squeeze out singleton dims

            obj = single( ...
                mlfourd.AbstractNIfTId.switchableSqueeze(obj, varargin{:}));
        end 
        function obj = ensureInt16(obj, varargin)
            obj = int16( ...
                mlfourd.AbstractNIfTId.switchableSqueeze(obj, varargin{:}));
        end
        function obj = ensureInt32(obj, varargin)
            obj = int32( ...
                mlfourd.AbstractNIfTId.switchableSqueeze(obj, varargin{:}));
        end
        function obj = ensureUint8(obj, varargin)
            obj = uint8( ...
                mlfourd.AbstractNIfTId.switchableSqueeze(obj, varargin{:}));
        end
        function obj = switchableSqueeze(obj, tf)
            assert(isnumeric(obj));
            if (~exist('tf', 'var')); tf  = true; end
            if (tf);                  obj = squeeze(obj); end
        end
    end
    
    methods (Access = 'protected')
        function this = AbstractNIfTId
            this.creationDate_ = datestr(now);
        end % ctor
        function obj  = scrub1D(this, obj)
            assert(isnumeric(obj));
            for x = 1:this.size(1)
                if (~isfinite(obj(x)))
                    obj(x) = 0; end
            end
        end
        function obj  = scrub2D(this, obj)
            assert(isnumeric(obj));
            for y = 1:this.size(2)
                for x = 1:this.size(1)
                    if (~isfinite(obj(x,y)))
                        obj(x,y) = 0; end
                end
            end
        end
        function obj  = scrub3D(this, obj)
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
        function obj  = scrub4D(this, obj)
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
        function        launchExternalViewer(this, app) 
            assert(ischar(app));
            try
                tmpFile = sprintf('%s_%s%s', this.fqfileprefix, datestr(now, 30), this.FILETYPE_EXT);
                this.saveas(tmpFile);
                [s,r] = mlbash(sprintf('%s %s', app, tmpFile));
                delete(tmpFile);
            catch ME
                if (s)
                    fprintf('AbstractNIfTId.freeview:  %s\n', r); end
                handexcept(ME);
            end
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
