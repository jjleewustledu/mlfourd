classdef NamingFacade < mlfourd.NamingInterface
	%% NAMINGFACADE  facade design pattern encapsulating file-naming conventions
	%  $Revision: 2308 $
 	%  was created $Date: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/NamingFacade.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: NamingFacade.m 2308 2013-01-12 23:51:00Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Dependent)
        fslPath
        backupFolder
        allNIfTI
    end
    
    methods (Static)
        function this  = createFromFslPath(pth)
            assert(lexist(pth, 'dir'));
            this = mlfourd.NamingFacade(pth);
        end
        function fn    = ensureNIfTIExtension(fn)
            import mlfourd.*;
            if (isempty(strfind(fn, NIfTI.FILETYPE_EXT)))
                fn = [fn NIfTI.FILETYPE_EXT];
            end
        end % static ensureNIfTIExtension  
    end
    
 	methods	%% set/get
        function pth   = get.fslPath(this)
            pth = this.imagingParser_.fslPath;
        end
        function fld   = get.backupFolder(this)
            fld = this.namingRegistry_.backupFolder;
        end
        function files = get.allNIfTI(this)
            files = this.namingRegistry_.allNIfTI;
        end
    end
    
    methods        
        function fp    = t1(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.t1, varargin{:});
        end        
        function fp    = t2(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.t2, varargin{:});
        end
        function fp    = flair(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.flair, varargin{:});
        end        
        function fp    = flair_abs(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.flair_abs, varargin{:});
        end 
        function fp    = gre(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.gre, varargin{:});
        end 
        function fp    = tof(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.tof, varargin{:});
        end
        function fp    = ep2d(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.ep2d, varargin{:});
        end        
        function fp    = ep2dMeanvol(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.ep2dMean, varargin{:});
        end        
        function fp    = h15o(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.h15o, varargin{:});
        end        
        function fp    = o15o(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.o15o, varargin{:});
        end  
        function fp    = h15oMeanvol(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.h15oMean, varargin{:});
        end        
        function fp    = o15oMeanvol(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.o15oMean, varargin{:});
        end
        function fp    = c15o(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.c15o, varargin{:});
        end 
        function fp    = tr(this, varargin)
            fp = mlfourd.ImagingParser.formFilename(this.imagingParser_.tr, varargin{:});
        end
        function cal   = allPet(this, pth) %#ok<INUSL>
            p = inputParser;
            addOptional(p, 'pth', @(x) lexist(x, 'dir'));
            parse(p, pth);
            cal = mlpatterns.CellArrayList;
            dt  = mlfourd.DirTool(p.Results.pth);
            for f = 1:length(dt.fqfns)
                if (true)
                end
            end
            cal.add(dt.fqfns);
        end
        function tf    = isPet(this, obj)
            tf = this.imagingParser_.isPet(ensureFilename(obj));
        end
        function tf    = isMr(this, obj)
            tf = this.imagingParser_.isMr(ensureFilename(obj));
        end
        function tf    = isAtlas(this, obj)
            tf = this.imagingParser_.isAtlas(ensureFilename(obj));
        end 
        function tf    = onPet(this, obj, pobj)
            assert(this.isPet(obj));
            assert(this.isPet(pobj));
            tf = lstrfind(filename(obj), ...
                [mlfsl.FlirtBuilder.FLIRT_TOKEN fileprefix(this.tr)]);
        end
        function tf    = onMr(~, ~, ~)
            tf = false;
            error('mlfourd:notImplemented', 'NamingFacade.onMr');
        end
        function tf    = onAtlas(this, obj, aobj)
            assert(this.isPet(obj));
            assert(this.isAtlas(aobj));
            tf = lstrfind(filename(obj), ...
                [mlfsl.FlirtBuilder.FLIRT_TOKEN fileprefix(this.atlas)]);
        end
        function fname = xfmName(this, varargin)
            fname = this.imagingParser_.xfmName(varargin{:});
        end
        function obj   = imageObject(this, varargin)
            obj = this.imagingParser_.imageObject(varargin{:});
        end     
    end
    
    methods (Access = 'protected')
 		function this  = NamingFacade(fslpth)
 			%% NAMINGFACADE 
 			%  Usage:  use delegation

            assert(lexist(fslpth) && lstrfind(fslpth, 'fsl'));
            import mlfourd.*;
 			this.imagingParser_ = ImagingParser(fslpth);
            this.namingRegistry_ = NamingRegistry.instance;
 		end %  ctor 
    end 

    %% PRIVATE
    
    properties (Access = 'private')
        imagingParser_
        namingRegistry_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

