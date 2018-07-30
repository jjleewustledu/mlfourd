classdef NIfTIdecorator < mlfourd.RootNIfTIdecorator & mlfourd.INIfTIdecorator & mlio.IOInterface
	%% NIFTIDECORATOR maintains an internal component object by composition, 
    %  forwarding most requests to the component.  It retains an interface consistent with the component's interface.
    %  Subclasses may optionally perform additional operations before/after forwarding requests.
    %  Subclasses must overload methods load, clone to ensure that method-returned objects are from the subclass.
    
	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
    
    properties (Dependent)
        component
    end
    
    methods
        
        %% GET/SET
        
        function g = get.component(this)
            g = this.component_;
        end
%         function this = set.component(this, s)
%             this.component_ = s;
%         end
        
        %% IOInterface
        
        function        save(this)
            this.component_.save;
        end
        function obj  = saveas(this, fqfn)
            obj = this.clone;
            obj.component_ = this.component_.saveas(fqfn);
        end
        function obj  = saveasx(this, fqfn, x)
            obj = this.clone;
            obj.component_ = this.component_.saveasx(fqfn, x);
        end
        
        %% INIfTI
        
        function obj  = clone(this)
            obj = this;
            obj.component_ = this.component_.clone;
        end   
        function tf   = isequal(this, niid)
            tf = this.isequaln(niid);
        end
        function tf   = isequaln(this, niid)
            tf = isa(niid, class(this));
            if (tf)
                tf = this.component_.isequaln(niid.component_);
            end
        end
        function this = makeSimilar(this, varargin)
            this.component_ = this.component_.makeSimilar(varargin{:});
        end          
        
        function x    = char(this)
            x = this.component_.char;
        end
        function this = append_descrip(this, varargin)
            this.component_ = this.component_.append_descrip(varargin{:});
        end
        function this = prepend_descrip(this, varargin)
            this.component_ = this.component_.prepend_descrip(varargin{:});
        end
        function x    = double(this)
            x = this.component_.double;
        end
        function x    = duration(this)
            x = this.component_.duration;
        end
        function this = append_fileprefix(this, varargin)
            this.component_ = this.component_.append_fileprefix(varargin{:});
        end
        function this = prepend_fileprefix(this, varargin)
            this.component_ = this.component_.prepend_fileprefix(varargin{:});
        end
        function this = false(this, varargin)
            this.component_ = this.component_.false(varargin{:});
        end
        function f    = fov(this) 
            f = this.component_.fov;     
        end
        function tf   = lexist(this)
            tf = this.component_.lexist;
        end
        function m    = matrixsize(this)
            m = this.component_.matrixsize;
        end
        function this = nan(this, varargin)
            this.component_ = this.component_.nan(varargin{:});
        end
        function this = ones(this, varargin)
            this.component_ = this.component_.ones(varargin{:});
        end
        function x    = rank(this, varargin)
            x = this.component_.rank(varargin{:});
        end
        function this = scrubNanInf(this)
            this.component_ = this.component_.scrubNanInf;
        end
        function x    = single(this)
            x = this.component_.single;
        end
        function x    = size(this, varargin)
            x = this.component_.size(varargin{:});
        end
        function this = true(this, varargin)
            this.component_ = this.component_.true(varargin{:});
        end
        function this = zeros(this, varargin)
            this.component_ = this.component_.zeros(varargin{:});
        end        
                
        %% 
        
        function        addLog(this, varargin)
            this.component_.addLog(varargin{:});
        end
        function        hist(this, varargin)
            this.component_.hist(varargin{:});
        end        
        function tf   = isscalar(this)
            tf = this.component_.isscalar;
        end
        function tf   = isvector(this)
            tf = this.component_.isvector;
        end
        function        freeview(this, varargin)
            this.component_.freeview(varargin{:});
        end        
        function        fsleyes(this, varargin)
            this.component_.fsleyes(varargin{:});
        end
        function        fslview(this, varargin)
            this.component_.fslview(varargin{:});
        end
        function        view(this, varargin)
            this.component_.view(varargin{:});
        end        
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        component_
    end
    
    methods (Access = protected)
 		function this = NIfTIdecorator(varargin) 
            %% NIFTIDECORATOR decorates other INIfTI objects, keeping the passed object as an internal component by composition;
            %  it will not act as a copy-ctor, as all passed objects are kept in a hierarchy of components.
            %  Usage:  obj = NIfTIdecorator(INIfTI_object);

            ip = inputParser;
            ip.KeepUnmatched = true;
            addOptional(ip, 'cmp', mlfourd.NIfTId, @(x) isa(x, 'mlfourd.INIfTI'));
            parse(ip, varargin{:});
            if (isa(ip.Results.cmp, 'mlfourd.NIfTIdecorator'))
                c = ip.Results.cmp;
                this.component_ = c.component_;
                return
            end
            this.component_ = ip.Results.cmp;
        end         
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

