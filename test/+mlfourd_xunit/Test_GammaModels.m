classdef Test_GammaModels < TestCase
    
    %% TEST_GAMMAMODELS tests high-level functioning of the GammaModels class
    %  such as instantiation, operation of salient properties and methods.
    %
    %  _Usage:_  runtests('mlfourd_xunit.Test_GammaModels')
    %
    %  _See also:_  web('/Users/jjlee/MATLAB-Drive/matlab_xunit/doc/xunit_product_page.html', ...
    %                   '-helpbrowser')
    %
    %  _Revision no._ $Revision: 2643 $ committed on $Date: 2013-09-21 17:58:37 -0500 (Sat, 21 Sep 2013) $ by $Author: jjlee $
    %   to repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_GammaModels.m $.
    %
    %  _Keywords:_  $Id: Test_GammaModels.m 2643 2013-09-21 22:58:37Z jjlee $
    %  
    %  _Requires:_  http://www.mathworks.com/matlabcentral/fileexchange/8797
    %
    %  _Copyright_ (c) 2010 $Author: jjlee $.  All rights reserved.
    %
    properties (Constant)
        TEST_HOME = '/Users/jjlee/MATLAB-Drive/mlfourd/test/+mlfourd_xunit';
        WORK_HOME = '/Volumes/ParietalHD2/cvl/MROMI/ForBayes/046/tp1_raw/images_2010apr12';
        shortt      = 0:1.5:9;
        longt       = 0:10:60;
        fullt       = 0:1.5:73.5;
    end
    
    properties
        db          = 0;
        params      = {[]};
        selectt     = [];
        epiShotSize = [128 128 14];
        repmatSize  = [];
        dt          = [];
    end
    
    methods
        
        function this = Test_GammaModels(varargin)
            this      = this@TestCase(varargin{:});
        end
        
        function setUp(this)
            
            import mlfourd.*;
            %cd(this.WORK_HOME);
            this.db            = DBase.getInstance;            
            this.params        = GammaModels.makeParams;
            this.selectt       = this.fullt;
            this.repmatSize    = this.epiShotSize;            
            this.repmatSize(4) = length(this.selectt);
            this.dt = GammaModels.dtimes(double(this.params.t0), this.selectt, this.epiShotSize); 
            
        end
        
        function test_params(this)
            
            fn    = fieldnames(this.params);
            for f = 1:length(fn)
                assert(isa(this.params.(fn{f}), 'mlfourd.INIfTI'));
                fprintf(1, 'params.%s.max->%g\n', fn{f}, this.params.(fn{f}).max);
                assert(    this.params.(fn{f}).max >= 0);
            end
        end
        
        function test_dtimes(this)
            
            import mlfourd.*;
            assert(all(this.repmatSize == size(this.dt)));
        end
        
        function test_modelArg(this)
            
            import mlfourd.*;
            arg = GammaModels.modelArg(this.params, this.dt);
            assert(all(this.repmatSize == size(arg)));
            disp('cf. dip_image(modelArg)'); dip_image(arg)
        end
        
        function test_modelConst(this)
            
            import mlfourd.*;
            const = GammaModels.modelConst(this.params, this.dt);
            assert(all(this.repmatSize == size(const)));
            disp('cf. dip_image(modelConst)'); dip_image(const)
        end
        
        function test_postbolus(this)
            
            import mlfourd.*;
            gm       = GammaModels.makeGammaModel;
            gm.times = this.longt;
            pb_mask  = gm.postbolus(this.params.t0);
            nvoxels  = numel(pb_mask(:,:,:,1));
            for t = 1:length(gm.times)
                fprintf(1, 'frac(pb_mask)->%g, frac(t0 < t)->%g\n', ...
                       sum(dip_image(pb_mask(:,:,:,t)))/nvoxels,   sum(dip_image(~double(this.params.t0 > gm.times(t))))/nvoxels);
                assert(sum(dip_image(pb_mask(:,:,:,t)))/nvoxels == sum(dip_image(~double(this.params.t0 > gm.times(t))))/nvoxels);
            end
        end
        
        function test_localAifMr(this)
            
            import mlfourd.*;
            disp('Must set ctor methods to public');
            gm         = GammaModels('mr', this.params, this.selectt);
            [foft,gm2] = gm.localAifMr(this.params, this.params.cbf, this.selectt);
            disp(['size(foft)->' num2str(size(foft))]); disp('cf. dip_image(foft)'); dip_image(foft)
            disp( 'gm2->'); disp(gm2)
            disp( 'gm2.params->'); disp(gm2.params)
            assert(~isempty(foft));
            assert(~isempty(gm2));
        end
        
        function test_localAifMrConst(this)
            
            import mlfourd.*;
            disp('Must set ctor methods to public');
            gm         = GammaModels('mrconst', this.params, this.selectt);
            [foft,gm2] = gm.localAifMrConst(this.params, this.params.cbf, this.params.const, this.selectt);
            disp(['size(foft)->' num2str(size(foft))]); disp('cf. dip_image(foft)'); dip_image(foft)
            disp( 'gm2->'); disp(gm2)
            disp( 'gm2.params->'); disp(gm2.params)
            assert(~isempty(foft));
            assert(~isempty(gm2));
        end
        
        function test_localAifMrRec(this)
            
            import mlfourd.*;
            disp('Must set ctor methods to public');
            gm         = GammaModels('mrrec', this.params, this.selectt);
            [foft,gm2] = gm.localAifMrRec(this.params, this.params.cbf, this.params.cbf2, this.selectt);
            disp(['size(foft)->' num2str(size(foft))]); disp('cf. dip_image(foft)'); dip_image(foft)
            disp( 'gm2->'); disp(gm2)
            disp( 'gm2.params->'); disp(gm2.params)
            assert(~isempty(foft));
            assert(~isempty(gm2));
        end
        
        function test_localAifMrRecConst(this)
            
            import mlfourd.*;
            disp('Must set ctor methods to public');
            gm         = GammaModels('mrrecconst', this.params, this.selectt);
            [foft,gm2] = gm.localAifMrRecConst(this.params, this.params.cbf, this.params.cbf2, ...
                                               this.params.const, this.params.const2, this.selectt);
            disp(['size(foft)->' num2str(size(foft))]); disp('cf. dip_image(foft)'); dip_image(foft)
            disp( 'gm2->'); disp(gm2)
            disp( 'gm2.params->'); disp(gm2.params)
            assert(~isempty(foft));
            assert(~isempty(gm2));
        end
        
        function test_something(this)
            
            import mlfourd.*;
        end     
    end
end
