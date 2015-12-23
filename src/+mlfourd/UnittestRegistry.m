classdef UnittestRegistry < mlpatterns.Singleton
	%% UNITTESTREGISTRY  

	%  $Revision$
 	%  was created 19-Oct-2015 00:30:19
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties
 		sessionFolder = 'mm01-020_p7377_2009feb5'
    end

	properties (Dependent)
 		sessionPath
    end
    
    methods % GET
        function g = get.sessionPath(this)
            g = fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl', 'np755', this.sessionFolder, '');
        end
    end
    
    methods (Static)
        function this = instance(qualifier)
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            persistent uniqueInstance
            
            if (exist('qualifier','var') && ischar(qualifier))
                if (strcmp(qualifier, 'initialize'))
                    uniqueInstance = [];
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlfourd.UnittestRegistry();
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end
    
	methods (Access = 'private')		  
 		function this = UnittestRegistry(varargin) 			
 			this = this@mlpatterns.Singleton(varargin{:}); 			
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

