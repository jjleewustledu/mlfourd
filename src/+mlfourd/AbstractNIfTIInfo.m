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
%            V = this.permuteCircshiftX(V);
            V = this.ensureDatatype(V, this.datatype_);
            untouch = jimmy.untouch;
            hdr = this.adjustHdr(jimmy.hdr); % update hdr.dime.{glmax,glmin}
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
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

