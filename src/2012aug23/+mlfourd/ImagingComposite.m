classdef ImagingComposite < mlfourd.ImagingComponent
	%% IMAGINGCOMPOSITE is the n-tuple interface for composite design patterns
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/ImagingComposite.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ImagingComposite.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Dependent)
        
        %% Interface from AbstractImage      
        bitpix
        datatype
        descrip
        img
        mmppix
        pixdim 
        fileprefix
        filepath
    end
    
    properties (Dependent, SetAccess = 'protected')
        originalType
    end
    
    methods (Static) 
        function this = createFromCell(cll, varargin)
            %% CREATEFROMCELL
            %  NB:   cells contain other data objects, including more cells, but cells are never leaves of a data-tree
            
            import mlfourd.*;
            assert(iscell(cll));
            lst = mlpatterns.CellArrayList;
            lst.add(cll);
            this = ImagingComposite.createFromList(lst, varargin{:});
        end
        function this = createFromList(lst, varargin)
            %% CREATEFROMLIST
            %  NB:   lists contain other data objects, including more lists, but leaves are never leaves of a data-tree
            
            import mlfourd.*;
            assert(isa(lst, 'mlpatterns.List'));
            if (1 == length(lst))
                this = ImagingSeries(lst.get(1), varargin{:});
            else                
                cal = mlpatterns.CellArrayList;
                for s = 1:length(lst)
                    cal.add(ImagingComposite.createFromObjects(lst.get(s)));
                end
                this = ImagingComposite(cal, varargin{:});
            end
        end
    end

	methods 
 		function this = ImagingComposite(cal, varargin) 
 			%% IMAGINGCOMPOSITE accepts a CellArrayList
 			%  Usage:  prefer static, creation methods 

            this = this@mlfourd.ImagingComponent(cal, varargin{:});
            assert(length(cal) > 1);
 		end %  ctor        
        
 		%% Implementations of AbstractImage        
        function bit  = get.bitpix(this)
            bit = this.agetter('bitpix');
        end
        function dt   = get.datatype(this)
            dt = this.agetter('datatype');
        end
        function d    = get.descrip(this)
            d = this.agetter('descrip');
        end
        function im   = get.img(this)
            im = this.agetter('img');
        end
        function mm   = get.mmppix(this)
            mm = this.agetter('mmppix');
        end
        function dim  = get.pixdim(this)
            dim = this.agetter('pixdim');
        end
        function t    = get.originalType(this)
            t = this.agetter('originalType');
        end
        function fp   = get.fileprefix(this)
            fp = this.agetter('fileprefix'); 
        end 
        function pth  = get.filepath(this)
            pth = this.agetter('filepath');
        end
        function this = set.filepath(this, pth)
            imcmp = this.cachedNext; % PARANOIA
            assert(~isempty(imcmp));
            imcmp.filepath = pth;
            this.cachedNext = imcmp;
        end 
    end
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function gotten = agetter(this, lbl)
            cc = this.cachedNext;
            assert(~isempty(cc));
            gotten = cc.(lbl);
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

