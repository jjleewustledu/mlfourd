classdef ImagingArrayList < mlpatterns.CellArrayList
	%% IMAGINGARRAYLIST is a CellArrayList designed for imaging data; e.g., for ImagingComponent; 
    %  ImagingArrayList.add is robust to adding nested CellArrayLists;
    %  helper method is ensureImagingArrayList, which casts to ImagingArrayList as needed;
    %  child of mlpatterns.List and so is a handle class
    
	%  $Revision: 2618 $
 	%  was created $Date: 2013-09-08 23:15:55 -0500 (Sun, 08 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-08 23:15:55 -0500 (Sun, 08 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingArrayList.m $, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id: ImagingArrayList.m 2618 2013-09-09 04:15:55Z jjlee $
    
    methods (Static)
        function ial = ensureImagingArrayList(varargin)
            %% ENSUREIMAGINGARRAYLIST ...
            %  Usage:  anImagingArrayList = ensureImagingArrayList(obj[, obj2, ..., ...])
            
            import mlfourd.*;
            ial = ImagingArrayList;
            for v = 1:length(varargin)
                ial.add(ImagingArray.flattenLists(varargin{v})); end
            ial = ImagingArrayList(ial);
        end
    end

	methods 
        function add(this, elts, varargin)
            %% ADD wraps mlpatterns.CellArrayList.add to safetly add cell arrays or cell-array lists.
            %  Usage:  ial = ial.add(elementsToAdd[, locationForAdd]) 
            %          ^     ^ anImagingArrayList
            
            import mlfourd.*;
            p = inputParser;
            addRequired(p, 'this',     @(x)  isa(x, 'mlfourd.ImagingArrayList'));
            addRequired(p, 'elts',     @(x) ~isempty(x));
            addOptional(p, 'loc',  [], @(x)  isinf(x) || (isnumeric(x) && isscalar(x)));
            parse(p, this, elts, varargin{:});
            this = p.Results.this;
            elts = this.flattenLists(p.Results.elts);
            if (~isempty(p.Results.loc))
                add@mlpatterns.CellArrayList(this, elts, p.Results.loc);
                return
            end
                add@mlpatterns.CellArrayList(this, elts);
        end
        function cll  = cell(this)
            cll = mlfourd.ImagingArrayList.list2cell(this);
        end
        function obj  = clone(this)
            obj = mlfourd.ImagingArrayList(this);
        end
        function tf   = isempty(this)
            %% ISEMPTY always returns a scalar logical
            tf = all(isempty@mlpatterns.CellArrayList(this));
        end
        function locs = locationsOf(this,elt)
            locs = cell(size(this));
            % Use linear index to populate locs cell array.
            for i = 1:numel(this)
                aList = this(i).list;
                tally = zeros(size(aList));
                for j = 1:length(tally)
                    if (~isempty(aList{j}))
                        tally(j) = isequal(aList{j}, elt);
                    end
                end
                locs{i} = find(tally);
            end
            % Return numerical array if single list operation.
            if numel(locs) == 1
                locs = locs{:};
            end
        end
        function this = ImagingArrayList(varargin)
            %% IMAGINGARRAYLIST is a copy-ctor when varargin{:} is an ImagingArrayList
            
            this = this@mlpatterns.CellArrayList(varargin{:});
        end
    end 

    methods (Static, Access = 'private')
        function obj = flattenLists(obj)
            if (iscell(obj))
                return; end
            if (isa(obj, 'mlpatterns.List'))
                obj = mlfourd.ImagingArrayList.list2cell(obj); return; end
            if (isstruct(obj))
                obj = mlfourd.ImagingArrayList.structs2cell(obj); return; end
            if (isa(obj, 'mlpatterns.ValueList'))
                obj = mlfourd.ImagingArrayList.hl2cell(obj); return; end
        end
        function cll = list2cell(lst)
            assert(isa(lst, 'mlpatterns.List'));
            cll = cell(1, length(lst));
            for c = 1:length(lst)
                cll{c} = lst.get(c);
            end
        end
        function cll = structs2cell(str)
            assert(isstruct(str));
            cll = cell(1, length(str));
            for c = 1:length(str)
                cll{c} = str(c);
            end
        end
        function cll = hl2cell(hl)
            assert(isa(hl, 'mlpatterns.ValueList'));
            cll = cell(1, length(hl));
            for c = 1:length(hl)
                cll{c} = hl.get(c);
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

