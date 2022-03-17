classdef SimpleT4ResolveBuilder < mlpipeline.AbstractBuilder
	%% SIMPLET4RESOLVEBUILDER implements t4_resolve while avoiding the complexity of AbstractT4ResolveBuilder.

	%  $Revision$
 	%  was created 16-Mar-2022 17:00:00 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.9.0.1538559 (R2021a) for MACI64.  Copyright 2022 John Joowon Lee.
 	
    methods (Static)
        function carr = deleteFourdfp(carr)
            %  Returns:
            %      carr (cell): of mlfourd.ImagingContext2, saved as 4dfp.
            
            if ~iscell(carr)
                carr = {carr};
            end
            carr = mlfourd.SimpleT4ResolveBuilder.imagingContext(carr);
            for idx = 1:length(carr)
                if ~isempty(carr{idx})
                    deleteExisting(strcat(carr{idx}.fqfp, '.4dfp.*'), 'metadata', '');
                end
            end 
        end
        function carr = imagingContext(carr)
            %  Returns:
            %      carr (cell): of mlfourd.ImagingContext2.
            
            if ~iscell(carr)
                carr = {carr};
            end
            for idx = 1:length(carr)
                if ~isempty(carr{idx})
                    carr{idx} = mlfourd.ImagingContext2(carr{idx});
                end
            end 
        end      
    end
    
    properties
        imageRegLog
        resolveLog
    end
    
    properties (Dependent)        
        blurArg
        maskForImages
        resolveTag
        theImages
        theImagesFinal
        theImagesOp
        workpath
    end

	methods 
        
        %% GET, SET
        
        function g    = get.blurArg(this)
            g = this.blurArg_;
        end
        function this = set.blurArg(this, s)
            assert(isnumeric(s));
            assert(~isempty(s));
            this.blurArg_ = s;
        end
        function g    = get.maskForImages(this)
            g = this.maskForImages_;
        end
        function this = set.maskForImages(this, s)
            assert(iscell(s))
            this.maskForImages_ = s;
            this.maskForImages_ = cellfun(@(x) mlfourd.ImagingContext2(x), this.maskForImages_, 'UniformOutput', false);
            cellfun(@(x) assert(contains(x.filesuffix, '.4dfp.hdr')), this.maskForImages_, 'UniformOutput', false)
        end
        function g    = get.resolveTag(this)
            g = this.resolveTag_;
        end
        function this = set.resolveTag(this, s)
            assert(ischar(s));
            assert(~isempty(s));
            this.resolveTag_ = s;
        end
        function g    = get.theImages(this)
            g = this.theImages_;
        end
        function this = set.theImages(this, s)
            assert(iscell(s))
            this.theImages_ = s;
            this.theImages_ = cellfun(@(x) mlfourd.ImagingContext2(x), this.theImages_, 'UniformOutput', false);
            cellfun(@(x) assert(contains(x.filesuffix, '.4dfp.hdr')), this.theImages_, 'UniformOutput', false)
        end
        function g    = get.theImagesFinal(this)
            g = this.theImagesFinal_;
        end
        function g    = get.theImagesOp(this)
            if ~isempty(this.theImagesOp_)
                g = this.theImagesOp_;
                return
            end
            len = length(this.theImages);
            g = cell(len, len);
            for ig1 = 1:len
                for ig2 = 1:len
                    if ig1 ~= ig2
                        g{ig1,ig2} = mlfourd.ImagingContext2( ...
                            fullfile( ...
                                this.workpath, ...
                                strcat(this.theImages{ig1}.fileprefix, '_op_', this.theImages{ig2}.fileprefix, '.4dfp.hdr')));
                    end
                end
            end
        end
        function g    = get.workpath(this)
            g = this.workpath_;
        end
        
        %%
		  
 		function this = SimpleT4ResolveBuilder(varargin)
 			%% SIMPLET4RESOLVEBUILDER
            %  @param workpath default := pwd.
            %  @param theImages is a cell-array of objects understood by ImagingContext2.
 			%  @param maskForImages is a cell-array of objects understood by ImagingContext2; default is empty.
            %  @param resolveTag is char; default ~ 'op_theFirstImageFileprefix'.
            %  @param blurArg default := 0.
            
            this = this@mlpipeline.AbstractBuilder(varargin{:});
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'workpath', pwd, @isfolder)
            addParameter(ip, 'theImages', [], @iscell);
            addParameter(ip, 'maskForImages', [], @iscell);
            addParameter(ip, 'resolveTag', '', @ischar);
            addParameter(ip, 'blurArg', 0, @isnumeric);
            parse(ip, varargin{:});  
            ipr = ip.Results;    
            
            % workpath_
            this.workpath_ = ipr.workpath;
            
            % theImages_
            this.theImages1_ = mlfourd.ImagingContext2(ipr.theImages{1}); % nifti
            this.theImages_ = this.saveAsFourdfp(ipr.theImages); % 4dfp
            targ = this.theImages_{1}.fileprefix;
            
            % maskForImages_
            if isempty(ipr.maskForImages)
                ipr.maskForImages = repmat({'none.4dfp.hdr'}, size(ipr.theImages));
            end
            this.maskForImages_ = this.saveAsFourdfp(ipr.maskForImages);
            
            % resolveTag_
            if isempty(ipr.resolveTag)
                ipr.resolveTag = strcat('op_', targ);
            end
            this.resolveTag_ = ipr.resolveTag;
            
            % blurArg_
            if isscalar(ipr.blurArg)
                ipr.blurArg = ipr.blurArg*ones(size(this.theImages_));
            end            
            this.blurArg_ = ipr.blurArg;            
            
            % etc
            this.imageRegLog = [targ '_imageReg.log'];
            this.resolveLog = [targ '_resolve.log'];
        end
        
        function this = resolve(this)
            pwd0 = pushd(this.workpath);
            fps = this.imageReg();
            this = this.resolveAndPaste(fps);
            this = this.writeJson();
            this = this.finalize();
            popd(pwd0);
        end
        function fps = imageReg(this)
            this.ensureFiles(this.theImages)
            this.ensureFiles(this.blurredImages)
            this.ensureFiles(this.maskForImages)
            len = length(this.theImages);
            fps = cellfun(@(x) x.fileprefix, this.theImages, 'UniformOutput', false);
            bfps = cellfun(@(x) x.fileprefix, this.blurredImages(), 'UniformOutput', false);
            mfps = cellfun(@(x) x.fileprefix, this.maskForImages, 'UniformOutput', false);
            for m = 1:len
                for n = 1:len
                    if (m ~= n)
                        t4 = this.buildVisitor.filenameT4(fps{n}, fps{m});
                        if (~this.valid_t4(t4))
                            this.buildVisitor.align_multiSpectral( ...
                                'dest',       bfps{m}, ...
                                'source',     bfps{n}, ...
                                'destMask',   mfps{m}, ...
                                'sourceMask', mfps{n}, ...
                                't4',         t4, ...
                                't4img_4dfp', false, ...
                                'log',        this.imageRegLog);
                        end
                        % t4_resolve requires an idiomatic naming convention for t4 files,
                        % based on the names of image files
                        % e. g., image1_to_image2_t4                            
                    end
                end
            end 
        end
        function ensureFiles(~, ics)
            for i = 1:length(ics)
                if ~isfile(ics{i}.fqfn)
                    assert(~isempty(ics{i}))
                    ics{i}.save()
                end
            end
        end
        function this = resolveAndPaste(this, fps)
            % Must use short fileprefixes in calls to t4_resolve to avoid filenaming error by t4_resolve.  E.g.:
            % t4_resolve: /data/nil-bluearc/raichle/PPGdata/jjlee2/HYGLY28/V1/FDG_V1-NAC/E8/fdgv1e8r1_frame1_to_/data/nil-bluearc/raichle/PPGdata/jjlee2/HYGLY28/V1/FDG_V1-NAC/E8/fdgv1e8r1_frame8_t4 read error
            
            [~,this.rec_] = this.buildVisitor.t4_resolve( ...
                this.resolveTag, cell2str(fps, 'AsRow', true), ...
                'options', '-v -m -s', 'log', this.resolveLog);
            this.t4imgAll(fps); % transform ipr.dest on this.resolveTag
        end
        function this = writeJson(this)
            for im = 2:length(this.theImages)
                try
                    j0 = fileread(strcat(this.theImages{im}.fqfp, ".json"));
                    j1 = this.cost_final();
                    jsonrecode(j0, j1, 'filenameNew', strcat(this.theImagesOp{im,1}.fqfp, ".json"));
                catch ME
                    handwarning(ME);
                end
            end            
        end
        function this = finalize(this)
            this.deleteFourdfp(this.maskForImages);
            this.deleteFourdfp(this.theImages);
            this.theImagesFinal_ = this.saveAsNifti(this.theImagesOp(:,1)); % op to theImages{1}
            this.theImagesFinal_{1} = this.theImages1_;
            this.deleteFourdfp(this.theImagesOp(:,1));
            this.logger.add(readtext(this.imageRegLog));
            this.logger.add(readtext(this.resolveLog));
            this.logger.save();
            movefile('*_t4', this.logger.filepath)
            movefile('*.mat0', this.logger.filepath)
            movefile('*.sub', this.logger.filepath)
            
            deleteExisting('*_imageReg.log');
            deleteExisting('*_resolve.log');
        end
    end     

    %% PROTECTED
    
    properties (Access = protected)
        blurArg_
        maskForImages_
        rec_ % rec entry from t4_resolve
        resolveTag_
        theImages_
        theImages1_
        theImagesFinal_
        theImagesOp_
        workpath_
    end
    
    methods (Access = protected)
        function b = blurredImages(this)
            b = cell(size(this.theImages));
            for ib = 1:length(b)
                b{ib} = this.theImages{ib}.blurred(this.blurArg(ib));
                if ~isfile(b{ib}.fqfilename)
                    b{ib}.save();
                end
            end
        end
        function j = cost_final(this)
            txt = readtext(this.resolveLog);
            rerr = regexp(txt, 'pairs total rotation error\s+(?<err>[\d.]+) \(rms deg\)', 'names');
            maskr = cell2mat(cellfun(@(x) ~isempty(x), rerr, 'UniformOutput', false));
            rerr = rerr(maskr);
            rerr = rerr{end};
            terr = regexp(txt, 'pairs total translation error\s+(?<err>[\d.]+) \(rms mm\)', 'names');
            maskt = cell2mat(cellfun(@(x) ~isempty(x), terr, 'UniformOutput', false));
            terr = terr(maskt);
            terr = terr{end};            
            
            s = struct('mlfourdfp_SimpleT4ResolveBuilder', ...
                  struct('cost_final', ...
                    struct( ...
                      'pairs_rotation_error', rerr, ...
                      'pairs_translation_error', terr)));
            j = jsonencode(s, 'PrettyPrint', true);
        end
        function carr = saveAsFourdfp(this, carr)
            %  Returns:
            %      carr (cell): of mlfourd.ImagingContext2, saved as 4dfp.
            
            if ~iscell(carr)
                carr = {carr};
            end
            carr = mlfourd.SimpleT4ResolveBuilder.imagingContext(carr);
            for idx = 1:length(carr)
                carr{idx}.selectFourdfpTool();
                carr{idx}.filepath = this.workpath;
                carr{idx}.save();
            end 
        end        
        function carr = saveAsNifti(this, carr)
            %  Returns:
            %      carr (cell): of mlfourd.ImagingContext2, saved as NIfTI.
            
            if ~iscell(carr)
                carr = {carr};
            end
            carr = mlfourd.SimpleT4ResolveBuilder.imagingContext(carr);
            for idx = 1:length(carr)
                if ~isempty(carr{idx})
                    carr{idx}.selectFourdfpTool();
                    ifc = carr{idx}.nifti();
                    ifc.filepath = this.workpath;
                    ifc.hdr = this.theImages1_.nifti.hdr; % bypasses faulty center coords of 4dfp
                    ifc.save();
                    carr{idx} = mlfourd.ImagingContext2(ifc);
                end
            end 
        end
        function this = t4imgAll(this, fps)
            tag = this.resolveTag;
            for f = 1:length(fps)
                fp = fps{f};
                if ~contains(tag, fp)
                    fp_out = sprintf('%s_%s', fp, tag);
                    this.buildVisitor.t4img_4dfp( ...
                        sprintf('%s_to_%s_t4', fp, tag), ...
                        fp, ...
                        'out', fp_out, ...
                        'options', ['-O' fps{1}]);                    
                    this.buildVisitor.imgrecUpdate(fp_out, this.rec_);                    
                end
            end
        end 
        function tf = valid_t4(~, t4)
            if ~isfile(t4)
                tf = false;
                return
            end
            d = dir(t4);
            if 0 == d.bytes
                tf = false;
                return
            end
            tf = true;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

