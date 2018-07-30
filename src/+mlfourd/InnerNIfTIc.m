classdef InnerNIfTIc < mlfourd.InnerNIfTIcIO & mlfourd.JimmyShenInterface & mlfourd.INIfTI & mlpatterns.Composite
	%% INNERNIFTIC supplies composite INIfTI objects to AbstractNIfTIComponent.  It also forms a composite
    %  design pattern with decorators InnerNIfTId, which supplies composite INIfTI objects to AbstractNIfTIComponent.
    %  InnerNIfTIc supports cell and mlpatterns.CellComposite.

	%  $Revision$
 	%  was created 15-Jan-2016 03:04:23
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	
    properties (Dependent)
        noclobber
        
        ext        % Legacy variable for mlfourd.JimmyShenInterface
        filetype   % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr        % See also:  mlfourd.ImagingInfo
        img
        originalType
        untouch
        
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
        
        logger
        separator % for descrip & label properties, not for filesystem behaviors
        stack
        viewer
    end 

    methods
        
        %% GET/SET
        
        function tf   = get.noclobber(this)
            tf = this.innerCellComp_.getter('noclobber');
        end
        function this = set.noclobber(this, nc)
            this = this.innerCellComp_.setter('noclobber', nc);
        end
        
        function g    = get.ext(this)
            g = this.innerCellComp_.getter('ext');
        end
        function g    = get.filetype(this)
            g = this.innerCellComp_.getter('filetype');
        end
        function this = set.filetype(this, s)
            this = this.innerCellComp_.setter('filetype', s);
        end
        function g    = get.hdr(this)
            g = this.innerCellComp_.getter('hdr');
        end
        function g    = get.img(this)
            g = this.innerCellComp_.getter('img');
        end
        function this = set.img(this, s)
            this = this.innerCellComp_.setter('img', s);
        end
        function o    = get.originalType(this)
            o = this.originalType_;
        end
        function g    = get.untouch(this)
            g = this.innerCellComp_.getter('untouch');
        end
        
        function g    = get.bitpix(this)
            g = this.innerCellComp_.getter('bitpix');
        end
        function this = set.bitpix(this, s)
            this = this.innerCellComp_.setter('bitpix', s);
        end
        function g    = get.creationDate(this)
            g = this.innerCellComp_.getter('creationDate');
        end
        function g    = get.datatype(this)
            g = this.innerCellComp_.getter('datatype');
        end
        function this = set.datatype(this, s)
            this = this.innerCellComp_.setter('datatype', s);
        end
        function g    = get.descrip(this)
            g = this.innerCellComp_.getter('descrip');
        end
        function this = set.descrip(this, s)
            this = this.innerCellComp_.setter('descrip', s);
        end
        function g    = get.entropy(this)
            g = this.innerCellComp_.getter('entropy');
        end
        function g    = get.hdxml(this)
            g = this.innerCellComp_.getter('hdxml');
        end
        function g    = get.label(this)
            g = this.innerCellComp_.getter('label');
        end
        function this = set.label(this, s)
            this = this.innerCellComp_.setter('label', s);
        end
        function g    = get.machine(this)
            g = this.innerCellComp_.getter('machine');
        end
        function g    = get.mmppix(this)
            g = this.innerCellComp_.getter('mmppix');
        end
        function this = set.mmppix(this, s)
            this = this.innerCellComp_.setter('mmppix', s);
        end
        function g    = get.negentropy(this)
            g = this.innerCellComp_.getter('negentropy');
        end
        function g    = get.orient(this)
            g = this.innerCellComp_.getter('orient');
        end
        function g    = get.pixdim(this)
            g = this.innerCellComp_.getter('pixdim');
        end
        function this = set.pixdim(this, s)
            this = this.innerCellComp_.setter('pixdim', s);
        end
        function g    = get.seriesNumber(this)
            g = this.innerCellComp_.getter('seriesNumber');
        end
        
        function s    = get.logger(this)
            s = this.innerCellComp_.getter('logger');
        end
        function g    = get.separator(this)
            g = this.innerCellComp_.getter('separator');
        end
        function this = set.separator(this, s)
            this = this.innerCellComp_.setter('separator', s);
        end
        function g    = get.stack(this)
            g = this.innerCellComp_.getter('stack');
        end
        function v    = get.viewer(this)
            v = this.viewer_;
        end
        function this = set.viewer(this, v)
            this.viewer_ = v;
        end
        
        %% NIfTIIO
        
        function        save(this)
            for c = 1:this.innerCellComp_.length
                cached = this.innerCellComp_{c};
                cached.save;
            end
        end
        function this = saveas(this, s)
            if (ischar(s))
                warning('mlfourd:ambiguousCompositeRequest', ...
                        'InnerNIfTIc.saveas received solitary %s; prepending fileprefixes', s);
                this = this.prepend_fileprefix(s);
            end
            if (iscell(s))
                this.fqfilename = s;
            end
            this.save;
        end    
        
        %% INIfTI  
        
        function c = char(this)
            c = this.innerCellComp_.fevalOut('char');
        end
        function this = append_descrip(this, varargin)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('append_descrip', varargin{:});
        end
        function this = prepend_descrip(this, varargin)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('prepend_descrip', varargin{:});
        end
        function d = double(this)
            d = this.innerCellComp_.fevalOut('double');
        end
        function d = duration(this)
            d = this.innerCellComp_.fevalOut('duration');
        end
        function this = append_fileprefix(this, varargin)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('append_fileprefix', varargin{:});
        end
        function this = prepend_fileprefix(this, varargin)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('prepend_fileprefix', varargin{:});
        end
        function f = fov(this)
            f = this.innerCellComp_.fevalOut('fov');
        end
        function m = matrixsize(this)
            m = this.innerCellComp_.fevalOut('matrixsize');
        end
        function this = prod(this)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('prod');
        end
        function r = rank(this)
            r = this.innerCellComp_.fevalOut('rank');
        end
        function this = scrubNanInf(this)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('scrubNanInf');
        end
        function s = single(this)
            s = this.innerCellComp_.fevalOut('single');
        end
        function s = size(this, varargin)
            s = this.innerCellComp_.fevalOut('size', varargin{:});
        end
        function this = sum(this)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('sum');
        end
                
        %% mlpatterns.Composite
        
        function this = add(this, obj)
            this.innerCellComp_ = this.innerCellComp_.add(obj);
        end        
        function iter = createIterator(this)
            iter = this.innerCellComp_.createIterator;
        end
        function s    = csize(this)   
            s = this.innerCellComp_.csize;
        end  
        function        disp(this)
           this.innerCellComp_.disp;
       end
        function idx  = find(this, obj)
            warning('off', 'mlfourd:isequal:mismatchedField');
            idx = this.innerCellComp_.find(obj);
            warning('on', 'mlfourd:isequal:mismatchedField');
        end
        function obj  = get(this, idx)
            obj = this.innerCellComp_.get(idx);
        end
        function tf   = isempty(this)
            tf = this.innerCellComp_.isempty;
        end
        function len  = length(this)
            len = this.innerCellComp_.length;
        end
        function this = rm(this, idx)
            this.innerCellComp_ = this.innerCellComp_.rm(idx);
        end   
        
        %% 
        
        function     addLog(this, varargin)
            for c = 1:this.innerCellComp_.length
                cached = this.innerCellComp_{c};
                cached.addLog(varargin{:});
            end
        end
        function e = fslentropy(this)
            e = this.innerCellComp_.fevalOut('fslentropy');
        end
        function E = fslEntropy(this)
            E = this.innerCellComp_.fevalOut('fslEntropy');
        end
        function     hist(~)
            error('mlfourd:notImplemented', 'InnerNIfTIc.hist');
        end
        function     view(this, varargin)
            this.(this.viewer)(varargin{:});
        end
        function     freeview(this, varargin)
            first = this.innerCellComp_.get(1);
            fqfns = this.innerCellComp_.fevalOut('fqfilename');
            fqfns = [fqfns(2:end) varargin{:}];
            first.freeview(fqfns{:});
        end
        function     fsleyes(this, varargin)
            first = this.innerCellComp_.get(1);
            fqfns = this.innerCellComp_.fevalOut('fqfilename');
            fqfns = [fqfns(2:end) varargin{:}];
            first.fsleyes(fqfns{:});
        end
        function     fslview(this, varargin)
            first = this.innerCellComp_.get(1);
            fqfns = this.innerCellComp_.fevalOut('fqfilename');
            fqfns = [fqfns(2:end) varargin{:}];
            first.fslview(fqfns{:});
        end        
        function e = lexistFile(this)
            e = this.innerCellComp_.fevalOut('lexist');
        end
        
 		function this = InnerNIfTIc(varargin)
            
            % copy-ctor
            if (nargin == 1 && isa(varargin{1}, 'mlfourd.InnerNIfTIc'))
                this.innerCellComp_ = varargin{1}.innerCellComp_;
                return
            end
            
            import mlfourd.*;
            ip = inputParser;
            addOptional(ip, 'obj', {}, @(x) isa(x, 'mlpatterns.CellComposite') || iscell(x));
            parse(ip, varargin{:});            
            this.innerCellComp_ = InnerCellComposite(ip.Results.obj);
 		end
    end 
    
    %% HIDDEN
    
    properties (Hidden)
        innerCellComp_
        originalType_
        viewer_ = 'freeview'
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

