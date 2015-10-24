classdef ImagingComposite < mlfourd.ImagingComponent
	%% IMAGINGCOMPOSITE is the n-tuple interface for composite design patterns
	%  Version $Revision: 2283 $ was created $Date: 2012-09-30 01:03:41 -0500 (Sun, 30 Sep 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-09-30 01:03:41 -0500 (Sun, 30 Sep 2012) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingComposite.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ImagingComposite.m 2283 2012-09-30 06:03:41Z jjlee $ 
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
        filetype
    end
 
    methods (Static) 
        function this = createFromCell(cll, varargin)
            %% CREATEFROMCELL
            %  NB:   cells contain other data objects, including more cells, but cells are never leaves of a data-tree
            
            import mlpatterns.* mlfourd.*;
            assert(iscell(cll));
            cal = CellArrayList;
            for c = 1:length(cll)
                imcmp = ImagingComponent.createFromObjects(cll{c});
                cal = cellArrayListAdd(cal, imcmp.asCellArrayList);
            end
            this = ImagingComposite.createFromCellArrayList(cal, varargin{:});
        end
        function this = createFromCellArrayList(cal, varargin)
            %% CREATEFROMCELLARRAYLIST
            %  NB:   lists contain other data objects, including more lists, but leaves are never leaves of a data-tree
            
            import mlfourd.*;
            assert(isa(cal, 'mlpatterns.CellArrayList'));
            if (1 == length(cal))
                this = ImagingSeries(cal, varargin{:});
            else
                this = ImagingComposite(cal, varargin{:});
            end
        end
    end

	methods 
 		function this = ImagingComposite(varargin) 
 			%% IMAGINGCOMPOSITE accepts a CellArrayList
 			%  Usage:  prefer static, creation methods 

            this = this@mlfourd.ImagingComponent(varargin{:});
            assert(length(this) > 1);
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
        function fp   = get.fileprefix(this)
            fp = this.agetter('fileprefix'); 
        end 
        function pth  = get.filepath(this)
            pth = this.agetter('filepath');
        end
        function this = set.filepath(this, pth)
            this = this.asetter('filepath', pth);
        end 
        function this = set.filetype(this, ft)
            
            %% SET.FILETYPE
            %  0 -> Analyze format .hdr/.img
            %  1 -> NIFTI .hdr/.img
            %  2 -> NIFTI .nii
            
            this = this.asetter('filetype', ft);
        end             
    end
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function gotten = agetter(this, lbl)
            cc = this.cachedNext;
            assert(~isempty(cc));
            gotten = cc.(lbl);
        end
        function this   = asetter(this, lbl, val)
            assert(~isempty(lbl));
            assert(~isempty(val));
            cc = this.cachedNext;
            cc.(lbl) = val;
            this.cachedNext = cc;
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

