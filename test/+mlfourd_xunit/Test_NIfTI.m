classdef Test_NIfTI < mlfourd_xunit.Test_mlfourd
    %% TEST_NIFTI tests high-level functioning of the NiiBrowser class
    %  such as instantiation, operation of salient properties and methods.
    %
    %  _Usage:_  runtests Test_NIfTI
    %
    %  _See also:_  web('/Users/jjlee/Local/src/mpackages/matlab_xunit/doc/xunit_product_page.html', ...
    %                   '-helpbrowser')
    %
    %  _Revision no._ $Revision: 2643 $ committed on $Date: 2013-09-21 17:58:37 -0500 (Sat, 21 Sep 2013) $ by $Author: jjlee $
    %  to repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_NIfTI.m $.
    %
    %  _Keywords:_  $Id: Test_NIfTI.m 2643 2013-09-21 22:58:37Z jjlee $
    %  
    %  _Requires:_  http://www.mathworks.com/matlabcentral/fileexchange/8797
    %
    %  _Copyright_ (c) 2010 $Author: jjlee $.  All rights reserved.

    properties (Constant)
        T1ENTROPY = 5.620934855208380;
        ZRANGE    = 70:74;
    end

    properties (Dependent)
        t1
        t1struct
        t1mask
        test_save_fqfn
        test_saveas_fqfn
    end
    
    methods %% GET/SET
        function t  = get.t1(this)
            t = this.t1_;
        end
        function t  = get.t1struct(this)
            t = this.t1struct_;
        end
        function t  = get.t1mask(this)
            t = this.t1mask_;
        end        
        function fn = get.test_save_fqfn(this)
            fn = fullfile(this.fslPath, 'test_save.nii.gz');
        end    
        function fn = get.test_saveas_fqfn(this)
            fn = fullfile(this.fslPath, 'test_saveas.nii.gz');
        end
    end
    
    methods
        function test_isaNIfTI(this)
            import mlfourd.*;
            assert(isNIfTI(this.t1),     'mlfourd:AssertFailure', ['t1 was class -> ' class(this.t1)]);
            assert(isNIfTI(this.t1mask), 'mlfourd:AssertFailure', ['t1mask was class -> ' class(this.t1mask)]);
        end
        
        function test_ctors(this)
            import mlfourd.*;
            fromfn    =            this.t1;        % from filename
            fromstrct = this.aCtor(this.t1struct); % from NIfTI struct
            fromobj   = this.aCtor(this.t1);       % from NIfTI object
            assertTrue(~isempty(fromfn));
            this.assertObjectsEqual(fromfn, fromstrct);            
            this.assertObjectsEqual(fromfn, fromobj);
        end
        function test_copyctor(this)
            import mlfourd.*;
            assert(isequal(this.t1, this.aCtor(this.t1)));
            t1ori   = this.t1;
            t1delta = this.t1;
            t1delta.img = [];
            assert(isequal(t1ori, this.t1));
        end
        function test_clone(this)
            import mlfourd.*;
            assert(isequal(this.t1, this.t1.clone));
        end
        function test_makeSimilar(this)
            t1sim     = this.t1.makeSimilar(this.t1.img);
            t1sim.img = t1sim.zeros;
            assert(0 ~= sum(sum(sum(this.t1.img))));
            assert(0 == sum(sum(sum(t1sim.img))));
        end
        function test_save(this)
            import mlfourd.*;
            fullt1 = this.aLoader(this.t1_fqfn);
            fullt1.save;
            saved  = this.aLoader(fullt1.fqfn);
            assert(isequal(fullt1.img, saved.img));
        end
        function test_saveAs(this)
            import mlfourd.*;
            this.t1.saveas(this.test_saveas_fqfn);
            t1savedas = this.aLoader(this.test_saveas_fqfn);
            assert(isequal(this.t1.img, t1savedas.img));
        end
        function test_filepath(this)
            this.t1_.filepath = '';
            assert(strcmp(pwd, this.t1.filepath));
        end
        
        function test_entropy(this)
            assertVectorsAlmostEqual(this.T1ENTROPY, this.t1.entropy);
        end
        function test_char(this)
            assertEqual(75, length(this.t1.char));
        end
        function test_forceDouble(this)
            forced = this.t1mask.forceDouble;
            assertEqual('double', class(forced.img));
        end
        function test_scrubNanInf(this)
            tmp = this.t1;
            tmp.img(:,:,1) = nan;
            tmp = tmp.scrubNanInf;
            assert(~any(isnan(tmp.img(:))));
        end        
        
        function test_aXplusy(this)
            One  = this.t1.ones;
            Tmp  = 2 * One + 1;
            img3 = 3 * ones(One.size);
            assertTrue(all(all(all(Tmp.img == img3))));
        end
        function test_AXplusy(this)
            One  = this.t1.ones;
            Tmp  = One .* One + 1;
            img2 = 2 * ones(One.size);
            assertTrue(all(all(all(Tmp.img == img2))));
        end
        function test_AXplusY(this)
            One   = this.t1.ones;
            Tmp   = One .* this.t1 + this.t1;
            img2t = 2 * this.t1.img;
            assertTrue(all(all(all(Tmp.img == img2t))));
        end
        function test_and_not(this)
            tmp = this.t1mask & (~this.t1mask);
            assertTrue(all(all(all(tmp.img == zeros(tmp.size)))));
        end
        function test_or_not(this)
            tmp = this.t1mask | ~this.t1mask;
            assertTrue(all(all(all(tmp.img == ones(tmp.size)))));
        end
        
        function setUp(this)
            this.setUp@mlfourd_xunit.Test_mlfourd;
        end
        function tearDown(this)
            this.tearDown@mlfourd_xunit.Test_mlfourd;
            if (lexist(this.test_saveas_fqfn, 'file'))
                delete(this.test_saveas_fqfn); end
        end
        function this = Test_NIfTI(varargin)
            this = this@mlfourd_xunit.Test_mlfourd(varargin{:});
            this.preferredSession = 2;
            cd(this.fslPath);
            if (isempty(this.t1struct))
                this.t1struct_     = this.fqfn2struct(this.t1_fqfn); 
                this.t1struct_.img = this.t1struct_.img(:,:,this.ZRANGE);
            end
            if (isempty(this.t1))
                this.t1_     = this.fqfn2struct2NIfTI(this.t1_fqfn); 
                this.t1_.img = this.t1_.img(:,:,this.ZRANGE);
            end
            if (isempty(this.t1mask))
                this.t1mask_     = this.fqfn2struct2NIfTI(this.t1mask_fqfn); 
                this.t1mask_.img = this.t1mask_.img(:,:,this.ZRANGE);
            end
        end
    end 
    
    %% PROTECTED
    
    methods (Static, Access = 'protected')
        function obj = aCtor(arg)
            obj = mlfourd.NIfTI(arg);
        end
        function obj = aLoader(arg)
            obj = mlfourd.NIfTI.load(arg);
        end
        function strct = fqfn2struct(fqfn) 
            fqnii = [fileprefix(fqfn) '.nii'];
            if (~lexist(fqnii, 'file'))
                try              
                    gunzip([fqnii '.gz']);
                catch ME
                    handexcept(ME, 'Test_NIfTI.fqfn2struct:  could not find %s', filename(fqfn));
                end
            end
            strct = load_untouch_nii(fqnii);
            delete(fqnii);
        end
        function nii   = fqfn2struct2NIfTI(fqfn)
            nii = mlfourd.NIfTI( ...
                  mlfourd_xunit.Test_NIfTI.fqfn2struct(fqfn));
        end
    end % private methods
    
    %% PRIVATE
    
    properties (Access = 'protected')        
        t1_
        t1struct_
        t1mask_
    end
    
end
