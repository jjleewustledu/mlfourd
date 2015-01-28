classdef Test_mlfourd < MyTestCase

    properties (Dependent)
        test_fqfn
    end

    methods %% get/set
        function fn  = get.test_fqfn(this)
            fn = this.fqfilenameInFsl('test');
        end
    end
    
    methods
 		function this = Test_mlfourd(varargin)
 			this = this@MyTestCase(varargin{:});
            if (isempty(this.pwd0))
                this.pwd0 = pwd;
            end
        end
        function setUp(this)
            this.cleanUpTestfile;
        end
        function tearDown(this)
            this.cleanUpTestfile;
        end
        function cleanUpTestfile(this)
            if (lexist(this.test_fqfn, 'file'))
                delete(this.test_fqfn);
            end
        end
    end 
    
    %% PROTECTED
    
    properties (Access = 'protected')
        pwd0
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

