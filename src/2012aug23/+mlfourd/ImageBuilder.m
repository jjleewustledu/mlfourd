classdef ImageBuilder < mlfourd.ImageBuilderInterface
	%% ImageBuilder is the simplest, concrete implementaion of ImageBuilderInterface
    %
    %  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/ImageBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: ImageBuilder.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    properties (Dependent)
        theProduct
        studyPath
        sessionPath
        foregrounds
        foreground
        converter
        averaging
        verbose
    end % dependent properties
    
    methods (Static)
        
        function this  = createFromConverter(cverter, averging)
            %% CREATEFROMCONVERTER returns an ImageBuilder instance for testing
            %  builder = ImageBuilder.createFromConverter(converter)
            
            assert(isa(cverter, 'mlfourd.ConverterInterface'));
            this = mlfourd.ImageBuilder(cverter);
            if (exist('averging','var'))
                this.averaging = averging;
            end
        end % static createFromConverter
        
        function imcmp = brightest(imcmp)
            import mlfourd.*;
            imcmp = ImageBuilder.maximum('dipmean', ...
                    ImagingComposite.createFromObjects(imcmp));
        end
        function imcmp = lowestSeriesNumber(imcmp)
            import mlfourd.*;
            imcmp = ImageBuilder.minimum('seriesNumber', ...
                    ImagingComposite.createFromObjects(imcmp));
        end
        function imcmp = mostEntropy(imcmp)
            import mlfourd.*;
            imcmp = ImageBuilder.maximum('entropy', ...
                    ImagingComposite.createFromObjects(imcmp));
        end
        function imcmp = mostNegentropy(imcmp)
            import mlfourd.*;
            imcmp = ImageBuilder.maximum('negentropy', ...
                    ImagingComposite.createFromObjects(imcmp));
        end
        function imcmp = smallestVoxels(imcmp)
            import mlfourd.*;
            imcmp = ImageBuilder.minimum('mmppix', ...
                    ImagingComposite.createFromObjects(imcmp));
        end
        function imcmp = longestDuration(imcmp)
            import mlfourd.*;
            imcmp = ImageBuilder.maximum('size', ...
                    ImageBuilder.timeDependent( ...
                    ImagingComposite.createFromObjects(imcmp)));
        end
        function imcmp = timeDependent(imcmp)
            import mlfourd.*;
            imcmp = ImageBuilder.imagingComponentFilter(@criteria, ...
                    ImagingComposite.createFromObjects(imcmp));
            
            function imcmp = criteria(imcmp0)
                imcmp = [];
                try
                    nii = mlfourd.NIfTI.load(imcmp0.fqfilename);
                    if (nii.size(4) > 1); imcmp = imcmp0; end
                catch ME
                    handwarning(ME, 'MocalityConverter.timeDependent could not find %s', imcmp0.fqfilename);
                end
            end
        end
        function imcmp = timeIndependent(imcmp)
            import mlfourd.*;
            imcmp = ImageBuilder.imagingComponentFilter(@criteria, ...
                    ImagingComposite.createFromObjects(imcmp));
            
            function imcmp = criteria(imcmp0)
                imcmp = [];
                try
                    nii = mlfourd.NIfTI.load(imcmp0.fqfilename);
                    if (nii.rank < 4 || nii.size(4) == 1); imcmp = imcmp0; end
                catch ME
                    handwarning(ME, 'MocalityConverter.timeIndependent could not find %s', imcmp0.fqfilename);
                end
            end
        end 
        function imcmp = notPet(imcmp)
            import mlfourd.*;
            imcmp = ImageBuilder.imagingComponentFilter(@criteria, ...
                    ImagingComposite.createFromObjects(imcmp));
            
            function imcmp = criteria(imcmp0)
                imcmp = [];
                tracerIds = mlfourd.NamingRegistry.instance.tracerIds;
                for i = 1:length(      tracerIds)
                    if (~lstrfind(imcps0.fileprefix, tracerIds{i}))
                        imcmp = imcmp0;
                    end
                end
            end
        end % static notPet
        function imcmp = maximum(prp, imcmp)
            %% MAXIMUM returns the ImagingComponent from an ImagingComposite with the maximum queried property
            %  imaging_component = maximum(property, imaging_composite)
            
            import mlfourd.*;
            imcmp = ImageBuilder.extremum(@gt, prp, ...
                    ImagingComposite.createFromObjects(imcmp));
        end % static maximum
        function imcmp = minimum(prp, imcmp)
            %% MINIMUM returns the ImagingComponent from an ImagingComposite with the minimum queried property
            %  imaging_component = minimum(property, imaging_composite)
            
            import mlfourd.*;
            imcmp = ImageBuilder.extremum(@lt, prp, ...
                    ImagingComposite.createFromObjects(imcmp));
        end % static minimum
    end % static methods
    
    methods
 		
        function prd    = get.theProduct(this)
            prd = this.theProduct_;
        end  
        function pth    = get.studyPath(this)
            pth = this.converter.studyPath;
        end
        function pth    = get.sessionPath(this)
            pth = this.converter.sessionPath;
        end 
        function this   = set.foregrounds(this, fgs)
            this.foregrounds_ = mlfourd.ImagingComposite.createFromObjects(fgs);
        end 
        function fgcmps = get.foregrounds(this)
            if (isempty(this.foregrounds_))
                throw(MException('mlfourd:objectReferencedBeforeAssigned', ...
                                 'ImageBuilder.get.foregrounds was called but this.foregrounds_ was empty'));
            end
            fgcmps = this.foregrounds_;
        end
        function fgcmp  = get.foreground(this)
            assert(~isempty(this.foregrounds_));
            fgcmp = this.foregrounds_.get(1);
        end
        function cvtr   = get.converter(this)
            cvtr = this.converter_;
        end          
        function v      = get.verbose(this) %#ok<MANU>
            v = mlpipeline.PipelineRegistry.instance.verbose;
        end
        function this   = set.averaging(this, avg)
            this.averaging_ = mlfourd.AveragingStrategy(avg);
        end
        function avg    = get.averaging(this)
            avg = this.averaging_;
        end
        
        function imcmp  = average(this, imcmp)
            assert(isa(this.averaging_, 'mlfourd.AveragingStrategy'));
            imcmp = this.averaging_.average(imcmp);
        end % averaging
 	end % methods
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function this = ImageBuilder(cverter)
            
            %% CTOR
            %  Usage:  this = ImageBuilder(converter[, foreground_object])
            %          pnum:  string
            %          fg_filename:  NIfTI or []
            import mlfourd.*;
            
            assert(isa(cverter, 'mlfourd.ConverterInterface'));
            this.converter_  = cverter;   
        end % ctor   
    end
   
    %% PRIVATE
    
    properties (Access = 'private')
        theProduct_
        foregrounds_
        converter_
        averaging_
    end
    
    methods (Static, Access = 'private')
        function imcps = imagingComponentFilter(h, imcps0)
            imcps = mlfourd.ImagingComposite.createFromObjects(mlpatterns.CellArrayList);
            imcps0.reset;
            while (imcps0.hasNext)
                   imcps0.pushNext;
                tmp = h(imcps0.cachedNext);
                if (~isempty(tmp))
                    imcps.add(tmp);
                end
            end
        end % static imagingComponentFilter
        function imcmp = extremum(fhandle, prp, imcps)
            import mlfourd.*;
            assert( ischar(prp));
            assert(~isImagingComponentEmpty(imcps));
            imcmp         =        imcps{1};
            candidateLast = metric(imcps{1});
            for f = 2:length(      imcps)
                candidate = metric(imcps{f});
                
                if (candidate == candidateLast)
                    imcmp = [imcmp imcps{f}];  %#ok<AGROW>
                elseif (fhandle(candidate, candidateLast))
                    candidateLast = candidate;
                    imcmp = imcps{f};
                end
            end
            
            function m = metric(imcmp)
                m = prod(imcmp.(prp));
            end % metric
        end % static extremum
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

