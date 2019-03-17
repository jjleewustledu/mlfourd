classdef DynamicsTool < handle & mlfourd.ImagingFormatTool
	%% DYNAMICSTOOL

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$  	 

    properties (Constant)
        AVGT_SUFFIX   = '_avgt'
        AVGXYZ_SUFFIX = '_avgxyz'
        SUMT_SUFFIX   = '_sumt'
        SUMXYZ_SUFFIX = '_sumxyz'
    end
    
	methods 
        function this = timeAveraged(this, varargin)
            %  @param optional T \in \mathbb{N}^n, n := length(T), masks by time indices; 
            %  e.g., [1 2 ... n] or [2 3 ... (n-1)].
            %  @param taus are frame durations in sec; default := 1:size(this.innerImaging_, 4)
            
            NT = size(this.innerImaging_, 4);
            ip = inputParser;
            addOptional(ip, 'T',  1:NT, @isnumeric);
            addParameter(ip, 'taus', ones(1, NT), @isnumeric);
            parse(ip, varargin{:});
            T = ip.Results.T;
            taus = ip.Results.taus(T);
            wtaus = taus/sum(taus);
            assert(~isempty(T));
            assert(~isempty(taus));
            
            for iT = T
                this.innerImaging_.img(:,:,:,iT) = wtaus(iT) .* this.innerImaging_.img(:,:,:,iT);
            end
            this.innerImaging_.img = sum(this.innerImaging_.img, 4, 'omitnan');
            this.fileprefix = [this.fileprefix this.AVGT_SUFFIX];
            this.addLog('DynamicsTool.timeAveraged weighted by %s', mat2str(1./taus));
        end
        function this = timeContracted(this, varargin)
            %  @param optional T \in \mathbb{N}^n, n := length(T), masks by time indices; 
            %  e.g., [1 2 ... n] or [2 3 ... (n-1)].
            
            ip = inputParser;
            addOptional(ip, 'T', 1:size(this.innerImaging_,4), @isnumeric);
            parse(ip, varargin{:});            
            T = ip.Results.T;
            
            this.innerImaging_.img = this.innerImaging_.img(:,:,:,T);
            this.innerImaging_.img = sum(this.innerImaging_.img, 4, 'omitnan');
            if (isempty(varargin))
                this.fileprefix = [this.fileprefix this.SUMT_SUFFIX];
            else
                this.fileprefix = sprintf('%s%s%g-%g', this.fileprefix, this.SUMT_SUFFIX, T(1), T(end));
            end
            this.addLog('DynamicsTool.timeContracted over %s', mat2str(T));
        end  
        function [this,M] = volumeAveraged(this, varargin)
            %  @param optional M is a mask, max(mask) == 1, understood by ImagingContext2.
            
            [this,M] = this.volumeContracted(varargin{:});            
            this.innerImaging_.img = this.innerImaging_.img / sum(sum(sum(M.nifti.img, 'omitnan'), 'omitnan'), 'omitnan');
            this.fileprefix = [this.fileprefix this.AVGXYZ_SUFFIX];
            this.addLog('DynamicsTool.volumeAveraged');
        end
        function [this,M] = volumeContracted(this, varargin)
            %  @param optional M is a mask, max(mask) == 1, understood by ImagingContext2.
            
            sz = this.innerImaging_.size;
            ones_ = ones(sz(1:3));
            ip = inputParser;
            addOptional(ip, 'M', ones_);
            parse(ip, varargin{:});
            this.verifyMaxMaskIsUnity(ip.Results.M);
            M = mlfourd.ImagingContext2(ip.Results.M);
            
            ming = M.nifti.img;
            for t = 1:sz(4)
                this.innerImaging_.img(:,:,:,t) =  ...
                    this.innerImaging_.img(:,:,:,t) .* ming;
            end            
            this.innerImaging_.img = ...
                ensureRowVector( ...
                    squeeze( ...
                        sum(sum(sum(this.innerImaging_.img, 1, 'omitnan'), 2, 'omitnan'), 3, 'omitnan')));
            if (lstrfind(M.fileprefix, 'rand'))
                this.fileprefix = [this.fileprefix this.SUMXYZ_SUFFIX];
            else
                this.fileprefix = [this.fileprefix this.SUMXYZ_SUFFIX upper(M.fileprefix(1)) M.fileprefix(2:end)];
            end
            this.addLog('DynamicsTool.volumeContracted over %s', M.fileprefix);            
        end
        
 		function this = DynamicsTool(h, varargin)
            this = this@mlfourd.ImagingFormatTool(h, varargin{:}); 
            assert(4 == this.innerImaging_.ndims);
        end 
    end
    
    %% PRIVATE
    
    methods (Access = private)
        function verifyMaxMaskIsUnity(this, M)
            M = mlfourd.ImagingContext2(M);
            ming = M.nifti.img;
            if (1 ~= dipmax(ming))
                this.addLog('DynamicsTool.verifyMaxMaskIsUnity dipmax(ming) == %g', dipmax(ming));
                warning('mlfourd:failedToVerify', 'DynamicsTool.verifyMaxMaskIsUnity');
            end
        end
    end
      
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

