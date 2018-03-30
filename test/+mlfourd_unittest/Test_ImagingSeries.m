classdef Test_ImagingSeries < mlpatterns_unittest.Test_AbstractComposite
	%% TEST_IMAGINGSERIES 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImagingSeries)
 	%          >> result  = run(mlfourd_unittest.Test_ImagingSeries, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 18-Oct-2015 15:55:11
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties
 		testObj
 	end

	methods (Test) 
        function test_copyctor(this)
            cp = mlfourd.ImagingSeries(this.imseries);
            cp.zeros;
            this.assertTrue(max(this.imseries.img(:)) > 0);
        end
        function test_createFromFilename(this)
            this.assertTrue(isa(this.imseries, 'mlfourd.ImagingSeries'));
        end
        function test_ctorAndImagingSeries(this)
            import mlfourd.*;
            cal = mlfourd.ImagingArrayList;
            cal.add(NIfTId.load(this.t1_fqfn));
            this.assertTrue(isa(ImagingSeries(cal), 'mlfourd.ImagingSeries')); 
        end    
        function test_ctorAndImagingComposite(this)
            import mlfourd.*;
            cal = mlfourd.ImagingArrayList;
            cal.add(NIfTId.load(this.t2_fqfn));
            cal.add(NIfTId.load(this.ir_fqfn));
            this.assertTrue(isa(ImagingComposite(cal), 'mlfourd.ImagingComposite'));
        end  
        function test_heterogeneousHorzcat(this)
            import mlfourd.*;
            objs =  ImagingSeries.load({this.t1_fqfn this.t1_fqfn this.t1_fqfn});
            cats = [ImagingSeries(this.imseries) ...
                    ImagingSeries(this.imseries) ... 
                    ImagingSeries(this.imseries)];
            this.assertEqual(length(objs), length(cats));
            for f = 1:length(objs)
                this.assertTrue(isequal( objs.get(f), cats.get(f)));
            end
        end
        function test_growingHorzcat(this)
            import mlfourd.*;
            tmp =      ImagingSeries(this.imseries);
            tmp = [tmp ImagingSeries(this.imseries)];
            tmp = [tmp ImagingSeries(this.imseries)];  
            this.assertTrue(isa(          this.imseries, 'mlfourd.ImagingSeries'));
            this.assertTrue(length(tmp) == 3);
            this.assertTrue(isa(   tmp, 'mlfourd.ImagingComposite'));
            this.assertEqual(      tmp.get(1), this.imseries.get(1));
        end
        function test_horzcat(this)
            import mlfourd.*;
            catted = [ImagingSeries(this.imseries) ImagingSeries(this.imseries) ImagingSeries(this.imseries)];  
            this.assertTrue(isa(this.imseries, 'mlfourd.ImagingSeries'));
            this.assertTrue(isa(    catted,    'mlfourd.ImagingComposite'));
            this.assertTrue( length(catted) == 3);
            for c = 1:length(  catted)
                this.assertTrue(isa(catted.get(c),           'mlfourd.INIfTI'));
                this.assertEqual(   catted.get(c).fqfilename, this.t1_fqfn);
            end
        end 
 		function test_subsref(this)
 			import mlfourd.*;            
            this.assertTrue(       isa(this.imseries, 'mlfourd.ImagingSeries'));
            this.assertEqual(1, length(this.imseries));
            this.assertTrue(       isa(this.imseries{1}, 'mlfourd.INIfTI'));
            this.assertTrue(   isequal(this.imseries{1}, this.imseries.cached));
            this.assertEqual(          this.imseries{1}.fqfilename, this.t1_fqfn);
        end     
        function test_makeSimilar(this)
            imser   = this.imseries;
            similar = imser.makeSimilar('img', ones(size(imser)), 'fileprefix', 'similar');
            this.assertEqual(ones(size(imser)), similar.img);
        end
%  		function test_saveas(this) 
%  			import mlfourd.*; 
%             is  = ImagingSeries.load(this.files3);
%             is2 = is.saveas(         this.test_fqfn);
%             is3 = ImagingSeries.load(this.test_fqfn);
%             this.assertEqual(is.img, is2.img);
%             this.assertEqual(is.img, is3.img);
%             this.assertTrue( strcmp(this.files3,     is.fqfilename));
%             this.assertFalse(strcmp(this.files3,    is2.fqfilename));
%             this.assertTrue( strcmp(is2.fqfilename, is3.fqfilename));
%         end
        function test_length(this)
            this.assertEqual(1, this.imseries.length);
        end
        function test_add(this)
            ir       = mlfourd.NIfTId.load(this.files{3});
            imseries = this.imseries;
            imseries = imseries.add(ir);
            this.assertEqual(2, imseries.length);
            this.assertTrue(isa(imseries, 'mlfourd.ImagingComposite'));
        end
        function test_remove(this)
            imseries = this.imseries;
            h = @() imseries.remove(1);
            this.assertError(h,'MATLAB:assertion:failed');
        end
        function test_get(this)
            nii = this.imseries.get(1);
            this.assertTrue(nii.isequal(mlfourd.NIfTId.load(this.t1_fqfn)));
        end
        function test_countOf(this)
            t1 = mlfourd.NIfTId.load(this.t1_fqfn);
            this.assertEqual(1, this.imseries.countOf(t1));
        end
        function test_locationsOf(this)
            item = this.imseries.get(1);
            this.assertEqual(1, this.imseries.locationsOf(item));
        end
        function test_iterator(this)
            %% TEST_ITERATOR tests reset, hasNext, next
            imseries = this.imseries;
            iter = imseries.createIterator;
            cnt = 0;
            while (iter.hasNext)
                cnt = cnt + 1;
                this.assertTrue(isa(iter.next, 'mlfourd.INIfTI'));
            end
            this.assertEqual(1, cnt);
        end
 	end

 	methods (TestClassSetup)
 		function setupImagingSeries(this)
 		end
 	end

 	methods (TestClassTeardown)
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

