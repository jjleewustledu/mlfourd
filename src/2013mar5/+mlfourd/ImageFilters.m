classdef ImageFilters
	%% IMAGEFILTERS selects images by criteria
	%  Version $Revision: 2308 $ was created $Date: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImageFilters.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: ImageFilters.m 2308 2013-01-12 23:51:00Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	methods (Static)
 		function imcmp = brightest(imcmp) 
            imcmp = mlfourd.ImageFilters.maximum('dipmean', imcmp);
        end
        function imcmp = lowestSeriesNumber(imcmp)
            import mlfourd.*;
            fns   = cell(1,length(imcmp));
            for f = 1:length(imcmp)
                fns{f} = imcmp{f}.fqfilename;
            end
            imcmp = ImagingComponent.createFromObjects( ...
                    FilenameFilters.lowestSeriesNumber(fns));
        end
        function imcmp = mostEntropy(imcmp)
            imcmp = mlfourd.ImageFilters.maximum('entropy', imcmp);
        end
        function imcmp = mostNegentropy(imcmp)
            imcmp = mlfourd.ImageFilters.maximum('negentropy', imcmp);
        end
        function imcmp = smallestVoxels(imcmp)
            imcmp = mlfourd.ImageFilters.minimum('mmppix', imcmp);
        end
        function imcmp = longestDuration(imcmp)
            import mlfourd.*;
            imcmp = ImageFilters.maximum('duration', ...
                    ImageFilters.timeDependent(imcmp));
        end
        function imcmp = timeDependent(imcmp, varargin)
            import mlfourd.*;
            p     = ImageFilters.filterParser(imcmp, varargin{:}); 
            imcmp = ImageFilters.imagingComponentFilter(@criteria, imcmp);
            
            function imcmp = criteria(imcmp0)
                imcmp = [];
                if (p.Results.positive)
                    if (imcmp0.duration > 1)
                        imcmp = imcmp0;
                    end
                else
                    if (imcmp0.duration == 1)
                        imcmp = imcmp0;
                    end
                end
            end
        end
        function imcmp = timeIndependent(imcmp)
            imcmp = mlfourd.ImageFilters.timeDependent(imcmp, false);
        end 
        function imcmp = isPet(imcmp, varargin)
            import mlfourd.*;
            p     = ImageFilters.filterParser(imcmp, varargin{:});
            imcmp = ImageFilters.imagingComponentFilter(@criteria, imcmp);
            
            function imcmp = criteria(imcmp0)
                imcmp = [];
                tracerIds = mlfourd.NamingRegistry.instance.tracerIds;
                for i = 1:length(tracerIds)
                    if (p.Results.positive && lstrfind(imcmp0.fileprefix, tracerIds{i}))
                        imcmp = imcmp0;
                    end
                end
            end
        end
        function imcmp = notIsPet(imcmp)
            imcmp = mlfourd.ImageFilters.isPet(imcmp, false);
        end
        function imcmp = isMcf(imcmp, varargin)
            import mlfourd.*;
            p     = ImageFilters.filterParser(imcmp, varargin{:});
            imcmp = ImageFilters.imagingComponentFilter(@criteria, imcmp);
            
            function imcmp = criteria(imcmp0)
                imcmp = [];
                if (p.Results.positive && lstrfind(imcmp0.fileprefix, mlfsl.FlirtBuilder.MCF_SUFFIX))
                    imcmp = imcmp0;
                end
            end
        end 
        function imcmp = notIsMcf(imcmp)
            imcmp = mlfourd.ImageFilters.notIsMcf(imcmp, false);
        end
        function imcmp = isFlirted(imcmp, varargin)
            import mlfourd.*;
            p     = ImageFilters.filterParser(imcmp, varargin{:}); 
            imcmp = ImageFilters.imagingComponentFilter(@criteria, imcmp);
            
            function imcmp = criteria(imcmp0)
                imcmp = [];
                if (p.Results.positive && lstrfind(imcmp0.fileprefix, mlfsl.FlirtBuilder.FLIRT_TOKEN))
                    imcmp = imcmp0;
                end
            end
        end 
        function imcmp = notIsFlirted(imcmp)
            imcmp = mlfourd.ImageFilters.notIsFlirted(imcmp, false);
        end
        function imcmp = isBetted(imcmp, varargin)
            import mlfourd.*;
            p     = ImageFilters.filterParser(imcmp, varargin{:}); 
            imcmp = ImageFilters.imagingComponentFilter(@criteria, imcmp);
            
            function imcmp = criteria(imcmp0)
                imcmp = [];
                if (p.Results.positive && mlfsl.BetBuilder.isbetted(imcmp0.fileprefix))
                    imcmp = imcmp0;
                end
            end
        end
        function imcmp = notIsBetted(imcmp)
            imcmp = mlfourd.ImageFilters.notIsBetted(imcmp, false);
        end
        function imcmp = maximum(prp, objs)
            %% MAXIMUM returns the ImagingComponent from an ImagingComposite with the maximum queried property
            %  imaging_component = maximum(property, imaging_composite)
            
            import mlfourd.*;
            imcmp = ImageFilters.extremum(@gt, prp, ...
                    ImagingComponent.createFromObjects(objs));
        end % static maximum
        function imcmp = minimum(prp, objs)
            %% MINIMUM returns the ImagingComponent from an ImagingComposite with the minimum queried property
            %  imaging_component = minimum(property, imaging_composite)
            
            import mlfourd.*;
            imcmp = ImageFilters.extremum(@lt, prp, ...
                    ImagingComponent.createFromObjects(objs));
        end % static minimum
    end
    
    %% PRIVATE
    
    methods (Static, Access = 'private')
        function imcmp = extremum(ineq, prp, imcmp0)
            assert(ischar(prp));
            if (length(imcmp0) < 2)
                imcmp = imcmp0;
            else
                imcmp = imcmp0{1};
                for f = 2:length(imcmp0)
                    if (~isempty(imcmp0{f}))
                        if (  ineq(metric(imcmp0{f}), metric(imcmp)))
                            imcmp = imcmp0{f};
                        elseif (eq(metric(imcmp0{f}), metric(imcmp)))
                            imcmp = [imcmp imcmp0{f}]; %#ok<AGROW>
                        end
                    end
                end
            end
            imcmp = mlfourd.ImagingComponent.createFromObjects(imcmp);
            
            function m = metric(imcmp)
                m = norm(imcmp.(prp));
            end % metric
        end % static extremum        
        function p = filterParser(imcmp, varargin)
            p = inputParser;
            addRequired(p, 'imcmp', @isimcmp);
            addOptional(p, 'positive', true, @islogical);
            parse(p, imcmp, varargin{:});
        end % static filterParser
        function imcmp = imagingComponentFilter(fhandle, imcmp0)
            import mlfourd.*;
            if (length(imcmp0) < 2)
                obj = ImagingSeries.createFromNIfTI(imcmp0.cachedNext);
            else
                cal = mlpatterns.CellArrayList;
                for f = 1:length(imcmp0)
                    tmp = fhandle(imcmp0{f});
                    if (~isempty(tmp))
                        cal.add(tmp);
                    end
                end
                obj = ImagingComponent.createFromObjects(cal);
            end
            imcmp = ImagingComponent.createFromObjects(obj);
        end % static imagingComponentFilter
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

