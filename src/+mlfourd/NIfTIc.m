classdef NIfTIc < mlfourd.AbstractNIfTIc
	%% NIFTIC  

	%  $Revision$
 	%  was created 15-Jan-2016 02:58:04
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	
    methods (Static)
        function this = load(varargin)
            %% LOAD loads imaging objects from the filesystem.  In the absence of file extension, LOAD will attempt guesses.
            %  @param [fn] is a cell-array of [fully-qualified] fileprefix or filename, specifies imaging objects on the filesystem.
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  @return this is an instance of mlfourd.NIfTIc.
            %  See also:  mlfourd.NIfTIc.NIfTIc
            
            assert(nargin >= 1);
            assert(iscell(varargin{1}));
            this = mlfourd.NIfTId(varargin{:});
        end
    end

	methods  
        
        %% From INIfTI
        
        function obj      = clone(this)
            obj = this.innerCellComp_.clone;
        end
        function [tf,msg] = isequal(this, obj)
            [tf,msg] = this.isequaln(obj);
        end
        function [tf,msg] = isequaln(this, obj)
            assert(iscell(obj) && size(obj) == size(this.innerCellComp_));
            
            tf  = this.innerCellComp_.cellEmpty;
            msg = this.innerCellComp_.cellEmpty;
            for c = 1:this.innerCellComp_.length
                [tf{c},msg{c}] = this.innerCellComp_{c}.isequaln(obj{c});
            end
        end
        function niic     = makeSimilar(this, varargin)
            %% MAKESIMILAR 
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  @return niic copy-construction with niic.descrip appended with 'made similar'.
            %  See also:  mlfourd.NIfTIc.NIfTIc
    
            niic = mlfourd.NIfTIc(this, varargin{:});
            niic = niic.append_descrip('made similar');

        end
        function            save(this)
            for c = 1:this.innerCellComp_.length
                this.innerCellComp_{c}.save;
            end
        end
        function this     = saveas(this, fn)
            assert(iscell(fn) && length(fn) == this.length);
            for c = 1:this.innerCellComp_.length
                this.innerCellComp_{c}.saveas(fn{c});
            end
        end
        
        %% Ctor
        
 		function this = NIfTIc(obj, varargin)
 			%% NIFTIC

 			this = this@mlfourd.AbstractNIfTIc;
            if (0 == nargin); return; end
            
            import mlfourd.*;
            ip = inputParser;
            addOptional( ip, 'obj',          [], @NIfTId.validateCtorObj);
            addParameter(ip, 'bitpix',       [], @isnumeric);
            addParameter(ip, 'datatype',     [], @(x) isnumeric(x) || ischar(x));
            addParameter(ip, 'descrip',      '', @ischar);
            addParameter(ip, 'ext',          []);
            addParameter(ip, 'filename',     '', @ischar);
            addParameter(ip, 'filepath',     '', @ischar);
            addParameter(ip, 'fileprefix',   '', @ischar);
            addParameter(ip, 'filetype',     [], @(x) isnumeric(x) && (isempty(x) || (x >= 0 && x <= 2)));
            addParameter(ip, 'fqfilename',   '', @ischar);
            addParameter(ip, 'fqfileprefix', '', @ischar);
            addParameter(ip, 'hdr',  struct([]), @isstruct);
            addParameter(ip, 'img',          [], @(x) isnumeric(x) || islogical(x));
            addParameter(ip, 'label',        '', @ischar);
            addParameter(ip, 'mmppix',       [], @isnumeric);
            addParameter(ip, 'noclobber',    []);
            addParameter(ip, 'pixdim',       [], @isnumeric);
            addParameter(ip, 'separator',    '', @ischar);
            parse(ip, varargin{:});
            
            %this.innerCellComp_ = InnerCellComposite(CellComposite(cell(1, length(obj))));
            %for idx = 1:this.innerCellComp_.length
                this.originalType_ = class(ip.Results.obj);
                switch (this.originalType) % no returns within switch!  must reach this.populateFieldsFromInputParser.
                    case 'cell'
                        for o = 1:length(ip.Results.obj);
                            niids{o} = NIfTId(ip.Results.obj{o});
                        end
                        this.innerCellComp_ = InnerCellComposite();
                    case 'char'
                        ff = this.existingFileform(ip.Results.obj);
                        if (~isempty(ff))
                            this = NIfTId.load_existing(ff);
                        else
                            [p,f] = myfileparts(ip.Results.obj);
                            this.fqfilename = fullfile(p, [f this.FILETYPE_EXT]);
                        end
                    case 'struct' 
                        % as described by mlniftitools.load_untouch_nii
                        this.hdr_         = ip.Results.obj.hdr;
                        this.filetype_    = ip.Results.obj.filetype;
                        this.fileprefix   = ip.Results.obj.fileprefix;
                        this.ext_         = ip.Results.obj.ext;
                        this.img_         = ip.Results.obj.img;
                        this.untouch_     = ip.Results.obj.untouch;
                    otherwise
                        if (isnumeric(ip.Results.obj))
                            rank                                 = length(size(ip.Results.obj));
                            this.img_                            = double(ip.Results.obj);
                            this.hdr_.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                            this.hdr_.dime.dim                   = ones(1,8);
                            this.hdr_.dime.dim(1)                = rank;
                            this.hdr_.dime.dim(2:rank+1)         = size(ip.Results.obj);
                            this.hdr_.dime.datatype              = 64;
                            this.hdr_.dime.bitpix                = 64;
                        elseif (isa(ip.Results.obj, 'mlfourd.NIfTIInterface'))
                            warning('off', 'MATLAB:structOnObject');
                            this = NIfTId(struct(ip.Results.obj));
                            warning('on', 'MATLAB:structOnObject');
                        elseif (isa(ip.Results.obj, 'mlfourd.INIfTI'))
                            this.ext_         = ip.Results.obj.ext;
                            this.fqfileprefix = ip.Results.obj.fqfileprefix;
                            this.filetype_    = ip.Results.obj.filetype;
                            this.hdr_         = ip.Results.obj.hdr;
                            this.img_         = ip.Results.obj.img;                     
                            this.label        = ip.Results.obj.label;
                            this.noclobber    = ip.Results.obj.noclobber;
                            this.separator    = ip.Results.obj.separator;
                            this.untouch_     = ip.Results.obj.untouch;   
                        else
                            NIfTId.validateCtorObj(ip.Results.obj);
                        end
                end
                
                this = this.populateFieldsFromInputParser(ip, idx);
            %end
 		end
    end 
    
    %% PRIVATE
    
    methods (Static, Access = private)
        function tf = ischar__(x)
            tf = ischar(x) || iscell(x);
        end
        function tf = isfiletype__(x)
            tf = (isnumeric(x) && (isempty(x) || (x >= 0 && x <= 2))) || ...
                  iscell(x); 
        end
        function tf = isnumeric__(x)
            tf = isnumeric(x) || iscell(x);
        end
        function tf = isnumericOrChar__(x)
            tf = isnumeric(x) || ischar(x) || iscell(x);
        end
        function tf = isnumericOrLogical__(x)
            tf = isnumeric(x) || islogical(x) || iscell(x);
        end
        function      validateCtorObj(obj)
            if (~(isa(obj, 'mlpatterns.Composite') || iscell(obj)))
                error('mlfourd:invalidCtorObj', ...
                      'NIfTId.validateCtorObj does not support class(obj)->%s', class(obj));
            end
        end
    end
    
    methods (Access = private)        
        function this = populateFieldsFromInputParser(this, ip, idx)
            for p = 1:length(ip.Parameters)
                if (~lstrfind(ip.Parameters{p}, ip.UsingDefaults))
                    switch (ip.Parameters{p})
                        case 'descrip'
                            this.innerCellComp_{idx} = this.innerCellComp_{idx}.append_descrip(ip.Results.descrip);
                        case 'ext'
                            this.innerCellComp_{idx}.ext_ = ip.Results.ext;
                        case 'hdr'
                            this.innerCellComp_{idx}.hdr_ = ip.Results.hdr;
                        case 'obj'
                        otherwise
                            this.innerCellComp_{idx}.(ip.Parameters{p}) = ip.Results.(ip.Parameters{p});
                    end
                end
            end
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

