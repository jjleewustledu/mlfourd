classdef ImagingComponent <  mlfourd.AbstractImage
	%% IMAGINGCOMPONENT is the root interface for a composite design pattern; AbstractImage not yet implemented
    %
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/ImagingComponent.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: ImagingComponent.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
       
    %% ABSTRACTIONS
    
    properties (Abstract)
        
        % Interface from AbstractImage      
        bitpix
        datatype
        descrip
        img
        mmppix
        pixdim 
        fileprefix
        filepath
    end
    
    properties (Abstract, SetAccess = 'protected')
        originalType
    end
    
    %% IMPLEMENTATIONS
    
    properties (Constant)
        FILETYPE_EXT = '.nii.gz';
    end
    
    properties (Dependent)
        cachedNext
        asCellArrayList
        seriesNumber
    end
 
    methods (Static)
        function this = createFromObjects(objs, varargin)
            %% CREATEFROMOBJECTS dispatches to ImagingComposites and ImagingSeries
            %  Usage:   obj = ImagingComposite.createFromObjects(objects);
            %           obj =    ImagingSeries.createFromObjects(objects);
            %                filenames, NIfTI, ImagingComponents ^
            %                or cell-arrays of 
            
            import mlfourd.*;
            objs = ImagingComponent.collectObjects(objs);
            if (iscell(objs))
                this = ImagingComposite.createFromCell(          objs, varargin{:});
            elseif (isa(objs, 'mlpatterns.List'))
                this = ImagingComposite.createFromList(          objs, varargin{:});
            elseif (isa(objs, 'mlfourd.ImageInterface'))
                this = ImagingComponent.createFromImageInterface(objs, varargin{:});
            elseif (ischar(objs))
                this = ImagingSeries.createFromFilename(         objs, varargin{:});
            else
                error('mlfourd:UnsupportedType', 'class(ImagingComponent.createObjects.objs)->%s', class(objs));
            end
        end
        function this = createFromImageInterface(ii, varargin)
            %% CREATEFROMIMAGEINTERFACE simply determines whether the passed ImageInterface is a Composite or Series
            %  Resstrictions:   the call-tree of CREATEFROMIMAGEINTERFACE must never call
            %  ImagingComponent.createFromObjects.   The ctor to ImagingComponent must only be called by the ctors of
            %  ImagingComposite or ImagingSeries
            
            import mlfourd.*;
            assert( isa(ii, 'mlfourd.ImageInterface'));
            cal = ImagingComponent.imageInterface2CellArrayList(ii);
            if (1 == length(cal))
                   this = ImagingSeries(cal, varargin{:});
            else
                this = ImagingComposite(cal, varargin{:});
            end
        end
        function cal  = imageInterface2CellArrayList(ii)
            assert(isa(ii, 'mlfourd.ImageInterface'));
            if (isa(ii, 'mlfourd.ImagingComponent'))
                cal = ii.asCellArrayList;
            elseif (isa(ii, 'mlfourd.NIfTI'))
                cal = mlpatterns.CellArrayList;
                cal.add(ii);
            else
                error('mlfourd:UnsupportedType', 'ImagingComponent.imageInterface2CellArrayList:  class(ii)->%s', class(ii));
            end
            assert(~isempty(cal)); % paranoia
        end        
        function cal  = imagingComponents2CellArrayList(varargin)
            cal = mlpatterns.CellArrayList;
            for v = 1:length(varargin)
                if (isa(varargin{v}, 'mlfourd.ImagingComposite'))
                    for c2 = 1:length(varargin{v})
                        cal.add(varargin{v}.componentList_.get(c2));
                    end
                elseif (isa(varargin{v}, 'mlfourd.ImagingSeries'))
                    cal.add(varargin{v});
                elseif (isa(varargin{v}, 'mlfourd.ImageInterface'))
                    cal.add(mlfourd.ImagingSeries.createFromImageInterface(varargin{v}));
                elseif (iscell(varargin{v}))
                    cal.add(varargin{v});
                else
                    error('mlfourd:UnsupportedType', ...
                          'ImagingComponent.imagingComponent2CellArrayList:  class(varargin{v})->%s', ...
                          class(varargin{v}));
                end
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
        function         save(this)
            assert(~isempty(this.cachedNext));
            this.cachedNext.save;
        end % save
        function         savecopy(this, fn)
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
            empty = this.asCellArrayList.isempty;
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
            elts = this.asCellArrayList.get(locs);
        end        
        function this  = remove( this, locs)
            this.assertComponentListReady('ImagingComponent.remove:  this.componentList_ was unassigned');
            if (1 == this.length)
                this.componentList_     = mlpatterns.CellArrayList;
                this.componentIterator_ = this.componentList_.createIterator;
                this.componentCurrent_  = [];
            else
                this.componentList_.remove(locs);
                this.componentIterator_ = this.asCellArrayList.createIterator;
            end
        end
        function cnt   = countOf(this, elt)
            this.assertComponentListReady('ImagingComponent.countOf:  this.componentList_ was unassigned');
            cnt = this.componentList_.countOf(elt);
        end
        function locs  = locationsOf(this, elt)
            this.assertComponentListReady('ImagingComponent.locationsOf:  this.componentList_ was unassigned');
            locs = this.componentList_.locationsOf(elt);
        end 
        function this  = reset(this)
            if (isempty(this.componentIterator_))
                this.componentIterator_ = this.asCellArrayList.createIterator;
            end
            this.componentIterator_.reset;
        end
        function tf    = hasNext(this)
            if (isempty(this.componentIterator_))
                this.componentIterator_ = this.asCellArrayList.createIterator;
            end
            tf = this.componentIterator_.hasNext;
        end
        function this  = pushNext(this)
            if (isempty(this.componentIterator_))
                this.componentIterator_ = this.asCellArrayList.createIterator;
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
            this.componentList_.add(cc);
            this.componentIterator_ = this.componentList_.createIterator;
            this.componentCurrent_ = cc;
            this = mlfourd.ImagingComponent.createFromObjects(this);
        end

        %% Other methods
        function         forceDouble(this)
            for c = 1:length(this.componentList_) %#ok<FORFLG>
                ele = this.componentList_.get(c); 
                      this.componentList_.remove(c);
                      this.componentList_.add(ele.forceDouble);
            end
        end 
        function cal   = get.asCellArrayList(this)
            if (isempty(this.componentList_))
                this.componentList_ = mlpatterns.CellArrayList;
            end
            cal = this.componentList_;
        end
        function idx   = get.seriesNumber(this)
            [~,trial] = strtok(this.fileprefix, '_');
               trial  = trial(2:4);
               idx    = str2double(trial);
        end 
        
        %% Operator overloading
        function imcmp = subsref(this, substr)
            %% SUBSREF overloads subscript referencing for '.' and '{}'; 
            %  Usage:   imaging_component = obj{n} % component obj, natural number n
            %                       field = obj.field_name;
            %                               obj(...) % throws exception
            
            switch (substr(1).type)
                case '.'
                        imcmp = builtin('subsref', this, substr);
                case '{}'   
                    this.componentCurrent_ = this.componentList_.get(substr(1).subs{:});
                    if (length(substr) < 2)                        
                        imcmp = this.componentCurrent_;
                        return
                    else
                        imcmp = builtin('subsref', this.componentCurrent_, substr(2:end));
                    end
                case '()'
                    error('mlfourd:subsref',...
                          '() is not a supported subscripted reference')
            end
        end
        function imcps = horzcat(this, varargin)
            %% HORZCAT  overload
            %  Usage:   imaging_composite = [imaging_component imaging_component2 ...]
            
            import mlfourd.*;
            cal  = ImagingComponent.imagingComponents2CellArrayList(this);
            cal2 = ImagingComponent.imagingComponents2CellArrayList(varargin{:});
            for c2 = 1:length(cal2)
                cal.add(cal2.get(c2));
            end
            if (length(cal) > 1)
                imcps = ImagingComposite(cal);
            else
                imcps = ImagingSeries(cal);
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
        function this = ImagingComponent(cal)
 			%% IMAGINGCOMPONENT accepts cell-array lists of any object, include more cell-array lists
 			%  Usage:  obj = ImagingComponent(cal)
            %                                 ^ cell-array list, cell-array or any impl. of AbstractImage
            %          Prefer creation methods; accepts elements of any data type as input.
            %          Using a cell array vector 'cav' will populate the list with numel(cav) unique elements, 
            %          otherwise the input will be treated as a single element.
                    
            this = this@mlfourd.AbstractImage;
            if (exist('cal', 'var') && isa(cal, 'mlpatterns.CellArrayList'))
                this.componentList_ = cal;
            else
                this.componentList_ = mlpatterns.CellArrayList;
            end
        end % ctor
    end 

    %% PRIVATE
    
    properties (Constant, Access = 'private')
        OBJS_TO_KEEP = { 'cell' 'mlpatterns.List' 'mlfourd.ImageInterface' 'char' };
    end
    
    properties (Access = 'private')
        converter_
        componentList_
        componentIterator_
        componentCurrent_
    end
    
    methods (Static, Access = 'private')
        function objs = collectObjects(objs0)
            import mlfourd.*;
            for o = 1:length(ImagingComponent.OBJS_TO_KEEP)
                if (isa(objs0, ImagingComponent.OBJS_TO_KEEP{o}))
                    objs = objs0;
                    return
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
                this.componentList_.add( ...
                    ImagingComponent.createFromObjects(varargin{v}));
            end
            this = ImagingComposite(this.componentList_);
        end
    end 
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
