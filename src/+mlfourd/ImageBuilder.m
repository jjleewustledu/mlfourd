classdef ImageBuilder
	%% IMAGEBUILDER is the base class for building image-objects.   It's methods may be empty but not abstract
    %  to allow concrete subclasses to implement building tasks as needed.  The concrete subclasses determine
    %  the details of representing the product objects, but the algorithms for construction are listed 
    %  in FslDirector subclasses.   Cf. GoF, builder pattern.   
    %  IMAGEBUILDER is DEPRECATED; prefer mlpipeline.PipelineVisitor
    
    %  Version $Revision: 2627 $ was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImageBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: ImageBuilder.m 2627 2013-09-16 06:18:10Z jjlee $ 

    properties (Dependent)
        converter
        lastLogged
        lastProduct
        logFilename
        logger
        modalityFolder
        modalityPath
        products
        sessionId
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
        function this = createFromOtherBuilder(bldr)
            this = mlfourd.ImageBuilder.createFromConverter( ...
                   bldr.converter);
        end
    end % static methods
  
    methods % set/get
        function this  = set.converter(this, c)
            assert(isa(c, 'mlfourd.ConverterInterface'));
            this.converter_ = c;
        end
        function cvrtr = get.converter(this)
            assert( isa(this.converter_, 'mlfourd.ConverterInterface'));
            cvrtr = this.converter_;
        end
        function this  = set.lastLogged(this, lg)
            assert(ischar(lg));
            this = this.addLogged(lg);
        end
        function prd   = get.lastLogged(this)
            prd = this.logger.get(this.logger.length);
        end
        function this  = set.lastProduct(this, prd)
            assert(~isempty(prd));
            this = this.addProduct(prd);
        end
        function prd   = get.lastProduct(this)
            prd = this.products.get(this.products.length);
        end
        function fn    = get.logFilename(this)
            [~,clname] = strtok(class(this), '.');
               clname  = clname(2:end);
            fn = fullfile(this.converter_.fslPath, mlfourd.NamingRegistry.instance.logFilename(clname));
        end
        function lg    = get.logger(this)
            assert(~isempty(this.logged_));
            lg = this.logged_.clone;
        end  
        function fld   = get.modalityFolder(this)
            fld = this.converter.modalityFolder;
        end
        function this  = set.modalityPath(this, pth)
            assert(lexist(pth, 'dir'), '%s not found', pth);
            this.converter.modalityPath = pth;
        end
        function pth   = get.modalityPath(this)
            pth = this.converter.modalityPath;
        end
        function this  = set.products(this, prd)
            if (~isa(prd, 'mlfourd.ImagingArrayList'))
                prd = mlfourd.ImagingArrayList(prd); end
            this.products_ = prd;
        end
        function prd   = get.products(this)
            assert(~isempty(this.products_));
            prd = this.products_.clone;
        end
        function fld   = get.sessionId(this)
            fld = path2folder(this.sessionPath);
        end
        function pth   = get.sessionPath(this)
            pth = parentPath(this.modalityPath);          
        end
        function fld   = get.studyFolder(this)
            fld = path2folder(this.studyPath);
        end
        function pth   = get.studyPath(this)
            pth = parentPath(this.sessionPath);
        end
        function tf    = get.verbose(this) %#ok<MANU>
            tf = mlpipeline.PipelineRegistry.instance.verbose;
        end
    end 
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function this = ImageBuilder(cvtr)
            assert(isa(cvtr, 'mlfourd.ConverterInterface'));
            this.converter_ = cvtr;
        end
    end
   
    %% PRIVATE
    
    properties (Access = 'private')
        converter_
        logged_
        products_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

