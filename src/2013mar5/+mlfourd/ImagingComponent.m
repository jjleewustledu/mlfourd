classdef ImagingComponent <  mlfourd.AbstractImage
	%% IMAGINGCOMPONENT is the root interface for a composite design pattern; AbstractImage not yet implemented
    %  Uses:   mlfourd.FilenameFilters.getSeriesNumber
    %
	%  Version $Revision: 2321 $ was created $Date: 2013-01-21 00:17:57 -0600 (Mon, 21 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-21 00:17:57 -0600 (Mon, 21 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingComponent.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: ImagingComponent.m 2321 2013-01-21 06:17:57Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
       
    %% ABSTRACTIONS
    
    properties (Abstract)
        
        % Interface from AbstractImage
        filepath
        fileprefix
        filetype
        bitpix
        datatype
        descrip
        img
        mmppix
        pixdim 
    end
    
    %% IMPLEMENTATIONS

    properties (Dependent)
        cachedNext
        asCellArrayList
    end
 
    methods (Static)
        function this = load(objs, varargin)
            this = mlfourd.ImagingComponent.createFromObjects(objs, varargin{:});
        end
        function this = createFromObjects(objs, varargin)
            %% CREATEFROMOBJECTS dispatches to ImagingComposites and ImagingSeries
            %  Usage:   obj = ImagingComposite.createFromObjects(objects);
            %           obj =    ImagingSeries.createFromObjects(objects);
            %                filenames, NIfTI, ImagingComponents ^
            %                or cell-arrays of 
            
            import mlfourd.*;
            if (iscell(objs))
                this = ImagingComposite.createFromCell(           objs, varargin{:});
            elseif (isa(objs, 'mlpatterns.CellArrayList'))
                this = ImagingComposite.createFromCellArrayList(  objs, varargin{:});
            elseif (isa(objs, 'mlfourd.ImageInterface'))
                this = ImagingComponent.createFromImageInterfaces(objs, varargin{:});
            elseif (ischar(objs))
                this = ImagingSeries.createFromFilename(          objs, varargin{:});
            else
                error('mlfourd:UnsupportedType', 'class(ImagingComponent.createObjects.objs)->%s', class(objs));
            end
        end
        function this = createFromImageInterfaces(ii, varargin)
            %% CREATEFROMIMAGEINTERFACES determines whether the passed ImageInterface is a Composite or Series
            
            import mlfourd.*;
            cal = ImagingComponent.imageInterfaces2CellArrayList(ii);
            if (1 == length(cal))
                this = ImagingSeries(cal, varargin{:});
            else
                this = ImagingComposite(cal, varargin{:});
            end
        end     
        function cal  = imageInterfaces2CellArrayList(varargin)
            import mlfourd.*;
            cal = ImagingComponent.imageInterface2CellArrayList(varargin{1});
            for v = 2:length(varargin)
                if (isa(varargin{v}, 'mlfourd.ImageInterface'))
                    cal  = cellArrayListAdd(cal, ...
                           ImagingComponent.imageInterface2CellArrayList(varargin{v}));
                else
                    error('mlfourd:UnsupportedType', ...
                          'ImagingComponent.imageInterfaces2CellArrayList:  class(varargin{v})->%s', ...
                           class(varargin{v}));
                end
            end
        end
        function cal  = imageInterface2CellArrayList(ii)
            assert(isa(ii, 'mlfourd.ImageInterface'));
            if (isa(ii, 'mlfourd.ImagingComponent'))
                cal = ii.asCellArrayList;
            elseif (isa(ii, 'mlfourd.NIfTI'))
                cal = mlpatterns.CellArrayList;
                cal = cellArrayListAdd(cal, ii);
            else
                error('mlfourd:UnsupportedType', ...
                      'ImagingComponent.imageInterface2CellArrayList:  class(ii)->%s', ...
                       class(ii));
            end
        end
    end % static methods
    
    methods
        
        %% Implementation of AbstractImage
        function cmp   = makeSimilar(this, varargin)
            %% MAKESIMILAR makes similar imaging component from this.next, the current component
            
            assert(~isempty(this.cachedNext));
            cmp = this.cachedNext;
            cmp = cmp.makeSimilar(varargin{:}); 
        end % makeSimilar
        function this  = save(this)
            assert(~isempty(this.cachedNext));
            this.cachedNext.save;
        end % save
        function this  = savecopy(this, fn)
            this.filename = fn;
            this.save;
        end % savecopy
        function cmp   = saveas(this, fn)
            assert(~isempty(this.cachedNext))
            cmp  = this.cachedNext;
            cmp  = cmp.saveas(fn);
        end % saveas        
        
        %% Implementation of mlpatterns.List, delegations
        %% Prefer readability and clarity over safety
        function nElts = length( this)
            nElts = this.componentList_.length;
        end 
        function empty = isempty(this)
            empty = this.componentList_.isempty;
        end
        function this  = add(    this, varargin)
            %% ADDCOMPONENT
            %  NOTE:  This method accepts mlfourd.ImageInterface as input.
            %  Using a cell array vector 'cav' will populate the list with
            %  numel(cav) unique elements, otherwise the input will be treated as
            %  a single element.
            
            if (this.isempty && 1 == length(varargin))
                this = this.imagingSeriesAdd(varargin{1});
            else
                this = this.imagingCompositeAdd(varargin{:});
            end
        end
        function elts  = get(    this, locs)
            this.assertComponentListReady('ImagingComponent.get:  this.componentList_ was unassigned');
            elts = this.componentList_.get(locs);
        end        
        function this  = remove( this, locs)
            this.assertComponentListReady('ImagingComponent.remove:  this.componentList_ was unassigned');
            if (1 == this.length)
                this.componentList_     = mlpatterns.CellArrayList;
                this.componentIterator_ = this.componentList_.createIterator;
                this.componentCurrent_  = [];
            else
                this.componentList_.remove(locs);
                this.componentIterator_ = this.componentList_.createIterator;
            end
        end
        function cnt   = countOf(this, elt)
            this.assertComponentListReady('ImagingComponent.countOf:  this.componentList_ was unassigned');
            cnt = this.componentList_.countOf(elt);
        end
        function iter  = createIterator(this)
            iter = this.componentList_.createIterator;
        end
        function locs  = locationsOf(this, elt)
            this.assertComponentListReady('ImagingComponent.locationsOf:  this.componentList_ was unassigned');
            locs = this.componentList_.locationsOf(elt);
        end 
        function kludg = reset(this)
            if (isempty(this.componentIterator_))
                this.componentIterator_ = this.componentList_.createIterator;
            end
            this.componentIterator_.reset;
            kludg = [];
        end
        function tf    = hasNext(this)
            if (isempty(this.componentIterator_))
                this.componentIterator_ = this.componentList_.createIterator;
            end
            tf = this.componentIterator_.hasNext;
        end
        function this  = pushNext(this)
            if (isempty(this.componentIterator_))
                this.componentIterator_ = this.componentList_.createIterator;
            end
            if (this.componentIterator_.hasNext)
                this.componentCurrent_ = this.componentIterator_.next;
            else
                error('mlfourd:ReferenceBeforeAssignment', 'ImagingComponent.pushNext called but does not have a next component');
            end
        end
        function cmp   = get.cachedNext(this)
            %% CACHEDNEXT returns a cached copy of the current component; NB pushNext
            %  Usage:   cached_component = obj.cachedNext;            
            
            if (1 == this.length || isempty(this.componentCurrent_))
                this.componentCurrent_ = this.get(1);
            end
            cmp = this.componentCurrent_;
        end        
        function this  = set.cachedNext(this, cc)
            %% SETNEXT
            %  Usage:   obj = obj.setNext(new_component)
            
            assert(isa(cc, 'mlfourd.ImageInterface'));
            locs = this.locationsOf(this.componentCurrent_);
            this.componentList_.remove(locs);
            this.componentList_ = cellArrayListAdd(this.componentList_, cc);
            this.componentIterator_ = this.componentList_.createIterator;
            this.componentCurrent_ = cc;
            this = mlfourd.ImagingComponent.createFromObjects(this);
        end

        %% Other methods
        function imcmp = cmpfun(this, fhandle)
            %% CMPFUN mimics cellfun for ImagingComponent objects
            
            imcmp = this.copy;
            cal = mlpatterns.CellArrayList;
            this.reset;
            while (this.hasNext)
                this = this.pushNext;
                tmp  = fhandle(this.cachedNext);
                if (~isempty(tmp))
                    cal.add(tmp);
                end
            end
            imcmp.componentList_ = cal;
        end
        function imcmp = copy(this)
            imcmp = this;
            imcmp.componentList_ = cellArrayListCopy(this.componentList_);
        end
        function this  = forceDouble(this)
            for c = 1:length(this.componentList_) %#ok<FORFLG>
                ele = this.componentList_.get(c); 
                      this.componentList_.remove(c);
                      this.componentList_ = cellArrayListAdd(this.componentList_, ele.forceDouble);
            end
        end
        function cal   = get.asCellArrayList(this)
            assert(~isempty(this.componentList_));
            cal = cellArrayListCopy(this.componentList_);
        end
        
        %% Operator overloading
        function imcmp = subsref(this, substr)
            %% SUBSREF overloads subscript referencing for '.' and '{}' and '()' to mimic cell-arrays; 
            %  Usage:   imaging_component = obj{n} % component obj, natural number n
            %                       field = obj.field_name
            %                         obj = obj(n) % retains only n-th list element
            
            switch (substr(1).type)
                case '.'
                        imcmp = builtin('subsref', this, substr);
                case '{}'   
                    this.componentCurrent_ = this.componentList_.get(substr(1).subs{:});
                    if (length(substr) < 2)                        
                        imcmp = this.componentCurrent_;
                    else
                        imcmp = builtin('subsref', this.componentCurrent_, substr(2:end));
                    end
                case '()'
                    error('mlfourd:NotImplemented', 'subsref() not implemented for debugging');
%                     tmp = this.componentList_.get(substr(1).subs{:});
%                     this.componentList_ = mlpatterns.CellArrayList;
%                     this.componentList_ = cellArrayListAdd(this.componentList_, tmp);
%                     if (length(substr) < 2)
%                         imcmp = this;
%                     else
%                         imcmp = builtin('subsref', this, substr(2:end));
%                     end
            end
        end
        function tf    = isequal(this, imcmp)
            tf = isa(imcmp, class(this));
            if (tf)
                this.reset; 
                imcmp.reset;
                while (this.hasNext && imcmp.hasNext)
                    this  = this.pushNext;
                    imcmp = imcmp.pushNext;
                    tf    = tf && isequal(this.cachedNext, imcmp.cachedNext);
                end
            end
        end
    end % methods

    %% PROTECTED
    
    methods (Access = 'protected')
        function this = ImagingComponent(obj)
 			%% IMAGINGCOMPONENT 
 			%  Usage:  component = ImagingComponent([obj])
            %                                        ^ cell-array list or any image or any other data type
            %                                          if empty, instantiates with empty cell-array list
            %          Prefer creation methods.
            %          Using a cell array vector 'cav' will populate the list with numel(cav) unique elements, 
            %          otherwise the input will be treated as a single element.
                    
            this = this@mlfourd.AbstractImage;
            import mlpatterns.* mlfourd.*;
            if (~exist('obj', 'var')); obj = CellArrayList; end
            if (isa(obj, 'mlpatterns.CellArrayList'))
                this.componentList_ = obj;
            else
                this.componentList_ = CellArrayList;
                this.componentList_ = cellArrayListAdd(this.componentList_, obj);
            end
        end % ctor
    end
    
    %% PRIVATE
    
    properties (Constant, Access = 'private')
        OBJS_TO_KEEP = { 'cell' 'mlpatterns.HandlelessListInterface' 'mlfourd.ImageInterface' 'char' };
    end
    
    properties (Access = 'private')
        componentList_
        componentIterator_
        componentCurrent_
    end
    
    methods (Static, Access = 'private')
        function objs = ensureFilenameSuffixes(objs0)
            import mlfourd.*;
            switch (class(objs0))
                case {'char' 'cell'}
                    objs = ImagingParser.ensureFilenameSuffixes(objs0);
                otherwise
                    if (isa(objs0, 'mlpatterns.HandlelessListInterface'))
                        objs = mlpatterns.CellArrayList;
                        for o = 1:length(objs0)
                            tmp = ImagingComponent.ensureFilenameSuffixes(objs0.get(o));
                            if (~isempty(tmp))
                                objs.add(tmp); end
                        end
                    elseif (isa(objs0, 'mlfourd.ImagingInterface'))
                        objs = objs0;
                    else
                        error('mlfourd:unsupportedType', ...
                            'ImagingComponent.ensureFilenameSuffix does not support %s', class(objs0));
                    end
            end
        end
    end
    
    methods (Access = 'private')
        function        assertComponentListReady(this, errmsg)
            if (iscell(errmsg)); errmsg = errmsg{:}; end
            assert(~isempty(this.componentList_), 'mlfourd:attemptToUseUninitializedObject', errmsg);            
        end
        function this = imagingSeriesAdd(this, obj)  %#ok<MANU>
            this = mlfourd.ImagingSeries.createFromObjects(obj);
        end
        function this = imagingCompositeAdd(this, varargin)
            import mlfourd.*;
            if (isempty(this.componentList_))
                this.componentList_ = mlpatterns.CellArrayList;
            end
            for v = 1:length(varargin)              
                this.componentList_ = cellArrayListAdd( ...
                    this.componentList_, ImagingComponent.createFromObjects(varargin{v}));
            end
            this = ImagingComposite(this.componentList_);
        end
    end 
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
