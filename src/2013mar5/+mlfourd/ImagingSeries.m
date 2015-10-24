classdef ImagingSeries < mlfourd.ImagingComponent
	%% IMAGINGSERIES is the interface for leaves in composite design patterns
	%  Version $Revision: 2318 $ was created $Date: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingSeries.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ImagingSeries.m 2318 2013-01-20 06:52:48Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Dependent)
        
        % Concrete implementations of AbstractImage        
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
        function this = createFromFilename(fn, varargin)
            %% CREATEFROMFILENAME returns an ImagingSeries object iff fn is a 
            %                     filename to a NIfTI that is available on the fileesystem
            %  Usage:   imaging_series_obj = ImgagingSeries.createFromFilename(nifti_filename);
            
            import mlpatterns.* mlfourd.*;
            cal = CellArrayList;
            cal.add(NIfTI.load(fn));
            this = ImagingSeries(cal, varargin{:});
        end
        function this = createFromNIfTI(nii, varargin)
            assert(isa(nii, 'mlfourd.NIfTI'));
            cal = mlpatterns.CellArrayList;
            cal.add(nii);
            this = mlfourd.ImagingSeries(cal, varargin{:});
        end
    end  
    
	methods
 		function this = ImagingSeries(varargin)
 			%% IMAGINGSERIES expects a cell-array list
            
            this = this@mlfourd.ImagingComponent(varargin{:});
            assert(length(this) < 2);
 		end %  ctor 
        
        %% Implementations of AbstractImage:  must override ImagingComponent
        function bit  = get.bitpix(this)
            bit = this.cachedNext.bitpix;
        end
        function dt   = get.datatype(this)
            dt = this.cachedNext.datatype;
        end
        function d    = get.descrip(this)
            d  = this.cachedNext.descrip;
        end
        function im   = get.img(this)
            cmp = this.cachedNext;
            im  = cmp.img;
        end
        function mm   = get.mmppix(this)
            mm = this.cachedNext.mmppix;
        end
        function dim  = get.pixdim(this)
            dim = this.cachedNext.pixdim;
        end
        function fp   = get.fileprefix(this)
            fp = this.cachedNext.fileprefix;
        end 
        function pth  = get.filepath(this)
            pth = this.cachedNext.filepath;
        end
        function this = set.filepath(this, pth)
            assert( ischar(pth));
            assert(~isempty(this.cachedNext));
            imcmp = this.cachedNext;
            imcmp.filepath = pth;
            this.cachedNext = imcmp;
        end 
        function this = set.filetype(this, ft)
            
            %% SET.FILETYPE
            %  0 -> Analyze format .hdr/.img
            %  1 -> NIFTI .hdr/.img
            %  2 -> NIFTI .nii
            assert(isnumeric(ft));
            this.cachedNext.filetype = ft;
        end             

        %% Other methods
        function q    = safe_quotient(this, iSeries, fgSeries, blur, scale)
            import mlfourd.*;
            assert(isa(iSeries,  'mlfourd.ImagingSeries'));            
            assert(isa(fgSeries, 'mlfourd.ImagingSeries'));
            assert(isnumeric(blur));
            assert(isnumeric(scale));
            niib = NiiBrowser(this.cachedNext);
            q    = ImagingSeries.createFromObjects( ...
                       niib.safe_quotient(... 
                           iSeries.cachedNext, fgSeries.cachedNext, blur, scale));
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

