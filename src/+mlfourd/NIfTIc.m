classdef NIfTIc < mlfourd.AbstractNIfTIComponent & mlfourd.INIfTIc
	%% NIFTIC specifies imaging data composites using img, fileprefix, hdr.hist.descrip, hdr.dime.pixdim as
    %  described by Jimmy Shen's entries at http://www.mathworks.com/matlabcentral/fileexchange/authors/20638.

	%  $Revision$
 	%  was created 15-Jan-2016 02:58:04
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	
    methods (Static)
        function this = load(varargin)
            %% LOAD aliases the ctor.
            
            this = mlfourd.NIfTIc(varargin{:});
        end
    end

	methods  
        function niic = clone(this, varargin)
            %% CLONE
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  @return niid copy-construction with niid.descrip appended with 'clone'.
            %  See also:  mlfourd.NIfTIc.NIfTIc
            
            niic = mlfourd.NIfTIc(this, varargin{:});
            niic = niic.append_descrip('made similar');
        end
        function tf   = isequal(this, obj)
            tf = this.isequaln(obj);
        end
        function tf   = isequaln(this, obj)
            tf = true;
            titer = this.createIterator;
            oiter = obj.createIterator;
            while (titer.hasNext && oiter.hasNext)
                cached = titer.next;
                tf = tf && cached.isequaln(oiter.next);
            end
        end
        function niic = makeSimilar(this, varargin)
            %% MAKESIMILAR 
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  @return niic copy-construction with niic.descrip appended with 'made similar'.
            %  See also:  mlfourd.NIfTIc.NIfTIc
    
            niic = mlfourd.NIfTIc(this, varargin{:});
            niic = niic.append_descrip('made similar');

        end   
        function o    = ones(this)
            o = this.innerNIfTI_.innerCellComp_.fevalOut('ones');
        end     
        function z    = zeros(this)
            z = this.innerNIfTI_.innerCellComp_.fevalOut('zeros');
        end
        
 		function this = NIfTIc(varargin)
 			%% NIFTIC 
            %  @ param [obj] may be empty, a filename, numerical, INIfTI instantiation, struct compliant with 
            %  package mlniftitools, cell-array, mlpatterns.Composite; it constructs the class instance. 
            %  @ param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  Valid param-names:  bitpix, datatype, descrip, ext, filename, filepath, fileprefix,
            %  filetype, fqfilename, fqfileprefix, hdr, img, label, mmppix, noclobber, pixdim, separator.
            %  @ return this as a class instance.  Without arguments, this has default values.
            %  @ throws mlfourd:invalidCtorObj, mlfourd:fileTypeNotSupported, mlfourd:fileNotFound, mlfourd:unsupportedParamValue, 
            %  mlfourd:unknownSwitchCase, mlfourd:unsupportedDatatype, mfiles:unixException, MATLAB:assertion:failed.

 			this = this@mlfourd.AbstractNIfTIComponent(mlfourd.InnerNIfTIc);
            if (0 == nargin); return; end
            
            import mlfourd.*;
            ip = inputParser;
            addOptional( ip, 'obj',          [], @NIfTIc.assertCtorObj); % compare to NIfTId
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
            addParameter(ip, 'circshiftK', 0,    @isnumeric);  % see also mlfourd.ImagingInfo
            addParameter(ip, 'N', true,          @islogical); % 
            parse(ip, varargin{:});

            this.innerNIfTI_.originalType_ = class(ip.Results.obj);
            switch (class(ip.Results.obj))
                case 'char'
                    this.innerNIfTI_.innerCellComp_ = ...
                        this.innerNIfTI_.innerCellComp_.add(NIfTId(ip.Results.obj)); % varargin{:}?
                    this = this.adjustFieldsFromInputParser(ip);
                case 'struct'
                    this.innerNIfTI_.innerCellComp_ = ...
                        this.innerNIfTI_.innerCellComp_.add(NIfTId(ip.Results.obj)); % varargin{:}?
                    this = this.adjustFieldsFromInputParser(ip);
                otherwise
                    if (isa(ip.Results.obj, 'mlio.IOInterface'))
                        this = this.adjustFieldsFromInputParser(ip);
                        this = this.adjustFieldsFromInputParser(ip);
                        return
                    end
                    if (isa(ip.Results.obj, 'mlfourd.INIfTId'))
                        %% dedecorates
                        this.innerNIfTI_.innerCellComp_ = ...
                            this.innerNIfTI_.innerCellComp_.add(NIfTId(ip.Results.obj));
                        this = this.adjustFieldsFromInputParser(ip);
                        return
                    end
                    if (isa(ip.Results.obj, 'mlfourd.NIfTIInterface'))
                        %% legacy
                        warning('off', 'MATLAB:structOnObject');
                        this = NIfTIc(struct(ip.Results.obj));
                        warning('on', 'MATLAB:structOnObject');
                        this = this.adjustFieldsFromInputParser(ip);
                        this = this.adjustFieldsFromInputParser(ip);
                        return
                    end
                    if (isnumeric(ip.Results.obj))
                        this.innerNIfTI_.innerCellComp_ = ...
                            this.innerNIfTI_.innerCellComp_.add(NIfTId(ip.Results.obj));
                        this = this.adjustFieldsFromInputParser(ip);
                        return
                    end
                    if (iscell(ip.Results.obj)) 
                        %% dedecorates
                        for idx = 1:length(ip.Results.obj)
                            this.innerNIfTI_.innerCellComp_ = ...
                                this.innerNIfTI_.innerCellComp_.add( ...
                                    NIfTId(this.reduceImagingContexts(ip.Results.obj{idx})));
                        end
                        this = this.adjustFieldsFromInputParser(ip);
                        return
                    end
                    if (isa(ip.Results.obj, 'mlpatterns.Composite')) 
                        %% dedecorates
                        iter = ip.Results.obj.createIterator;
                        while (iter.hasNext)   
                            this.innerNIfTI_.innerCellComp_ = ...
                                this.innerNIfTI_.innerCellComp_.add( ...
                                    NIfTId(this.reduceImagingContexts(iter.next)));
                        end
                        this = this.adjustFieldsFromInputParser(ip);
                        return
                    end
                    error('mlfourd:unsupportedSwitchcase', ...
                        'class(NIfTIc.ctor.ip.Results.obj) -> %s', class(ip.Results.obj));
            end
 		end
    end 
    
    %% PRIVATE
    
    methods (Static, Access = private)
        function      assertCtorObj(obj)
            if (~(ischar(obj) || isstruct(obj) || isnumeric(obj) || ...
                    isa(obj, 'mlfourd.INIfTI') || isa(obj, 'mlfourd.NIfTIInterface') || ...
                    isa(obj, 'mlpatterns.Composite') || iscell(obj)))
                error('mlfourd:invalidCtorObj', ...
                      'NIfTIc.assertCtorObj does not support class(obj)->%s', class(obj));
            end
        end
        function ic = reduceImagingContexts(ic)
            if (isa(ic, 'mlfourd.ImagingContext'))
                switch (ic.stateTypeclass)
                    case 'mlfourd.NIfTIdState'
                        ic = ic.niftid;
                    case 'mlfourd.NumericalNIfTIdState'
                        ic = ic.numericalNiftid;
                    case 'mlfourd.MGHState'
                        ic = ic.niftid;
                    case 'mlfourd.FilenameState'
                        ic = ic.fqfilename;
                    case 'mlfourd.DoubleState'
                        ic = ic.double;
                    otherwise
                        % not yet suppporting mlfourd.NIfTIcState, mlfourd.CellCompositeState
                        % which would be needed for recursions
                        error('mlfourd:switchCaseNotSupported', ...
                              'class(NIfTIc.reduceImagingContexts.ic) -> %s', class(ic));
                end
            end
        end
    end
    
    methods (Access = private)      
        function this = adjustFieldsFromInputParser(this, ip)
            for p = 1:length(ip.Parameters)
                if (~lstrfind(ip.Parameters{p}, ip.UsingDefaults))
                    for idx = 1:this.innerNIfTI_.length
                        switch (ip.Parameters{p})
                            case 'descrip'
                                this.innerNIfTI_.innerCellComp_{idx} = this.innerNIfTI_.innerCellComp_{idx}.append_descrip(ip.Results.descrip);
                            case 'ext'
                                this.innerNIfTI_.innerCellComp_{idx}.ext_ = ip.Results.ext;
                            case 'hdr'
                                this.innerNIfTI_.innerCellComp_{idx}.hdr_ = ip.Results.hdr;
                            case 'obj'
                            otherwise
                                this.(ip.Parameters{p}) = ip.Results.(ip.Parameters{p});
                        end
                    end
                end
            end
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

