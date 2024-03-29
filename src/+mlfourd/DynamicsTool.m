classdef DynamicsTool < handle & mlfourd.ImagingTool
	%% DYNAMICSTOOL

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$  	 

    properties (Constant)
        AVGW_SUFFIX   = '_avgw'
        AVGT_SUFFIX   = '_avgt'
        AVGXYZ_SUFFIX = '_avgxyz'
        SUMT_SUFFIX   = '_sumt'
        SUMXYZ_SUFFIX = '_sumxyz'
    end
    
	methods 
        function this = corrcoef(this, varargin)
            %% CORRCOEF finds the corrcoef for time-series.
            %  @param mask is interpretable by the ctor and is 3D;
            %         default := fullfil(getenv(), 'gm3d.nii.gz').
            %  @param rsn_labels is interpretable by the ctor and is 3D; 
            %         default := fullfile(getenv('REFDIR'), 'Yeo2011_7Networks_333.nii.gz').
            
            mask_ = mlfourd.ImagingContext2( ...
                fullfile(getenv('REFDIR'), 'N21_aparc+aseg_GMctx_on_711-2V_333_avg_zlt0.5_gAAmask_v1_binarized.nii.gz'));
                % 'gm3d.nii.gz'
            rsn_labels_ = mlfourd.ImagingContext2( ...
                fullfile(getenv('REFDIR'), 'Yeo', 'Yeo2011_7Networks_333.nii.gz'));            
            persistent xfm_
            
            ip = inputParser;
            addParameter(ip, 'mask', mask_)
            addParameter(ip, 'rsn_labels', rsn_labels_)            
            parse(ip, varargin{:})
            ipr = ip.Results;
            ipr.mask = mlfourd.ImagingContext2(ipr.mask);
            ipr.rsn_labels = mlfourd.ImagingContext2(ipr.rsn_labels);
            
            this.imagingFormat_.fileprefix = strcat(this.imagingFormat_.fileprefix, '_corrcoef');
            if ~contains(this.imagingFormat_.filesuffix, '.nii')
                this.imagingFormat_.filesuffix = '.nii.gz';
            end
            this.imagingFormat_ = mlfourd.NiftiTool.createFromImagingFormat(this.imagingFormat_);
            sz = size(this.imagingFormat_);
            Nxyz = prod(sz(1:3));
            Nt = sz(4);
                        
            found = find(reshape(ipr.mask.nifti.img, [Nxyz 1]));
            if ~isempty(varargin)
                xfm_ = [];
            end
            if isempty(xfm_)
                xfm_ = xfm();
            end
            found = xfm_ * found;            
            
            bold = reshape(this.imagingFormat_.img, [Nxyz Nt])'; % Nt x Nxyz
            this.imagingFormat_.img = corrcoef(bold(:, found), 'Rows', 'complete'); % Nfound x Nfound            
            
            function m = xfm()
                Nrsn = dipmax(ipr.rsn_labels) + 1;
                
                msk = ipr.mask.nifti;
                msk_vec_ = reshape(msk.img, [1 Nxyz]);
                msk_vec = msk_vec_;
                msk_vec(msk_vec == 0) = nan;
                Nmsk = sum(msk_vec_, 'omitnan');
                found_msk = find(msk_vec_);

                rsn = ipr.rsn_labels.nifti;
                rsn_vec = reshape(rsn.img, [1 Nxyz]);
                rsn_vec = rsn_vec .* msk_vec;
                rsn_vec(rsn_vec == 0) = Nrsn;
                rsn_vec(isnan(rsn_vec)) = 0;

                found_rsn = [];
                for irsn = 1:Nrsn
                    found_rsn = [found_rsn find(rsn_vec == irsn)]; %#ok<*AGROW>
                end
                assert(numel(found_rsn) == Nmsk)

                m = zeros(Nmsk, Nmsk);
                for n = 1:Nmsk
                    m(found_rsn == found_msk(n), n) = 1;
                end
            end            
        end
        function this = coeffvar(this, varargin)
            s = std(copy(this), varargin{:});
            m = mean(copy(this), varargin{:});
            this.imagingFormat_.img = s.imagingFormat_.img ./ m.imagingFormat_.img;
            this.addLog('DynamicsTool.coeffvar');
        end
        function this = del2(this, varargin)
            this.imagingFormat_.img = del2(this.imagingFormat_.img, varargin{:});
            this.addLog('DynamicsTool.del2');
        end
        function this = diff(this, varargin)
            %% DIFF applies Matlab diff over time samples, time dimension will be smaller by 1.
            %  See also:  Matlab diff.
            
            img = shiftdim(this.imagingFormat_.img, this.ndims-1); % t is leftmost
            img = diff(img, varargin{:});
            this.imagingFormat_.img = shiftdim(img, 1);
            this.addLog('DynamicsTool.diff');
        end
        function this = gradient(this, varargin)
            %% replaces img in R^n with img in R^(n+1) such that last dim contains gradient components.
            %  E.g.,  for input in R^4, return R^5 with last dim containing gradient components [e_x e_y e_z e_t].
            
            imgz = zeros([size(this.imagingFormat_.img) this.ndims]);
            if (4 == this.ndims)
                img = this.imagingFormat_.img;
                [imgz(:,:,:,:,1),imgz(:,:,:,:,2),imgz(:,:,:,:,3),imgz(:,:,:,:,4)] = gradient(img, varargin{:});
                this.imagingFormat_.img = imgz;
                this.addLog('DynamicsTool.gradient');
                return
            end
            if (3 == this.ndims)
                img = this.imagingFormat_.img;
                [imgz(:,:,:,1),imgz(:,:,:,2),imgz(:,:,:,3)] = gradient(img, varargin{:});
                this.imagingFormat_.img = imgz;
                this.addLog('DynamicsTool.gradient');
                return
            end
            error('mlfourd:RuntimeError', 'DynamicsTool.gradient.ndims->%i', this.ndims)
        end
        function this = interp1(this, varargin)
            ip = inputParser;
            addRequired(ip, 'times0', @isnumeric)
            addRequired(ip, 'times1', @isnumeric)
            addParameter(ip, 'method', 'linear', @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            img = this.imagingFormat_.img;
            sz = size(img);
            assert(sz(4), length(ipr.times0))
            Nxyz = sz(1)*sz(2)*sz(3);
            img = reshape(img, [Nxyz, sz(4)]);
            img1 = zeros(Nxyz, length(ipr.times1));
            for x = 1:Nxyz
                img1(x,:) = interp1(ipr.times0, img(x,:), ipr.times1, ipr.method, 'extrap');
            end
            img1 = reshape(img1, [sz(1) sz(2) sz(3) length(ipr.times1)]);
            this.imagingFormat_.img = img1;
            this.fileprefix = strcat(this.fileprefix, '_interp1');
        end
        function this = makima(this, varargin)
            ip = inputParser;
            addRequired(ip, 'times0', @isnumeric)
            addRequired(ip, 'times1', @isnumeric)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            img = this.imagingFormat_.img;
            sz = size(img);
            img = reshape(img, [sz(1)*sz(2)*sz(3) sz(4)]);
            img = makima(ipr.times0, img, ipr.times1);
            img = reshape(img, [sz(1) sz(2) sz(3) length(ipr.times1)]);
            this.imagingFormat_.img = img;            
            this.fileprefix = strcat(this.fileprefix, '_makima');
        end
        function this = mean(this, varargin)
            %% applies Matlab mean over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.imagingFormat_.img, 3); % t is leftmost
            this.imagingFormat_.img = squeeze(mean(img, varargin{:}));
            this.addLog('DynamicsTool.mean');
        end
        function this = median(this, varargin)
            %% applies Matlab median over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.imagingFormat_.img, 3); % t is leftmost
            this.imagingFormat_.img = squeeze(median(img, varargin{:}));
            this.addLog('DynamicsTool.median');
        end
        function this = mode(this, varargin)
            %% applies Matlab mode over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.imagingFormat_.img, 3); % t is leftmost
            this.imagingFormat_.img = squeeze(mode(img, varargin{:}));
            this.addLog('DynamicsTool.mode');
        end   
        function this = pchip(this, varargin)
            ip = inputParser;
            addRequired(ip, 'times0', @isnumeric)
            addRequired(ip, 'times1', @isnumeric)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            img = this.imagingFormat_.img;
            sz = size(img);
            img = reshape(img, [sz(1)*sz(2)*sz(3) sz(4)]);
            img = pchip(ipr.times0, img, ipr.times1);
            img = reshape(img, [sz(1) sz(2) sz(3) length(ipr.times1)]);
            this.imagingFormat_.img = img;            
            this.fileprefix = strcat(this.fileprefix, '_pchip');
        end  
        function this = Q(this, varargin)
            %% Q is the sum of squares of time series := \Sigma_t this_t.^2.
            
            assert(4 == this.ndims)
            for iT = 1:size(this.imagingFormat_, 4)
                this.imagingFormat_.img(:,:,:,iT) = this.imagingFormat_.img(:,:,:,iT).^2;
            end
            this.imagingFormat_.img = sum(this.imagingFormat_, 4, 'omitnan');
            this.addLog('DynamicsTool.Q')
        end
        function this = std(this, varargin)
            %% applies Matlab std over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.imagingFormat_.img, 3); % t is leftmost
            this.imagingFormat_.img = squeeze(std(img, varargin{:}));
            this.addLog('DynamicsTool.std');
        end
        function this = timeAppend(this, varargin)
            %% Appends imagingFormat.img in time, the trailing array index.

            sz = size(this.imagingFormat_.img);
            Nt = sz(end);
            Ndims = ndims(this.imagingFormat_.img);

            ip = inputParser;
            addRequired(ip, 'toappend', @(x) ~isempty(x))
            parse(ip, varargin{:})
            ipr = ip.Results;

            toappend = mlfourd.ImagingContext2(ipr.toappend);
            toappend = toappend.imagingFormat;
            sz1 = size(toappend.img);
            Nt1 = sz1(end);
            assert(all(sz(1:Ndims-1) == sz1(1:Ndims-1)))
            
            % append supported Ndims
            switch Ndims
                case 2
                    this.imagingFormat_.img(:,Nt+1:Nt+Nt1) = toappend.img;
                case 3
                    this.imagingFormat_.img(:,:,Nt+1:Nt+Nt1) = toappend.img;
                case 4 
                    this.imagingFormat_.img(:,:,:,Nt+1:Nt+Nt1) = toappend.img;
                otherwise
                    error('mlfourd:ValueError', 'DynamicsTool.timeAppend.Ndims->%i', Ndims);
            end

            % json
            j = this.json_metadata;
            j1 = toappend.json_metadata;
            j2 = j;
            try
                j2.starts = {j.starts, j1.starts};
            catch %#ok<*CTCH>
            end
            try
                j2.taus = {j.taus, j1.taus};
            catch %#ok<*CTCH>
            end
            try
                j2.timesMid = {j.timesMid, j1.timesMid};
            catch
            end
            try
                j2.times = {j.times, j1.times};
            catch
            end
            try
                j2.timeUnit = {j.timeUnit, j1.timeUnit};
            catch
            end
            this.json_metadata = j2;

            % names & logging
            this.fileprefix = sprintf("%s_timeAppend-%i", this.fileprefix, Nt1);
            this.addLog('DynamicsTool.timeAppend %s', toappend.fqfn);
        end
        function this = timeAveraged(this, varargin)
            %% Contracts imagingFormat.img in time, the trailing array index.
            %  Args:
            %      tindex (optional):  selects unique time indices\in \mathbb{N}^length(tindex); 
            %                                 e.g., [1 2 ... n] or [3 4 5   7 ... (n-1)].
            %      weights (numeric):  to multiply each time frame after selecting tindex.  Default is uniform weighting.
            %      taus (numeric):  sets weights = taus/sum(taus) after selecting tindex, replacing other requests for weights.
            %  Returns:
            %      this
            %  See also:  mlfourd.DynamicsTool.timeCensored(), mlfourd.DynamicsTool.timeContracted()
            
            sz = size(this.imagingFormat_.img);
            Nt = sz(end);
            Ndims = ndims(this.imagingFormat_.img);

            ip = inputParser;
            addParameter(ip, 'tindex', [], @(x) isnumeric(x) && length(x) <= Nt);
            addParameter(ip, 'weights', [], @isnumeric)
            addParameter(ip, 'taus', [], @isnumeric);
            parse(ip, varargin{:});
            ipr = ip.Results;
            if isempty(ipr.tindex)
                Ntc = Nt;
            else
                Ntc = length(ipr.tindex);
            end
            w = ipr.weights;
            if isempty(w)
                w = ones(1, Ntc)/Ntc;
            end
            taus = ipr.taus;
            if ~isempty(taus)
                w = taus/sum(taus);
            end

            % censor times
            this = this.timeCensored(ipr.tindex);

            % apply weights
            switch Ndims
                case 2
                    for it = 1:Ntc
                        this.imagingFormat_.img(:,it) = w(it)*this.imagingFormat_.img(:,it);
                    end
                case 3
                    for it = 1:Ntc
                        this.imagingFormat_.img(:,:,it) = w(it)*this.imagingFormat_.img(:,:,it);
                    end
                case 4          
                    for it = 1:Ntc
                        this.imagingFormat_.img(:,:,:,it) = w(it)*this.imagingFormat_.img(:,:,:,it);
                    end
                otherwise
                    error('mlfourd:ValueError', 'DynamicsTool.timeAveraged.Ndims->%i', Ndims);
            end

            % contract in time 
            this = this.timeContracted();

            % names & logging
            this.fileprefix = strrep(this.fileprefix, this.SUMT_SUFFIX, this.AVGT_SUFFIX);
            if all(w == w(1))
                this.addLog('DynamicsTool.timeAveraged weighted by %g', w(1));
            else
                this.addLog('DynamicsTool.timeAveraged weighted by %s', mat2str(w));
            end
        end
        function this = timeCensored(this, varargin)
            %% Censors imagingFormat.img in time, the trailing array index.
            %  Args:
            %      tindex (optional scalar):  selects unique time indices\in \mathbb{N}^length(tindex); 
            %                                 e.g., [1 2 ... n] or [3 4 5   7 ... (n-1)].
            %  Returns:
            %      this: with censoring of times.  Default returns this unchanged.

            sz = size(this.imagingFormat_.img);
            Nt = sz(end);
            Ndims = ndims(this.imagingFormat_.img);

            ip = inputParser;
            ip.KeepUnmatched = true;
            addOptional(ip, 'tindex', [], @(x) isnumeric(x) && length(x) <= Nt);
            parse(ip, varargin{:});
            ipr = ip.Results;
            tidx = ipr.tindex;
            if isempty(tidx)
                return
            end
            cnt = histcounts(tidx);
            if any(cnt > 1)
                error('mlfourd:ValueError', 'DynamicsTool.timeCensored.ipr.tindex must have unique indices');
            end
            switch Ndims
                case 2
                    this.imagingFormat_.img = this.imagingFormat_.img(:,tidx);
                case 3
                    this.imagingFormat_.img = this.imagingFormat_.img(:,:,tidx);
                case 4
                    this.imagingFormat_.img = this.imagingFormat_.img(:,:,:,tidx);
                otherwise
                    error('mlfourd:ValueError', 'DynamicsTool.timeCensored.Ndims->%i', Ndims);
            end

            % names & logging
            this.fileprefix = sprintf('%s_keepframes-%g-%g', this.fileprefix, tidx(1), tidx(end));
            this.addLog('DynamicsTool.timeCensored with tindex->%s', mat2str(tidx));
        end
        function this = timeContracted(this, varargin)
            %% Contracts imagingFormat.img in time, the trailing array index.
            %  Args:
            %      tindex (optional scalar):  selects unique time indices\in \mathbb{N}^length(tindex); 
            %                                 e.g., [1 2 ... n] or [3 4 5   7 ... (n-1)].
            %  Returns:
            %      this: with contracted time-index.
            %  See also:  mlfourd.DynamicsTool.timeCensored()
            
            sz = size(this.imagingFormat_.img);
            Nt = sz(end);
            Ndims = ndims(this.imagingFormat_.img);

            ip = inputParser;
            addOptional(ip, 'tindex', [], @(x) isnumeric(x) && length(x) <= Nt);
            parse(ip, varargin{:});
            ipr = ip.Results;
            tidx = ipr.tindex;

            this = this.timeCensored(tidx);
            this.imagingFormat_.img = sum(this.imagingFormat_.img, Ndims, 'omitnan');
            
            % names & logging
            this.fileprefix = strcat(this.fileprefix, this.SUMT_SUFFIX);
            this.addLog('DynamicsTool.timeContracted()');
        end
        function this = timeInterleaved(this, varargin)
            %% For M-1 objects in varargin, obtain corresponding imagingFormat and img.
            %  For n in N time frames for each object:
            %      For m in M objects including this:
            %          img(:,:,:,M*(n-1) + m) = imgs{m}(:,:,:,n);
            %  Args:
            %      each element of varargin must be interpretable by mlfourd.ImagingContext2

            assert(~isempty(varargin))
            ics = cellfun(@(x) mlfourd.ImagingContext2(x), varargin, UniformOutput=false);
            ifcs_ = [{this.imagingFormat_} cellfun(@(x) x.imagingFormat, ics, UniformOutput=false)];
            imgs = cellfun(@(x) x.img, ifcs_, UniformOutput=false);
            len = length(imgs);
            sz1 = size(imgs{1}); % size of 1st
            sz = sz1;
            sz(4) = len*sz(4); % expand times of new img
            img = zeros(sz);

            for n = 1:sz1(4)
                for m = 1:len
                    img(:,:,:,len*(n-1) + m) = imgs{m}(:,:,:,n);
                end
            end

            this.imagingFormat_.img = img;
            this.fileprefix = sprintf("%s_interleave%i", this.fileprefix, len);
            this.addLog('DynamicsTool.timeInterleaved()');
        end
        function this = timeSelected(this, varargin)
            %% Selects imagingFormat.img in time, the trailing array index.
            %  Synonym for timeCensored(this, varargin).

            this = this.timeCensored(varargin{:});
        end
        function this = timeShifted(this, times, Dt)
            %% Shifts imagingFormat.img forwards or backwards in time.
            %  Args:
            %      times (required numeric):  possibly nonuniform, e.g., [1 2 2.5 2.7 2.8 2.9].
            %      Dt (required scalar):  e.g., seconds.
            %  Returns: 
            %      this: shifted forwards (Dt > 0) or backwards (Dt < 0) in time.
            
            assert(isnumeric(times))
            assert(isscalar(Dt))
            
            [~,this.imagingFormat_.img] = shiftNumeric(times, this.imagingFormat_.img, Dt);
            
            % names & logging
            this.fileprefix = sprintf('%s_timeShifted-%g', this.fileprefix, Dt);
            this.addLog('DynamicsTool.timeShifted by Dt->%g', Dt);
        end  
        function this = var(this, varargin)
            %% applies Matlab var over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.imagingFormat_.img, 3); % t is leftmost
            this.imagingFormat_.img = squeeze(var(img, varargin{:}));
            this.addLog('DynamicsTool.var');
        end        
        function [this,dbleM] = volumeAveraged(this, varargin)
            %  @param optional mask, forced to uniform distribution, understood by ImagingContext2.
            
            [this,boolM] = this.volumeContracted(varargin{:});
            dbleM = double(boolM);
            this.imagingFormat_.img = this.imagingFormat_.img / sum(dbleM(boolM), 'omitnan');
            
            % names & logging
            this.fileprefix = strrep(this.fileprefix, this.SUMXYZ_SUFFIX, this.AVGXYZ_SUFFIX);
            this.addLog('DynamicsTool.volumeAveraged');
        end
        function [this,boolM] = volumeContracted(this, varargin)
            %  @param optional mask, forced to logical array, understood by ImagingContext2.
            
            sz = this.imagingFormat_.size;
            ip = inputParser;
            addOptional(ip, 'M', ones(sz(1:3)));
            parse(ip, varargin{:});
            ipr = ip.Results;

            M = mlfourd.ImagingContext2(ipr.M);
            boolM = logical(M);
            assert(all(size(boolM) == sz(1:3)), 'mlfourd:RuntimeError', 'DynamicsTool.volumeContracted');
            
            if 4 == length(sz)
                img = zeros(1,sz(4)); % row vector
                for t = 1:sz(4)
                    iiimg = this.imagingFormat_.img(:,:,:,t);
                    img(t) = sum(iiimg(boolM), 'omitnan');
                end
                this.imagingFormat_.img = img;
            else
                this.imagingFormat_.img = sum(this.imagingFormat_.img(boolM), 'omitnan');
            end
            
            % names & logging
            this.fileprefix = strcat(this.fileprefix, this.SUMXYZ_SUFFIX);
            this.addLog('DynamicsTool.volumeContracted over %s', M.fileprefix);            
        end
        function [this,W] = volumeWeightedAveraged(this, varargin)
            %  @param optional weights \in reals, understood by ImagingContext2.

            sz = this.imagingFormat_.size;
            ip = inputParser;
            addOptional(ip, 'W', ones(sz(1:3)))
            parse(ip, varargin{:})
            ipr = ip.Results;

            W = mlfourd.ImagingContext2(ipr.W);
            assert(all(size(W) == sz(1:3)), 'mlfourd:RuntimeError', 'DynamicsTool.volumeWeightedAveraged');
            if 4 == length(sz)
                img = zeros(1,sz(4));
                for t = 1:sz(4)
                    iiimg = this.imagingFormat_.img(:,:,:,t);
                    img(t) = sum(iiimg .* W.imagingFormat.img, 'all', 'omitnan');
                end
                this.imagingFormat_.img = img;
            else
                this.imagingFormat_.img = sum(this.imagingFormat_.img .* W.imagingFormat.img, 'all', 'omitnan');
            end

            % names & logging
            this.fileprefix = strcat(this.fileprefix, this.AVGW_SUFFIX);
            this.addLog('DynamicsTool.volumeWeightedAveraged over %s', W.fileprefix);  
        end
        
 		function this = DynamicsTool(varargin)
            this = this@mlfourd.ImagingTool(varargin{:}); 
        end 
    end

    %% PROTECTED

    methods (Access = protected)
        
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

