% Test_NiiPublish < mlunit.test_case  has spot-checks for sanity testing
%
% Instantiation:
%		runner = mlunit.text_test_runner(1, 2);
%		loader = mlunit.test_loader;
%		run(runner, load_tests_from_test_case(loader, 'mlfourd.Test_NiiPublish'));
%		run(gui_test_runner, 'mlfourd.Test_NiiPublish');
%		run(gui_test_runner, 'mlfourd.Test_NiiPublish');
%
% See Also:
%		help text_test_runner
%		http://mlunit.dohmke.de/Main_Page
%		http://mlunit.dohmke.de/Unit_Testing_With_MATLAB
%		thomi@users.sourceforge.net
%
% Created by John Lee on 2008-12-22.
% Copyright (c) 2008 Washington University School of Medicine.  All rights reserved.
% Report bugs to .

classdef Test_NiiPublish < mlunit.test_case
	
	properties
		aNii_        = struct([]);
		aNiiPublish_ = struct([]);
		afilename_   = ['/Volumes/Parietal\ Data/cvl/np287/vc4437/MLEM/' ...
						'SHIMONY_CBF_MLEM_LOGFRACTAL_VONKEN_LOWPASS_00-1-1_2008-3-6.4dfp'];
	end


	methods

		function obj = Test_NiiPublish(varargin)
			obj              = obj@mlunit.test_case(varargin{:});
			obj.aNii_        = mlfourd.NIfTI.load(obj.afilename_);
			obj.aNiiPublish_ = mlfourd.NiiPublish(obj.aNii_);
		end


		function obj = test_null(obj)
			mlunit.assert_equals(0, sin(0));
		end
		
		
		function obj = test_niiPublish(obj)
			niipublish1 = mlfourd.NiiPublish(nii_vc4437_mlemcbf);
			niipublish2 = mlfourd.NiiPublish(nii_vc4437_mlemcbf, [10 10 0]);
			niipublish3 = mlfourd.NiiPublish(nii_vc4437_mlemcbf, [10 10 0], nii_vc4437_fg.img);
			
			mlunit.assert_equals(expected, actual, '');
			mlunit.assert_not_equals(expected, actual, '');
		end
		
		
		function obj = test_nii(obj)
			size(niipublish.nii_.img)
			dip_image(niipublish.nii_.img)
			niipublish.nii_.hdr
			niipublish.nii_.hdr.hk
			niipublish.nii_.hdr.dime
			niipublish.nii_.hdr.dime.dim
			niipublish.nii_.hdr.dime.pixdim
			niipublish.nii_.hdr.hist
			niipublish.nii_.hdr.hist.descrip
			mlunit.assert_equals(expected, actual, '');
			mlunit.assert_not_equals(expected, actual, '');
		end
		
		
		function obj = test_niiblur(obj)
			niib = niipublish.niiblur(nii_vc4437_fg.img)
			niib.hdr
			niib.hdr.hist
			niib.hdr.hist.descrip
		end
		

		
		
		
		
		
		
		
		
		
		
		
		
		
	end
end
