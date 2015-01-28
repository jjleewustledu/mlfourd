classdef AbstractComponent <  mlio.AbstractComponentIO & mlpatterns.ValueList
	%% ABSTRACTCOMPONENT is a child class of mlio.AbstractIOInterface, inheriting the AbstractComponentIO fork from AbstractIO.   
    %  Component characteristics arise from mlpatterns.ValueList, which resembles mlpatterns.List but is a value class.
    %  Uses:   mlfourd.ImagingArrayList, which is more robust with adding Lists
    %  Yet abstract:  mlio.IOInterface method save
    %                 mlpatterns.ValueList method clone
    
	%  $Revision: 2618 $
 	%  was created $Date: 2013-09-08 23:15:55 -0500 (Sun, 08 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-08 23:15:55 -0500 (Sun, 08 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AbstractComponent.m $, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id: AbstractComponent.m 2618 2013-09-09 04:15:55Z jjlee $
	
    properties (Dependent)
        asList
        cachedNext
    end
    
    methods %% SET/GET
        function ial  = get.asList(this)
            ial = mlfourd.ImagingArrayList(this.componentList_);
        end
        function this = set.cachedNext(this, cc)
            %% SET.CACHEDNEXT replaces the current element of the internal list in situ with loss of data
            
            assert(isa(cc, 'mlfourd.NIfTIInterface'));
            if (isempty(this.componentCurrent_))
                this.componentList_.add(cc);
            end
            locs = this.locationsOf(this.componentCurrent_);
            this.componentList_.remove(locs);
            this.componentList_.add(cc, locs);
        end
        function cmp  = get.cachedNext(this)
            %% GET.CACHEDNEXT returns a cached copy of the current component without changing the iterator of the internal list
            %  Usage:   cachedComponent = obj.cachedNext;            
            
            cmp = this.componentCurrent_.clone; 
        end       
    end
    
    methods            
        function cll  = cell(this)
            cll = this.componentList_.cell;
        end
        function this = compfun(this, fun, varargin)
            %% COMPFUN Apply a function to each element of a composite (AbstractComponent).
            %  A = compfun(C, FUN[, ARGS]) applies the function specified by FUN to the
            %  contents of each element of composite C, and returns the results in
            %  composite A.  A is the same size as C, and the (I,J,...)th element of A
            %  is equal to FUN(C{I,J,...}[, ARGS]). FUN is a function handle to a method of C
            %  that may also take arguments ARGS.  The order in which compfun computes 
            %  elements of A is not specified and should not be relied on.
            
            this = this.reset;
            while (this.hasNext)
                this = this.iterateNext;
                this = fun(this, varargin{:});
            end
        end
        function tf   = hasNext(this)
            assert(~isempty(this.componentIterator_));
            tf = this.componentIterator_.hasNext;
        end
        function cmp  = horzcat(this, varargin)
            %% HORZCAT overloads []
            %  Usage:   imaging_composite = [imaging_component imaging_component2 ...]
            
            if (isempty(this.componentList_))
                this.componentList_ = mlfourd.ImagingArrayList; end
            for v = 1:length(varargin)
                this.componentList_.add(varargin{v});
            end
            cmp = this.clone;
        end
        function tf   = isequal(this, imcmp)
            tf = isa(imcmp, class(this));
            if (tf)
                for c = 1:length(this)
                    tf = tf && isequal(this.get(c), imcmp.get(c));
                end
                tf = this.fieldsequal(imcmp);
            end
        end   
        function this = iterateNext(this)
            assert(~isempty(this.componentIterator_));
            this.componentCurrent_ = this.next;
        end
        function cmp  = next(this)
            assert(~isempty(this.componentIterator_));
            this.componentCurrent_ = this.componentIterator_.next;
            cmp = this.componentCurrent_.clone;
        end
        function this = reset(this)
            %% RESET:  lhs this required by subsref of concrete ImagingComponent classes
            
            assert(~isempty(this.componentIterator_));
            this.componentIterator_.reset;
        end
        function cmp  = vertcat(this, varargin)
            cmp = this.horzcat(varargin{:});
        end
        
        %% Implementations of mlpatterns.ValueList
        
        function nElts       = length(this)
            if (isempty(this.componentList_))
                nElts = 0; return; end
            nElts = this.componentList_.length;
        end         
        function tf          = isempty(this)
            if (isempty(this.componentList_))
                tf = true; return; end
            tf = this.componentList_.isempty;
        end
        function this        = add(this, varargin)
            %% ADD accumulates the internal component list:
            %  applies the copy-ctor for any passed AbstractComponent (resetting internal state)
            %  or accumulating all other data types
            
            import mlfourd.*;
            if (isempty(this.componentList_))
                this.componentList_ = ImagingArrayList; end
            assert(~isempty(varargin));
            
            for v = 1:length(varargin)
                if (isa(varargin{v}, 'mlfourd.AbstractComponent'))
                    this.componentList_.add(varargin{v}.componentList_);
                else
                    this.componentList_.add(varargin{v});
                end
            end
        end          
        function elts        = get(this, varargin)
            if (isempty(this.componentList_))
                elts = []; return; end
            elts = this.componentList_.get(varargin{:});
        end
        function [this,elts] = remove(this, locs)
            if (isempty(this.componentList_))
                elts = []; return; end
            elts = this.componentList_.remove(locs);
        end  
        function cnt         = countOf(this, elt)
            assert(~isempty(this.componentList_));
            cnt = this.componentList_.countOf( ...
                  this.imagingContextCast(elt));
        end
        function locs        = locationsOf(this, elt)
            assert(~isempty(this.componentList_));
            locs = this.componentList_.locationsOf( ...
                   this.imagingContextCast(elt));
        end 
        function str         = char(this)
            if (isempty(this.componentList_))
                str = ''; return; end
            str = this.componentList_.char;
        end
        function this        = display(this)
            %% DISPLAY:  lhs this required by subsref of concrete ImagingComponent classes
            if (~isempty(this.componentList_))
                this.componentList_.display; end
        end
        function iter        = createIterator(this)
            assert(~isempty(this.componentList_));
            iter = this.componentList_.createIterator;
        end
    end
    
    %% PROTECTED
    
    properties (Access = 'protected')
        componentList_
        componentIterator_
        componentCurrent_
    end
    
    methods (Static, Access = 'protected')
        function obj  = componentCast(obj)
            import mlfourd.*;
            assert(isa(obj, 'mlpatterns.ValueList') || isa(obj, 'mlpatterns.List'));
            if (1 == length(obj) || isempty(obj))
                obj = ImagingSeries(obj);
                return
            end
            obj = ImagingComposite(obj);
        end
        function elts = imagingContextCast(elts)
            import mlfourd.*;
            if (isa(elts, 'mlfourd.ImagingContext'))
                elts = ImagingComponent.imcomponent2cell(elts.imcomponent); return; end
            if (isa(elts, 'mlfourd.ImagingComponent'))
                elts = ImagingComponent.imcomponent2cell(elts); return; end
            if (isa(elts, 'mlfourd.NIfTIInterface'))
                return; end
            error('mlfourd:unsupportedTypeclass', 'class(ImagingComponent.imagingContextCast.elts)->%s', class(elts));
        end
        function cll  = imcomponent2cell(imcmp)
            cll = cell(1, length(imcmp));
            for c = 1:length(imcmp)
                cll{c} = imcmp.get(c);
            end
        end
    end
    
    methods (Access = 'protected')
        function this = AbstractComponent(varargin)
            %% ABSTRACTCOMPONENT 
 			%  Usage:  this = this@AbstractComponent([obj,..., obj2])
            %                                        ^ instantiates with empty imaging-array list iff empty;
            %                                          copy-ctor if any obj is an AbstractComponent;
            %                                          copy-ctor if any obj is a List
            %                                          adds         any other data type
            %          Prefer creation methods.
            %          Using a ValueList object 'vlo' will populate the list with numel(vlo) unique elements.
            %          Using a cell array vector 'cav' will populate the list with numel(cav) unique elements. 
            %          Otherwise, the input will be treated as a single element.

            for v = 1:length(varargin)
                this = this.updateValueList(varargin{v});
            end
        end
        function tf   = fieldsequal(this, imobj)
            try
                tf   = true;
                flds = fieldnames(this);
                for f = 1:length(flds)
                    if (isempty(lstrfind(flds{f}, mlfourd.NIfTI.ISEQUAL_IGNORES)))
                        tf = tf && isequal(this.(flds{f}), imobj.(flds{f}));
                        if (~tf); break; end
                    end
                end
            catch ME
                if (mlpipeline.PipelineRegistry.instance.verbosity > 0.98)
                    handwarning(ME); end
                tf = false;
            end
        end
        function this = updateValueList(this, elts)
            import mlfourd.*;
            if (isempty(this.componentList_))
                this.componentList_ = ImagingArrayList; end
            
            % copy-ctor
            if (isa(elts, 'mlfourd.AbstractComponent'))
                this.componentList_ = ImagingArrayList(elts.componentList_);
                this = this.updateIterator;
                return
            end
            
            % copy-ctor for internal List
            if (isa(elts, 'mlfourd.ValueList') || isa(elts, 'mlpatterns.List'))
                this.componentList_ = ImagingArrayList(elts);
                this = this.updateIterator;
                return
            end
                
            this.componentList_.add(elts);
            this = this.updateIterator;
        end
        function this = updateIterator(this)
            this.componentIterator_ = this.componentList_.createIterator;
            this = this.updateCurrent;
        end
        function this = updateCurrent(this)
            if (this.componentIterator_.hasNext)
                this.componentCurrent_ = this.componentIterator_.next; end
        end
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

