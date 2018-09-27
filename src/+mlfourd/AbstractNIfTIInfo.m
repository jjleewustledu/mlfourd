classdef (Abstract) AbstractNIfTIInfo < mlfourd.ImagingInfo
	%% ABSTRACTNIFTIINFO  

	%  $Revision$
 	%  was created 24-Jul-2018 15:07:27 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
    
    properties (Dependent)
                     Filename % : '/Users/jjlee/Tmp/T1.nii.gz'
                  Filemoddate % : '30-Apr-2018 16:33:59'
                     Filesize % : 5401810
                  Description % : 'FreeSurfer Jan 19 2017'
                    ImageSize % : [256 256 256]
              PixelDimensions % : [1 1 1]
                     Datatype % : 'uint8'
                 BitsPerPixel % : 8
                   SpaceUnits % : 'Millimeter'
                    TimeUnits % : 'Second'
               AdditiveOffset % : 0
        MultiplicativeScaling % : 0
                   TimeOffset % : 0
                    SliceCode % : 'Unknown'
           FrequencyDimension % : 0
               PhaseDimension % : 0
             SpatialDimension % : 0
        DisplayIntensityRange % : [0 0]
                TransformName % : 'Sform'
                    Transform % : [1×1 affine3d]
                      Qfactor % : -1
    end
    
	methods 
		  
        %% GET/SET
        
        function g = get.Filename(this)
            g = this.fqfilename;
        end
        function g = get.Filemoddate(this)
            s = dir(this.Filename);
            g = s.date;
        end
        function g = get.Filesize(this)
            s = dir(this.Filename);
            g = s.bytes;
        end
        function g = get.Description(this)
            g = this.raw_.descrip;
        end
        function g = get.ImageSize(this)
            end_ = 1+this.raw_.dim(1);
            g = this.raw_.dim(2:end_);
        end
        function g = get.PixelDimensions(this)
            end_ = 1+this.raw_.dim(1);
            g = this.raw_.pixdim(2:end_);
        end
        function g = get.Datatype(this)
            switch (this.raw_.datatype)
                case 0
                    g = 'Unknown';
                case 1
                    g = 'ubit1';
                case 2
                    g = 'uint8';
                case 4
                    g = 'int16';
                case 8
                    g = 'int32';
                case 16
                    g = 'single';
                case 32
                    g = 'double'; % complex
                case 64
                    g = 'double';
                case 128
                    g = 'uint8'; % RGB
                case 256
                    g = 'int8';
                case 511
                    g = 'single';
                case 512
                    g = 'uint16';
                case 768
                    g = 'uint32';
                case 1024
                    g = 'int64';
                case 1280
                    g = 'uint64';
                case 1536
                    g = 'Unsupported';
                case 1792
                    g = 'float64';
                case 2048
                    g = 'Unsupported';
                otherwise
                    error('mlfourd:unsupportedSwitchcase', 'NIfTIInfo.get.Datatype');
            end
        end
        function g = get.BitsPerPixel(this)
            g = this.raw_.bitpix;
        end
        function g = get.SpaceUnits(this)
            g = this.spaceUnits_;
        end
        function g = get.TimeUnits(this)
            g = this.timeUnits_;
        end
        function g = get.AdditiveOffset(this)
            g = this.additiveOffset_;
        end
        function g = get.MultiplicativeScaling(this)
            g = this.multiplicativeScaling_;
        end
        function g = get.TimeOffset(this)
            g = this.timeOffset_;
        end
        function g = get.SliceCode(this)
            if (0 == this.raw_.slice_code)
                g = 'Unknown';
                return
            end
            g = this.raw_.slice_code;
        end
        function g = get.FrequencyDimension(this)
            g = this.frequencyDimension_;
        end
        function g = get.PhaseDimension(this)
            g = this.phaseDimension_;
        end
        function g = get.SpatialDimension(this)
            g = this.spatialDimension_;
        end
        function g = get.DisplayIntensityRange(~)
            g = [0 0];
        end
        function g = get.TransformName(~)
            g = 'Sform';
        end
        function g = get.Transform(this)
            g = affine3d(this.affineTransform_);
        end
        function g = get.Qfactor(this) % a.k.a. qfac
            g = this.raw_.pixdim(1); 
            if (0 == g)
                g = 1;
            end
        end   
		  
        %%
        
        function fqfn = fqfileprefix_nii(this)
            fqfn = [this.fqfileprefix '.nii'];
        end
        function fqfn = fqfileprefix_nii_gz(this)
            fqfn = [this.fqfileprefix '.nii.gz'];
        end
        
        function nii = make_nii(this)
            [X,untouch,hdr] = niftiread(this);
            nii.img = this.ensureDatatype(X, this.datatype_);
            nii.hdr = hdr;
            nii.untouch = untouch;
        end
        function [V,untouch,hdr] = niftiread(this)
            %% calls mlniftitools.load_untouch_nii
            
            jimmy = this.load_untouch_nii; % struct
            V = jimmy.img;
            V = this.ensureDatatype(V, this.datatype_);
            untouch = jimmy.untouch;
            hdr = this.adjustHdr(jimmy.hdr); % update hdr.dime.{glmax,glmin}
        end
        function hdr = recalculateHdrHistOriginator(~, hdr)
        end
       function this = zoom(this, rmin, rsize)
           shift = this.AffMats*[rmin(1:3) 0]';
           
           this.hdr.hist.srow_x(4) = this.hdr.hist.srow_x(4) + shift(1);
           this.hdr.hist.srow_y(4) = this.hdr.hist.srow_y(4) + shift(2);
           this.hdr.hist.srow_z(4) = this.hdr.hist.srow_z(4) + shift(3);
           this.hdr.hist.originator = rsize(1:3)/2;
       end
        function xyz = RMatrixMethod2(this, ijk)
            %%   RMATRIXMETHOD2 (used when qform_code > 0, which should be the "normal" case):
            %    -----------------------------------------------------------------------------
            %    The (x,y,z) coordinates are given by the pixdim[] scales, a rotation
            %    matrix, and a shift.  This method is intended to represent
            %    "scanner-anatomical" coordinates, which are often embedded in the
            %    image header (e.g., DICOM fields (0020,0032), (0020,0037), (0028,0030),
            %    and (0018,0050)), and represent the nominal orientation and location of
            %    the data.  This method can also be used to represent "aligned"
            %    coordinates, which would typically result from some post-acquisition
            %    alignment of the volume to a standard orientation (e.g., the same
            %    subject on another day, or a rigid rotation to true anatomical
            %    orientation from the tilted position of the subject in the scanner).
            %    The formula for (x,y,z) in terms of header parameters and (i,j,k) is:
            % 
            %      [ x ]   [ R11 R12 R13 ] [       pixdim[1] * i ]   [ qoffset_x ]
            %      [ y ] = [ R21 R22 R23 ] [       pixdim[2]   j ] + [ qoffset_y ]
            %      [ z ]   [ R31 R32 R33 ] [ qfac  pixdim[3] * k ]   [ qoffset_z ]            
            % 
            %    The qoffset_* shifts are in the NIFTI-1 header.  Note that the center
            %    of the (i,j,k)=(0,0,0) voxel (first value in the dataset array) is
            %    just (x,y,z)=(qoffset_x,qoffset_y,qoffset_z).
            % 
            %    The rotation matrix R is calculated from the quatern_* parameters.
            %    This calculation is described below.
            % 
            %    The scaling factor qfac is either 1 or -1.  The rotation matrix R
            %    defined by the quaternion parameters is "proper" (has determinant 1).
            %    This may not fit the needs of the data; for example, if the image
            %    grid is
            %      i increases from Left-to-Right
            %      j increases from Anterior-to-Posterior
            %      k increases from Inferior-to-Superior
            %    Then (i,j,k) is a left-handed triple.  In this example, if qfac=1,
            %    the R matrix would have to be
            % 
            %      [  1   0   0 ]
            %      [  0  -1   0 ]  which is "improper" (determinant = -1).
            %      [  0   0   1 ]
            % 
            %    <b>If we set qfac=-1, then the R matrix would be<\b>
            % 
            %      [  1   0   0 ]
            %      [  0  -1   0 ]  which is proper.
            %      [  0   0  -1 ]
            % 
            %    This R matrix is represented by quaternion [a,b,c,d] = [0,1,0,0]
            %    (which encodes a 180 degree rotation about the x-axis).    
            %
            %    See also https://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html
            %
            %    @param  ijk := voxel indices
            %    @return xyz := Cartesian position
            
            assert(this.qform_code > 0, ...
                'mlfourd:unexpectedInternalParam', 'AbstractNIfTIInfo.RMatrixMethod3.qform_code->%i', this.qform_code);
            assert(abs(this.qfac) == 1, ...
                'mlfourd:unexpectedInternalParam', 'AbstractNIfTIInfo.RMatrixMethod3.qfac->%i', this.qfac);
            
            i   = ijk(1);
            j   = ijk(2);
            k   = ijk(3);
            d   = this.hdr.dime;
            h   = this.hdr.hist;
            xyz = this.RMatq * [d.pixdim(2)*i d.pixdim(3)*j d.pixdim(4)*k*this.qfac]' + ...
                               [h.qoffset_x   h.qoffset_y   h.qoffset_z  ]';
            
        end
        function R   = RMatq(this)
            a = 0;
            b = this.hdr.hist.quatern_b;
            c = this.hdr.hist.quatern_c;
            d = this.hdr.hist.quatern_d;
            R = [ (2*a^2 - 1 + 2*b^2) (2*b*c - 2*d*a)     (2*b*d + 2*c*a); ...
                  (2*b*c + 2*d*a)     (2*a^2 - 1 + 2*c^2) (2*c*d - 2*b*a); ...
                  (2*b*d - 2*c*a)     (2*c*d + 2*b*a)     (2*a^2 - 1 + 2*d^2) ];
        end
        function xyz = AffineMethod3(this, ijk)
            % AFFINEMETHOD3 (used when sform_code > 0):
            % -----------------------------------------
            % The (x,y,z) coordinates are given by a general affine transformation
            % of the (i,j,k) indexes:
            % 
            %   x = srow_x[0] * i + srow_x[1] * j + srow_x[2] * k + srow_x[3]
            %   y = srow_y[0] * i + srow_y[1] * j + srow_y[2] * k + srow_y[3]
            %   z = srow_z[0] * i + srow_z[1] * j + srow_z[2] * k + srow_z[3]
            % 
            % The srow_* vectors are in the NIFTI_1 header.  Note that no use is
            % made of pixdim[] in this method.
            %
            %    See also https://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html
            %
            %    @param  ijk := voxel indices
            %    @return xyz := Cartesian position
            
            assert(this.sform_code > 0, ...
                'mlfourd:unexpectedInternalParam', 'AbstractNIfTIInfo.RMatrixMethod3.sform_code->%i', this.sform_code);
            
            xyz = this.AffMats * [ensureColVector(ijk); 1];
        end
        function A   = AffMats(this)
            A      = zeros(3, 4);
            A(1,:) = this.hdr.hist.srow_x;
            A(2,:) = this.hdr.hist.srow_y;
            A(3,:) = this.hdr.hist.srow_z;
        end
        
 		function this = AbstractNIfTIInfo(varargin)
 			%% ABSTRACTNIFTIINFO
 			%  @param .

 			this = this@mlfourd.ImagingInfo(varargin{:});
 		end
 	end 
    
    %% PROTECTED
    
    properties (Access = protected)
        affineTransform_
        additiveOffset_ = 0
        frequencyDimension_ = 0
        multiplicativeScaling_ = 0
        phaseDimension_ = 0
        spatialDimension_ = 0
        spaceUnits_ = 'Millimeter'
        timeOffset_ = 0
        timeUnits_ = 'Second'
    end
    
    methods (Access = protected)
            
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

