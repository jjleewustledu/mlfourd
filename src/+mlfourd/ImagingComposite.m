classdef ImagingComposite < mlfourd.ImagingComponent
	%% IMAGINGCOMPOSITE is the n-tuple interface for composite design patterns
	%  Version $Revision: 2618 $ was created $Date: 2013-09-08 23:15:55 -0500 (Sun, 08 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-08 23:15:55 -0500 (Sun, 08 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingComposite.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ImagingComposite.m 2618 2013-09-09 04:15:55Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    methods (Static) 
        function this = createFromCell(cll, varargin)
            %% CREATEFROMCELL
            %  NB:   cells contain other data objects, including more cells, but cells are never leaves of a data-tree
            
            import mlpatterns.* mlfourd.*;
            assert(iscell(cll));
            ial = mlfourd.ImagingArrayList;
            for c = 1:length(cll)
                imcmp = ImagingComponent.load(cll{c});
                for d = 1:length(imcmp)
                    ial.add(imcmp.get(d));
                end
            end
            this = ImagingComposite.createFromImagingArrayList(ial, varargin{:});
        end
        function this = createFromImagingArrayList(ial, varargin)
            %% CREATEFROMCELLARRAYLIST
            %  NB:   lists contain other data objects, including more lists, but leaves are never leaves of a data-tree
            
            import mlfourd.*;
            assert(isa(ial, 'mlfourd.ImagingArrayList'));
            if (1 == length(ial) || isempty(ial))
                this = ImagingSeries(ial, varargin{:});
            else
                this = ImagingComposite(ial, varargin{:});
            end
        end
    end

	methods 
        function obj  = clone(this)
            import mlfourd.*;
            if (1 == length(this))
                obj = ImagingSeries(this); return; end
            obj = ImagingComposite(this);
        end
 		function this = ImagingComposite(varargin) 
 			%% IMAGINGCOMPOSITE accepts a CellArrayList
 			%  Usage:  prefer static, creation methods 

            this = this@mlfourd.ImagingComponent(varargin{:});
            assert(length(this) > 1);
 		end %  ctor        
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

