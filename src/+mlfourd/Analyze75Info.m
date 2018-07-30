classdef Analyze75Info < mlfourd.ImagingInfo
	%% ANALYZE75INFO  

	%  $Revision$
 	%  was created 27-Jun-2018 00:34:54 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties (Dependent)
            Filename % : '/Users/jjlee/Tmp/T1.4dfp.hdr'
         FileModDate % : '02-Jun-2018 18:17:24'
         HdrFileSize % : 348
         ImgFileSize % : 67108864
              Format % : 'Analyze'
       FormatVersion % : '7.5'
               Width % : 256
              Height % : 256
            BitDepth % : 32
           ColorType % : 'grayscale'
           ByteOrder % : 'ieee-le'
         HdrDataType % : ''
        DatabaseName % : ''
             Extents % : 16384
        SessionError % : 0
             Regular % : 1
          Dimensions % : [256 256 256 1]
          VoxelUnits % : ''
    CalibrationUnits % : ''
         ImgDataType % : 'DT_FLOAT'
     PixelDimensions % : [1 1 1]
         VoxelOffset % : 0
      CalibrationMax % : 0
      CalibrationMin % : 0
          Compressed % : 0
            Verified % : 0
           GlobalMax % : 0
           GlobalMin % : 0
          Descriptor % : ''
             AuxFile % : ''
         Orientation % : 'Transverse unflipped'
          Originator % : 'jjlee'
           Generated % : '2018'
          Scannumber % : ''
           PatientID % : ''
        ExposureDate % : 'SatJun2'
        ExposureTime % : '18:17:24'
               Views % : 0
        VolumesAdded % : 0
          StartField % : 0
           FieldSkip % : 0
                OMax % : 0
                OMin % : 0
                SMax % : 0
                SMin % : 0 		
 	end

	methods 

        %% GET/SET
        
        function g = get.Filename(this)
            g = this.info_.Filename;
        end
        function g = get.FileModDate(this)
            g = this.info_.FileModDate;
        end
        function g = get.HdrFileSize(this)
            g = this.info_.HdrFileSize;
        end
        function g = get.ImgFileSize(this)
            g = this.info_.ImgFileSize;
        end
        function g = get.Format(this)
            g = this.info_.Format;
        end
        function g = get.FormatVersion(this)
            g = this.info_.FormatVersion;
        end
        function g = get.Width(this)
            g = this.info_.Width;
        end
        function g = get.Height(this)
            g = this.info_.Height;
        end
        function g = get.BitDepth(this)
            g = this.info_.BitDepth;
        end
        function g = get.ColorType(this)
            g = this.info_.ColorType;
        end
        function g = get.ByteOrder(this)
            g = this.info_.ByteOrder;
        end
        function g = get.HdrDataType(this)
            g = this.info_.HdrDataType;
        end
        function g = get.DatabaseName(this)
            g = this.info_.DatabaseName;
        end
        function g = get.Extents(this)
            g = this.info_.Extents;
        end
        function g = get.SessionError(this)
            g = this.info_.SessionError;
        end
        function g = get.Regular(this)
            g = this.info_.Regular;
        end
        function g = get.Dimensions(this)
            g = this.info_.Dimensions;
        end
        function g = get.VoxelUnits(this)
            g = this.info_.VoxelUnits;
        end
        function g = get.CalibrationUnits(this)
            g = this.info_.CalibrationUnits;
        end
        function g = get.ImgDataType(this)
            g = this.info_.ImgDataType;
        end
        function g = get.PixelDimensions(this)
            g = this.info_.PixelDimensions;
        end        
        function g = get.VoxelOffset(this)
            g = this.info_.VoxelOffset;
        end
        function g = get.CalibrationMax(this)
            g = this.info_.CalibrationMax;
        end
        function g = get.CalibrationMin(this)
            g = this.info_.CalibrationMin;
        end
        function g = get.Compressed(this)
            g = this.info_.Compressed;
        end
        function g = get.Verified(this)
            g = this.info_.Verified;
        end
        function g = get.GlobalMax(this)
            g = this.info_.GlobalMax;
        end
        function g = get.GlobalMin(this)
            g = this.info_.GlobalMin;
        end
        function g = get.Descriptor(this)
            g = this.info_.Descriptor;
        end
        function g = get.AuxFile(this)
            g = this.info_.AuxFile;
        end
        function g = get.Orientation(this)
            g = this.info_.Orientation;
        end
        function g = get.Originator(this)
            g = this.info_.Originator;
        end
        function g = get.Generated(this)
            g = this.info_.Generated;
        end
        function g = get.Scannumber(this)
            g = this.info_.Scannumber;
        end
        function g = get.PatientID(this)
            g = this.info_.PatientID;
        end
        function g = get.ExposureDate(this)
            g = this.info_.ExposureDate;
        end
        function g = get.ExposureTime(this)
            g = this.info_.ExposureTime;
        end
        function g = get.Views(this)
            g = this.info_.Views;
        end
        function g = get.VolumesAdded(this)
            g = this.info_.VolumesAdded;
        end
        function g = get.StartField(this)
            g = this.info_.StartField;
        end
        function g = get.FieldSkip(this)
            g = this.info_.FieldSkip;
        end
        function g = get.OMax(this)
            g = this.info_.OMax;
        end
        function g = get.OMin(this)
            g = this.info_.OMin;
        end
        function g = get.SMax(this)
            g = this.info_.SMax;
        end
        function g = get.SMin(this)
            g = this.info_.SMin;
        end
        
        %%        
		  
        function fqfn = fqfileprefix_hdr(this)
            fqfn = [this.fqfileprefix '.hdr'];
        end
        function fqfn = fqfileprefix_img(this)
            fqfn = [this.fqfileprefix '.img'];
        end
        
        function [X,untouch,hdr] = analyze75read(this)
            %% calls mlniftitools.load_nii
            
            jimmy = this.load_nii; % struct
            X = jimmy.img;
            X = flip(X, 1); % storage order := Neurological, conforming to Analyze conventions
            X = this.ensureDatatype(X, this.datatype_);
            untouch = false;
            hdr = this.adjustHdr(jimmy.hdr);
        end
        function nii = make_nii(this)
            [X,untouch,hdr] = this.analyze75read;
            nii = mlniftitools.make_nii( ...
                X, this.PixelDimensions(1:3), hdr.hist.originator(1:3), this.datatype_, this.Descriptor);
            nii.img = this.ensureDatatype(nii.img, this.datatype_);
            nii.hdr = this.newHdr(nii.hdr);
            nii.untouch = untouch;
        end
        
 		function this = Analyze75Info(varargin)
 			%% ANALYZE75INFO calls mlniftitools.load_untouch_header_only
 			%  @param filename is required.
 			
            this = this@mlfourd.ImagingInfo(varargin{:});            
            
            this.info_ = analyze75info(this.fqfilename); % Matlab's native 
            this.info_ = this.permuteInfo(this.info_); % KLUDGE            
            this.raw_.sizeof_hdr = this.HdrFileSize;
            this.raw_.descrip = this.Descriptor;
            this.raw_.aux_file = this.AuxFile;
            this.anaraw_.ByteOrder = this.ByteOrder;
            this.anaraw_.Extents = this.Extents;
            this.anaraw_.ImgDataType = this.ImgDataType;
            this.anaraw_.GlobalMax = this.GlobalMax;
            this.anaraw_.GlobalMin = this.GlobalMin;   
            this.anaraw_.OMax = this.OMax;
            this.anaraw_.OMin = this.OMin;
            this.anaraw_.SMax = this.SMax;
            this.anaraw_.SMin = this.SMin;
            
            % from mlniftitools
            [this.hdr_,this.ext_,this.filetype_,this.machine_] = this.load_untouch_header_only;
            this.hdr_ = this.adjustHdr(this.hdr_);            
            this.raw_.dim = this.hdr_.dime.dim;
            this.raw_.datatype = this.hdr_.dime.datatype;
            this.raw_.bitpix = this.hdr_.dime.bitpix;
            this.raw_.pixdim = this.hdr_.dime.pixdim;
            this.raw_.vox_offset = this.hdr_.dime.vox_offset;
            this.raw_.cal_max = this.hdr_.dime.cal_max;
            this.raw_.cal_min = this.hdr_.dime.cal_min;
 		end
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        info_
    end
    
    methods (Access = protected)
        
        %% methods to complete NIfTI-1 specifications from Analyze 7.5 data
        
        function hdr  = adjustDime(this, hdr)
            %  mimicry:  mlniftitools.make_nii squeezes singleton dimensions s.t. nii.hdr.dime.dim(1) := 3 for single
            %  time frames.  However, load_nii sets nii.hdr.dime.dim(1) := 4 for single time frames.
            %  mimicry:  mlniftitools.make_nii populates nii.hdr.dime.pixdim := [0 1 1 1 1 1 1 1].   
            %  However, load_nii tends to set nii.hdr.dime.pixdim := [1 1 1 1 1 0 0 0].
            %  mimicry:  mlniftitools.make_nii  sets nii.hdr.dime.vox_offset := 0.
            
            hdr.dime.pixdim(1) = this.qfac; % qfac rules https://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html
            hdr.dime.vox_offset = 352;
        end
        function hdr  = adjustHist(~, hdr)
            % mimicry:  mlniftitools.make_nii drops nii.hdr.hist.magic := ''.            
            hdr.hist.aux_file = '';
            hdr.hist.magic = 'n+1';
            if (isfield(hdr.hist, 'originator'))
                hdr.hist.originator = hdr.hist.originator(1:3);
            end
        end
        function hdr  = newHdr(this, hdr)
            hdr.dime.xyzt_units = 2+8; % mm, sec; see also mlniftitools.extra_nii_hdr
            hdr.hist.qform_code = 1;
            hdr.hist.sform_code = 1;
            
                                    % a = 0.5  * sqrt(1 + trace(R));
            hdr.hist.quatern_b = 0; % 0.25 * (R(3,2) - R(2,3)) / a;
            hdr.hist.quatern_c = 0; % 0.25 * (R(1,3) - R(3,1)) / a;
            hdr.hist.quatern_d = 0; % 0.25 * (R(2,1) - R(1,2)) / a;
            hdr.hist.qoffset_x = -hdr.hist.originator(1)*hdr.dime.pixdim(2);
            hdr.hist.qoffset_y = -hdr.hist.originator(2)*hdr.dime.pixdim(3);
            hdr.hist.qoffset_z = -hdr.hist.originator(3)*hdr.dime.pixdim(4);            
            
            % for compliance with NIfTI format
            srow = [[hdr.dime.pixdim(2) 0 0           -hdr.hist.originator(1)*hdr.dime.pixdim(2)]; ...
                    [0 hdr.dime.pixdim(3) 0           -hdr.hist.originator(2)*hdr.dime.pixdim(3)]; ...
                    [0 0 hdr.dime.pixdim(4)*this.qfac -hdr.hist.originator(3)*hdr.dime.pixdim(4)]];
            
            hdr.hist.srow_x = srow(1,:);
            hdr.hist.srow_y = srow(2,:);
            hdr.hist.srow_z = srow(3,:);            
            hdr = mlniftitools.extra_nii_hdr(hdr);
            hdr = this.adjustDime(hdr);
            hdr = this.adjustHist(hdr);
        end
        function xyz  = RMatrixMethod2(this, ijk)
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
                'mlfourd:unexpectedInternalParam', 'Analyze75Info.RMatrixMethod3.qform_code->%i', this.qform_code);
            assert(abs(this.qfac) == 1, ...
                'mlfourd:unexpectedInternalParam', 'Analyze75Info.RMatrixMethod3.qfac->%i', this.qfac);
            
            i   = ijk(1);
            j   = ijk(2);
            k   = ijk(3);
            d   = this.hdr.dime;
            h   = this.hdr.hist;
            xyz = RMat * [d.pixdim(2)*i d.pixdim(3)*j d.pixdim(4)*k*this.qfac]' + ...
                         [h.qoffset_x   h.qoffset_y   h.qoffset_z  ]';
            
            function R = RMat
                if (1 == this.qfac)
                    R = [1 0 0; 0 -1 0; 0 0 1]; % det =: -1
                else
                    R = [1 0 0; 0 -1 0; 0 0 -1]; % det =: 1
                end
            end
            function Rq = RMatq %#ok<DEFNU>
                qa = 0;
                qb = this.hdr.hist.quatern_b;
                qc = this.hdr.hist.quatern_c;
                qd = this.hdr.hist.quatern_d;
                Rq = [(1 - 2*qc^2  - 2*qd^2 ) (    2*qb*qc - 2*qd*qa) (    2*qb*qd + 2*qc*qa); ...
                      (    2*qb*qc + 2*qd*qa) (1 - 2*qb^2  - 2*qd^2 ) (    2*qc*qd - 2*qb*qa); ...
                      (    2*qb*qd - 2*qc*qa) (    2*qc*qd + 2*qb*qa) (1 - 2*qx^2  - 2*qc^2)];
            end
        end
        function xyz  = AffineMethod3(this, ijk)
            %    AFFINEMETHOD3 (used when sform_code > 0):
            %    -----------------------------------------
            %    The (x,y,z) coordinates are given by a general affine transformation
            %    of the (i,j,k) indexes:
            % 
            %      x = srow_x[0] * i + srow_x[1] * j + srow_x[2] * k + srow_x[3]
            %      y = srow_y[0] * i + srow_y[1] * j + srow_y[2] * k + srow_y[3]
            %      z = srow_z[0] * i + srow_z[1] * j + srow_z[2] * k + srow_z[3]
            % 
            %    The srow_* vectors are in the NIFTI_1 header.  Note that no use is
            %    made of pixdim[] in this method.
            %
            %    See also https://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html
            %
            %    @param  ijk := voxel indices
            %    @return xyz := Cartesian position
            
            assert(this.sform_code > 0, ...
                'mlfourd:unexpectedInternalParam', 'Analyze75Info.RMatrixMethod3.sform_code->%i', this.sform_code);
            
            S =  [srow_x(1) srow_x(2) srow_x(3); ...
                  srow_y(1) srow_y(2) srow_y(3); ...
                  srow_z(1) srow_z(2) srow_z(3)];
            s1 = [srow_x(4) srow_y(4) srow_z(4)]';
            xyz = S*ijk + s1;
        end
        function info = permuteInfo(this, info)
            info.Width           = info.Dimensions(1);
            info.Height          = info.Dimensions(3);
            if (0 == this.circshiftK_); return; end
            info.PixelDimensions = this.permuteCircshiftVec(info.PixelDimensions);
            info.Dimensions      = this.permuteCircshiftVec(info.Dimensions);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

