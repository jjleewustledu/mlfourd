classdef Test_ImagingArrayList < mlfourd_unittest.Test_mlfourd
	%% TEST_IMAGINGARRAYLIST 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImagingArrayList)
 	%          >> result  = run(mlfourd_unittest.Test_ImagingArrayList, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 18-Oct-2015 18:42:12
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
	properties
        ialist
 		testObj
 	end

	methods (Test)
 		function test_clone(this)  
            %% TEST_CLONE extracts from mlpatterns_xunit/demoCloneScript
            
            % Create two instances of ImagingArrayList
            import mlfourd.*;
            a = ImagingArrayList();
            b = ImagingArrayList();

            % Change the parameters in objects
            a.add([5 10]);
            b.add([1 2]);

            % Call the copy object method to create a clone of 'a' using 'b'
            b = ImagingArrayList(a);
            this.assertListsEqual(a, b);

            % Change the parameters in object 'a' again
            a.remove(1); a.remove(2);
            a.add([500 1000]);            
            this.assertListsNotEqual(a, b);

            % ANOTHER WAY TO CLONE - USING CONSTRUCTOR
            % This procedure implicitly creates a placeholder in memory
            % for cloning the original object by way of the constructor.

            % Create a clone (or deep copy) of object 'a'
            b = mlfourd.ImagingArrayList(a);

            % Change the parameters in object 'a' again
            a.remove(1); a.remove(2);
            a.add([501 1001]);
            this.assertListsNotEqual(a, b);
        end         
        function test_ctor(this)
            this.verifyTrue(this.ialist.isempty);
            this.verifyEqual(0, this.ialist.length);
        end        
        function test_list(this)
            myList = mlfourd.ImagingArrayList;
            myList.add(5);
            myList.add(rand(2)); % 2x2 matrix
            myList.add({50,55}); % 2 separate integer elements

            % check elements
            this.verifyFalse(myList.isempty);
            this.verifyEqual(4, myList.length);
            
            % seeking:  countOf, locationsOf
            this.verifyEqual(1, myList.countOf(50));
            this.verifyEqual(3, myList.locationsOf(50));

            myList.add({rand(3),5:7},2);  % a 3x3 matrix and a 1x3 array
            myList.add(myList,7);    % reference to self!   ImagingArrayList will flatten
            myList.add({10,11;12,13},5);  % a 2x2 cell array
            myList.add({150,160,170},3);  % 3 integers as 3 unique elements

            % check elements
            this.verifyEqual(16, myList.length); 

            % get elements
            this.verifyEqual(150,        myList.get(3));          % elt = 150
            this.verifyEqual([2 2], size(myList.get(7)));  % elt = 2x2 rand matrix
            this.verifyEqual([2 2], size(myList.get(8)));  % elt = 2x2 cell array
            elts = myList.get([3:4,2]);
            this.verifyEqual(150, elts{1});
            this.verifyEqual(160, elts{2});
            this.verifyEqual([3 3], size(elts{3}));

            % add duplicate element
            myList.add(5,6);

            % seeking
            this.verifyEqual(3,        myList.countOf(5));
            this.verifyEqual([1;6;12], myList.locationsOf(5));

            % remove elements
            this.verifyTrue(isempty(myList.remove([4:5,20])));
            this.verifyEqual(17,    myList.length);

            % remove all elements
            myList.remove(1:myList.length);

            % check elements
            this.verifyTrue(myList.isempty);
            this.verifyEqual(0, myList.length);
        end
        function test_arrayOfimagingArrayList(this) 
            myList(2,2) = mlfourd.ImagingArrayList;
            myList.add({rand(3),5:7},2);  % a 3x3 matrix and a 1x3 array
            myList.add(500,5);            % a single integer
            myList(:,1).add({99,100});  % 2 integers
            this.verifyEqual([5,3; 5,3], myList.length);

            % insert element to two lists at location 4
            myList(1,:).add(rand(2),4);
            this.verifyEqual([6,4; 5,3], myList.length);

            % append element
            myList(2,1).add(99);
            this.verifyEqual([6,4; 6,3], myList.length);

            % seek on element
            this.verifyEqual([1,0; 2,0], myList.countOf(99));
            %%assertElementsAlmostEqual({5,[ ]; [4;6],[ ]}, myList.locationsOf(99));

            % remove elements
            elts  = myList.remove([4,5]);
            elts2 = elts{1,1};
            this.verifyEqual([2 2], size(elts2{1}));
            this.verifyEqual(99, elts2{2});
            this.verifyEqual({99; 100}, elts{2,1});
            this.verifyTrue(isempty(elts{1,2}));
            this.verifyTrue(isempty(elts{2,2}));
        end
 	end

 	methods (TestClassSetup)
 		function setupImagingArrayList(this)
 			import mlfourd.*;            
            this.ialist = ImagingArrayList;
 		end
 	end

 	methods (TestMethodSetup)
    end
    
    %% PRIVATE
    
    methods (Access = 'private')
        function assertListsEqual(this, a, b)
            this.verifyEqual(a.length, b.length);
            for i = 1:length(a);
                this.verifyEqual(a.get(i), b.get(i));
            end
        end
        function assertListsNotEqual(this, a, b)
            this.verifyEqual(a.length, b.length);
            for i = 1:length(a);
                this.verifyNotEqual(a.get(i), b.get(i));
            end
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

