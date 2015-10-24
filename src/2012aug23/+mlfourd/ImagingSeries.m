classdef ImagingSeries < mlfourd.ImagingComponent
	%% IMAGINGSERIES is the interface for leaves in composite design patterns
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/ImagingSeries.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ImagingSeries.m 1231 2012-08-23 21:21:49Z jjlee $ 
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
    end
    
    properties (Dependent, SetAccess = 'protected')
        originalType
    end
    
    methods (Static)
        function this = createFromFilename(fn, varargin)
            %% CREATEFROMFILENAME returns an ImagingSeries object iff fn is a filename to a NIfTI that is available on the fileesystem
            %  Usage:   imaging_series_obj = ImgagingSeries.createFromFilename(nifti_filename);
            
            import mlfourd.*;
            assert(ischar(fn));
            assert(lexist(filename(fn), 'file'));
            cal = mlpatterns.CellArrayList;
            cal.add(NIfTI.load_hdr(fn));
            this = ImagingSeries(cal, varargin{:});
        end
    end  
    
	methods
 		function this = ImagingSeries(cal, varargin)
 			%% IMAGINGSERIES 
 			%  Usage:  prefer static, creation methods 
            
            this = this@mlfourd.ImagingComponent(cal, varargin{:});
            assert(length(cal) < 2);
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
        function t    = get.originalType(this)
            t = this.cachedNext.originalType;
        end
        function fp   = get.fileprefix(this)
            fp = this.cachedNext.fileprefix;
        end 
        function pth  = get.filepath(this)
            pth = this.cachedNext.filepath;
        end
        function this = set.filepath(this, pth)
            imcmp = this.cachedNext;
            assert(~isempty(imcmp)); % PARANOIA
            imcmp.filepath = pth;
            this.cachedNext = imcmp;
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

