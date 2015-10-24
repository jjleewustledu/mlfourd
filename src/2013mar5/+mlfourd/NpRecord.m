classdef NpRecord 
	%% NPRECORD is a container for data-records organized by np-projects%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/NpRecord.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: NpRecord.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        
        patients
    end 

    methods (Static)
        function np = createNp(patient0)
            np = mlfourd.NpRecord;
            np.patients(patient0.key) = patient0;
        end
    end % static methods
    
	methods (Access = 'protected')
 		function this = NpRecord
			this.patients = containers.Map;
 		end % NpRecord (ctor) 
 	end % methods

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

