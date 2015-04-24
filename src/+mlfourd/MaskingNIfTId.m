classdef MaskingNIfTId < mlfourd.NIfTIdecorator
	%% MASKINGNIFTID is a NIfTIdecorator that composes an internal INIfTId object
    %  according to the decorator design pattern
        
    methods (Static)        
        function this = load(varargin)
            %% LOAD 
            %  Usage:  this = MaskingNIfTId.load(filename[, description])
            
            import mlfourd.*;            
            this = MaskingNIfTId(NIfTId.load(varargin{:}));
        end
        function S    = sumall(obj)
            img = double(obj); % N.B. overload in NIfTIdecorator
            switch length(size(img))
                case 1
                    S = sum(img);
                case 2
                    S = sum(sum(img));
                case 3
                    S = sum(sum(sum(img)));
                case 4
                    S = sum(sum(sum(sum(img))));
                otherwise
                    error('mlfourd:notImplemented', ...
                          'MaskedNIfTI.sumall does not support images of size %s', mat2str(size(img)));
            end
        end
        function M    = maxall(obj)
            img = double(obj); % N.B. overload in NIfTIdecorator
            switch length(size(img))
                case 1
                    M = max(img);
                case 2
                    M = max(max(img));
                case 3
                    M = max(max(max(img)));
                case 4
                    M = max(max(max(max(img))));
                otherwise
                    error('mlfourd:notImplemented', ...
                          'MaskedNIfTI.maxall does not support images of size %s', mat2str(size(img)));
            end
        end
        function M    = minall(obj)
            img = double(obj); % N.B. overload in NIfTIdecorator
            switch length(size(img))
                case 1
                    M = min(img);
                case 2
                    M = min(min(img));
                case 3
                    M = min(min(min(img)));
                case 4
                    M = min(min(min(min(img))));
                otherwise
                    error('mlfourd:notImplemented', ...
                          'MaskedNIfTI.minall does not support images of size %s', mat2str(size(img)));
            end
        end
        function M    = meanall(obj)
            img = double(obj); % N.B. overload in NIfTIdecorator
            switch length(size(img))
                case 1
                    M = mean(img);
                case 2
                    M = mean(mean(img));
                case 3
                    M = mean(mean(mean(img)));
                case 4
                    M = mean(mean(mean(mean(img))));
                otherwise
                    error('mlfourd:notImplemented', ...
                          'MaskedNIfTI.meanall does not support images of size %s', mat2str(size(img)));
            end
        end
        function S    = stdall(obj)
            img = double(obj); % N.B. overload in NIfTIdecorator
            switch length(size(img))
                case 1
                    S = std(img);
                case 2
                    S = std(std(img));
                case 3
                    S = std(std(std(img)));
                case 4
                    S = std(std(std(std(img))));
                otherwise
                    error('mlfourd:notImplemented', ...
                          'MaskedNIfTI.stdall does not support images of size %s', mat2str(size(img)));
            end
        end
        function M    = modeall(obj)
            img = double(obj); % N.B. overload in NIfTIdecorator
            switch length(size(img))
                case 1
                    M = mode(img);
                case 2
                    M = mode(mode(img));
                case 3
                    M = mode(mode(mode(img)));
                case 4
                    M = mode(mode(mode(mode(img))));
                otherwise
                    error('mlfourd:notImplemented', ...
                          'MaskedNIfTI.modeall does not support images of size %s', mat2str(size(img)));
            end
        end
    end
    
    methods        
        function this = MaskingNIfTId(cmp, varargin)            
            %% MASKINGNIFTID 
            %  Usage:  this = MaskingNIfTId(NIfTIdecorator_object[, option-name, option-value, ...])
            %
            %          options:  'binarize'        logical
            %                    'thresh'          numerical
            %                    'pthresh'         numerical
            %                    'niftid_mask'     INIfTId
            %                    'freesurfer_mask' INIfTId, to be binarized internally
            
            import mlfourd.*; 
            this = this@mlfourd.NIfTIdecorator(cmp);
            this = this.append_descrip('decorated by MaskingNIfTId');
            
            p = inputParser;
            addParameter(p, 'binarize',        false, @islogical);
            addParameter(p, 'thresh',          [],    @isnumeric);
            addParameter(p, 'pthresh',         [],    @isnumeric);
            addParameter(p, 'niftid_mask',     [],    @(x) isa(x, 'mlfourd.INIfTId'));
            addParameter(p, 'freesurfer_mask', [],    @(x) isa(x, 'mlfourd.INIfTId'));
            parse(p, varargin{:});
            
            if (p.Results.binarize)
                this = this.binarize;
            end
            if (~isempty(p.Results.thresh))
                this = this.thresh(p.Results.thresh);
            end
            if (~isempty(p.Results.pthresh))
                this = this.pthresh(p.Results.pthresh);
            end
            if (~isempty(p.Results.niftid_mask))
                this = this.masked(p.Results.niftid_mask);
            end
            if (~isempty(p.Results.freesurfer_mask))
                import mlfourd.*; 
                this = this.masked( ...
                       MaskingNIfTId(p.Results.freesurfer_mask, 'binarize', true));
            end
        end           
        function this = masked(this, niidMask)            
            %% MASKED returns this with the internal image multiplied by the passed INIfTId mask;
            %  Usage:   mn = MaskingNIfTId(...)
            %           mn = mn.masked(INIfTId_mask)
            
            assert(isa(niidMask, 'mlfourd.INIfTId'));
            assert(all(this.size == niidMask.size));
            mx = this.maxall(niidMask);
            mn = this.minall(niidMask);
            if (mx > 1 || mn < 0)
                warning('mlfourd:possibleNumericalInconsistency', ...
                        'MaskedNIfTI.masked received a mask object with min->%g, max->%g', mn, mx); 
            end            
            
            this = this.makeSimilar( ...
                   'img', this.img .* niidMask.img, ...
                   'descrip', sprintf('MaskedNIfTI.masked(%s)', niidMask.fileprefix), ...
                   'fileprefix', '_masked');
        end
        function N    = count(this)            
            %% COUNT counts nonzero elements in the internal INIfTId component
            
            msk = this.img ~= 0;
            N   = this.sumall(msk);
        end
        function this = thresh(this, thresh)            
            %% THRESH returns a binary mask after thresholding
            %  Usage:  mn = MaskingNIfTId(...)
            %          mn = mn.thresh(167); % returns MaskingNIfTId with MaskingNIfTId.img > 167 set as binary image
            %          max(max(max(mn.img)))
            %          ans = 1
            
            assert(isscalar(thresh));
            img  = double(this.img > thresh);
            this = this.makeSimilar( ...
                   'img', img, ...
                   'fileprefix', sprintf('_thresh%g', thresh), ...
                   'descrip', sprintf('MaskedNIfTI.thresh(%g)', thresh));
        end
        function this = pthresh(this, pthr)            
            %% PTHR returns binary mask after applying a robust percent threshold
            %  Usage:  mn = MaskingNIfTId(...)
            %          mn = mn.pthr(0.67) % returns MaskingNIfTId with MaskingNIfTId.img > 67% robust threshold set as binary image
            
            if (pthr >= 1)
                pthr = pthr/100; 
                assert(pthr <= 100);
            end
            img  = double(this.img > norminv(pthr, this.meanall(this.img), this.stdall(this.img)));
            this = this.makeSimilar( ...
                   'img', img, ...
                   'fileprefix', sprintf('_pthresh%g', pthr), ...
                   'descrip', sprintf('MaskedNIfTI.pthresh(%g)', pthr));
        end        
        function this = binarize(this)            
            %% BINARIZE
            
            img  = double(this.img ~= 0);
            this = this.makeSimilar( ...
                   'img', img, ...
                   'fileprefix', sprintf('_binarize'), ...
                   'descrip', sprintf('MaskedNIfTI.binarize'));
        end
    end
    
end