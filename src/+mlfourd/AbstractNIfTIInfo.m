classdef (Abstract) AbstractNIfTIInfo < handle & mlfourd.ImagingInfo
	%% ABSTRACTNIFTIINFO  

	%  $Revision$
 	%  was created 24-Jul-2018 15:07:27 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
    
    methods (Static)
        function [X,hdr] = exportNiftiToFourdfp(X, hdr)
            %% provides symmetries for the app programming interface, but performs no transformations 
            %  since internal representations must be NIfTI compatible
        end
    end

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
            g = this.raw.descrip;
        end
        function g = get.ImageSize(this)
            end_ = 1+this.raw.dim(1);
            g = this.raw.dim(2:end_);
        end
        function g = get.PixelDimensions(this)
            end_ = 1+this.raw.dim(1);
            g = this.raw.pixdim(2:end_);
        end
        function g = get.Datatype(this)
            switch (this.raw.datatype)
                case 0
                    g = 'none';
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
                    g = 'single'; % RGB
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
                    g = 'double'; % complex
                case 2048
                    g = 'Unsupported';
                otherwise
                    error('mlfourd:unsupportedSwitchcase', 'NIfTIInfo.get.Datatype');
            end
        end
        function g = get.BitsPerPixel(this)
            g = this.raw.bitpix;
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
            if (0 == this.raw.slice_code)
                g = 'Unknown';
                return
            end
            g = this.raw.slice_code;
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
            g = this.raw.pixdim(1); 
            if (0 == g)
                g = 1;
            end
        end   
		  
        %%
        
        function nii  = apply_scl(~, nii)
            dime = nii.hdr.dime;
            if ~isfield(dime, 'scl_slope')
                return
            end
            if dime.scl_slope == 0 || (dime.scl_slope == 1 && dime.scl_inter == 0) 
                return
            end
            maxi = rescl(dime, dipmax(nii.img));
            if abs(maxi) < realmax('single')
                nii.img = rescl(dime, single(nii.img));
                nii.hdr.dime.scl_slope = 1;
                nii.hdr.dime.scl_inter = 0;
                nii.hdr.dime.glmax = dipmax(single(nii.img));
                nii.hdr.dime.datatype = 16;
                nii.hdr.dime.bitpix = 32;
                return
            else % (abs(maxi) < realmax('double'))
                nii.img = rescl(dime, double(nii.img));
                nii.hdr.dime.scl_slope = 1;
                nii.hdr.dime.scl_inter = 0;
                nii.hdr.dime.glmax = dipmax(double(nii.img));
                nii.hdr.dime.datatype = 64;
                nii.hdr.dime.bitpix = 64;
                return                
            end
            
            function x = rescl(dime, x)
                x = dime.scl_slope*x + dime.scl_inter;
            end
        end
        function fqfn = fqfileprefix_nii(this)
            fqfn = strcat(this.fqfileprefix, '.nii');
        end
        function fqfn = fqfileprefix_nii_gz(this)
            fqfn = strcat(this.fqfileprefix, '.nii.gz');
        end
        
 		function this = AbstractNIfTIInfo(varargin)
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

