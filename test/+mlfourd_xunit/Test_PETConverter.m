classdef Test_PETConverter < mlfourd_xunit.Test_mlfourd;
    
    properties (Constant)
        petFolder =   'ECAT_EXACT'; 
        petFilesNii     = { 'cho_f5to24.nii.gz' 'poc.nii.gz' 'ptr.nii.gz' 'coo_f7to26.nii.gz' };
        entropies = { ...
            4.899365913303674 ...
            4.624299364538743...
            5.281129072031266 ...
            4.832356397232611};
    end
    
    properties (Dependent)
        petFilesInFsl
        unpackFiles
        unpackPath
        xunitPath
        xunitFiles
    end

	methods %% GET
        function fls = get.petFilesInFsl(this)
            fls = cellfun(@(f) fullfile(this.fslPath,f), this.petFilesNii, 'UniformOutput', false);
        end   
        function pth = get.unpackPath(this)
            pth = fullfile(this.sessionPath, 'ECAT_EXACT', '962_4dfp', '');
        end  
        function fls = get.unpackFiles(this)
            fls = cellfun(@(f) fullfile(this.unpackPath,f), this.petFilesNii, 'UniformOutput', false);
        end 
        function pth = get.xunitPath(this)
            pth = fullfile(this.sessionPath, 'XUnit', '');
        end 
        function fls = get.xunitFiles(this)            
            fls = cellfun(@(f) fullfile(this.xunitPath,f), this.petFilesNii, 'UniformOutput', false);
        end    
    end
    
    methods
        function test_convertEcatExact(this)
            this.converter_.convertEcatExact(this.converter_.cossexp, 'c');
            this.converter_.convertEcatExact(this.converter_.petexp,  'p');
            for f = 1:length(this.unpackFiles)
                %this.dispEntropies(this.unpackFiles{f});
                this.assertEntropies(this.entropies{f}, this.unpackFiles{f});
            end
        end
        function test_orientRepair(this)
            import mlfourd.* mlfourd_xunit.*;
            this.converter_.copyUnpacked(this.unpackPath, this.xunitPath);
            PETConverter.orientRepair(this.xunitPath, this.converter_.orients2fix);
            for f = 1:length(this.xunitFiles)
                %this.dispEntropies(this.xunitFiles{f});
                this.assertEntropies(this.entropies{f}, this.xunitFiles{f});
            end
 		end 
 		function test_copyUnpacked(this)
            this.converter_.copyUnpacked(this.unpackPath, this.xunitPath);
            for f = 1:length(this.xunitFiles) 
                assertTrue(lexist(this.xunitFiles{f}, 'file')); 
            end
        end
        function test_ctor(this)
            assertTrue(isa(this.converter_, 'mlfourd.PETConverter'));
        end
        
        function this = Test_PETConverter(varargin)
 			this = this@mlfourd_xunit.Test_mlfourd(varargin{:});
            this.preferredSession = 2;
            this.converter_ = mlfourd.PETConverter.createFromModalityPath(this.petPath);
            if ( lexist(this.xunitPath, 'dir'))
                mlbash(['rm -rf ' this.xunitPath]); end   
        end 
        function setUp(this)
            setUp@mlfourd_xunit.Test_mlfourd(this);
            this.setUpUnpackPath;
            this.setUpXunitPath;
        end
        function tearDown(this)
            tearDown@mlfourd_xunit.Test_mlfourd(this);            
        end
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        converter_
    end
    
    methods (Access = 'private')
        function setUpUnpackPath(this)
            if ( lexist(this.unpackPath, 'dir'))
                mlbash(sprintf('rm -rf %s', this.unpackPath)); end
            mlbash(sprintf('pushd %s; bunzip2 -c %s.tbz | tar -xf -; popd', this.petPath, this.unpackPath));
        end
        function setUpXunitPath(this)
            if (~lexist(this.xunitPath,'dir'))
                mkdir(this.xunitPath); end
            copyfiles(this.unpackFiles, this.xunitPath);
        end
    end
end
