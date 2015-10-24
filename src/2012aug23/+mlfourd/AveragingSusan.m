classdef AveragingSusan < mlfourd.AveragingType 
	%% AVERAGINGSUSAN is a place-holder for AveragingStrstegy for the case of no averaging
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/AveragingSusan.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: AveragingSusan.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties  		
        baseBlur       = mlfsl.PETBuilder.PET_POINTSPREAD;
         useBlurSuffix = false; % for backwards compatibility         
            blurSuffix
 	end 

	methods 

 		function this = AveragingSusan(blur) 
            this.baseBlur = blur;
 		end %  ctor 
        
        function imgcmp = average(this, imgcmp) %#ok<MANU>
            error('Not Implemented');
        end        
        
        function this  = set.baseBlur(this, blr)
            %% SET.BLOCKSIZE adds singleton dimensions as needed to fill 3D
            assert(isnumeric(blr));
            
            if (norm(blr) < norm(mlfsl.PETBuilder.PET_POINTSPREAD))
                this.baseBlur = mlfsl.PETBuilder.PET_POINTSPREAD;
            end
            switch (numel(blr))
                case 1
                    this.baseBlur = [blr blr blr]; % isotropic
                case 2
                    this.baseBlur = [blr(1) blr(2) 0]; % in-plane only
                case 3
                    this.baseBlur = [blr(1) blr(2) blr(3)];
                otherwise
                    this.baseBlur = [0 0 0];
            end
        end % set.baseBlur
        function suff  = get.blurSuffix(this)
            bB   = this.baseBlur;
            suff = ['_' num2str(bB(1),1) 'x' num2str(bB(2),1) 'x' num2str(bB(3),1) 'gauss'];
        end % get.blurSuffix        
        
        function tf    = blur2bool(this)
            assert(isnumeric(this.baseBlur));
            tf = ~all([0 0 0] == this.baseBlur);
        end    
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end



