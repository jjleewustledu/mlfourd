classdef PETImagingComponent < mlfourd.ImagingComponent
	%% PETIMAGINGCOMPONENT implements interface ImagingComponent
	%  Version $Revision: 2308 $ was created $Date: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/PETImagingComponent.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: PETImagingComponent.m 2308 2013-01-12 23:51:00Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties    
        butanolCorrected = false;
    end
    
    properties (Dependent)
        converter
        sessionPath
        petFolder
        petPath
        path962
        tracers
        tries    
        hdrPath
        hdrFilenames
    end
    
	methods 		
        function this  = set.converter(this, cvert)
            assert( isa(cvert, 'mlfourd.ConverterInterface'));
            assert(~isempty(this.builder));
            this.converter_ = cvert;
        end
        function cvert = get.converter(this)
            cvert = this.converter_;
        end
        function this  = set.sessionPath(this, pth)
            this.converter.sessionPath = pth;
        end
        function pth  = get.sessionPath(this)
            if (~isempty(this.converter))
                pth = this.converter.sessionPath;
            else
                pth = '';
            end
        end 
        function fld  = get.petFolder(this)
            folders = this.converter.modalityFolders;
            for f = 1:length(folders)
                fld = folders{f};
                if (lexist(fullfile(this.sessionPath, fld, ''), 'dir'))
                    break;
                end
            end
        end
        function pth  = get.petPath(this)
            pth = fullfile(this.sessionPath, this.petFolder, '');
        end
        function pth  = get.path962(this)
            pth  = firstExistingFile(this.petPath, this.converter.unpackFolders);
        end 
        function t    = get.tracers(this)
            assert(isa(this.converter, 'mlfourd.PETConverter'));
            t = this.converter.tracers;
        end 
        function pth  = get.hdrPath(this)
            pth = fullfile(this.petPath, this.converter.hdrFolder, '');
        end  
        function fns  = get.hdrFilenames(this)
            dt  = mlfourd.DirTool(fullfile(this.hdrPath, '*.hdr.info'));
            fns = dt.fqfns;
        end
    end
    
    %% PROTECTED
    
    methods (Access = 'protected')
        
        function fn   = hdrinfo_filename(this, tracer, pnum)
            %% HDRINFO_FILENAME
            %  Usage:  fn = mlfourd.Np797.hdrinfo_filename(tracer, pnum)
            %                                              ^ 'ho', 'ho1', ...
            %                                                      ^ p1234, etc.
            assert(nargin >= 3);
            if (~lstrfind(tracer, 'g3') && ~lstrfind(tracer, 'rot'))
                fn = [pnum tracer '_g3']; end
            fn = filename(fullfile(this.hdrPath, fn), '.hdr.info');
        end 
 		function this = PETImagingComponent(cal, cverter)
 			%% PETImagingComponent
 			%  Usage:  this = this@mlfourd.PETImagingComponent(cellarraylist, converter)
            
            this = this@mlfourd.ImagingComponent(cal);
            assert(isa(cverter, 'mlfourd.PETConverter'));
            this.converter_ = cverter;
 		end % PETImagingComponent (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
