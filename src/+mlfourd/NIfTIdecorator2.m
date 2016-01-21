classdef NIfTIdecorator2 < mlfourd.INIfTI & mlio.IOInterface
	%% NIFTIDECORATOR2 maintains an internal component object by composition, 
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
    
    properties (SetAccess = protected)
        component
    end
    
    methods
        
        %% IOInterface
        
        function        save(this)
            this.component.save;
        end
        function obj  = saveas(this, fqfn)
            obj = this.clone;
            obj.component = this.component.saveas(fqfn);
        end
        function obj  = saveasx(this, fqfn, x)
            obj = this.clone;
            obj.component = this.component.saveasx(fqfn, x);
        end
        
        %% INIfTI
        
        function obj  = clone(this)
            obj = this;
            obj.component = this.component.clone;
        end   
        function tf   = isequal(this, niid)
            tf = this.isequaln(niid);
        end
        function tf   = isequaln(this, niid)
            tf = isa(niid, class(this));
            if (tf)
                tf = this.component.isequaln(niid.component);
            end
        end
        function this = makeSimilar(this, varargin)
            this.component = this.component.makeSimilar(varargin{:});
        end          
        
        function x    = char(this)
            x = this.component.char;
        end
        function this = append_descrip(this, varargin)
            this.component = this.component.append_descrip(varargin{:});
        end
        function this = prepend_descrip(this, varargin)
            this.component = this.component.prepend_descrip(varargin{:});
        end
        function x    = double(this)
            x = this.component.double;
        end
        function x    = duration(this)
            x = this.component.duration;
        end
        function this = append_fileprefix(this, varargin)
            this.component = this.component.append_fileprefix(varargin{:});
        end
        function this = prepend_fileprefix(this, varargin)
            this.component = this.component.prepend_fileprefix(varargin{:});
        end
        function f    = fov(this) 
            f = this.component.fov;     
        end
        function m    = matrixsize(this)
            m = this.component.matrixsize;
        end
        function this = ones(this, varargin)
            this.component = this.component.ones(varargin{:});
        end
        function x    = rank(this, varargin)
            x = this.component.rank(varargin{:});
        end
        function this = scrubNanInf(this)
            this.component = this.component.scrubNanInf;
        end
        function x    = single(this)
            x = this.component.single;
        end
        function x    = size(this, varargin)
            x = this.component.size(varargin{:});
        end
        function this = zeros(this, varargin)
            this.component = this.component.zeros(varargin{:});
        end        
                   
        function        freeview(this, varargin)
            this.component.freeview(varargin{:});
        end        
        function        fslview(this, varargin)
            this.component.fslview(varargin{:});
        end
    end 
    
    methods (Access = protected)
 		function this = NIfTIdecorator2(varargin) 
            %% NIFTIDECORATOR2 decorates other INIfTI objects, keeping the passed object as an internal component by composition;
            %  it will not act as a copy-ctor, as all passed objects are kept in a hierarchy of components.
            %  Usage:  obj = NIfTIdecorator2(INIfTI_object);

            ip = inputParser;
            addOptional(ip, 'cmp', mlfourd.NIfTId, @(x) isa(x, 'mlfourd.INIfTI'));
            parse(ip, varargin{:});
            this.component = ip.Results.cmp;
        end         
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

