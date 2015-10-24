classdef AveragingBlindDeconv < mlfourd.AveragingType 
	%% AVERAGINGGAUSS is a place-holder for AveragingStrstegy for the case of no averaging
	%  Version $Revision: 2308 $ was created $Date: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AveragingBlindDeconv.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: AveragingBlindDeconv.m 2308 2013-01-12 23:51:00Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Constant)
        magic      = 3;
        duration   = 60;
        filesuffix = '_blindd';
    end 

    methods (Static)
        function imcmp = deconv(imcmp)
            import mlfourd.*;
            nxt     = imcmp.cachedNext;
            AveragingBlindDeconv.plotFrames(nxt.img);
            if (nxt.rank > 3)
                nxt.img = nxt.img(:,:,:,1:AveragingBlindDeconv.duration);
                nxt.img = sum(nxt.img, nxt.rank);
            end
            nxt.img = deconvblind(nxt.img, fspecial('gaussian', AveragingBlindDeconv.magic, 2.9387/4), ...
                                                                AveragingBlindDeconv.magic);
            imcmp = ImagingComponent.createFromObjects(nxt);
            imcmp.saveas([imcmp.fileprefix AveragingBlindDeconv.filesuffix]);
        end % static deconv
        function plotFrames(img)
            assert(isnumeric(img));
            img1d = squeeze(sum(sum(sum(img))));
            plot(img1d,'DisplayName','AveragingBlindDeconv.deconv.img1d','YDataSource','img1d');
            figure(gcf);
        end % static plotFrames
        
        function sigma = width2sigma(width, fheight)
            
            %% WIDTH2SIGMA returns the Gaussian sigma corresponding to width at fheight, metppix & metric units.
            %  Usage: sigma = width2sigma(width[, fheight])
            %         width:   vector for full-width at fheight, in metric units
            %         fheight: fractional height, 0.5 for fwhh is default, 0.1 for fwth
            %         sigma:   vector in units of metric
            %
            %  Rationale:              fheight*a1 = a1*exp(-((x-b1)/c1)^2);
            %                        log(fheight) = -((x - b1)/c1)^2
            %                                c1^2 = 2*sigma^2;
            %             2*sigma^2*log(fheight)  = -(x - b1)^2
            %      sqrt(2*sigma^2*log(1/fheight)) =   x - b1
            %                                     =   width/2
            %  See also:  sigma2width
            %
            switch (nargin)
                case 1
                    fheight = 0.5;
                case 2
                otherwise
                    error('mlfourd:InputParamsErr', ['NiiBrowser.width2sigma.nargin->' num2str(nargin)]);
            end
            sigma = abs(sqrt((width/2).^2/(2*log(1/fheight))));
        end % static function width2sigma

        function width = sigma2width(sigma, fheight)
            
            %% SIGMA2WIDTH returns the width at fheight corresponding to sigma, metppix & metric units.
            %  Usage: width = sigma2width(sigma[, fheight])
            %         width:   vector for full-width at half-height, in metric units
            %         fheight: fractional height, 0.5 for fwhh is default, 0.1 for fwth
            %         sigma:   vector in units of metric
            %
            %  See also:   width2sigma
            %
            switch (nargin)
                case 1
                    fheight = 0.5;
                case 2 
                otherwise
                    error('mlfourd:InputParamsErr', ['NiiBrowser.sigma2width.nargin->' num2str(nargin)]);
            end
            width = 2*sqrt(2*log(1/fheight)*sigma.^2);
        end % static sigma2width    
    end 
    
	methods 
        function imgcmp = average(this, imgcmp) 
            imgcmp.reset;
            while (imgcmp.hasNext)
                imgcmp = imgcmp.pushNext;
                if (isa(imgcmp, 'mlfourd.ImagingComposite'))
                    imgcmp.cachedNext = this.average(imgcmp.cachedNext);
                else
                    imgcmp.cachedNext = mlfourd.AveragingBlindDeconv.deconv(imgcmp.cachedNext);
                end
            end
        end 
    end 
    

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end



