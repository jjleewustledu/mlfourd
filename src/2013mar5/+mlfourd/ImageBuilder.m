classdef ImageBuilder
	%% IMAGEBUILDER is the base class for building image-objects.   It's methods may be empty but not abstract
    %  to allow concrete subclasses to implement building tasks as needed.  The concrete subclasses determine
    %  the details of representing the product objects, but the algorithms for construction are listed 
    %  in FslDirector subclasses.   Cf. GoF, builder pattern.
    %
    %  Version $Revision: 2330 $ was created $Date: 2013-01-23 12:38:37 -0600 (Wed, 23 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-23 12:38:37 -0600 (Wed, 23 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImageBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: ImageBuilder.m 2330 2013-01-23 18:38:37Z jjlee $ 

    properties (Dependent)
        averaging
        converter
        lastLogged
        lastProduct
        logFilename
        logged
        modalityFolder
        modalityPath
        products
        sessionFolder
        sessionPath
        studyFolder
        studyPath
        verbose
    end % dependent properties
    
    methods (Static)
        function this = createFromConverter(cvrtr)
            %% CREATEFROMCONVERTER
            %  Usage:  builder = ImageBuilder.createFromConverter(converter)
            
            assert(isa(cvrtr, 'mlfourd.ConverterInterface'));
            this = mlfourd.ImageBuilder(cvrtr);
        end
        function this = createFromModalityPath(mpth)
            %% CREATEFROMMODALITYPATH bootstraps MRIConverter or PETConverter
            
            import mlfourd.* mlfsl.*;
            if     (lstrfind(mpth, MRIConverter.modalityFolders))
                this = MRIBuilder.createFromModalityPath(mpth);
            elseif (lstrfind(mpth, PETConverter.modalityFolders))
                this = O15Builder.createFromModalityPath(mpth);
            else                
                error('mlfourd:UnsupportedInputParamValue', ...
                      'ImageBuilder.createFromModalityPath could not parse modality-path:  %s', mpth);
            end
        end
        function this = createFromOtherBuilder(bldr)
            this = mlfourd.ImageBuilder.createFromConverter( ...
                   bldr.converter);
        end
    end % static methods
  
    methods % set/get
        function this   = set.averaging(this, avg)
            assert(isa(avg, 'mlfourd.AveragingType'), '%s unsupported', class(avg));
            this.averaging_ = mlfourd.AveragingStrategy(avg);
        end
        function avg    = get.averaging(this)
            avg = this.averaging_;
        end
        function cvrtr  = get.converter(this)
            assert( isa(this.converter_, 'mlfourd.ConverterInterface'));
            cvrtr = this.converter_;
        end
        function this = set.lastLogged(this, lg)
            assert(ischar(lg));
            this = this.addLogged(lg);
        end
        function prd  = get.lastLogged(this)
            prd = this.logged.get(this.logged.length);
        end
        function this = set.lastProduct(this, prd)
            assert(~isempty(prd));
            this = this.addProduct(prd);
        end
        function prd  = get.lastProduct(this)
            prd = this.products.get(this.products.length);
        end
        function fn   = get.logFilename(this)
            [~,clname] = strtok(class(this), '.');
               clname  = clname(2:end);
            fn = fullfile(this.converter_.fslPath, mlfourd.NamingRegistry.instance.logFilename(clname));
        end
        function lg   = get.logged(this)
            assert(~isempty(this.logged_));
            lg = cellArrayListCopy(this.logged_);
        end  
        function fld    = get.modalityFolder(this)
            fld = this.converter.modalityFolder;
        end
        function this   = set.modalityPath(this, pth)
            assert(lexist(pth, 'dir'), '%s not found', pth);
            this.converter.modalityPath = pth;
        end
        function pth    = get.modalityPath(this)
            pth = this.converter.modalityPath;
        end
        function this = set.products(this, prd)
            if (~isa(prd, 'mlpatterns.CellArrayList'))
                prd = ensureCellArrayList(prd); end
            this.products_ = prd;
        end
        function prd  = get.products(this)
            assert(~isempty(this.products_));
            prd = cellArrayListCopy(this.products_);
        end
        function fld    = get.sessionFolder(this)
            fld = path2folder(this.sessionPath);
        end
        function pth    = get.sessionPath(this)
            pth = parentPath(this.modalityPath);          
        end
        function fld    = get.studyFolder(this)
            fld = path2folder(this.studyPath);
        end
        function pth    = get.studyPath(this)
            pth = parentPath(this.sessionPath);
        end
        function tf     = get.verbose(this) %#ok<MANU>
            tf = mlpipeline.PipelineRegistry.instance.verbose;
        end
    end % set/get methods
    
    methods
        function imobj = average(this, imobj)
            assert(isa(this.averaging_, 'mlfourd.AveragingType'));
            imobj = this.averaging_.average(imobj);
        end 
        function this  = addProduct(this, prd)
            this.products_.add(prd);
        end
        function this  = resetProducts(this)
            this.products_ = mlpatterns.CellArrayList;
            this = this.resetLogged;
        end
        function this  = addLogged(this, lg)
            this.logged_.add(lg);
        end
        function this  = resetLogged(this)
            this.logged_ = mlpatterns.CellArrayList;
        end
 	end % methods
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function this = ImageBuilder(cvtr)
            import mlfourd.* mlpatterns.*;
            assert(isa(cvtr, 'mlfourd.ConverterInterface'));
            this.converter_ = cvtr;
            this.averaging_ = AveragingStrategy('none');
            this = this.resetLogged;
            this = this.resetProducts;
        end
    end
   
    %% PRIVATE

    properties (Access = 'private')
        averaging_
        converter_
        logged_
        products_
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

