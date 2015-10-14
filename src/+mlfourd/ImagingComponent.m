classdef ImagingComponent <  mlfourd.AbstractNIfTIComponent
	%% IMAGINGCOMPONENT is the root interface for a composite design pattern.
    %
	%  Version $Revision: 2642 $ was created $Date: 2013-09-21 17:58:30 -0500 (Sat, 21 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:30 -0500 (Sat, 21 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingComponent.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: ImagingComponent.m 2642 2013-09-21 22:58:30Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Dependent)
        descrip
        img
        mmppix
        pixdim
    end
    
	properties (SetAccess = 'protected')        
        ext
        filetype % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr
        untouch
    end 
 
    methods (Static)
        function this = load(objs, varargin)
            %% LOAD dispatches to ImagingComposites and ImagingSeries
            %  Usage:   obj = ImagingComposite.load(objects);
            %           obj =    ImagingSeries.load(objects);
            %                                       ^ filenames, NIfTI, NIfTIInterface, ImagingContext,
            %                                         or cell-array of, or ImagingArrayList of
            %  TODO:   use imcast once it is mature
            
            import mlfourd.*;
            this = [];
            try
                if (isa(objs, 'mlfourd.ImagingContext'))
                    this = objs.imcomponent;
                    return
                end
                if (isa(objs, 'mlfourd.NIfTIInterface'))
                    this = ImagingComponent(objs, varargin{:});
                    if (1 == this.length)
                        this = ImagingSeries(this);
                    else
                        this = ImagingComposite(this);
                    end
                    return
                end
                if (isa(objs, 'mlfourd.ImagingArrayList'))
                    this = ImagingComposite.createFromImagingArrayList(objs, varargin{:});
                    return
                end
                if (iscell(objs))
                    this = ImagingComposite.createFromCell(objs, varargin{:});
                    return
                end
                if (ischar(objs))
                    this = ImagingSeries.createFromFilename(objs, varargin{:});
                    return
                end
                error('mlfourd:UnsupportedType', 'class(ImagingComponent.createObjects.objs)->%s', class(objs));
            catch ME
                handwarning(ME);
            end
        end   
    end 
    
    methods %% SET/GET delegate to ImagingComponent.cachedNext, AbstractComponent.componentCurrent_  
        function d  = get.descrip(this)
            d = this.cachedNext.descrip;
        end
        function im = get.img(this)
            im = this.cachedNext.img;
        end
        function m  = get.mmppix(this)
            m = this.cachedNext.mmppix;
        end
        function p  = get.pixdim(this)
            p = this.cachedNext.pixdim;
        end    
    end
    
    methods
        function obj  = clone(this)
            obj = mlfourd.ImagingComponent(this);
        end
        function cmp  = horzcat(this, varargin)
            %% HORZCAT overloads [], manages ImagingComposites, ImagingSeries
            %  Usage:   imaging_composite = [imaging_component imaging_component2 ...]
            
            cal = horzcat@mlfourd.AbstractComponent(this, varargin{:});
            import mlfourd.*;
            if (1 == length(cal))
                cmp = ImagingSeries(cal); return; end
            cmp = ImagingComposite(cal);
        end
        function cmp  = makeSimilar(this, varargin)
            %% MAKESIMILAR makes similar imaging component from this.next, the current component
            
            assert(~isempty(this.cachedNext));
            cmp = this.cachedNext;
            cmp = cmp.makeSimilar(varargin{:}); 
        end
        function this = subsasgn(this, substr, rhs)
            %% SUBSASN overload subscript assignment for '.' and '{}' and '()' to mimic cell-arrays
            
            switch (substr(1).type)
                case '.'
                    this = builtin('subsasgn', this, substr, rhs);
                case '{}' 
                    locs = substr(1).subs{:};
                    if (~isa(rhs, 'mlfourd.AbstractComponent'))
                        rhs = imcast(rhs, 'mlfourd.NIfTI'); end
                    this.componentCurrent_ = this.componentList_.get(locs);   
                    if (length(substr) < 2) 
                        this.componentList_.remove(locs);
                        this.componentList_.add(rhs, locs);
                    else
                        this.componentCurrent_ = ...
                            builtin('subsasgn', this.componentCurrent_, substr(2:end), rhs);
                    end
                case '()'
                    error('mlfourd:NotImplemented', 'subsasgn() not implemented for debugging');
            end
        end
        function obj  = subsref(this, substr)
            %% SUBSREF overloads subscript referencing for '.' and '{}' and '()' to mimic cell-arrays; 
            %  Usage:   imaging_component = obj{n} % component obj, natural number n
            %                       field = obj.field_name
            %                         obj = obj(n) % retains only n-th list element
            
            switch (substr(1).type)
                case '.'
                    if (length(substr) < 2 && strcmp('save', substr.subs))
                              builtin('subsref', this, substr); 
                        obj = [];
                    else
                        obj = builtin('subsref', this, substr);
                    end
                case '{}'   
                    this.componentCurrent_ = this.componentList_.get(substr(1).subs{:});
                    if (length(substr) < 2)                        
                        obj = this.componentCurrent_;
                    else
                        obj = builtin('subsref', this.componentCurrent_, substr(2:end));
                    end
                case '()'
                    error('mlfourd:NotImplemented', 'subsref() not implemented for debugging');
            end
        end  
        
        %% Overloaded methods of mlfourd.AbstractComponent, mlpatterns.ValueList:
        %  prefer convenience, readability and clarity over safety
        
        function this        = add(this, varargin)
            this = this.componentCast( ...
                   add@mlfourd.AbstractComponent(this, ...
                   this.imagingContextCast(varargin{:})));
        end      
        function [this,elts] = remove(this, locs)
            assert(~isempty(this.componentList_));
            [this,elts] = remove@mlfourd.AbstractComponent(this, locs);
             this       = this.componentCast(this);
        end
        
        %% Implemented methods of mlio.IOInterface
        
        function       save(this)
            assert(~isempty(this.cachedNext));
            cn = this.cachedNext;
            cn.save;
        end % save
        function cmp = saveas(this, fn)
            cmp  = this.cachedNext;
            cmp  = cmp.saveas(fn);
        end % saveas         
        
    end 

    %% PROTECTED
    
    methods (Access = 'protected')
        function this = ImagingComponent(varargin)
 			%% IMAGINGCOMPONENT 
 			%  Usage:  component = ImagingComponent([obj,..., obj2])
            %                                        ^ instantiates with empty imaging-array list iff empty;
            %                                          copy-ctor iff any obj is a single ImagingComponent;
            %                                          imaging-array list or any image or any other data type to accumulate
            %          Prefer creation methods.
            %          Using a cell array vector 'cav' will populate the list with numel(cav) unique elements, 
            %          otherwise the input will be treated as a single element.
                    
            this = this@mlfourd.AbstractNIfTIComponent(varargin{:});
        end
        function q    = safe_quotient(this, denom, fg, blur, scale)
            import mlfourd.*;
            assert(isa(denom, 'mlfourd.ImagingComponent'));            
            assert(isa(fg,    'mlfourd.ImagingComponent'));
            assert(isnumeric(blur));
            assert(isnumeric(scale));
            niib = NiiBrowser(this.cachedNext);
            q    = ImagingSeries.load( ...
                       niib.safe_quotient(... 
                           denom.cachedNext, fg.cachedNext, blur, scale));
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
