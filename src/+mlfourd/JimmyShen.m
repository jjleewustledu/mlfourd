classdef JimmyShen
    %% See also fullfile(getenv('HOME'), 'MATLAB-Drive', 'mlniftitools', '')
    %  
    %  Created 27-Feb-2022 23:45:37 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1873467 (R2021b) Update 3 for MACI64.  Copyright 2022 John J. Lee.
    
    methods (Static)
        function nii = adjust_nii(nii)
            %% adjust nii for use by ImagingFormatTool

            import mlfourd.JimmyShen;

            if nii.filetype ~= 1 && nii.filetype ~= 2 % not nifti
                return
            end
            if ~isfield(nii, 'original') || isempty(nii.original)
                return
            end
            if nii.original.hdr.dime.pixdim(1) == 0 || ...
               nii.original.hdr.dime.pixdim(1) == -1 % original radiological
                nii.hdr.dime.pixdim(1) = -1;
                %nii.hdr.hist.qform_code = 0;
                %nii.hdr.hist.sform_code = 1;
                nii.img = flip(nii.img, 1);
                return
            end
            if nii.original.hdr.dime.pixdim(1) == 1 % original neurological
                nii.hdr.dime.pixdim(1) = -1;
                %nii.hdr.hist.qform_code = 0;
                %nii.hdr.hist.sform_code = 1;
                nii.hdr.hist.quatern_b = 0;
                nii.hdr.hist.quatern_c = 1;
                nii.hdr.hist.quatern_d = 0;
                nii.hdr.hist.qoffset_x = -nii.hdr.hist.qoffset_x;
                nii.hdr.hist.srow_x = -nii.hdr.hist.srow_x;
                nii.img = flip(nii.img, 1);
                return
            end
        end
        function nii = flip_lr_nii(nii)
            %% With flip_lr_nii, you can convert any ANALYZE or NIfTI (no matter
            %  3D or 4D) file to a flipped NIfTI file. This is implemented simply
            %  by flipping the affine matrix in the NIfTI header and the NIfTI image.
            %
            %  Usage: nii = flip_lr_nii(nii)
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
            %  - John Lee (jjlee@wustl.edu)

            M = diag(nii.hdr.dime.pixdim(2:5));
            M(1:3,4) = -M(1:3,1:3)*(nii.hdr.hist.originator(1:3)-1)';
            M(1,:) = -1*M(1,:);
            nii.hdr.hist.sform_code = 1;
            nii.hdr.hist.srow_x = M(1,:);
            nii.hdr.hist.srow_y = M(2,:);
            nii.hdr.hist.srow_z = M(3,:);

            % alternatives

            % M=[[diag(nii.hdr.dime.pixdim(2:4)) -[nii.hdr.hist.originator(1:3).*nii.hdr.dime.pixdim(2:4)]'];[0 0 0 1]]; 

            % hdr.hist.sform_code = 1;
            % hdr.hist.srow_x(1) = hdr.dime.pixdim(2);
            % hdr.hist.srow_x(2) = 0;
            % hdr.hist.srow_x(3) = 0;
            % hdr.hist.srow_y(1) = 0;
            % hdr.hist.srow_y(2) = hdr.dime.pixdim(3);
            % hdr.hist.srow_y(3) = 0;
            % hdr.hist.srow_z(1) = 0;
            % hdr.hist.srow_z(2) = 0;
            % hdr.hist.srow_z(3) = hdr.dime.pixdim(4);
            % hdr.hist.srow_x(4) = (1-hdr.hist.originator(1))*hdr.dime.pixdim(2);
            % hdr.hist.srow_y(4) = (1-hdr.hist.originator(2))*hdr.dime.pixdim(3);
            % hdr.hist.srow_z(4) = (1-hdr.hist.originator(3))*hdr.dime.pixdim(4);
        end
        function nii = load_nii(filename, img_idx, dim5_idx, dim6_idx, dim7_idx, ...
    			old_RGB, tolerance, preferredForm)
            %% Load NIFTI or ANALYZE dataset. Support both *.nii and *.hdr/*.img
            %  file extension. If file extension is not provided, *.hdr/*.img will
            %  be used as default.
            %
            %  A subset of NIFTI transform is included. For non-orthogonal rotation,
            %  shearing etc., please use 'reslice_nii.m' to reslice the NIFTI file.
            %  It will not cause negative effect, as long as you remember not to do
            %  slice time correction after reslicing the NIFTI file. Output variable
            %  nii will be in RAS orientation, i.e. X axis from Left to Right,
            %  Y axis from Posterior to Anterior, and Z axis from Inferior to
            %  Superior.
            %
            %  Usage: nii = load_nii(filename, [img_idx], [dim5_idx], [dim6_idx], ...
            %			[dim7_idx], [old_RGB], [tolerance], [preferredForm])
            %
            %  filename  - 	NIFTI or ANALYZE file name.
            %
            %  img_idx (optional)  -  a numerical array of 4th dimension indices,
            %	which is the indices of image scan volume. The number of images
            %	scan volumes can be obtained from get_nii_frame.m, or simply
            %	hdr.dime.dim(5). Only the specified volumes will be loaded.
            %	All available image volumes will be loaded, if it is default or
            %	empty.
            %
            %  dim5_idx (optional)  -  a numerical array of 5th dimension indices.
            %	Only the specified range will be loaded. All available range
            %	will be loaded, if it is default or empty.
            %
            %  dim6_idx (optional)  -  a numerical array of 6th dimension indices.
            %	Only the specified range will be loaded. All available range
            %	will be loaded, if it is default or empty.
            %
            %  dim7_idx (optional)  -  a numerical array of 7th dimension indices.
            %	Only the specified range will be loaded. All available range
            %	will be loaded, if it is default or empty.
            %
            %  old_RGB (optional)  -  a scale number to tell difference of new RGB24
            %	from old RGB24. New RGB24 uses RGB triple sequentially for each
            %	voxel, like [R1 G1 B1 R2 G2 B2 ...]. Analyze 6.0 from AnalyzeDirect
            %	uses old RGB24, in a way like [R1 R2 ... G1 G2 ... B1 B2 ...] for
            %	each slices. If the image that you view is garbled, try to set
            %	old_RGB variable to 1 and try again, because it could be in
            %	old RGB24. It will be set to 0, if it is default or empty.
            %
            %  tolerance (optional) - distortion allowed in the loaded image for any
            %	non-orthogonal rotation or shearing of NIfTI affine matrix. If
            %	you set 'tolerance' to 0, it means that you do not allow any
            %	distortion. If you set 'tolerance' to 1, it means that you do
            %	not care any distortion. The image will fail to be loaded if it
            %	can not be tolerated. The tolerance will be set to 0.1 (10%), if
            %	it is default or empty.
            %
            %  preferredForm (optional)  -  selects which transformation from voxels
            %	to RAS coordinates; values are s,q,S,Q.  Lower case s,q indicate
            %	"prefer sform or qform, but use others if preferred not present".
            %	Upper case indicate the program is forced to use the specificied
            %	tranform or fail loading.  'preferredForm' will be 's', if it is
            %	default or empty.	- Jeff Gunter
            %
            %  Returned values:
            %
            %  nii structure:
            %
            %	hdr -		struct with NIFTI header fields.
            %
            %	filetype -	Analyze format .hdr/.img (0);
            %			NIFTI .hdr/.img (1);
            %			NIFTI .nii (2)
            %
            %	fileprefix - 	NIFTI filename without extension.
            %
            %	machine - 	machine string variable.
            %
            %	img - 		3D (or 4D) matrix of NIFTI data.
            %
            %	original -	the original header before any affine transform.
            %
            %  Part of this file is copied and modified from:
            %  http://www.mathworks.com/matlabcentral/fileexchange/1878-mri-analyze-tools
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)

            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.load_nii_hdr;
            import mlfourd.JimmyShen.load_nii_img;
            import mlfourd.JimmyShen.xform_nii;

            filename = convertStringsToChars(filename);

            if ~exist('filename','var')
                error('mlfourd:NameError', 'Usage: nii = load_nii(filename, [img_idx], [dim5_idx], [dim6_idx], [dim7_idx], [old_RGB], [tolerance], [preferredForm])');
            end

            if ~exist('img_idx','var') || isempty(img_idx)
                img_idx = [];
            end

            if ~exist('dim5_idx','var') || isempty(dim5_idx)
                dim5_idx = [];
            end

            if ~exist('dim6_idx','var') || isempty(dim6_idx)
                dim6_idx = [];
            end

            if ~exist('dim7_idx','var') || isempty(dim7_idx)
                dim7_idx = [];
            end

            if ~exist('old_RGB','var') || isempty(old_RGB)
                old_RGB = 0;
            end

            if ~exist('tolerance','var') || isempty(tolerance)
                tolerance = 0.1;			% 10 percent
            end

            if ~exist('preferredForm','var') || isempty(preferredForm)
                preferredForm= mlfourd.JimmyShen.PREFERRED_FORM;		% jjlee
            end

            v = version;

            %  Check file extension. If .gz, unpack it into temp folder
            %
            if length(filename) > 2 && strcmp(filename(end-2:end), '.gz')

                if ~strcmp(filename(end-6:end), '.img.gz') && ...
               	     ~strcmp(filename(end-6:end), '.hdr.gz') && ...
            	     ~strcmp(filename(end-6:end), '.nii.gz')

                    error('mlfourd:ValueError', 'Please check filename.');
                end

                if str2double(v(1:3)) < 7.1 || ~usejava('jvm')
                    error('mlfourd:RuntimeError', 'Please use MATLAB 7.1 (with java) and above, or run gunzip outside MATLAB.');
                elseif strcmp(filename(end-6:end), '.img.gz')
                    filename1 = filename;
                    filename2 = filename;
                    filename2(end-6:end) = '';
                    filename2 = [filename2, '.hdr.gz'];

                    tmpDir = tempname;
                    mkdir(tmpDir);
                    gzFileName = filename;

                    filename1 = gunzip(filename1, tmpDir);
                    filename2 = gunzip(filename2, tmpDir);
                    filename = char(filename1);	% convert from cell to string
                elseif strcmp(filename(end-6:end), '.hdr.gz')
                    filename1 = filename;
                    filename2 = filename;
                    filename2(end-6:end) = '';
                    filename2 = [filename2, '.img.gz'];

                    tmpDir = tempname;
                    mkdir(tmpDir);
                    gzFileName = filename;

                    filename1 = gunzip(filename1, tmpDir);
                    filename2 = gunzip(filename2, tmpDir);
                    filename = char(filename1);	% convert from cell to string
                elseif strcmp(filename(end-6:end), '.nii.gz')
                    tmpDir = tempname;
                    mkdir(tmpDir);
                    gzFileName = filename;
                    filename = gunzip(filename, tmpDir);
                    filename = char(filename);	% convert from cell to string
                end
            end

            %  Read the dataset header
            %
            [nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = JimmyShen.load_nii_hdr(filename);

            %  Read the header extension
            %
            %   nii.ext = load_nii_ext(filename);

            %  Read the dataset body
            %
            [nii.img,nii.hdr] = JimmyShen.load_nii_img(nii.hdr,nii.filetype,nii.fileprefix, ...
        		nii.machine,img_idx,dim5_idx,dim6_idx,dim7_idx,old_RGB);

            %  Perform some of sform/qform transform
            %
            nii = JimmyShen.xform_nii(nii, tolerance, preferredForm);

            %  Clean up after gunzip
            %
            if exist('gzFileName', 'var')

                %  fix fileprefix so it doesn't point to temp location
                %
                nii.fileprefix = gzFileName(1:end-7);
                rmdir(tmpDir,'s');
            end

            %  Adjust orientations and 4dfp as needed; jjlee
            %
            nii = JimmyShen.adjust_nii(nii);
        end
        function nii = make_nii(varargin)
            %% Make NIfTI structure specified by an N-D matrix. Usually, N is 3 for 
            %  3D matrix [x y z], or 4 for 4D matrix with time series [x y z t]. 
            %  Optional parameters can also be included, such as: voxel_size, 
            %  origin, datatype, and description. 
            %  
            %  Once the NIfTI structure is made, it can be saved into NIfTI file 
            %  using "save_nii" command (for more detail, type: help save_nii). 
            %  
            %  Usage: nii = make_nii(img, [voxel_size], [origin], [datatype], [description])
            %
            %  Where:
            %
            %	img:		Usually, img is a 3D matrix [x y z], or a 4D
            %			matrix with time series [x y z t]. However,
            %			NIfTI allows a maximum of 7D matrix. When the
            %			image is in RGB format, make sure that the size
            %			of 4th dimension is always 3 (i.e. [R G B]). In
            %			that case, make sure that you must specify RGB
            %			datatype, which is either 128 or 511.
            %
            %	voxel_size (optional):	Voxel size in millimeter for each
            %				dimension. Default is [1 1 1].
            %
            %	origin (optional):	The AC origin. Default is [0 0 0].
            %
            %	datatype (optional):	Storage data type:
            %		2 - uint8,  4 - int16,  8 - int32,  16 - float32,
            %		32 - complex64,  64 - float64,  128 - RGB24,
            %		256 - int8,  511 - RGB96,  512 - uint16,
            %		768 - uint32,  1792 - complex128
            %			Default will use the data type of 'img' matrix
            %			For RGB image, you must specify it to either 128
            %			or 511.
            %
            %	description (optional):	Description of data. Default is ''.
            %
            %  e.g.:
            %     origin = [33 44 13]; datatype = 64;
            %     nii = make_nii(img, [], origin, datatype);    % default voxel_size
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)

            import mlfourd.JimmyShen
            import mlfourd.JimmyShen.make_header;

            nii.img = varargin{1};
            dims = size(nii.img);
            dims = [length(dims) dims ones(1,8)];
            dims = dims(1:8);

            voxel_size = [0 ones(1,7)];
            origin = zeros(1,5);
            descrip = '';

            switch class(nii.img)
                case 'uint8'
                    datatype = 2;
                case 'int16'
                    datatype = 4;
                case 'int32'
                    datatype = 8;
                case 'single'
                    if isreal(nii.img)
                        datatype = 16;
                    else
                        datatype = 32;
                    end
                case 'double'
                    if isreal(nii.img)
                        datatype = 64;
                    else
                        datatype = 1792;
                    end
                case 'int8'
                    datatype = 256;
                case 'uint16'
                    datatype = 512;
                case 'uint32'
                    datatype = 768;
                otherwise
                    error('mlfourd:TypeError', 'Datatype is not supported by make_nii.');
            end

            if nargin > 1 && ~isempty(varargin{2})
                voxel_size(2:4) = double(varargin{2});
            end

            if nargin > 2 && ~isempty(varargin{3})
                origin(1:3) = double(varargin{3});
            end

            if nargin > 3 && ~isempty(varargin{4})
                datatype = double(varargin{4});

                if datatype == 128 || datatype == 511
                    dims(5) = [];
                    dims(1) = dims(1) - 1;
                    dims = [dims 1];
                end
            end

            if nargin > 4 && ~isempty(varargin{5})
                descrip = varargin{5};
            end

            if ndims(nii.img) > 7
                error('mlfourd:RuntimeError', 'NIfTI only allows a maximum of 7 Dimension matrix.');
            end

            maxval = round(double(max(nii.img(:))));
            minval = round(double(min(nii.img(:))));

            nii.hdr = JimmyShen.make_header(dims, voxel_size, origin, datatype, ...
            	descrip, maxval, minval);

            switch nii.hdr.dime.datatype
                case 2
                    nii.img = uint8(nii.img);
                case 4
                    nii.img = int16(nii.img);
                case 8
                    nii.img = int32(nii.img);
                case 16
                    nii.img = single(nii.img);
                case 32
                    nii.img = single(nii.img);
                case 64
                    nii.img = double(nii.img);
                case 128
                    nii.img = uint8(nii.img);
                case 256
                    nii.img = int8(nii.img);
                case 511
                    img = double(nii.img(:));
                    img = single((img - min(img))/(max(img) - min(img)));
                    nii.img = reshape(img, size(nii.img));
                    nii.hdr.dime.glmax = double(max(img));
                    nii.hdr.dime.glmin = double(min(img));
                case 512
                    nii.img = uint16(nii.img);
                case 768
                    nii.img = uint32(nii.img);
                case 1792
                    nii.img = double(nii.img);
                otherwise
                    error('mlfourd:TypeError', 'Datatype is not supported by make_nii.');
            end
        end
        function reslice_nii(old_fn, new_fn, voxel_size, verbose, bg, method, img_idx, preferredForm)
            %%  The basic application of the 'reslice_nii.m' program is to perform
            %  any 3D affine transform defined by a NIfTI format image.
            %
            %  In addition, the 'reslice_nii.m' program can also be applied to
            %  generate an isotropic image from either a NIfTI format image or
            %  an ANALYZE format image.
            %
            %  The resliced NIfTI file will always be in RAS orientation.
            %
            %  This program only supports real integer or floating-point data type.
            %  For other data type, the program will exit with an error message 
            %  "Transform of this NIFTI data is not supported by the program".
            %
            %  Usage: reslice_nii(old_fn, new_fn, [voxel_size], [verbose], [bg], ...
            %			[method], [img_idx], [preferredForm]);
            %
            %  old_fn  -	filename for original NIfTI file
            %
            %  new_fn  -	filename for resliced NIfTI file
            %
            %  voxel_size (optional)  - size of a voxel in millimeter along x y z
            %		direction for resliced NIfTI file. 'voxel_size' will use
            %		the minimum voxel_size in original NIfTI header,
            %		if it is default or empty.
            %
            %  verbose (optional) - 1, 0
            %			1:  show transforming progress in percentage
            %			0:  progress will not be displayed
            %			'verbose' is 0 if it is default or empty.
            %
            %  bg (optional)  -	background voxel intensity in any extra corner that
            %			is caused by 3D interpolation. 0 in most cases. 'bg'
            %			will be the average of two corner voxel intensities
            %			in original image volume, if it is default or empty.
            %
            %  method (optional)  -	1, 2, or 3
            %			1:  for Trilinear interpolation
            %			2:  for Nearest Neighbor interpolation
            %			3:  for Fischer's Bresenham interpolation
            %			'method' is 1 if it is default or empty.
            %
            %  img_idx (optional)  -  a numerical array of image volume indices. Only
            %		the specified volumes will be loaded. All available image
            %		volumes will be loaded, if it is default or empty.
            %
            %	The number of images scans can be obtained from get_nii_frame.m,
            %	or simply: hdr.dime.dim(5).
            %
            %  preferredForm (optional)  -  selects which transformation from voxels
            %	to RAS coordinates; values are s,q,S,Q.  Lower case s,q indicate
            %	"prefer sform or qform, but use others if preferred not present". 
            %	Upper case indicate the program is forced to use the specificied
            %	tranform or fail loading.  'preferredForm' will be 's', if it is
            %	default or empty.	- Jeff Gunter
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %  
            %  - Jimmy Shen (jshen@research.baycrest.org)

            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.affine;
            import mlfourd.JimmyShen.load_nii_no_xform;
            import mlfourd.JimmyShen.save_nii;

            old_fn = convertStringsToChars(old_fn);
            new_fn = convertStringsToChars(new_fn);
            if exist('preferredForm','var')
                preferredForm = convertStringsToChars(preferredForm);
            end

            if ~exist('old_fn','var') || ~exist('new_fn','var')
                error('Usage: reslice_nii(old_fn, new_fn, [voxel_size], [verbose], [bg], [method], [img_idx])');
            end

            if ~exist('method','var') || isempty(method)
                method = 1;
            end

            if ~exist('img_idx','var') || isempty(img_idx)
                img_idx = [];
            end

            if ~exist('verbose','var') || isempty(verbose)
                verbose = 0;
            end

            if ~exist('preferredForm','var') || isempty(preferredForm)
                preferredForm= 's';	% Jeff
            end

            nii = load_nii_no_xform(old_fn, img_idx, 0, preferredForm);

            if ~ismember(nii.hdr.dime.datatype, [2,4,8,16,64,256,512,768])
                error('Transform of this NIFTI data is not supported by the program.');
            end

            if ~exist('voxel_size','var') || isempty(voxel_size)
                voxel_size = abs(min(nii.hdr.dime.pixdim(2:4)))*ones(1,3);
            elseif length(voxel_size) < 3
                voxel_size = abs(voxel_size(1))*ones(1,3);
            end

            if ~exist('bg','var') || isempty(bg)
                bg = mean([nii.img(1) nii.img(end)]);
            end

            old_M = nii.hdr.hist.old_affine;

            if nii.hdr.dime.dim(5) > 1
                for i = 1:nii.hdr.dime.dim(5)
                    if verbose
                        fprintf('Reslicing %d of %d volumes.\n', i, nii.hdr.dime.dim(5));
                    end

                    [img(:,:,:,i),M] = ...
                		affine(nii.img(:,:,:,i), old_M, voxel_size, verbose, bg, method);
                end
            else
                [img,M] = affine(nii.img, old_M, voxel_size, verbose, bg, method);
            end

            new_dim = size(img);
            nii.img = img;
            nii.hdr.dime.dim(2:4) = new_dim(1:3);
            nii.hdr.dime.datatype = 16;
            nii.hdr.dime.bitpix = 32;
            nii.hdr.dime.pixdim(2:4) = voxel_size(:)';
            nii.hdr.dime.glmax = max(img(:));
            nii.hdr.dime.glmin = min(img(:));
            nii.hdr.hist.qform_code = 0;
            nii.hdr.hist.sform_code = 1;
            nii.hdr.hist.srow_x = M(1,:);
            nii.hdr.hist.srow_y = M(2,:);
            nii.hdr.hist.srow_z = M(3,:);
            nii.hdr.hist.new_affine = M;

            save_nii(nii, new_fn);
        end
        function save_nii(nii, fileprefix, old_RGB)
            %% Save NIFTI dataset. Support both *.nii and *.hdr/*.img file extension.
            %  If file extension is not provided, *.hdr/*.img will be used as default.
            %
            %  Usage: save_nii(nii, filename, [old_RGB])
            %
            %  nii.hdr - struct with NIFTI header fields (from load_nii.m or make_nii.m)
            %
            %  nii.img - 3D (or 4D) matrix of NIFTI data.
            %
            %  filename - NIFTI file name.
            %
            %  old_RGB    - an optional boolean variable to handle special RGB data
            %       sequence [R1 R2 ... G1 G2 ... B1 B2 ...] that is used only by
            %       AnalyzeDirect (Analyze Software). Since both NIfTI and Analyze
            %       file format use RGB triple [R1 G1 B1 R2 G2 B2 ...] sequentially
            %       for each voxel, this variable is set to FALSE by default. If you
            %       would like the saved image only to be opened by AnalyzeDirect
            %       Software, set old_RGB to TRUE (or 1). It will be set to 0, if it
            %       is default or empty.
            %
            %  Tip: to change the data type, set nii.hdr.dime.datatype,
            %	and nii.hdr.dime.bitpix to:
            %
            %     0 None                     (Unknown bit per voxel) % DT_NONE, DT_UNKNOWN
            %     1 Binary                         (ubit1, bitpix=1) % DT_BINARY
            %     2 Unsigned char         (uchar or uint8, bitpix=8) % DT_UINT8, NIFTI_TYPE_UINT8
            %     4 Signed short                  (int16, bitpix=16) % DT_INT16, NIFTI_TYPE_INT16
            %     8 Signed integer                (int32, bitpix=32) % DT_INT32, NIFTI_TYPE_INT32
            %    16 Floating point    (single or float32, bitpix=32) % DT_FLOAT32, NIFTI_TYPE_FLOAT32
            %    32 Complex, 2 float32      (Use float32, bitpix=64) % DT_COMPLEX64, NIFTI_TYPE_COMPLEX64
            %    64 Double precision  (double or float64, bitpix=64) % DT_FLOAT64, NIFTI_TYPE_FLOAT64
            %   128 uint RGB                  (Use uint8, bitpix=24) % DT_RGB24, NIFTI_TYPE_RGB24
            %   256 Signed char            (schar or int8, bitpix=8) % DT_INT8, NIFTI_TYPE_INT8
            %   511 Single RGB              (Use float32, bitpix=96) % DT_RGB96, NIFTI_TYPE_RGB96
            %   512 Unsigned short               (uint16, bitpix=16) % DT_UNINT16, NIFTI_TYPE_UNINT16
            %   768 Unsigned integer             (uint32, bitpix=32) % DT_UNINT32, NIFTI_TYPE_UNINT32
            %  1024 Signed long long              (int64, bitpix=64) % DT_INT64, NIFTI_TYPE_INT64
            %  1280 Unsigned long long           (uint64, bitpix=64) % DT_UINT64, NIFTI_TYPE_UINT64
            %  1536 Long double, float128  (Unsupported, bitpix=128) % DT_FLOAT128, NIFTI_TYPE_FLOAT128
            %  1792 Complex128, 2 float64  (Use float64, bitpix=128) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128
            %  2048 Complex256, 2 float128 (Unsupported, bitpix=256) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128
            %
            %  Part of this file is copied and modified from:
            %  http://www.mathworks.com/matlabcentral/fileexchange/1878-mri-analyze-tools
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
            %  - "old_RGB" related codes in "save_nii.m" are added by Mike Harms (2006.06.28)

            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.write_nii;

            fileprefix = convertStringsToChars(fileprefix);

            if ~exist('nii','var') || isempty(nii) || ~isfield(nii,'hdr') || ...
                	~isfield(nii,'img') || ~exist('fileprefix','var') || isempty(fileprefix)

                error('mlfourd:NameError', 'Usage: save_nii(nii, filename, [old_RGB])');
            end

            if isfield(nii, 'untouch') && ~isempty(nii.untouch) && nii.untouch == 1
                error('mlfourd:ValueError', 'Usage: please use ''save_untouch_nii.m'' for the untouched structure.');
            end

            if ~exist('old_RGB','var') || isempty(old_RGB)
                old_RGB = 0;
            end

            v = version;

            %  Check file extension. If .gz, unpack it into temp folder
            %
            if length(fileprefix) > 2 && strcmp(fileprefix(end-2:end), '.gz')

                if ~strcmp(fileprefix(end-6:end), '.img.gz') && ...
                        ~strcmp(fileprefix(end-6:end), '.hdr.gz') && ...
                        ~strcmp(fileprefix(end-6:end), '.nii.gz')
                    error('mlfourd:ValueError', 'Please check filename.');
                end

                if str2double(v(1:3)) < 7.1 || ~usejava('jvm')  
                    error('mlfourd:RuntimeError', 'Please use MATLAB 7.1 (with java) and above, or run gunzip outside MATLAB.');
                else
                    gzFile = 1;
                    fileprefix = fileprefix(1:end-3);
                end
            end

            filetype = 1;

            %  Note: fileprefix is actually the filename you want to save
            %
            if endsWith(fileprefix, '.nii')
                filetype = 2;
                fileprefix(end-3:end)='';
            end

            if endsWith(fileprefix, '.hdr')
                fileprefix(end-3:end)='';
            end

            if endsWith(fileprefix, '.img')
                fileprefix(end-3:end)='';
            end

            JimmyShen.write_nii(nii, filetype, fileprefix, old_RGB);

            %  gzip output file if requested
            %
            if exist('gzFile', 'var')
                if filetype == 1
                    gzip([fileprefix, '.img']);
                    delete([fileprefix, '.img']);
                    gzip([fileprefix, '.hdr']);
                    delete([fileprefix, '.hdr']);
                elseif filetype == 2
                    gzip([fileprefix, '.nii']);
                    delete([fileprefix, '.nii']);
                end
            end

            if filetype == 1

                %  So earlier versions of SPM can also open it with correct originator
                %
                M=[[diag(nii.hdr.dime.pixdim(2:4)) -[nii.hdr.hist.originator(1:3).*nii.hdr.dime.pixdim(2:4)]'];[0 0 0 1]]; %#ok<NBRAK> 
                save([fileprefix '.mat'], 'M');
            end
        end
        function save_nii_ext(ext, fid)
            %% Save NIFTI header extension.
            %
            %  Usage: save_nii_ext(ext, fid)
            %
            %  ext - struct with NIFTI header extension fields.
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.write_ext;

            if ~exist('ext','var') || ~exist('fid','var')
                error('mlfourd:NameError', 'Usage: save_nii_ext(ext, fid)');
            end

            if ~isfield(ext,'extension') || ~isfield(ext,'section') || ~isfield(ext,'num_ext')
                error('mlfourd:ValueError', 'Wrong header extension');
            end

            JimmyShen.write_ext(ext, fid);
        end
        function [ext, esize_total] = verify_nii_ext(ext)
            %% Verify NIFTI header extension to make sure that each extension section
            %  must be an integer multiple of 16 byte long that includes the first 8
            %  bytes of esize and ecode. If the length of extension section is not the
            %  above mentioned case, edata should be padded with all 0.
            %
            %  Usage: [ext, esize_total] = verify_nii_ext(ext)
            %
            %  ext - Structure of NIFTI header extension, which includes num_ext,
            %       and all the extended header sections in the header extension.
            %       Each extended header section will have its esize, ecode, and
            %       edata, where edata can be plain text, xml, or any raw data
            %       that was saved in the extended header section.
            %
            %  esize_total - Sum of all esize variable in all header sections.
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)

            if ~isfield(ext, 'section')
                error('mlfourd:ValueError', 'Incorrect NIFTI header extension structure.');
            elseif ~isfield(ext, 'num_ext')
                ext.num_ext = length(ext.section);
            elseif ~isfield(ext, 'extension')
                ext.extension = [1 0 0 0];
            end

            esize_total = 0;

            for i=1:ext.num_ext
                if ~isfield(ext.section(i), 'ecode') || ~isfield(ext.section(i), 'edata')
                    error('mlfourd:ValueError', 'Incorrect NIFTI header extension structure.');
                end

                ext.section(i).esize = ceil((length(ext.section(i).edata)+8)/16)*16;
                ext.section(i).edata = ...
                	[ext.section(i).edata ...
               	 zeros(1,ext.section(i).esize-length(ext.section(i).edata)-8)];
                esize_total = esize_total + ext.section(i).esize;
            end
        end

        %% load_nii dependencies

        function [hdr, filetype, fileprefix, machine] = load_nii_hdr(fileprefix)

            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.read_header;

            fileprefix = convertStringsToChars(fileprefix);

            if ~exist('fileprefix','var')
                error('mlfourd:NameError', 'Usage: [hdr, filetype, fileprefix, machine] = load_nii_hdr(filename)');
            end

            machine = 'ieee-le';
            new_ext = 0;

            if endsWith(fileprefix, '.nii')
                new_ext = 1;
                fileprefix(end-3:end)='';
            end

            if endsWith(fileprefix, '.hdr')
                fileprefix(end-3:end)='';
            end

            if endsWith(fileprefix, '.img')
                fileprefix(end-3:end)='';
            end

            if new_ext
                fn = sprintf('%s.nii',fileprefix);

                if ~isfile(fn)
                    error('mlfourd:IOError', 'Cannot find file "%s.nii".', fileprefix);
                end
            else
                fn = sprintf('%s.hdr',fileprefix);

                if ~isfile(fn)
                    error('mlfourd:IOError', 'Cannot find file "%s.hdr".', fileprefix);
                end
            end

            fid = fopen(fn,'r',machine);

            if fid < 0
                error('mlfourd:IOError', 'Cannot open file %s.', fn);
            else
                fseek(fid,0,'bof');

                if fread(fid,1,'int32') == 348
                    hdr = JimmyShen.read_header(fid);
                    fclose(fid);
                else
                    fclose(fid);

                    %  first try reading the opposite endian to 'machine'
                    %
                    switch machine
                        case 'ieee-le', machine = 'ieee-be';
                        case 'ieee-be', machine = 'ieee-le';
                    end

                    fid = fopen(fn,'r',machine);

                    if fid < 0
                        error('mlfourd:IOError', 'Cannot open file %s.', fn);
                    else
                        fseek(fid,0,'bof');

                        if fread(fid,1,'int32') ~= 348

                            %  Now throw an error
                            %
                            error('mlfourd:IOError', 'File "%s" is corrupted.', fn);
                        end

                        hdr = JimmyShen.read_header(fid);
                        fclose(fid);
                    end
                end
            end

            if strcmp(hdr.hist.magic, 'n+1')
                filetype = 2;
            elseif strcmp(hdr.hist.magic, 'ni1')
                filetype = 1;
            else
                filetype = 0;
            end
        end
        function dsr = read_header(fid)

            %  Original header structures
        	%  struct dsr
        	%       {
        	%       struct header_key hk;            /*   0 +  40       */
        	%       struct image_dimension dime;     /*  40 + 108       */
        	%       struct data_history hist;        /* 148 + 200       */
        	%       };                               /* total= 348 bytes*/

            import mlfourd.JimmyShen;

            dsr.hk   = JimmyShen.read_header_key(fid);
            dsr.dime = JimmyShen.read_image_dimension(fid);
            dsr.hist = JimmyShen.read_data_history(fid);

            %  For Analyze data format
            %
            if ~strcmp(dsr.hist.magic, 'n+1') && ~strcmp(dsr.hist.magic, 'ni1')
                dsr.hist.qform_code = 0;
                dsr.hist.sform_code = 0;
            end
        end
        function hk = read_header_key(fid)

            fseek(fid,0,'bof');

        	%  Original header structures
        	%  struct header_key                     /* header key      */
        	%       {                                /* off + size      */
        	%       int sizeof_hdr                   /*  0 +  4         */
        	%       char data_type[10];              /*  4 + 10         */
        	%       char db_name[18];                /* 14 + 18         */
        	%       int extents;                     /* 32 +  4         */
        	%       short int session_error;         /* 36 +  2         */
        	%       char regular;                    /* 38 +  1         */
        	%       char dim_info;   % char hkey_un0;        /* 39 +  1 */
        	%       };                               /* total=40 bytes  */
        	%
        	% int sizeof_header   Should be 348.
        	% char regular        Must be 'r' to indicate that all images and
        	%                     volumes are the same size.

            v6 = version;
            if str2double(v6(1))<6
                directchar = '*char';
            else
                directchar = 'uchar=>char';
            end

            hk.sizeof_hdr    = fread(fid, 1,'int32')';	% should be 348!
            hk.data_type     = deblank(fread(fid,10,directchar)');
            hk.db_name       = deblank(fread(fid,18,directchar)');
            hk.extents       = fread(fid, 1,'int32')';
            hk.session_error = fread(fid, 1,'int16')';
            hk.regular       = fread(fid, 1,directchar)';
            hk.dim_info      = fread(fid, 1,'uchar')';
        end
        function dime = read_image_dimension(fid)

        	%  Original header structures
        	%  struct image_dimension
        	%       {                                /* off + size      */
        	%       short int dim[8];                /* 0 + 16          */
            %       /*
            %           dim[0]      Number of dimensions in database; usually 4.
            %           dim[1]      Image X dimension;  number of *pixels* in an image row.
            %           dim[2]      Image Y dimension;  number of *pixel rows* in slice.
            %           dim[3]      Volume Z dimension; number of *slices* in a volume.
            %           dim[4]      Time points; number of volumes in database
            %       */
        	%       float intent_p1;   % char vox_units[4];   /* 16 + 4       */
        	%       float intent_p2;   % char cal_units[8];   /* 20 + 4       */
        	%       float intent_p3;   % char cal_units[8];   /* 24 + 4       */
        	%       short int intent_code;   % short int unused1;   /* 28 + 2 */
        	%       short int datatype;              /* 30 + 2          */
        	%       short int bitpix;                /* 32 + 2          */
        	%       short int slice_start;   % short int dim_un0;   /* 34 + 2 */
        	%       float pixdim[8];                 /* 36 + 32         */
        	%	/*
        	%		pixdim[] specifies the voxel dimensions:
        	%		pixdim[1] - voxel width, mm
        	%		pixdim[2] - voxel height, mm
        	%		pixdim[3] - slice thickness, mm
        	%		pixdim[4] - volume timing, in msec
        	%					..etc
        	%	*/
        	%       float vox_offset;                /* 68 + 4          */
        	%       float scl_slope;   % float roi_scale;     /* 72 + 4 */
        	%       float scl_inter;   % float funused1;      /* 76 + 4 */
        	%       short slice_end;   % float funused2;      /* 80 + 2 */
        	%       char slice_code;   % float funused2;      /* 82 + 1 */
        	%       char xyzt_units;   % float funused2;      /* 83 + 1 */
        	%       float cal_max;                   /* 84 + 4          */
        	%       float cal_min;                   /* 88 + 4          */
        	%       float slice_duration;   % int compressed; /* 92 + 4 */
        	%       float toffset;   % int verified;          /* 96 + 4 */
        	%       int glmax;                       /* 100 + 4         */
        	%       int glmin;                       /* 104 + 4         */
        	%       };                               /* total=108 bytes */

            dime.dim         = fread(fid,8,'int16')';
            dime.intent_p1   = fread(fid,1,'float32')';
            dime.intent_p2   = fread(fid,1,'float32')';
            dime.intent_p3   = fread(fid,1,'float32')';
            dime.intent_code = fread(fid,1,'int16')';
            dime.datatype    = fread(fid,1,'int16')';
            dime.bitpix      = fread(fid,1,'int16')';
            dime.slice_start = fread(fid,1,'int16')';
            dime.pixdim      = fread(fid,8,'float32')';
            dime.vox_offset  = fread(fid,1,'float32')';
            dime.scl_slope   = fread(fid,1,'float32')';
            dime.scl_inter   = fread(fid,1,'float32')';
            dime.slice_end   = fread(fid,1,'int16')';
            dime.slice_code  = fread(fid,1,'uchar')';
            dime.xyzt_units  = fread(fid,1,'uchar')';
            dime.cal_max     = fread(fid,1,'float32')';
            dime.cal_min     = fread(fid,1,'float32')';
            dime.slice_duration = fread(fid,1,'float32')';
            dime.toffset     = fread(fid,1,'float32')';
            dime.glmax       = fread(fid,1,'int32')';
            dime.glmin       = fread(fid,1,'int32')';
        end
        function hist = read_data_history(fid)

        	%  Original header structures
        	%  struct data_history
        	%       {                                /* off + size      */
        	%       char descrip[80];                /* 0 + 80          */
        	%       char aux_file[24];               /* 80 + 24         */
        	%       short int qform_code;            /* 104 + 2         */
        	%       short int sform_code;            /* 106 + 2         */
        	%       float quatern_b;                 /* 108 + 4         */
        	%       float quatern_c;                 /* 112 + 4         */
        	%       float quatern_d;                 /* 116 + 4         */
        	%       float qoffset_x;                 /* 120 + 4         */
        	%       float qoffset_y;                 /* 124 + 4         */
        	%       float qoffset_z;                 /* 128 + 4         */
        	%       float srow_x[4];                 /* 132 + 16        */
        	%       float srow_y[4];                 /* 148 + 16        */
        	%       float srow_z[4];                 /* 164 + 16        */
        	%       char intent_name[16];            /* 180 + 16        */
        	%       char magic[4];   % int smin;     /* 196 + 4         */
        	%       };                               /* total=200 bytes */

            v6 = version;
            if str2double(v6(1))<6
                directchar = '*char';
            else
                directchar = 'uchar=>char';
            end

            hist.descrip     = deblank(fread(fid,80,directchar)');
            hist.aux_file    = deblank(fread(fid,24,directchar)');
            hist.qform_code  = fread(fid,1,'int16')';
            hist.sform_code  = fread(fid,1,'int16')';
            hist.quatern_b   = fread(fid,1,'float32')';
            hist.quatern_c   = fread(fid,1,'float32')';
            hist.quatern_d   = fread(fid,1,'float32')';
            hist.qoffset_x   = fread(fid,1,'float32')';
            hist.qoffset_y   = fread(fid,1,'float32')';
            hist.qoffset_z   = fread(fid,1,'float32')';
            hist.srow_x      = fread(fid,4,'float32')';
            hist.srow_y      = fread(fid,4,'float32')';
            hist.srow_z      = fread(fid,4,'float32')';
            hist.intent_name = deblank(fread(fid,16,directchar)');
            hist.magic       = deblank(fread(fid,4,directchar)');

            fseek(fid,253,'bof');
            hist.originator  = fread(fid, 5,'int16')';
        end
        
        function [img,hdr] = load_nii_img(hdr,filetype,fileprefix,machine,img_idx,dim5_idx,dim6_idx,dim7_idx,old_RGB)

            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.read_image;

            fileprefix = convertStringsToChars(fileprefix);

            if ~exist('hdr','var') || ~exist('filetype','var') || ~exist('fileprefix','var') || ~exist('machine','var')
                error('mlfourd:NameError', 'Usage: [img,hdr] = load_nii_img(hdr,filetype,fileprefix,machine,[img_idx],[dim5_idx],[dim6_idx],[dim7_idx],[old_RGB]);');
            end

            if ~exist('img_idx','var') || isempty(img_idx) || hdr.dime.dim(5)<1
                img_idx = [];
            end

            if ~exist('dim5_idx','var') || isempty(dim5_idx) || hdr.dime.dim(6)<1
                dim5_idx = [];
            end

            if ~exist('dim6_idx','var') || isempty(dim6_idx) || hdr.dime.dim(7)<1
                dim6_idx = [];
            end

            if ~exist('dim7_idx','var') || isempty(dim7_idx) || hdr.dime.dim(8)<1
                dim7_idx = [];
            end

            if ~exist('old_RGB','var') || isempty(old_RGB)
                old_RGB = 0;
            end

            %  check img_idx
            %
            if ~isempty(img_idx) && ~isnumeric(img_idx)
                error('mlfourd:IndexError', '"img_idx" should be a numerical array.');
            end

            if length(unique(img_idx)) ~= length(img_idx)
                error('mlfourd:IndexError', 'Duplicate image index in "img_idx"');
            end

            if ~isempty(img_idx) && (min(img_idx) < 1 || max(img_idx) > hdr.dime.dim(5))
                max_range = hdr.dime.dim(5);

                if max_range == 1
                    error('mlfourd:IndexError', '"img_idx" should be 1.');
                else
                    range = ['1 ' num2str(max_range)];
                    error('mlfourd:IndexError', '"img_idx" should be an integer within the range of %g.', range);
                end
            end

            %  check dim5_idx
            %
            if ~isempty(dim5_idx) && ~isnumeric(dim5_idx)
                error('mlfourd:TypeError', '"dim5_idx" should be a numerical array.');
            end

            if length(unique(dim5_idx)) ~= length(dim5_idx)
                error('mlfourd:IndexError', 'Duplicate index in "dim5_idx"');
            end

            if ~isempty(dim5_idx) && (min(dim5_idx) < 1 || max(dim5_idx) > hdr.dime.dim(6))
                max_range = hdr.dime.dim(6);

                if max_range == 1
                    error('mlfourd:IndexError', '"dim5_idx" should be 1.');
                else
                    range = ['1 ' num2str(max_range)];
                    error('mlfourd:IndexError', '"dim5_idx" should be an integer within the range of %g.', range);
                end
            end

            %  check dim6_idx
            %
            if ~isempty(dim6_idx) && ~isnumeric(dim6_idx)
                error('mlfourd:TypeError', '"dim6_idx" should be a numerical array.');
            end

            if length(unique(dim6_idx)) ~= length(dim6_idx)
                error('mlfourd:IndexError', 'Duplicate index in "dim6_idx"');
            end

            if ~isempty(dim6_idx) && (min(dim6_idx) < 1 || max(dim6_idx) > hdr.dime.dim(7))
                max_range = hdr.dime.dim(7);

                if max_range == 1
                    error('mlfourd:IndexError', '"dim6_idx" should be 1.');
                else
                    range = ['1 ' num2str(max_range)];
                    error('mlfourd:IndexError', '"dim6_idx" should be an integer within the range of %g.', range);
                end
            end

            %  check dim7_idx
            %
            if ~isempty(dim7_idx) && ~isnumeric(dim7_idx)
                error('mlfourd:TypeError', '"dim7_idx" should be a numerical array.');
            end

            if length(unique(dim7_idx)) ~= length(dim7_idx)
                error('mlfourd:IndexError', 'Duplicate index in "dim7_idx"');
            end

            if ~isempty(dim7_idx) && (min(dim7_idx) < 1 || max(dim7_idx) > hdr.dime.dim(8))
                max_range = hdr.dime.dim(8);

                if max_range == 1
                    error('mlfourd:IndexError', '"dim7_idx" should be 1.');
                else
                    range = ['1 ' num2str(max_range)];
                    error('mlfourd:IndexError', '"dim7_idx" should be an integer within the range of %g.', range);
                end
            end

            [img,hdr] = JimmyShen.read_image(hdr,filetype,fileprefix,machine,img_idx,dim5_idx,dim6_idx,dim7_idx,old_RGB);
        end
        function [img,hdr] = read_image(hdr,filetype,fileprefix,machine,img_idx,dim5_idx,dim6_idx,dim7_idx,old_RGB)

            fileprefix = convertStringsToChars(fileprefix);

            switch filetype
                case {0, 1}
                    fn = [fileprefix '.img'];
                case 2
                    fn = [fileprefix '.nii'];
            end

            fid = fopen(fn,'r',machine);

            if fid < 0
                error('mlfourd:IOError', 'Cannot open file %s.', fn);
            end

            %  Set bitpix according to datatype
            %
            %  /*Acceptable values for datatype are*/
            %
            %     0 None                     (Unknown bit per voxel) % DT_NONE, DT_UNKNOWN
            %     1 Binary                         (ubit1, bitpix=1) % DT_BINARY
            %     2 Unsigned char         (uchar or uint8, bitpix=8) % DT_UINT8, NIFTI_TYPE_UINT8
            %     4 Signed short                  (int16, bitpix=16) % DT_INT16, NIFTI_TYPE_INT16
            %     8 Signed integer                (int32, bitpix=32) % DT_INT32, NIFTI_TYPE_INT32
            %    16 Floating point    (single or float32, bitpix=32) % DT_FLOAT32, NIFTI_TYPE_FLOAT32
            %    32 Complex, 2 float32      (Use float32, bitpix=64) % DT_COMPLEX64, NIFTI_TYPE_COMPLEX64
            %    64 Double precision  (double or float64, bitpix=64) % DT_FLOAT64, NIFTI_TYPE_FLOAT64
            %   128 uint8 RGB                 (Use uint8, bitpix=24) % DT_RGB24, NIFTI_TYPE_RGB24
            %   256 Signed char            (schar or int8, bitpix=8) % DT_INT8, NIFTI_TYPE_INT8
            %   511 Single RGB              (Use float32, bitpix=96) % DT_RGB96, NIFTI_TYPE_RGB96
            %   512 Unsigned short               (uint16, bitpix=16) % DT_UNINT16, NIFTI_TYPE_UNINT16
            %   768 Unsigned integer             (uint32, bitpix=32) % DT_UNINT32, NIFTI_TYPE_UNINT32
            %  1024 Signed long long              (int64, bitpix=64) % DT_INT64, NIFTI_TYPE_INT64
            %  1280 Unsigned long long           (uint64, bitpix=64) % DT_UINT64, NIFTI_TYPE_UINT64
            %  1536 Long double, float128  (Unsupported, bitpix=128) % DT_FLOAT128, NIFTI_TYPE_FLOAT128
            %  1792 Complex128, 2 float64  (Use float64, bitpix=128) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128
            %  2048 Complex256, 2 float128 (Unsupported, bitpix=256) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128
            %
            switch hdr.dime.datatype
                case   1
                    hdr.dime.bitpix = 1;  precision = 'ubit1';
                case   2
                    hdr.dime.bitpix = 8;  precision = 'uint8';
                case   4
                    hdr.dime.bitpix = 16; precision = 'int16';
                case   8
                    hdr.dime.bitpix = 32; precision = 'int32';
                case  16
                    hdr.dime.bitpix = 32; precision = 'float32';
                case  32
                    hdr.dime.bitpix = 64; precision = 'float32';
                case  64
                    hdr.dime.bitpix = 64; precision = 'float64';
                case 128
                    hdr.dime.bitpix = 24; precision = 'uint8';
                case 256
                    hdr.dime.bitpix = 8;  precision = 'int8';
                case 511
                    hdr.dime.bitpix = 96; precision = 'float32';
                case 512
                    hdr.dime.bitpix = 16; precision = 'uint16';
                case 768
                    hdr.dime.bitpix = 32; precision = 'uint32';
                case 1024
                    hdr.dime.bitpix = 64; precision = 'int64';
                case 1280
                    hdr.dime.bitpix = 64; precision = 'uint64';
                case 1792
                    hdr.dime.bitpix = 128; precision = 'float64';
                otherwise
                    error('mlfourd:TypeError', 'This datatype is not supported');
            end

            hdr.dime.dim(find(hdr.dime.dim < 1)) = 1;

            %  move pointer to the start of image block
            %
            switch filetype
                case {0, 1}
                    fseek(fid, 0, 'bof');
                case 2
                    fseek(fid, hdr.dime.vox_offset, 'bof');
            end

            %  Load whole image block for old Analyze format or binary image;
            %  otherwise, load images that are specified in img_idx, dim5_idx,
            %  dim6_idx, and dim7_idx
            %
            %  For binary image, we have to read all because pos can not be
            %  seeked in bit and can not be calculated the way below.
            %
            if hdr.dime.datatype == 1 || isequal(hdr.dime.dim(5:8),ones(1,4)) || ...
                	(isempty(img_idx) && isempty(dim5_idx) && isempty(dim6_idx) && isempty(dim7_idx))

                %  For each frame, precision of value will be read
                %  in img_siz times, where img_siz is only the
                %  dimension size of an image, not the byte storage
                %  size of an image.
                %
                img_siz = prod(hdr.dime.dim(2:8));

                %  For complex float32 or complex float64, voxel values
                %  include [real, imag]
                %
                if hdr.dime.datatype == 32 || hdr.dime.datatype == 1792
                    img_siz = img_siz * 2;
                end

                %MPH: For RGB24, voxel values include 3 separate color planes
                %
                if hdr.dime.datatype == 128 || hdr.dime.datatype == 511
               	 img_siz = img_siz * 3;
                end

                img = fread(fid, img_siz, sprintf('*%s',precision));

                d1 = hdr.dime.dim(2);
                d2 = hdr.dime.dim(3);
                d3 = hdr.dime.dim(4);
                d4 = hdr.dime.dim(5);
                d5 = hdr.dime.dim(6);
                d6 = hdr.dime.dim(7);
                d7 = hdr.dime.dim(8);

                if isempty(img_idx)
                    img_idx = 1:d4;
                end

                if isempty(dim5_idx)
                    dim5_idx = 1:d5;
                end

                if isempty(dim6_idx)
                    dim6_idx = 1:d6;
                end

                if isempty(dim7_idx)
                    dim7_idx = 1:d7;
                end
            else

                d1 = hdr.dime.dim(2);
                d2 = hdr.dime.dim(3);
                d3 = hdr.dime.dim(4);
                d4 = hdr.dime.dim(5);
                d5 = hdr.dime.dim(6);
                d6 = hdr.dime.dim(7);
                d7 = hdr.dime.dim(8);

                if isempty(img_idx)
                    img_idx = 1:d4;
                end

                if isempty(dim5_idx)
                    dim5_idx = 1:d5;
                end

                if isempty(dim6_idx)
                    dim6_idx = 1:d6;
                end

                if isempty(dim7_idx)
                    dim7_idx = 1:d7;
                end

                %  compute size of one image
                %
                img_siz = prod(hdr.dime.dim(2:4));

                %  For complex float32 or complex float64, voxel values
                %  include [real, imag]
                %
                if hdr.dime.datatype == 32 || hdr.dime.datatype == 1792
                    img_siz = img_siz * 2;
                end

                %MPH: For RGB24, voxel values include 3 separate color planes
                %
                if hdr.dime.datatype == 128 || hdr.dime.datatype == 511
                    img_siz = img_siz * 3;
                end

                % preallocate img
                img = zeros(img_siz, length(img_idx)*length(dim5_idx)*length(dim6_idx)*length(dim7_idx) );
                currentIndex = 1;

                for i7=1:length(dim7_idx)
                    for i6=1:length(dim6_idx)
                        for i5=1:length(dim5_idx)
                            for t=1:length(img_idx)

                                %  Position is seeked in bytes. To convert dimension size
                                %  to byte storage size, hdr.dime.bitpix/8 will be
                                %  applied.
                                %
                                pos = sub2ind([d1 d2 d3 d4 d5 d6 d7], 1, 1, 1, ...
                          			img_idx(t), dim5_idx(i5),dim6_idx(i6),dim7_idx(i7)) -1;
                                pos = pos * hdr.dime.bitpix/8;

                                if filetype == 2
                                    fseek(fid, pos + hdr.dime.vox_offset, 'bof');
                                else
                                    fseek(fid, pos, 'bof');
                                end

                                %  For each frame, fread will read precision of value
                                %  in img_siz times
                                %
                                img(:,currentIndex) = fread(fid, img_siz, sprintf('*%s',precision));
                                currentIndex = currentIndex +1;

                            end
                        end
                    end
                end
            end

            %  For complex float32 or complex float64, voxel values
            %  include [real, imag]
            %
            if hdr.dime.datatype == 32 || hdr.dime.datatype == 1792
                img = reshape(img, [2, length(img)/2]);
                img = complex(img(1,:)', img(2,:)');
            end

            fclose(fid);

            %  Update the global min and max values
            %
            hdr.dime.glmax = double(max(img(:)));
            hdr.dime.glmin = double(min(img(:)));

            %  old_RGB treat RGB slice by slice, now it is treated voxel by voxel
            %
            if old_RGB && hdr.dime.datatype == 128 && hdr.dime.bitpix == 24
                % remove squeeze
                img = (reshape(img, [hdr.dime.dim(2:3) 3 hdr.dime.dim(4) length(img_idx) length(dim5_idx) length(dim6_idx) length(dim7_idx)]));
                img = permute(img, [1 2 4 3 5 6 7 8]);
            elseif hdr.dime.datatype == 128 && hdr.dime.bitpix == 24
                % remove squeeze
                img = (reshape(img, [3 hdr.dime.dim(2:4) length(img_idx) length(dim5_idx) length(dim6_idx) length(dim7_idx)]));
                img = permute(img, [2 3 4 1 5 6 7 8]);
            elseif hdr.dime.datatype == 511 && hdr.dime.bitpix == 96
                img = double(img(:));
                img = single((img - min(img))/(max(img) - min(img)));
                % remove squeeze
                img = (reshape(img, [3 hdr.dime.dim(2:4) length(img_idx) length(dim5_idx) length(dim6_idx) length(dim7_idx)]));
                img = permute(img, [2 3 4 1 5 6 7 8]);
            else
                % remove squeeze
                img = (reshape(img, [hdr.dime.dim(2:4) length(img_idx) length(dim5_idx) length(dim6_idx) length(dim7_idx)]));
            end

            if ~isempty(img_idx)
                hdr.dime.dim(5) = length(img_idx);
            end

            if ~isempty(dim5_idx)
                hdr.dime.dim(6) = length(dim5_idx);
            end

            if ~isempty(dim6_idx)
                hdr.dime.dim(7) = length(dim6_idx);
            end

            if ~isempty(dim7_idx)
                hdr.dime.dim(8) = length(dim7_idx);
            end
        end

        function nii = xform_nii(nii, tolerance, preferredForm)
            %% xform_nii is an internal function called by load_nii, so
            %  you do not need run this program by yourself. It does simplified
            %  NIfTI sform/qform affine transform, and supports some of the
            %  affine transforms, including translation, reflection, and
            %  orthogonal rotation (N*90 degree).
            %
            %  For other affine transforms, e.g. any degree rotation, shearing
            %  etc. you will have to use the included 'reslice_nii.m' program
            %  to reslice the image volume. 'reslice_nii.m' is not called by
            %  any other program, and you have to run 'reslice_nii.m' explicitly
            %  for those NIfTI files that you want to reslice them.
            %
            %  Since 'xform_nii.m' does not involve any interpolation or any
            %  slice change, the original image volume is supposed to be
            %  untouched, although it is translated, reflected, or even
            %  orthogonally rotated, based on the affine matrix in the
            %  NIfTI header.
            %
            %  However, the affine matrix in the header of a lot NIfTI files
            %  contain slightly non-orthogonal rotation. Therefore, optional
            %  input parameter 'tolerance' is used to allow some distortion
            %  in the loaded image for any non-orthogonal rotation or shearing
            %  of NIfTI affine matrix. If you set 'tolerance' to 0, it means
            %  that you do not allow any distortion. If you set 'tolerance' to
            %  1, it means that you do not care any distortion. The image will
            %  fail to be loaded if it can not be tolerated. The tolerance will
            %  be set to 0.1 (10%), if it is default or empty.
            %
            %  Because 'reslice_nii.m' has to perform 3D interpolation, it can
            %  be slow depending on image size and affine matrix in the header.
            %
            %  After you perform the affine transform, the 'nii' structure
            %  generated from 'xform_nii.m' or new NIfTI file created from
            %  'reslice_nii.m' will be in RAS orientation, i.e. X axis from
            %  Left to Right, Y axis from Posterior to Anterior, and Z axis
            %  from Inferior to Superior.
            %
            %  NOTE: This function should be called immediately after load_nii.
            %
            %  Usage: [ nii ] = xform_nii(nii, [tolerance], [preferredForm])
            %
            %  nii	- NIFTI structure (returned from load_nii)
            %
            %  tolerance (optional) - distortion allowed for non-orthogonal rotation
            %	or shearing in NIfTI affine matrix. It will be set to 0.1 (10%),
            %	if it is default or empty.
            %
            %  preferredForm (optional)  -  selects which transformation from voxels
            %	to RAS coordinates; values are s,q,S,Q.  Lower case s,q indicate
            %	"prefer sform or qform, but use others if preferred not present".
            %	Upper case indicate the program is forced to use the specificied
            %	tranform or fail loading.  'preferredForm' will be 's', if it is
            %	default or empty.	- Jeff Gunter
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)

            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.change_hdr;

            %  save a copy of the header as it was loaded.  This is the
            %  header before any sform, qform manipulation is done.
            %
            nii.original.hdr = nii.hdr;

            if ~exist('tolerance','var') || isempty(tolerance)
                tolerance = 0.1;
            elseif(tolerance<=0)
                tolerance = eps;
            end

            if ~exist('preferredForm','var') || isempty(preferredForm)
                preferredForm= 's';				% Jeff
            end

            %  if scl_slope field is nonzero, then each voxel value in the
            %  dataset should be scaled as: y = scl_slope * x + scl_inter
            %  I bring it here because hdr will be modified by change_hdr.
            %
            if nii.hdr.dime.scl_slope ~= 0 && ...
                	ismember(nii.hdr.dime.datatype, [2,4,8,16,64,256,512,768]) && ...
                	(nii.hdr.dime.scl_slope ~= 1 || nii.hdr.dime.scl_inter ~= 0)

                nii.img = ...
                	nii.hdr.dime.scl_slope * double(nii.img) + nii.hdr.dime.scl_inter;

                if nii.hdr.dime.datatype == 64

                    nii.hdr.dime.datatype = 64;
                    nii.hdr.dime.bitpix = 64;
                else
                    nii.img = single(nii.img);

                    nii.hdr.dime.datatype = 16;
                    nii.hdr.dime.bitpix = 32;
                end

                nii.hdr.dime.glmax = max(double(nii.img(:)));
                nii.hdr.dime.glmin = min(double(nii.img(:)));

                %  set scale to non-use, because it is applied in xform_nii
                %
                nii.hdr.dime.scl_slope = 0;

            end

            %  However, the scaling is to be ignored if datatype is DT_RGB24.

            %  If datatype is a complex type, then the scaling is to be applied
            %  to both the real and imaginary parts.
            %
            if nii.hdr.dime.scl_slope ~= 0 && ...
                	ismember(nii.hdr.dime.datatype, [32,1792])

                nii.img = ...
                	nii.hdr.dime.scl_slope * double(nii.img) + nii.hdr.dime.scl_inter;

                if nii.hdr.dime.datatype == 32
                    nii.img = single(nii.img);
                end

                nii.hdr.dime.glmax = max(double(nii.img(:)));
                nii.hdr.dime.glmin = min(double(nii.img(:)));

                %  set scale to non-use, because it is applied in xform_nii
                %
                nii.hdr.dime.scl_slope = 0;

            end

            %  There is no need for this program to transform Analyze data
            %
            if nii.filetype == 0 && exist([nii.fileprefix '.mat'],'file')
                spm = load([nii.fileprefix '.mat']); % old SPM affine matrix
                R=spm.M(1:3,1:3);
                T=spm.M(1:3,4);
                T=R*ones(3,1)+T;
                spm.M(1:3,4)=T;
                nii.hdr.hist.qform_code=0;
                nii.hdr.hist.sform_code=1;
                nii.hdr.hist.srow_x=spm.M(1,:);
                nii.hdr.hist.srow_y=spm.M(2,:);
                nii.hdr.hist.srow_z=spm.M(3,:);
            elseif nii.filetype == 0
                nii.hdr.hist.rot_orient = [];
                nii.hdr.hist.flip_orient = [];
                return;				% no sform/qform for Analyze format
            end

            hdr = nii.hdr;
            [hdr,orient] = JimmyShen.change_hdr(hdr,tolerance,preferredForm);

            %  flip and/or rotate image data
            %
            if ~isequal(orient, [1 2 3])

                old_dim = hdr.dime.dim(2:4);

                %  More than 1 time frame
                %
                if ndims(nii.img) > 3
                    pattern = 1:prod(old_dim);
                else
                    pattern = [];
                end

                if ~isempty(pattern)
                    pattern = reshape(pattern, old_dim);
                end

                %  calculate for rotation after flip
                %
                rot_orient = mod(orient + 2, 3) + 1;

                %  do flip:
                %
                flip_orient = orient - rot_orient;

                for i = 1:3
                    if flip_orient(i)
                        if ~isempty(pattern)
                            pattern = flip(pattern, i);
                        else
                            nii.img = flip(nii.img, i);
                        end
                    end
                end

                %  get index of orient (rotate inversely)
                %
                [~,rot_orient] = sort(rot_orient);

                new_dim = old_dim;
                new_dim = new_dim(rot_orient);
                hdr.dime.dim(2:4) = new_dim;

                new_pixdim = hdr.dime.pixdim(2:4);
                new_pixdim = new_pixdim(rot_orient);
                hdr.dime.pixdim(2:4) = new_pixdim;

                %  re-calculate originator
                %
                tmp = hdr.hist.originator(1:3);
                tmp = tmp(rot_orient);
                flip_orient = flip_orient(rot_orient);

                for i = 1:3
                    if flip_orient(i) && ~isequal(tmp(i), 0)
                        tmp(i) = new_dim(i) - tmp(i) + 1;
                    end
                end

                hdr.hist.originator(1:3) = tmp;
                hdr.hist.rot_orient = rot_orient;
                hdr.hist.flip_orient = flip_orient;

                %  do rotation:
                %
                if ~isempty(pattern)
                    pattern = permute(pattern, rot_orient);
                    pattern = pattern(:);

                    if hdr.dime.datatype == 32 || hdr.dime.datatype == 1792 || ...
                     		hdr.dime.datatype == 128 || hdr.dime.datatype == 511

                        tmp = reshape(nii.img(:,:,:,1), [prod(new_dim) hdr.dime.dim(5:8)]);
                        tmp = tmp(pattern, :);
                        nii.img(:,:,:,1) = reshape(tmp, [new_dim       hdr.dime.dim(5:8)]);

                        tmp = reshape(nii.img(:,:,:,2), [prod(new_dim) hdr.dime.dim(5:8)]);
                        tmp = tmp(pattern, :);
                        nii.img(:,:,:,2) = reshape(tmp, [new_dim       hdr.dime.dim(5:8)]);

                        if hdr.dime.datatype == 128 || hdr.dime.datatype == 511
                            tmp = reshape(nii.img(:,:,:,3), [prod(new_dim) hdr.dime.dim(5:8)]);
                            tmp = tmp(pattern, :);
                            nii.img(:,:,:,3) = reshape(tmp, [new_dim       hdr.dime.dim(5:8)]);
                        end

                    else
                        nii.img = reshape(nii.img, [prod(new_dim) hdr.dime.dim(5:8)]);
                        nii.img = nii.img(pattern, :);
                        nii.img = reshape(nii.img, [new_dim       hdr.dime.dim(5:8)]);
                    end
                else
                    if hdr.dime.datatype == 32 || hdr.dime.datatype == 1792 || ...
                     		hdr.dime.datatype == 128 || hdr.dime.datatype == 511

                        nii.img(:,:,:,1) = permute(nii.img(:,:,:,1), rot_orient);
                        nii.img(:,:,:,2) = permute(nii.img(:,:,:,2), rot_orient);

                        if hdr.dime.datatype == 128 || hdr.dime.datatype == 511
                            nii.img(:,:,:,3) = permute(nii.img(:,:,:,3), rot_orient);
                        end
                    else
                        nii.img = permute(nii.img, rot_orient);
                    end
                end
            else
                hdr.hist.rot_orient = [];
                hdr.hist.flip_orient = [];
            end

            nii.hdr = hdr;
        end
        function [hdr, orient] = change_hdr(hdr, tolerance, preferredForm)

            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.get_orient;
            import mlfourd.JimmyShen.get_units;

            orient = [1 2 3];
            affine_transform = 1;

            %  NIFTI can have both sform and qform transform. This program
            %  will check sform_code prior to qform_code by default.
            %
            %  If user specifys "preferredForm", user can then choose the
            %  priority.					- Jeff
            %
            useForm=[];					% Jeff

            if isequal(preferredForm,'S')
                if isequal(hdr.hist.sform_code,0)
                    error('mlfourd:ValueError', 'User requires sform, sform not set in header');
                else
                    useForm='s';
                end
            end						% Jeff

            if isequal(preferredForm,'Q')
                if isequal(hdr.hist.qform_code,0)
                    error('mlfourd:ValueError', 'User requires qform, qform not set in header');
                else
                    useForm='q';
                end
            end						% Jeff

            if isequal(preferredForm,'s')
                if hdr.hist.sform_code > 0
                    useForm='s';
                elseif hdr.hist.qform_code > 0
                    useForm='q';
                end
            end						% Jeff

            if isequal(preferredForm,'q')
                if hdr.hist.qform_code > 0
                    useForm='q';
                elseif hdr.hist.sform_code > 0
                    useForm='s';
                end
            end						% Jeff

            if isequal(useForm,'s')
                R = [hdr.hist.srow_x(1:3)
                    hdr.hist.srow_y(1:3)
                    hdr.hist.srow_z(1:3)];

                T = [hdr.hist.srow_x(4)
                    hdr.hist.srow_y(4)
                    hdr.hist.srow_z(4)];

                if det(R) == 0 || ~isequal(R(find(R)), sum(R)') %#ok<*FNDSB> 
                    hdr.hist.old_affine = [ [R;[0 0 0]] [T;1] ];
                    R_sort = sort(abs(R(:)));
                    R( find( abs(R) < tolerance*min(R_sort(end-2:end)) ) ) = 0;
                    hdr.hist.new_affine = [ [R;[0 0 0]] [T;1] ];

                    if det(R) == 0 || ~isequal(R(find(R)), sum(R)')
                        msg = [newline newline '   Non-orthogonal rotation or shearing '];
                        msg = [msg 'found inside the affine matrix' newline];
                        msg = [msg '   in this NIfTI file. You have 3 options:' newline newline];
                        msg = [msg '   1. Using included ''reslice_nii.m'' program to reslice the NIfTI' newline];
                        msg = [msg '      file. I strongly recommand this, because it will not cause' newline];
                        msg = [msg '      negative effect, as long as you remember not to do slice' newline];
                        msg = [msg '      time correction after using ''reslice_nii.m''.' newline newline];
                        msg = [msg '   2. Using included ''load_untouch_nii.m'' program to load image' newline];
                        msg = [msg '      without applying any affine geometric transformation or' newline];
                        msg = [msg '      voxel intensity scaling. This is only for people who want' newline];
                        msg = [msg '      to do some image processing regardless of image orientation' newline];
                        msg = [msg '      and to save data back with the same NIfTI header.' newline newline];
                        msg = [msg '   3. Increasing the tolerance to allow more distortion in loaded' newline];
                        msg = [msg '      image, but I don''t suggest this.' newline newline];
                        msg = [msg '   To get help, please type:' newline newline '   help reslice_nii.m' newline];
                        msg = [msg '   help load_untouch_nii.m' newline '   help load_nii.m'];
                        error('mlfourd:JimmyShen:RuntimeError', msg);
                    end
                end

            elseif isequal(useForm,'q')
                b = hdr.hist.quatern_b;
                c = hdr.hist.quatern_c;
                d = hdr.hist.quatern_d;

                if 1.0-(b*b+c*c+d*d) < 0
                    if abs(1.0-(b*b+c*c+d*d)) < 1e-5
                        a = 0;
                    else
                        error('mlfourd:ValueError', 'Incorrect quaternion values in this NIFTI data.');
                    end
                else
                    a = sqrt(1.0-(b*b+c*c+d*d));
                end

                qfac = hdr.dime.pixdim(1);
                if qfac==0, qfac = mlfourd.JimmyShen.INTERNAL_QFAC; end % jjlee
                i = hdr.dime.pixdim(2);
                j = hdr.dime.pixdim(3);
                k = qfac * hdr.dime.pixdim(4);

                R = [a*a+b*b-c*c-d*d     2*b*c-2*a*d        2*b*d+2*a*c
                    2*b*c+2*a*d         a*a+c*c-b*b-d*d    2*c*d-2*a*b
                    2*b*d-2*a*c         2*c*d+2*a*b        a*a+d*d-c*c-b*b];

                T = [hdr.hist.qoffset_x
                    hdr.hist.qoffset_y
                    hdr.hist.qoffset_z];

                %  qforms are expected to generate rotation matrices R which are
                %  det(R) = 1; we'll make sure that happens.
                %
                %  now we make the same checks as were done above for sform data
                %  BUT we do it on a transform that is in terms of voxels not mm;
                %  after we figure out the angles and squash them to closest
                %  rectilinear direction. After that, the voxel sizes are then
                %  added.
                %
                %  This part is modified by Jeff Gunter.
                %
                if det(R) == 0 || ~isequal(R(find(R)), sum(R)')

                    %  det(R) == 0 is not a common trigger for this ---
                    %  R(find(R)) is a list of non-zero elements in R; if that
                    %  is straight (not oblique) then it should be the same as
                    %  columnwise summation. Could just as well have checked the
                    %  lengths of R(find(R)) and sum(R)' (which should be 3)
                    %
                    hdr.hist.old_affine = [ [R * diag([i j k]);[0 0 0]] [T;1] ];
                    R_sort = sort(abs(R(:)));
                    R( find( abs(R) < tolerance*min(R_sort(end-2:end)) ) ) = 0;
                    R = R * diag([i j k]);
                    hdr.hist.new_affine = [ [R;[0 0 0]] [T;1] ];

                    if det(R) == 0 || ~isequal(R(find(R)), sum(R)')
                        msg = [newline newline '   Non-orthogonal rotation or shearing '];
                        msg = [msg 'found inside the affine matrix' newline];
                        msg = [msg '   in this NIfTI file. You have 3 options:' newline newline];
                        msg = [msg '   1. Using included ''reslice_nii.m'' program to reslice the NIfTI' newline];
                        msg = [msg '      file. I strongly recommand this, because it will not cause' newline];
                        msg = [msg '      negative effect, as long as you remember not to do slice' newline];
                        msg = [msg '      time correction after using ''reslice_nii.m''.' newline newline];
                        msg = [msg '   2. Using included ''load_untouch_nii.m'' program to load image' newline];
                        msg = [msg '      without applying any affine geometric transformation or' newline];
                        msg = [msg '      voxel intensity scaling. This is only for people who want' newline];
                        msg = [msg '      to do some image processing regardless of image orientation' newline];
                        msg = [msg '      and to save data back with the same NIfTI header.' newline newline];
                        msg = [msg '   3. Increasing the tolerance to allow more distortion in loaded' newline];
                        msg = [msg '      image, but I don''t suggest this.' newline newline];
                        msg = [msg '   To get help, please type:' newline newline '   help reslice_nii.m' newline];
                        msg = [msg '   help load_untouch_nii.m' newline '   help load_nii.m'];
                        error(msg);
                    end

                else
                    R = R * diag([i j k]);
                end					% 1st det(R)

            else
                affine_transform = 0;	% no sform or qform transform
            end

            if affine_transform == 1
                voxel_size = abs(sum(R,1));
                inv_R = inv(R);
                originator = inv_R*(-T) + 1; %#ok<*MINV> 
                orient = JimmyShen.get_orient(inv_R);

                %  modify pixdim and originator
                %
                hdr.dime.pixdim(2:4) = voxel_size;
                hdr.hist.originator(1:3) = originator;

                %  set sform or qform to non-use, because they have been
                %  applied in xform_nii
                %
                hdr.hist.qform_code = 0;
                hdr.hist.sform_code = 0;
            end

            %  apply space_unit to pixdim if not 1 (mm)
            %
            space_unit = JimmyShen.get_units(hdr);

            if space_unit ~= 1
                hdr.dime.pixdim(2:4) = hdr.dime.pixdim(2:4) * space_unit;

                %  set space_unit of xyzt_units to millimeter, because
                %  voxel_size has been re-scaled
                %
                hdr.dime.xyzt_units = char(bitset(hdr.dime.xyzt_units,1,0));
                hdr.dime.xyzt_units = char(bitset(hdr.dime.xyzt_units,2,1));
                hdr.dime.xyzt_units = char(bitset(hdr.dime.xyzt_units,3,0));
            end

            hdr.dime.pixdim(1) = mlfourd.JimmyShen.INTERNAL_QFAC; % jjlee
            hdr.dime.pixdim(2:end) = abs(hdr.dime.pixdim(2:end)); % jjlee
        end
        function orient = get_orient(R)
            orient = [];
            for i = 1:3
                switch find(R(i,:)) * sign(sum(R(i,:)))
                    case 1
                        orient = [orient 1];		 %#ok<*AGROW> % Left to Right
                    case 2
                        orient = [orient 2];		% Posterior to Anterior
                    case 3
                        orient = [orient 3];		% Inferior to Superior
                    case -1
                        orient = [orient 4];		% Right to Left
                    case -2
                        orient = [orient 5];		% Anterior to Posterior
                    case -3
                        orient = [orient 6];		% Superior to Inferior
                end
            end
        end
        function [space_unit, time_unit] = get_units(hdr)
            switch bitand(hdr.dime.xyzt_units, 7)	% mask with 0x07
                case 1
                    space_unit = 1e+3;		% meter, m
                case 3
                    space_unit = 1e-3;		% micrometer, um
                otherwise
                    space_unit = 1;			% millimeter, mm
            end
            switch bitand(hdr.dime.xyzt_units, 56)	% mask with 0x38
                case 16
                    time_unit = 1e-3;			% millisecond, ms
                case 24
                    time_unit = 1e-6;			% microsecond, us
                otherwise
                    time_unit = 1;			% second, s
            end
        end

        %% make_nii dependencies

        function hdr = make_header(dims, voxel_size, origin, datatype, ...
                descrip, maxval, minval)

            import mlfourd.JimmyShen;

            hdr.hk   = JimmyShen.make_header_key;
            hdr.dime = JimmyShen.make_image_dimension(dims, voxel_size, datatype, maxval, minval);
            hdr.hist = JimmyShen.make_data_history(origin, descrip);
        end
        function hk = make_header_key()
            hk.sizeof_hdr       = 348;			% must be 348!
            hk.data_type        = '';
            hk.db_name          = '';
            hk.extents          = 0;
            hk.session_error    = 0;
            hk.regular          = 'r';
            hk.dim_info         = 0;
        end
        function [dime,precision] = make_image_dimension(dims, voxel_size, datatype, maxval, minval)
            dime.dim = dims;
            dime.intent_p1 = 0;
            dime.intent_p2 = 0;
            dime.intent_p3 = 0;
            dime.intent_code = 0;
            dime.datatype = datatype;

            switch dime.datatype
                case 2
                    dime.bitpix = 8;  precision = 'uint8';
                case 4
                    dime.bitpix = 16; precision = 'int16';
                case 8
                    dime.bitpix = 32; precision = 'int32';
                case 16
                    dime.bitpix = 32; precision = 'float32';
                case 32
                    dime.bitpix = 64; precision = 'float32';
                case 64
                    dime.bitpix = 64; precision = 'float64';
                case 128
                    dime.bitpix = 24; precision = 'uint8';
                case 256
                    dime.bitpix = 8;  precision = 'int8';
                case 511
                    dime.bitpix = 96; precision = 'float32';
                case 512
                    dime.bitpix = 16; precision = 'uint16';
                case 768
                    dime.bitpix = 32; precision = 'uint32';
                case 1792
                    dime.bitpix = 128; precision = 'float64';
                otherwise
                    error('mlfourd:TypeError', 'Datatype is not supported by make_nii.');
            end

            dime.slice_start = 0;
            dime.pixdim = voxel_size;
            dime.vox_offset = 0;
            dime.scl_slope = 0;
            dime.scl_inter = 0;
            dime.slice_end = 0;
            dime.slice_code = 0;
            dime.xyzt_units = 0;
            dime.cal_max = 0;
            dime.cal_min = 0;
            dime.slice_duration = 0;
            dime.toffset = 0;
            dime.glmax = maxval;
            dime.glmin = minval;
        end
        function hist = make_data_history(origin, descrip)
            hist.descrip = descrip;
            hist.aux_file = 'none';
            hist.qform_code = 0;
            hist.sform_code = 0;
            hist.quatern_b = 0;
            hist.quatern_c = 0;
            hist.quatern_d = 0;
            hist.qoffset_x = 0;
            hist.qoffset_y = 0;
            hist.qoffset_z = 0;
            hist.srow_x = zeros(1,4);
            hist.srow_y = zeros(1,4);
            hist.srow_z = zeros(1,4);
            hist.intent_name = '';
            hist.magic = '';
            hist.originator = origin;
        end
        
        %% reslice_nii dependencies

        function [new_img,new_M] = affine(old_img, old_M, new_elem_size, verbose, bg, method)
            %% Using 2D or 3D affine matrix to rotate, translate, scale, reflect and
            %  shear a 2D image or 3D volume. 2D image is represented by a 2D matrix,
            %  3D volume is represented by a 3D matrix, and data type can be real 
            %  integer or floating-point.
            %
            %  You may notice that MATLAB has a function called 'imtransform.m' for
            %  2D spatial transformation. However, keep in mind that 'imtransform.m'
            %  assumes y for the 1st dimension, and x for the 2nd dimension. They are
            %  equivalent otherwise.
            %
            %  In addition, if you adjust the 'new_elem_size' parameter, this 'affine.m'
            %  is equivalent to 'interp2.m' for 2D image, and equivalent to 'interp3.m'
            %  for 3D volume.
            %
            %  Usage: [new_img new_M] = ...
            %	affine(old_img, old_M, [new_elem_size], [verbose], [bg], [method]);
            %
            %  old_img  -	original 2D image or 3D volume. We assume x for the 1st
            %		dimension, y for the 2nd dimension, and z for the 3rd
            %		dimension.
            %
            %  old_M  -	a 3x3 2D affine matrix for 2D image, or a 4x4 3D affine
            %		matrix for 3D volume. We assume x for the 1st dimension,
            %		y for the 2nd dimension, and z for the 3rd dimension.
            %
            %  new_elem_size (optional)  -  size of voxel along x y z direction for 
            %		a transformed 3D volume, or size of pixel along x y for
            %		a transformed 2D image. We assume x for the 1st dimension
            %		y for the 2nd dimension, and z for the 3rd dimension.
            %		'new_elem_size' is 1 if it is default or empty.
            %
            %		You can increase its value to decrease the resampling rate,
            %		and make the 2D image or 3D volume more coarse. It works
            %		just like 'interp3'.
            %
            %  verbose (optional) - 1, 0
            %		1:  show transforming progress in percentage
            %		2:  progress will not be displayed
            %		'verbose' is 1 if it is default or empty.
            %
            %  bg (optional) - background voxel intensity in any extra corner that
            %		is caused by the interpolation. 0 in most cases. If it is
            %		default or empty, 'bg' will be the average of two corner
            %		voxel intensities in original data.
            %
            %  method (optional) - 1, 2, or 3
            %		1:  for Trilinear interpolation
            %		2:  for Nearest Neighbor interpolation
            %		3:  for Fischer's Bresenham interpolation
            %		'method' is 1 if it is default or empty.
            %
            %  new_img - transformed 2D image or 3D volume
            %
            %  new_M - transformed affine matrix
            %
            %  Example 1 (3D rotation):
            %	load mri.mat;   old_img = double(squeeze(D));
            %	old_M = [0.88 0.5 3 -90; -0.5 0.88 3 -126; 0 0 2 -72; 0 0 0 1];
            %	new_img = affine(old_img, old_M, 2);
            %	[x y z] = meshgrid(1:128,1:128,1:27);
            %	sz = size(new_img);
            %	[x1 y1 z1] = meshgrid(1:sz(2),1:sz(1),1:sz(3));
            %	figure; slice(x, y, z, old_img, 64, 64, 13.5);
            %	shading flat; colormap(map); view(-66, 66);
            %	figure; slice(x1, y1, z1, new_img, sz(1)/2, sz(2)/2, sz(3)/2);
            %	shading flat; colormap(map); view(-66, 66);
            %
            %  Example 2 (2D interpolation):
            %	load mri.mat;   old_img=D(:,:,1,13)';
            %	old_M = [1 0 0; 0 1 0; 0 0 1];
            %	new_img = affine(old_img, old_M, [.2 .4]);
            %	figure; image(old_img); colormap(map);
            %	figure; image(new_img); colormap(map);
            %
            %  This program is inspired by:
            %  SPM5 Software from Wellcome Trust Centre for Neuroimaging
            %	http://www.fil.ion.ucl.ac.uk/spm/software
            %  Fischer, J., A. del Rio (2004). A Fast Method for Applying Rigid
            %	Transformations to Volume Data, WSCG2004 Conference.
            %	http://wscg.zcu.cz/wscg2004/Papers_2004_Short/M19.pdf
            %  
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)

            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.trilinear;
            import mlfourd.JimmyShen.nearest_neighbor;
            import mlfourd.JimmyShen.bresenham;

            if ~exist('old_img','var') || ~exist('old_M','var')
                error('Usage: [new_img new_M] = affine(old_img, old_M, [new_elem_size], [verbose], [bg], [method]);');
            end

            if ndims(old_img) == 3
                if ~isequal(size(old_M),[4 4])
                    error('old_M should be a 4x4 affine matrix for 3D volume.');
                end
            elseif ndims(old_img) == 2
                if ~isequal(size(old_M),[3 3])
                    error('old_M should be a 3x3 affine matrix for 2D image.');
                end
            else
                error('old_img should be either 2D image or 3D volume.');
            end

            if ~exist('new_elem_size','var') || isempty(new_elem_size)
                new_elem_size = [1 1 1];
            elseif length(new_elem_size) < 2
                new_elem_size = new_elem_size(1)*ones(1,3);
            elseif length(new_elem_size) < 3
                new_elem_size = [new_elem_size(:); 1]';
            end

            if ~exist('method','var') || isempty(method)
                method = 1;
            elseif ~exist('bresenham_line3d.m','file') && method == 3
                error([newline newline 'Please download 3D Bresenham''s line generation program from:' newline newline 'http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=21057' newline newline 'to test Fischer''s Bresenham interpolation method.' newline newline]);
            end

            %  Make compatible to MATLAB earlier than version 7 (R14), which
            %  can only perform arithmetic on double data type
            %
            old_img = double(old_img);
            old_dim = size(old_img);

            if ~exist('bg','var') | isempty(bg)
                bg = mean([old_img(1) old_img(end)]);
            end

            if ~exist('verbose','var') | isempty(verbose)
                verbose = 1;
            end

            if ndims(old_img) == 2
                old_dim(3) = 1;
                old_M = old_M(:, [1 2 3 3]);
                old_M = old_M([1 2 3 3], :);
                old_M(3,:) = [0 0 1 0];
                old_M(:,3) = [0 0 1 0]';
            end

            %  Vertices of img in voxel
            %
            XYZvox = [	1		1		1
        		1		1		old_dim(3)
        		1		old_dim(2)	1
        		1		old_dim(2)	old_dim(3)
        		old_dim(1)	1		1
        		old_dim(1)	1		old_dim(3)
        		old_dim(1)	old_dim(2)	1
        		old_dim(1)	old_dim(2)	old_dim(3)   ]';

            old_R = old_M(1:3,1:3);
            old_T = old_M(1:3,4);

            %  Vertices of img in millimeter
            %
            XYZmm = old_R*(XYZvox-1) + repmat(old_T, [1, 8]);

            %  Make scale of new_M according to new_elem_size
            %
            new_M = diag([new_elem_size 1]);

            %  Make translation so minimum vertex is moved to [1,1,1]
            %
            new_M(1:3,4) = round( min(XYZmm,[],2) );

            %  New dimensions will be the maximum vertices in XYZ direction (dim_vox)
            %  i.e. compute   dim_vox   via   dim_mm = R*(dim_vox-1)+T
            %  where, dim_mm = round(max(XYZmm,[],2));
            %
            new_dim = ceil(new_M(1:3,1:3) \ ( round(max(XYZmm,[],2))-new_M(1:3,4) )+1)';

            %  Initialize new_img with new_dim
            %
            new_img = zeros(new_dim(1:3));

            %  Mask out any changes from Z axis of transformed volume, since we
            %  will traverse it voxel by voxel below. We will only apply unit
            %  increment of mask_Z(3,4) to simulate the cursor movement
            %
            %  i.e. we will use   mask_Z * new_XYZvox   to replace   new_XYZvox
            %
            mask_Z = diag(ones(1,4));
            mask_Z(3,3) = 0;

            %  It will be easier to do the interpolation if we invert the process
            %  by not traversing the original volume. Instead, we traverse the
            %  transformed volume, and backproject each voxel in the transformed
            %  volume back into the original volume. If the backprojected voxel
            %  in original volume is within its boundary, the intensity of that
            %  voxel can be used by the cursor location in the transformed volume.
            %
            %  First, we traverse along Z axis of transformed volume voxel by voxel
            %
            for z = 1:new_dim(3)

                if verbose && ~mod(z,10)
                    fprintf('%.2f percent is done.\n', 100*z/new_dim(3));
                end

                %  We need to find out the mapping from voxel in the transformed
                %  volume (new_XYZvox) to voxel in the original volume (old_XYZvox)
                %
                %  The following equation works, because they all equal to XYZmm:
                %  new_R*(new_XYZvox-1) + new_T  ==  old_R*(old_XYZvox-1) + old_T
                %
                %  We can use modified new_M1 & old_M1 to substitute new_M & old_M
                %      new_M1 * new_XYZvox       ==       old_M1 * old_XYZvox
                %
                %  where: M1 = M;   M1(:,4) = M(:,4) - sum(M(:,1:3),2);
                %  and:             M(:,4) == [T; 1] == sum(M1,2)
                %
                %  Therefore:   old_XYZvox = old_M1 \ new_M1 * new_XYZvox;
                %
                %  Since we are traverse Z axis, and   new_XYZvox   is replaced
                %  by   mask_Z * new_XYZvox, the above formula can be rewritten
                %  as:    old_XYZvox = old_M1 \ new_M1 * mask_Z * new_XYZvox;
                %
                %  i.e. we find the mapping from new_XYZvox to old_XYZvox:
                %  M = old_M1 \ new_M1 * mask_Z;
                %
                %  First, compute modified old_M1 & new_M1
                %
                old_M1 = old_M;   old_M1(:,4) = old_M(:,4) - sum(old_M(:,1:3),2);
                new_M1 = new_M;   new_M1(:,4) = new_M(:,4) - sum(new_M(:,1:3),2);

                %  Then, apply unit increment of mask_Z(3,4) to simulate the
                %  cursor movement
                %
                mask_Z(3,4) = z;

                %  Here is the mapping from new_XYZvox to old_XYZvox
                %
                M = old_M1 \ new_M1 * mask_Z;

                switch method
                    case 1
                        new_img(:,:,z) = trilinear(old_img, new_dim, old_dim, M, bg);
                    case 2
                        new_img(:,:,z) = nearest_neighbor(old_img, new_dim, old_dim, M, bg);
                    case 3
                        new_img(:,:,z) = bresenham(old_img, new_dim, old_dim, M, bg);
                end

            end	% for z

            if ndims(old_img) == 2
                new_M(3,:) = [];
                new_M(:,3) = [];
            end
        end
        function img_slice = bresenham(img, dim1, dim2, M, bg)

            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.bresenham_line3d;

            img_slice = zeros(dim1(1:2));

            %  Dimension of transformed 3D volume
            %
            xdim1 = dim1(1);
            ydim1 = dim1(2);

            %  Dimension of original 3D volume
            %
            xdim2 = dim2(1);
            ydim2 = dim2(2);
            zdim2 = dim2(3);

            for y = 1:ydim1

                start_old_XYZ = round(M*[0     y 0 1]');
                end_old_XYZ   = round(M*[xdim1 y 0 1]');

                [X,Y,Z] = bresenham_line3d(start_old_XYZ, end_old_XYZ);

                %  line error correction
                %
                %      del = end_old_XYZ - start_old_XYZ;
                %     del_dom = max(del);
                %    idx_dom = find(del==del_dom);
                %   idx_dom = idx_dom(1);
                %  idx_other = [1 2 3];
                % idx_other(idx_dom) = [];
                %del_x1 = del(idx_other(1));
                %      del_x2 = del(idx_other(2));
                %     line_slope = sqrt((del_x1/del_dom)^2 + (del_x2/del_dom)^2 + 1);
                %    line_error = line_slope - 1;
                % line error correction removed because it is too slow

                for x = 1:xdim1

                    %  rescale ratio
                    %
                    i = round(x * length(X) / xdim1);

                    if i < 1
                        i = 1;
                    elseif i > length(X)
                        i = length(X);
                    end

                    xi = X(i);
                    yi = Y(i);
                    zi = Z(i);

                    %  within boundary of the old XYZ space
                    %
                    if (	xi >= 1 && xi <= xdim2 && ...
                    		yi >= 1 && yi <= ydim2 && ...
                    		zi >= 1 && zi <= zdim2	)

                        img_slice(x,y) = img(xi,yi,zi);

                        %            if line_error > 1
                        %              x = x + 1;

                        %               if x <= xdim1
                        %                 img_slice(x,y) = img(xi,yi,zi);
                        %                line_error = line_slope - 1;
                        %            end
                        %        end		% if line_error
                        % line error correction removed because it is too slow

                    else
                        img_slice(x,y) = bg;

                    end	% if boundary

                end	% for x
            end		% for y
        end
        function [X,Y,Z] = bresenham_line3d(P1, P2, precision)
            %% Generate X Y Z coordinates of a 3D Bresenham's line between
            %  two given points.
            %
            %  A very useful application of this algorithm can be found in the
            %  implementation of Fischer's Bresenham interpolation method in my
            %  another program that can rotate three dimensional image volume
            %  with an affine matrix:
            %  http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=21080
            %
            %  Usage: [X Y Z] = bresenham_line3d(P1, P2, [precision]);
            %
            %  P1	- vector for Point1, where P1 = [x1 y1 z1]
            %
            %  P2	- vector for Point2, where P2 = [x2 y2 z2]
            %
            %  precision (optional) - Although according to Bresenham's line
            %	algorithm, point coordinates x1 y1 z1 and x2 y2 z2 should
            %	be integer numbers, this program extends its limit to all
            %	real numbers. If any of them are floating numbers, you
            %	should specify how many digits of decimal that you would
            %	like to preserve. Be aware that the length of output X Y
            %	Z coordinates will increase in 10 times for each decimal
            %	digit that you want to preserve. By default, the precision
            %	is 0, which means that they will be rounded to the nearest
            %	integer.
            %
            %  X	- a set of x coordinates on Bresenham's line
            %
            %  Y	- a set of y coordinates on Bresenham's line
            %
            %  Z	- a set of z coordinates on Bresenham's line
            %
            %  Therefore, all points in XYZ set (i.e. P(i) = [X(i) Y(i) Z(i)])
            %  will constitute the Bresenham's line between P1 and P1.
            %
            %  Example:
            %	P1 = [12 37 6];     P2 = [46 3 35];
            %	[X Y Z] = bresenham_line3d(P1, P2);
            %	figure; plot3(X,Y,Z,'s','markerface','b');
            %
            %  This program is ported to MATLAB from:
            %
            %  B.Pendleton.  line3d - 3D Bresenham's (a 3D line drawing algorithm)
            %  ftp://ftp.isc.org/pub/usenet/comp.sources.unix/volume26/line3d, 1992
            %
            %  Which is also referenced by:
            %
            %  Fischer, J., A. del Rio (2004).  A Fast Method for Applying Rigid
            %  Transformations to Volume Data, WSCG2004 Conference.
            %  http://wscg.zcu.cz/wscg2004/Papers_2004_Short/M19.pdf
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)

            import mlfourd.JimmyShen;

            if ~exist('precision','var') || isempty(precision) || round(precision) == 0
                precision = 0;
                P1 = round(P1);
                P2 = round(P2);
            else
                precision = round(precision);
                P1 = round(P1*(10^precision));
                P2 = round(P2*(10^precision));
            end

            d = max(abs(P2-P1)+1);
            X = zeros(1, d);
            Y = zeros(1, d);
            Z = zeros(1, d);

            x1 = P1(1);
            y1 = P1(2);
            z1 = P1(3);

            x2 = P2(1);
            y2 = P2(2);
            z2 = P2(3);

            dx = x2 - x1;
            dy = y2 - y1;
            dz = z2 - z1;

            ax = abs(dx)*2;
            ay = abs(dy)*2;
            az = abs(dz)*2;

            sx = sign(dx);
            sy = sign(dy);
            sz = sign(dz);

            x = x1;
            y = y1;
            z = z1;
            idx = 1;

            if (ax>=max(ay,az))			% x dominant
                yd = ay - ax/2;
                zd = az - ax/2;

                while (1)
                    X(idx) = x;
                    Y(idx) = y;
                    Z(idx) = z;
                    idx = idx + 1;

                    if(x == x2)		% end
                        break;
                    end

                    if(yd >= 0)		% move along y
                        y = y + sy;
                        yd = yd - ax;
                    end

                    if(zd >= 0)		% move along z
                        z = z + sz;
                        zd = zd - ax;
                    end

                    x  = x  + sx;		% move along x
                    yd = yd + ay;
                    zd = zd + az;
                end
            elseif (ay>=max(ax,az))		% y dominant
                xd = ax - ay/2;
                zd = az - ay/2;

                while (1)
                    X(idx) = x;
                    Y(idx) = y;
                    Z(idx) = z;
                    idx = idx + 1;

                    if(y == y2)		% end
                        break;
                    end

                    if(xd >= 0)		% move along x
                        x = x + sx;
                        xd = xd - ay;
                    end

                    if(zd >= 0)		% move along z
                        z = z + sz;
                        zd = zd - ay;
                    end

                    y  = y  + sy;		% move along y
                    xd = xd + ax;
                    zd = zd + az;
                end
            elseif (az>=max(ax,ay))		% z dominant
                xd = ax - az/2;
                yd = ay - az/2;

                while (1)
                    X(idx) = x;
                    Y(idx) = y;
                    Z(idx) = z;
                    idx = idx + 1;

                    if(z == z2)		% end
                        break;
                    end

                    if(xd >= 0)		% move along x
                        x = x + sx;
                        xd = xd - az;
                    end

                    if(yd >= 0)		% move along y
                        y = y + sy;
                        yd = yd - az;
                    end

                    z  = z  + sz;		% move along z
                    xd = xd + ax;
                    yd = yd + ay;
                end
            end
            if precision ~= 0
                X = X/(10^precision);
                Y = Y/(10^precision);
                Z = Z/(10^precision);
            end
        end
        function [nii] = load_nii_no_xform(filename, img_idx, old_RGB, preferredForm)
        
            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.load_nii_hdr;
            import mlfourd.JimmyShen.load_nii_img;

            filename = convertStringsToChars(filename);

            if ~exist('filename','var')
                error('Usage: [nii] = load_nii(filename, [img_idx], [old_RGB])');
            end

            if ~exist('img_idx','var'), img_idx = []; end
            if ~exist('old_RGB','var'), old_RGB = 0; end
            if ~exist('preferredForm','var'), preferredForm= 's'; end     % Jeff

            v = version;

            %  Check file extension. If .gz, unpack it into temp folder
            %
            if length(filename) > 2 && strcmp(filename(end-2:end), '.gz')

                if ~strcmp(filename(end-6:end), '.img.gz') && ...
            	         ~strcmp(filename(end-6:end), '.hdr.gz') && ...
            	         ~strcmp(filename(end-6:end), '.nii.gz')
                    error('Please check filename.');
                end

                if str2double(v(1:3)) < 7.1 || ~usejava('jvm')
                    error('Please use MATLAB 7.1 (with java) and above, or run gunzip outside MATLAB.');
                elseif strcmp(filename(end-6:end), '.img.gz')
                    filename1 = filename;
                    filename2 = filename;
                    filename2(end-6:end) = '';
                    filename2 = [filename2, '.hdr.gz'];

                    tmpDir = tempname;
                    mkdir(tmpDir);
                    gzFileName = filename;

                    filename1 = gunzip(filename1, tmpDir);
                    filename2 = gunzip(filename2, tmpDir);
                    filename = char(filename1); % convert from cell to string
                elseif strcmp(filename(end-6:end), '.hdr.gz')
                    filename1 = filename;
                    filename2 = filename;
                    filename2(end-6:end) = '';
                    filename2 = [filename2, '.img.gz'];

                    tmpDir = tempname;
                    mkdir(tmpDir);
                    gzFileName = filename;

                    filename1 = gunzip(filename1, tmpDir);
                    filename2 = gunzip(filename2, tmpDir);
                    filename = char(filename1); % convert from cell to string
                elseif strcmp(filename(end-6:end), '.nii.gz')
                    tmpDir = tempname;
                    mkdir(tmpDir);
                    gzFileName = filename;
                    filename = gunzip(filename, tmpDir);
                    filename = char(filename);	% convert from cell to string
                end
            end

            %  Read the dataset header
            %
            [nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = ...
                load_nii_hdr(filename);

            %  Read the header extension
            %
            %nii.ext = load_nii_ext(filename);

            %  Read the dataset body
            %
            [nii.img,nii.hdr] = ...
                load_nii_img(nii.hdr,nii.filetype,nii.fileprefix,nii.machine,img_idx,'','','',old_RGB);

            %  Perform some of sform/qform transform
            %
            %nii = xform_nii(nii, preferredForm);

            %  Clean up after gunzip
            %
            if exist('gzFileName', 'var')

                %  fix fileprefix so it doesn't point to temp location
                %
                nii.fileprefix = gzFileName(1:end-7);
                rmdir(tmpDir,'s');
            end

            hdr = nii.hdr;

            %  NIFTI can have both sform and qform transform. This program
            %  will check sform_code prior to qform_code by default.
            %
            %  If user specifys "preferredForm", user can then choose the
            %  priority.	 - Jeff
            %
            useForm=[];				% Jeff

            if isequal(preferredForm,'S')
                if isequal(hdr.hist.sform_code,0)
                    error('User requires sform, sform not set in header');
                else
                    useForm='s';
                end
            end						% Jeff

            if isequal(preferredForm,'Q')
                if isequal(hdr.hist.qform_code,0)
                    error('User requires sform, sform not set in header');
                else
                    useForm='q';
                end
            end						% Jeff

            if isequal(preferredForm,'s')
                if hdr.hist.sform_code > 0
                    useForm='s';
                elseif hdr.hist.qform_code > 0
                    useForm='q';
                end
            end						% Jeff

            if isequal(preferredForm,'q')
                if hdr.hist.qform_code > 0
                    useForm='q';
                elseif hdr.hist.sform_code > 0
                    useForm='s';
                end
            end						% Jeff

            if isequal(useForm,'s')
                R = [hdr.hist.srow_x(1:3)
                    hdr.hist.srow_y(1:3)
                    hdr.hist.srow_z(1:3)];

                T = [hdr.hist.srow_x(4)
                    hdr.hist.srow_y(4)
                    hdr.hist.srow_z(4)];

                nii.hdr.hist.old_affine = [ [R;[0 0 0]] [T;1] ];

            elseif isequal(useForm,'q')
                b = hdr.hist.quatern_b;
                c = hdr.hist.quatern_c;
                d = hdr.hist.quatern_d;

                if 1.0-(b*b+c*c+d*d) < 0
                    if abs(1.0-(b*b+c*c+d*d)) < 1e-5
                        a = 0;
                    else
                        error('Incorrect quaternion values in this NIFTI data.');
                    end
                else
                    a = sqrt(1.0-(b*b+c*c+d*d));
                end

                qfac = hdr.dime.pixdim(1);
                i = hdr.dime.pixdim(2);
                j = hdr.dime.pixdim(3);
                k = qfac * hdr.dime.pixdim(4);

                R = [a*a+b*b-c*c-d*d     2*b*c-2*a*d        2*b*d+2*a*c
                    2*b*c+2*a*d         a*a+c*c-b*b-d*d    2*c*d-2*a*b
                    2*b*d-2*a*c         2*c*d+2*a*b        a*a+d*d-c*c-b*b];

                T = [hdr.hist.qoffset_x
                    hdr.hist.qoffset_y
                    hdr.hist.qoffset_z];

                nii.hdr.hist.old_affine = [ [R * diag([i j k]);[0 0 0]] [T;1] ];

            elseif nii.filetype == 0 && exist([nii.fileprefix '.mat'],'file')
                ld = load([nii.fileprefix '.mat']); % old SPM affine matrix
                M = ld.M;
                R=M(1:3,1:3);
                T=M(1:3,4);
                T=R*ones(3,1)+T;
                M(1:3,4)=T;
                nii.hdr.hist.old_affine = M;
            else
                M = diag(hdr.dime.pixdim(2:5));
                M(1:3,4) = -M(1:3,1:3)*(hdr.hist.originator(1:3)-1)';
                M(4,4) = 1;
                nii.hdr.hist.old_affine = M;
            end
        end
        function img_slice = nearest_neighbor(img, dim1, dim2, M, bg)

            import mlfourd.JimmyShen;

            img_slice = zeros(dim1(1:2));

            %  Dimension of transformed 3D volume
            %
            xdim1 = dim1(1);
            ydim1 = dim1(2);

            %  Dimension of original 3D volume
            %
            xdim2 = dim2(1);
            ydim2 = dim2(2);
            zdim2 = dim2(3);

            %  initialize new_Y accumulation
            %
            Y2X = 0;
            Y2Y = 0;
            Y2Z = 0;

            for y = 1:ydim1

                %  increment of new_Y accumulation
                %
                Y2X = Y2X + M(1,2);		% new_Y to old_X
                Y2Y = Y2Y + M(2,2);		% new_Y to old_Y
                Y2Z = Y2Z + M(3,2);		% new_Y to old_Z

                %  backproject new_Y accumulation and translation to old_XYZ
                %
                old_X = Y2X + M(1,4);
                old_Y = Y2Y + M(2,4);
                old_Z = Y2Z + M(3,4);

                for x = 1:xdim1

                    %  accumulate the increment of new_X and apply it
                    %  to the backprojected old_XYZ
                    %
                    old_X = M(1,1) + old_X  ;
                    old_Y = M(2,1) + old_Y  ;
                    old_Z = M(3,1) + old_Z  ;

                    xi = round(old_X);
                    yi = round(old_Y);
                    zi = round(old_Z);

                    %  within boundary of original image
                    %
                    if (	xi >= 1 && xi <= xdim2 && ...
                    		yi >= 1 && yi <= ydim2 && ...
                    		zi >= 1 && zi <= zdim2	)
                        img_slice(x,y) = img(xi,yi,zi);
                    else
                        img_slice(x,y) = bg;
                    end	% if boundary

                end	% for x
            end		% for y
        end
        function img_slice = trilinear(img, dim1, dim2, M, bg)

            import mlfourd.JimmyShen;

            img_slice = zeros(dim1(1:2));
            TINY = 5e-2; % tolerance

            %  Dimension of transformed 3D volume
            %
            xdim1 = dim1(1);
            ydim1 = dim1(2);

            %  Dimension of original 3D volume
            %
            xdim2 = dim2(1);
            ydim2 = dim2(2);
            zdim2 = dim2(3);

            %  initialize new_Y accumulation
            %
            Y2X = 0;
            Y2Y = 0;
            Y2Z = 0;

            for y = 1:ydim1

                %  increment of new_Y accumulation
                %
                Y2X = Y2X + M(1,2);		% new_Y to old_X
                Y2Y = Y2Y + M(2,2);		% new_Y to old_Y
                Y2Z = Y2Z + M(3,2);		% new_Y to old_Z

                %  backproject new_Y accumulation and translation to old_XYZ
                %
                old_X = Y2X + M(1,4);
                old_Y = Y2Y + M(2,4);
                old_Z = Y2Z + M(3,4);

                for x = 1:xdim1

                    %  accumulate the increment of new_X, and apply it
                    %  to the backprojected old_XYZ
                    %
                    old_X = M(1,1) + old_X  ;
                    old_Y = M(2,1) + old_Y  ;
                    old_Z = M(3,1) + old_Z  ;

                    %  within boundary of original image
                    %
                    if (	old_X > 1-TINY && old_X < xdim2+TINY && ...
                    		old_Y > 1-TINY && old_Y < ydim2+TINY && ...
                    		old_Z > 1-TINY && old_Z < zdim2+TINY	)

                        %  Calculate distance of old_XYZ to its neighbors for
                        %  weighted intensity average
                        %
                        dx = old_X - floor(old_X);
                        dy = old_Y - floor(old_Y);
                        dz = old_Z - floor(old_Z);

                        x000 = floor(old_X);
                        x100 = x000 + 1;

                        if floor(old_X) < 1
                            x000 = 1;
                            x100 = x000;
                        elseif floor(old_X) > xdim2-1
                            x000 = xdim2;
                            x100 = x000;
                        end

                        x010 = x000;
                        x001 = x000;
                        x011 = x000;

                        x110 = x100;
                        x101 = x100;
                        x111 = x100;

                        y000 = floor(old_Y);
                        y010 = y000 + 1;

                        if floor(old_Y) < 1
                            y000 = 1;
                            y100 = y000;
                        elseif floor(old_Y) > ydim2-1
                            y000 = ydim2;
                            y010 = y000;
                        end

                        y100 = y000;
                        y001 = y000;
                        y101 = y000;

                        y110 = y010;
                        y011 = y010;
                        y111 = y010;

                        z000 = floor(old_Z);
                        z001 = z000 + 1;

                        if floor(old_Z) < 1
                            z000 = 1;
                            z001 = z000;
                        elseif floor(old_Z) > zdim2-1
                            z000 = zdim2;
                            z001 = z000;
                        end

                        z100 = z000;
                        z010 = z000;
                        z110 = z000;

                        z101 = z001;
                        z011 = z001;
                        z111 = z001;

                        x010 = x000;
                        x001 = x000;
                        x011 = x000;

                        x110 = x100;
                        x101 = x100;
                        x111 = x100;

                        v000 = double(img(x000, y000, z000));
                        v010 = double(img(x010, y010, z010));
                        v001 = double(img(x001, y001, z001));
                        v011 = double(img(x011, y011, z011));

                        v100 = double(img(x100, y100, z100));
                        v110 = double(img(x110, y110, z110));
                        v101 = double(img(x101, y101, z101));
                        v111 = double(img(x111, y111, z111));

                        img_slice(x,y) = v000*(1-dx)*(1-dy)*(1-dz) + ...
                            v010*(1-dx)*dy*(1-dz) + ...
                            v001*(1-dx)*(1-dy)*dz + ...
                            v011*(1-dx)*dy*dz + ...
                            v100*dx*(1-dy)*(1-dz) + ...
                            v110*dx*dy*(1-dz) + ...
                            v101*dx*(1-dy)*dz + ...
                            v111*dx*dy*dz;

                    else
                        img_slice(x,y) = bg;

                    end	% if boundary

                end	% for x
            end		% for y
        end

        %% save_nii dependencies

        function write_nii(nii, filetype, fileprefix, old_RGB)

            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.save_nii_hdr;
            import mlfourd.JimmyShen.save_nii_ext;
            import mlfourd.JimmyShen.verify_nii_ext;

            fileprefix = convertStringsToChars(fileprefix);

            hdr = nii.hdr;

            if isfield(nii,'ext') && ~isempty(nii.ext)
                ext = nii.ext;
                [ext, esize_total] = JimmyShen.verify_nii_ext(ext);
            else
                ext = [];
            end

            switch double(hdr.dime.datatype)
                case   1
                    hdr.dime.bitpix = int16(1 ); precision = 'ubit1';
                case   2
                    hdr.dime.bitpix = int16(8 ); precision = 'uint8';
                case   4
                    hdr.dime.bitpix = int16(16); precision = 'int16';
                case   8
                    hdr.dime.bitpix = int16(32); precision = 'int32';
                case  16
                    hdr.dime.bitpix = int16(32); precision = 'float32';
                case  32
                    hdr.dime.bitpix = int16(64); precision = 'float32';
                case  64
                    hdr.dime.bitpix = int16(64); precision = 'float64';
                case 128
                    hdr.dime.bitpix = int16(24); precision = 'uint8';
                case 256
                    hdr.dime.bitpix = int16(8 ); precision = 'int8';
                case 511
                    hdr.dime.bitpix = int16(96); precision = 'float32';
                case 512
                    hdr.dime.bitpix = int16(16); precision = 'uint16';
                case 768
                    hdr.dime.bitpix = int16(32); precision = 'uint32';
                case 1024
                    hdr.dime.bitpix = int16(64); precision = 'int64';
                case 1280
                    hdr.dime.bitpix = int16(64); precision = 'uint64';
                case 1792
                    hdr.dime.bitpix = int16(128); precision = 'float64';
                otherwise
                    error('mlfourd:TypeError', 'This datatype is not supported');
            end

            hdr.dime.glmax = round(double(max(nii.img(:))));
            hdr.dime.glmin = round(double(min(nii.img(:))));

            if filetype == 2
                fid = fopen(sprintf('%s.nii',fileprefix),'w');

                if fid < 0
                    error('mlfourd:IOError', 'Cannot open file %s.nii.', fileprefix);  
                end

                hdr.dime.vox_offset = 352;

                if ~isempty(ext)
                    hdr.dime.vox_offset = hdr.dime.vox_offset + esize_total;
                end

                hdr.hist.magic = 'n+1';
                JimmyShen.save_nii_hdr(hdr, fid);

                if ~isempty(ext)
                    JimmyShen.save_nii_ext(ext, fid);
                end
            else
                fid = fopen(sprintf('%s.hdr',fileprefix),'w');

                if fid < 0
                    error('mlfourd:IOError', 'Cannot open file %s.hdr.', fileprefix);  
                end

                hdr.dime.vox_offset = 0;
                hdr.hist.magic = 'ni1';
                JimmyShen.save_nii_hdr(hdr, fid);

                if ~isempty(ext)
                    JimmyShen.save_nii_ext(ext, fid);
                end

                fclose(fid);
                fid = fopen(sprintf('%s.img',fileprefix),'w');
            end

            ScanDim = double(hdr.dime.dim(5)); %#ok<*NASGU> % t
            SliceDim = double(hdr.dime.dim(4));	            % z
            RowDim   = double(hdr.dime.dim(3));             % y
            PixelDim = double(hdr.dime.dim(2));	            % x
            SliceSz  = double(hdr.dime.pixdim(4));
            RowSz    = double(hdr.dime.pixdim(3));
            PixelSz  = double(hdr.dime.pixdim(2));

            x = 1:PixelDim;

            if filetype == 2 && isempty(ext)
                skip_bytes = double(hdr.dime.vox_offset) - 348;
            else
                skip_bytes = 0;
            end

            if double(hdr.dime.datatype) == 128

                %  RGB planes are expected to be in the 4th dimension of nii.img
                %
                if(size(nii.img,4)~=3)
                    error('mlfourd:RuntimeError', 'The NII structure does not appear to have 3 RGB color planes in the 4th dimension');
                end

                if old_RGB
                    nii.img = permute(nii.img, [1 2 4 3 5 6 7 8]);
                else
                    nii.img = permute(nii.img, [4 1 2 3 5 6 7 8]);
                end
            end

            if double(hdr.dime.datatype) == 511

                %  RGB planes are expected to be in the 4th dimension of nii.img
                %
                if(size(nii.img,4)~=3)
                    error('mlfourd:RuntimeError', 'The NII structure does not appear to have 3 RGB color planes in the 4th dimension');
                end

                if old_RGB
                    nii.img = permute(nii.img, [1 2 4 3 5 6 7 8]);
                else
                    nii.img = permute(nii.img, [4 1 2 3 5 6 7 8]);
                end
            end

            %  For complex float32 or complex float64, voxel values
            %  include [real, imag]
            %
            if hdr.dime.datatype == 32 || hdr.dime.datatype == 1792
                real_img = real(nii.img(:))';
                nii.img = imag(nii.img(:))';
                nii.img = [real_img; nii.img];
            end

            if skip_bytes
                fwrite(fid, zeros(1,skip_bytes), 'uint8');
            end

            fwrite(fid, nii.img, precision);
            %fwrite(fid, nii.img, precision, skip_bytes); % error using skip
            fclose(fid);
        end
        function write_ext(ext, fid)
            fwrite(fid, ext.extension, 'uchar');

            for i=1:ext.num_ext
                fwrite(fid, ext.section(i).esize, 'int32');
                fwrite(fid, ext.section(i).ecode, 'int32');
                fwrite(fid, ext.section(i).edata, 'uchar');
            end
        end
        function save_nii_hdr(hdr, fid)
            import mlfourd.JimmyShen;
            import mlfourd.JimmyShen.write_header;

            if ~exist('hdr','var') || ~exist('fid','var')
                error('mlfourd:NameError', 'Usage: save_nii_hdr(hdr, fid)');
            end

            if ~isequal(hdr.hk.sizeof_hdr,348)
                error('mlfourd:ValueError', 'hdr.hk.sizeof_hdr must be 348.');
            end

            if hdr.hist.qform_code == 0 && hdr.hist.sform_code == 0
                hdr.hist.sform_code = 1;
                hdr.hist.srow_x(1) = hdr.dime.pixdim(2);
                hdr.hist.srow_x(2) = 0;
                hdr.hist.srow_x(3) = 0;
                hdr.hist.srow_y(1) = 0;
                hdr.hist.srow_y(2) = hdr.dime.pixdim(3);
                hdr.hist.srow_y(3) = 0;
                hdr.hist.srow_z(1) = 0;
                hdr.hist.srow_z(2) = 0;
                hdr.hist.srow_z(3) = hdr.dime.pixdim(4);
                hdr.hist.srow_x(4) = (1-hdr.hist.originator(1))*hdr.dime.pixdim(2);
                hdr.hist.srow_y(4) = (1-hdr.hist.originator(2))*hdr.dime.pixdim(3);
                hdr.hist.srow_z(4) = (1-hdr.hist.originator(3))*hdr.dime.pixdim(4);
            end

            JimmyShen.write_header(hdr, fid);
        end
        function write_header(hdr, fid)

            %  Original header structures
    	    %  struct dsr				/* dsr = hdr */
    	    %       {
    	    %       struct header_key hk;            /*   0 +  40       */
    	    %       struct image_dimension dime;     /*  40 + 108       */
    	    %       struct data_history hist;        /* 148 + 200       */
    	    %       };                               /* total= 348 bytes*/

            import mlfourd.JimmyShen;

            JimmyShen.write_header_key(fid, hdr.hk);
            JimmyShen.write_image_dimension(fid, hdr.dime);
            JimmyShen.write_data_history(fid, hdr.hist);

            %  check the file size is 348 bytes
            %
            fbytes = ftell(fid);

            if ~isequal(fbytes,348)
                warning('mlfourd:ValueWarning', 'Header size is not 348 bytes.');
            end
        end
        function write_header_key(fid, hk)

            fseek(fid,0,'bof');

        	%  Original header structures
        	%  struct header_key                      /* header key      */
        	%       {                                /* off + size      */
        	%       int sizeof_hdr                   /*  0 +  4         */
        	%       char data_type[10];              /*  4 + 10         */
        	%       char db_name[18];                /* 14 + 18         */
        	%       int extents;                     /* 32 +  4         */
        	%       short int session_error;         /* 36 +  2         */
        	%       char regular;                    /* 38 +  1         */
        	%       char dim_info;   % char hkey_un0;        /* 39 +  1 */
        	%       };                               /* total=40 bytes  */

            fwrite(fid, hk.sizeof_hdr(1),    'int32');	% must be 348.

            % data_type = sprintf('%-10s',hk.data_type);	% ensure it is 10 chars from left
            % fwrite(fid, data_type(1:10), 'uchar');
            pad = zeros(1, 10-length(hk.data_type));
            hk.data_type = [hk.data_type  char(pad)];
            fwrite(fid, hk.data_type(1:10), 'uchar');

            % db_name   = sprintf('%-18s', hk.db_name);	% ensure it is 18 chars from left
            % fwrite(fid, db_name(1:18), 'uchar');
            pad = zeros(1, 18-length(hk.db_name));
            hk.db_name = [hk.db_name  char(pad)];
            fwrite(fid, hk.db_name(1:18), 'uchar');

            fwrite(fid, hk.extents(1),       'int32');
            fwrite(fid, hk.session_error(1), 'int16');
            fwrite(fid, hk.regular(1),       'uchar');	% might be uint8

            % fwrite(fid, hk.hkey_un0(1),    'uchar');
            % fwrite(fid, hk.hkey_un0(1),    'uint8');
            fwrite(fid, hk.dim_info(1),      'uchar');
        end
        function write_image_dimension(fid, dime)

        	%  Original header structures
        	%  struct image_dimension
        	%       {                                /* off + size      */
        	%       short int dim[8];                /* 0 + 16          */
        	%       float intent_p1;   % char vox_units[4];   /* 16 + 4       */
        	%       float intent_p2;   % char cal_units[8];   /* 20 + 4       */
        	%       float intent_p3;   % char cal_units[8];   /* 24 + 4       */
        	%       short int intent_code;   % short int unused1;   /* 28 + 2 */
        	%       short int datatype;              /* 30 + 2          */
        	%       short int bitpix;                /* 32 + 2          */
        	%       short int slice_start;   % short int dim_un0;   /* 34 + 2 */
        	%       float pixdim[8];                 /* 36 + 32         */
        	%			/*
        	%				pixdim[] specifies the voxel dimensions:
        	%				pixdim[1] - voxel width
        	%				pixdim[2] - voxel height
        	%				pixdim[3] - interslice distance
        	%				pixdim[4] - volume timing, in msec
        	%					..etc
        	%			*/
        	%       float vox_offset;                /* 68 + 4          */
        	%       float scl_slope;   % float roi_scale;     /* 72 + 4 */
        	%       float scl_inter;   % float funused1;      /* 76 + 4 */
        	%       short slice_end;   % float funused2;      /* 80 + 2 */
        	%       char slice_code;   % float funused2;      /* 82 + 1 */
        	%       char xyzt_units;   % float funused2;      /* 83 + 1 */
        	%       float cal_max;                   /* 84 + 4          */
        	%       float cal_min;                   /* 88 + 4          */
        	%       float slice_duration;   % int compressed; /* 92 + 4 */
        	%       float toffset;   % int verified;          /* 96 + 4 */
        	%       int glmax;                       /* 100 + 4         */
        	%       int glmin;                       /* 104 + 4         */
        	%       };                               /* total=108 bytes */

            fwrite(fid, dime.dim(1:8),        'int16');
            fwrite(fid, dime.intent_p1(1),  'float32');
            fwrite(fid, dime.intent_p2(1),  'float32');
            fwrite(fid, dime.intent_p3(1),  'float32');
            fwrite(fid, dime.intent_code(1),  'int16');
            fwrite(fid, dime.datatype(1),     'int16');
            fwrite(fid, dime.bitpix(1),       'int16');
            fwrite(fid, dime.slice_start(1),  'int16');
            fwrite(fid, dime.pixdim(1:8),   'float32');
            fwrite(fid, dime.vox_offset(1), 'float32');
            fwrite(fid, dime.scl_slope(1),  'float32');
            fwrite(fid, dime.scl_inter(1),  'float32');
            fwrite(fid, dime.slice_end(1),    'int16');
            fwrite(fid, dime.slice_code(1),   'uchar');
            fwrite(fid, dime.xyzt_units(1),   'uchar');
            fwrite(fid, dime.cal_max(1),    'float32');
            fwrite(fid, dime.cal_min(1),    'float32');
            fwrite(fid, dime.slice_duration(1), 'float32');
            fwrite(fid, dime.toffset(1),    'float32');
            fwrite(fid, dime.glmax(1),        'int32');
            fwrite(fid, dime.glmin(1),        'int32');
        end
        function write_data_history(fid, hist)

        	% Original header structures
        	%struct data_history
        	%       {                                /* off + size      */
        	%       char descrip[80];                /* 0 + 80          */
        	%       char aux_file[24];               /* 80 + 24         */
        	%       short int qform_code;            /* 104 + 2         */
        	%       short int sform_code;            /* 106 + 2         */
        	%       float quatern_b;                 /* 108 + 4         */
        	%       float quatern_c;                 /* 112 + 4         */
        	%       float quatern_d;                 /* 116 + 4         */
        	%       float qoffset_x;                 /* 120 + 4         */
        	%       float qoffset_y;                 /* 124 + 4         */
        	%       float qoffset_z;                 /* 128 + 4         */
        	%       float srow_x[4];                 /* 132 + 16        */
        	%       float srow_y[4];                 /* 148 + 16        */
        	%       float srow_z[4];                 /* 164 + 16        */
        	%       char intent_name[16];            /* 180 + 16        */
        	%       char magic[4];   % int smin;     /* 196 + 4         */
        	%       };                               /* total=200 bytes */

            % descrip     = sprintf('%-80s', hist.descrip);     % 80 chars from left
            % fwrite(fid, descrip(1:80),    'uchar');
            pad = zeros(1, 80-length(hist.descrip));
            hist.descrip = [hist.descrip  char(pad)];
            fwrite(fid, hist.descrip(1:80), 'uchar');

            % aux_file    = sprintf('%-24s', hist.aux_file);    % 24 chars from left
            % fwrite(fid, aux_file(1:24),   'uchar');
            pad = zeros(1, 24-length(hist.aux_file));
            hist.aux_file = [hist.aux_file  char(pad)];
            fwrite(fid, hist.aux_file(1:24), 'uchar');

            fwrite(fid, hist.qform_code,    'int16');
            fwrite(fid, hist.sform_code,    'int16');
            fwrite(fid, hist.quatern_b,   'float32');
            fwrite(fid, hist.quatern_c,   'float32');
            fwrite(fid, hist.quatern_d,   'float32');
            fwrite(fid, hist.qoffset_x,   'float32');
            fwrite(fid, hist.qoffset_y,   'float32');
            fwrite(fid, hist.qoffset_z,   'float32');
            fwrite(fid, hist.srow_x(1:4), 'float32');
            fwrite(fid, hist.srow_y(1:4), 'float32');
            fwrite(fid, hist.srow_z(1:4), 'float32');

            % intent_name = sprintf('%-16s', hist.intent_name);	% 16 chars from left
            % fwrite(fid, intent_name(1:16),    'uchar');
            pad = zeros(1, 16-length(hist.intent_name));
            hist.intent_name = [hist.intent_name  char(pad)];
            fwrite(fid, hist.intent_name(1:16), 'uchar');

            % magic	= sprintf('%-4s', hist.magic);		% 4 chars from left
            % fwrite(fid, magic(1:4),           'uchar');
            pad = zeros(1, 4-length(hist.magic));
            hist.magic = [hist.magic  char(pad)];
            fwrite(fid, hist.magic(1:4),        'uchar');
        end        
    end

    properties (Constant)
        INTERNAL_QFAC = 1
        PREFERRED_FORM = 's'
    end

    %% PRIVATE

    methods (Access = private)
        function this = JimmyShen(varargin)
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
