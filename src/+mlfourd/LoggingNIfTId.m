classdef LoggingNIfTId < mlfourd.NIfTIdecorator
	%% LOGGINGNIFTID maintains an internal instance of mlpipeline.Logger.

	%  $Revision$
 	%  was created 10-Jan-2016 15:53:48
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	
    
    properties (Dependent)
        
        logger
        
        %% IOInterface
        
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp 
        noclobber
        
        %% INIfTI
        
        img
        
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
    end
    
    methods %% SET/GET
        
        function g = get.logger(this)
            g = this.logger_;
        end
        
        %% IOInterface
        
        function this = set.filename(this, fn)
            this.component.filename = fn;
            this.logger_.filename = fn;
        end
        function fn   = get.filename(this)
            fn = this.component.filename;
        end
        function this = set.filepath(this, pth)
            this.component.filepath = pth;
            this.logger_.filepath = pth;
        end
        function pth  = get.filepath(this)
            pth = this.component.filepath;
        end
        function this = set.fileprefix(this, fp)
            this.component.fileprefix = fp;
            this.logger_.fileprefix = fp;
        end
        function fp   = get.fileprefix(this)
            fp = this.component.fileprefix;
        end
        function this = set.filesuffix(this, fs)
            this.component.filesuffix = fs;
        end
        function fs   = get.filesuffix(this)
            fs = this.component.filesuffix;
        end
        function this = set.fqfilename(this, fqfn)
            this.component.fqfilename = fqfn; 
            [p,f] = myfileparts(fqfn);
            this.logger_.fqfilename = fullfile(p, [f this.logger_.FILETYPE_EXT]); 
        end
        function fqfn = get.fqfilename(this)
            fqfn = this.component.fqfilename;
        end
        function this = set.fqfileprefix(this, fqfp)
            this.component.fqfileprefix = fqfp;
            [p,f] = myfileparts(fqfn);
            this.logger_.fqfileprefix = fullfile(p, f); 
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = this.component.fqfileprefix;
        end
        function this = set.fqfn(this, f)
            this.fqfilename = f;
        end
        function f    = get.fqfn(this)
            f = this.fqfilename;
        end
        function this = set.fqfp(this, f)
            this.fqfileprefix = f;
        end
        function f    = get.fqfp(this)
            f = this.fqfileprefix;
        end
        function this = set.noclobber(this, nc)
            this.component.noclobber_ = nc;
            this.logger_.noclobber_ = nc;
        end
        function tf   = get.noclobber(this)
            tf = this.component.noclobber;
        end
        
        %% INIfTI
        
        function this = set.img(this, im)
            this.component.img = im;
            this.logger_.add(sprintf('LoggingNIfTId.set.img <- im with entropy %g', entropy(double(im))));
        end
        function im   = get.img(this)
            im = this.component.img;
        end
        
        function this = set.bitpix(this, x)
            this.component.bitpix = x;
            this.logger_.add(sprintf('LoggingNIfTId.set.bitpix <- %g', x));
        end
        function sw = get.bitpix(this)
            sw = this.component.bitpix;
        end  
        function sw = get.creationDate(this)
            sw = this.component.creationDate;
        end     
        function this = set.datatype(this, x)
            this.component.datatype = x;
            this.logger_.add(sprintf('LoggingNIfTId.set.datatype <- %g', x));
        end
        function sw = get.datatype(this)
            sw = this.component.datatype;
        end
        function this = set.descrip(this, varargin)
            this.component.descrip = cell2str(varargin);
            this.logger_.add(varargin{:});
        end
        function g = get.descrip(this)
            g = this.logger_;
        end
       function sw = get.entropy(this)
           sw = this.component.entropy;
       end
        function x    = get.hdxml(this)
            x = this.component.hdxml;
        end
        function this = set.label(this, x)
            this.component.label = x;
            this.logger_.add(sprintf('LoggingNIfTId.set.label <- %s', x));
        end
        function sw = get.label(this)
            sw = this.component.label;
        end
        function sw = get.machine(this)
            sw = this.component.machine;
        end
        function this = set.mmppix(this, m)
            this.component.mmppix = m;
            this.logger_.add(sprintf('LoggingNIfTId.set.mmppix <- %s', mat2str(m)));
        end
        function m    = get.mmppix(this)
            m = this.component.mmppix;
        end
        function sw   = get.negentropy(this)
            sw = this.component.negentropy;
        end   
        function x    = get.orient(this)
            x = this.component.orient;
        end  
        function this = set.pixdim(this, p)
            this.mmppix = p;
        end
        function p    = get.pixdim(this)
            p = this.mmppix;
        end   
        function x    = get.seriesNumber(this)
            x = this.component.seriesNumber;
        end  
    end
    
    methods (Static)        
        function this = load(varargin)
            import mlfourd.*;
            this = LoggingNIfTId(NIfTId.load(varargin{:}));
        end
    end

	methods
 		function this = LoggingNIfTId(varargin)
 			%% LOGGINGNIFTID
 			%  Usage:  this = LoggingNIfTId()

 			this = this@mlfourd.NIfTIdecorator(varargin{:});            
            import mlpipeline.*;
            this.logger_ = Logger( ...
                fullfile(this.filepath, [this.fileprefix Logger.FILETYPE_EXT]), this);
            this.logger_.add(sprintf('decorated by %s', class(this)));
        end
        
        function        addLog(this, varargin)
            this.logger_.add(varargin{:});
        end
        function c    = clone(this)
            c = this;
            c.logger_ = mlpipeline.Logger(this.logger_); % copy-construct handle-class Logger
            c.logger_.add('LoggingNIfTId.clone');
        end
        function iter = createIteratorLogger(this)
            iter = this.logger_.createIterator;
        end
        function d    = double(this)
            d = this.component.double;
            this.logger_.add('LoggingNIfTId.double');
        end
        function s    = makeSimilar(this, varargin)
            s = this.component.makeSimilar(varargin{:});
            this.logger_.add(sprintf('LogginNIfTId.makeSimilar(%s)', cell2str(varargin)));
        end
        function o    = ones(this, varargin)
            o = this.component.(varargin{:});
            this.logger_.add(sprintf('LogginNIfTId.ones(%s)', cell2str(varargin)));
        end
        function d    = single(this)
            d = this.component.single;
            this.logger_.add('LoggingNIfTId.single');
        end
        function z    = zeros(this, varargin)
            z = this.component.(varargin{:});
            this.logger_.add(sprintf('LogginNIfTId.zeros(%s)', cell2str(varargin)));
        end
        
        %% IOInterface
        
        function save(this)
            this.component.save;
            this.logger_.fqfileprefix = this.component.fqfileprefix;
            this.logger_.save;
        end
        function this = saveas(this, s)
            this.component = this.component.saveas(s);
            this.logger_.fqfileprefix = this.component.fqfileprefix;
            this.logger_.saveas(s);
        end
        
        %% INIfTI
        
        function this = append_descrip(this, d)
            this.descrip = d;
        end
        function this = prepend_descrip(this, d)
            this.descrip = d;
        end        
    end 
    
    properties (Access = 'private')
        logger_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

