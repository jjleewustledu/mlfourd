classdef StudyBuilder < mlfsl.FslBuilder
	%% STUDYBUILDER is a design-pattern builder of imaging composites
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/StudyBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: StudyBuilder.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
 	end 

	methods 
        function        orientChange2Standards(this, nppth)
            %% REORIENT2STD
            
            import mlfourd.*;
            nplist   = DirTool(nppth);
            sessions = nplist.fqdns;
            fslfld   = this.fslRegistry.fslFolder;  
            for s = 1:length(sessions)
                
                fslpth = fullfile(sessions{s}, fslfld, '');
                if (lexist(fslpth, 'dir'))
                    try
                        this.orientChange2Standard(fslpth); 
                    catch ME
                        disp(ME);
                        warning('mlfourd:RuntimeFailure', ...
                                'StudyBuilder.orientChange2Standards:  %s  Skipping folder %s\n', ME.message, fslpth);
                    end
                end
            end
        end % reorients2std
 		function this = StudyBuilder(cvert, varargin) 
 			%% STUDYBUILDER 
 			%  Usage:  obj = StudyBuilder(converter[, foreground_object])	 
            
            this = this@mlfsl.FslBuilder(cvert, varargin{:});
 		end % StudyBuilder (ctor) 
        function       orientChange2Standard(this, fslpth)
            error('mlfourd:NotImplemented', 'StudyBuilder.orientChange2Standard');
        end
    end % methods    

    %  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

