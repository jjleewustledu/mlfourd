classdef FourdRegistry < mlpatterns.Singleton  
	%% FOURDREGISTRY  

	%  $Revision$
 	%  was created 02-Feb-2016 19:13:44
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

    methods (Static)
        function this = instance(qualifier)
            
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            persistent uniqueInstance
            
            if (exist('qualifier','var') && ischar(qualifier))
                switch (qualifier)
                    case 'initialize'
                        uniqueInstance = [];
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlfourd.FourdRegistry;
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end 
    
	%% PROTECTED
    
    methods (Access = 'protected')
 		function this = FourdRegistry(varargin)
            this = this@mlpatterns.Singleton(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

