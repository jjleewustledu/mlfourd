classdef DicomSorter < mlpipeline.DicomSorter
	%% DICOMSORTER  

	%  $Revision$
 	%  was created 05-Sep-2018 19:57:28 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
 	end
    
    methods (Static)   
        function this  = Create(varargin)
            this = mlfourd.DicomSorter(varargin{:});
        end    
        function this  = CreateSorted(varargin)
            this = mlfourd.DicomSorter(varargin{:});
            this = this.sessionSort(varargin{:});
        end    
        function [s,r] = copyConverted(srcFp, destFp, varargin)
            ip = inputParser;
            addRequired(ip, 'srcFp',  @(x) ischar(x) && lexist(ensureNiigz(x), 'file'));
            addRequired(ip, 'destFp', @ischar);
            parse(ip, srcFp, destFp, varargin{:});
            [s,r] = copyfile(ensureNiigz(srcFp), ensureNiigz(destFp), varargin{:});
            
            function fn = ensureNiigz(fn)
                [pth,fp,x] = myfileparts(fn);
                if (~strcmp(x, '.nii.gz')); x = '.nii.gz'; end
                fn = fullfile(pth, [fp x]);
            end
        end
        function tf    = lexistConverted(fqfp)
            tf = lexist([fqfp '.nii.gz'], 'file');
        end    
    end

	methods 
        function canonFp = dcm2imagingFormat(this, info, parentDcmPth, destPth)
            %% DCM2IMAGINGFORMAT
            %  @param info is a struct produced by dcminfo.
            %  @param parentFqdn is the parent directory of a DICOM directory.
            %  @returns canonFp, a fileprefix determined by this.canonicalName.
            
            assert(isstruct(info) && ~isempty(info))
            assert(isfolder(parentDcmPth));
            assert(isfolder(destPth));

            canonFp = this.canonicalName(info);
            mlbash(sprintf('dcm2niix -f %s -o %s/ -z i %s', canonFp, destPth, this.studyData.seriesDicom(parentDcmPth)));
        end
        function g       = getDcmConverter(~)
            g = 'dcm2niix';
        end
		  
 		function this = DicomSorter(varargin)
 			%% DICOMSORTER

 			this = this@mlpipeline.DicomSorter(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

