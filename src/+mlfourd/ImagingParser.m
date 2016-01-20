classdef ImagingParser
	%% IMAGINGPARSER parses persistent imaging objects.
    %  Imaging studies must already have been converted/extracted but imaging objects may have ambiguous names, variable imaging properties.
    %
	%  Version $Revision: 2608 $ was created $Date: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingParser.m $
 	%  Developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: ImagingParser.m 2608 2013-09-08 00:14:08Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
    
    properties (Dependent)
        adc
        asl
        c15o
        dwi
        ep2d
        ep2dMeanvol
        ir
        ir_abs
        fslPath
        gre
        h15o
        h15oMeanvol
        imageObjType
        o15o
        o15oMeanvol
        choosers
        t1
        t2
        tof
        tr
    end
    
	methods (Static) 
        function fname = formFilename(fname, varargin) 
            %% FORMFILENAME returns a canonical form for the passed filename and attributes 
            %  Usage:    canonical_filename = ...
            %                ImagingParser.formFilename(filename_pattern[, 'fq', complete_path, 'fp', 'betted', 'meanvol', ...])
            %            ^ e.g., /pathtofile/ep2d_020_mcf_meanvol.nii.gz
            %                                           ^ e.g., ep2d_020
            %                                                            ^  'fq' 'fp' 'fn' 'fqfp' 'fqfn'
            %                                                               'betted' 'motioncorrected' 'meanvol'
            %                                                               'fqfilename' requires complete path to be specified 
            %                                                               'average'    requires averaging type
            %                                                               'blur'       requires blur-label
            %                                                               'block'      requires block-label
            %                                                       '                            ^ 'fp', 'betted', ...
            
            import mlfourd.*;
            fname = imcast(fname, 'fqfilename');
            sname = struct('path', '', 'stem', '', 'ext', '');
            [sname.path,sname.stem,sname.ext] = filepartsx(fname, mlfourd.INIfTI.FILETYPE_EXT);
            varargin = cellfun(@ensureChar, varargin, 'UniformOutput', false);
            for k = 1:length(varargin) 
                sname = buildFilename(sname, varargin{k});
            end
            fname = fullfile(sname.path, [sname.stem sname.ext]);
            
            function sn = buildFilename(sn, arg)
                import mlfourd.* mlfsl.*;
                try                   
                    [~,sn.stem] = myfileparts(sn.stem);
                    switch (lower(arg))
                        case {'fq' 'fullqual' 'fullyqualified'}
                            sn      = makeFullyQualified(sn,k);
                        case {'fqfileprefix' 'fqfp'}
                            sn      = makeFullyQualified(sn,k);
                            sn.ext  = '';
                        case {'fqfilename' 'fqfn'}
                            sn      = makeFullyQualified(sn,k);
                            sn.ext  = INIfTI.FILETYPE_EXT;
                        case {'fp' 'fileprefix' 'fileprefixPattern'} 
                            sn.path = '';
                            sn.ext  = '';
                        case {'fn' 'filename'}                        
                            sn.path = '';
                        case {'bet' 'betted' 'brain' '_brain'}
                            sn.stem = fileprefix(BrainExtractionVisitor.bettedFilename(sn.stem));
                        case {'motioncorrect' 'motioncorrected' 'mcf' '_mcf'} 
                            sn.stem = [sn.stem FlirtVisitor.MCF_SUFFIX];
                        case {'meanvol' '_meanvol'} 
                            sn.stem = [sn.stem FlirtVisitor.MEANVOL_SUFFIX];
                        case {'block'   'blocked'}
                            sn.stem = [sn.stem '_' varargin{k+1}];
                        case {'blur'    'blurred'}
                            sn.stem = [sn.stem '_' varargin{k+1}];
                        case {'average' 'averaged' 'aver'}
                            sn.stem = [sn.stem '_' varargin{k+1}];
                        case {'*'}
                            sn.stem = [sn.stem '*'];
                        otherwise
                    end
                catch ME
                    handexcept(ME);
                end
            end
            function sname = makeFullyQualified(sname, kidx)
                if (exist('kidx','var') && ...
                        length(varargin) > kidx && ...
                            ischar(varargin{kidx+1}))
                    sname.path = varargin{kidx+1};
                end
            end % inner function
        end % static formFilename             
    end % static methods
    
    methods %% set/get 
        function this     = set.fslPath(this, pth)
            this.choosers_.fslPath = pth;
        end
        function pth      = get.fslPath(this)
            pth = this.choosers_.fslPath;
        end   
        function this = set.choosers(this, ch)
            assert(isa(ch, 'mlchoosers.ImagingChoosers'));
            this.choosers_ = ch;
        end
        function ch   = get.choosers(this)
            assert(isa(this.choosers_, 'mlchoosers.ImagingChoosers'))
            ch = this.choosers_;
        end
        function this = set.adc(this, obj)
            this.adc_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.adc(this)
            if (isempty(this.adc_))
                this.adc_ = this.choosers.choose_adc; end
            obj = this.adc_;
        end
        function this = set.asl(this, obj)
            if (isempty(this.asl_))
                this.asl_ = mlfourd.ImagingComponent.load(obj);
                return
            end
            this.asl_.add(imcast(obj, this.imageObjType));
        end
        function obj  = get.asl(this)
            if (isempty(this.asl_))
                this.asl_ = this.choosers.choose_asl; end
            obj = this.asl_;
        end
        function this = set.dwi(this, obj)
            this.dwi_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.dwi(this)
            if (isempty(this.dwi_))
                this.dwi_ = this.choosers.choose_dwi; end
            obj = this.dwi_;
        end
        function this = set.t1(this, obj)
            this.t1_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.t1(this)
            if (isempty(this.t1_))
                this.t1_ = this.choosers.choose_t1; end
            obj = this.t1_;
        end
        function this = set.t2(this, obj)
            this.t2_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.t2(this)
            if (isempty(this.t2_))
                this.t2_ = this.choosers.choose_t2; end
            obj = this.t2_;
        end
        function this = set.ir(this, obj)
            this.ir_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.ir(this)
            if (isempty(this.ir_))
                this.ir_ = this.choosers.choose_ir; end
            obj = this.ir_;
        end
        function this = set.ir_abs(this, obj)
            this.ir_abs_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.ir_abs(this)
            if (isempty(this.ir_abs_))
                this.ir_abs_ = this.choosers.choose_ir_abs; end
            obj = this.ir_abs_;
        end
        function this = set.gre(this, obj)
            this.gre_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.gre(this)
            if (isempty(this.gre_))
                this.gre_ = this.choosers.choose_gre; end
            obj = this.gre_;
        end
        function this = set.tof(this, obj)
            this.tof_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.tof(this)
            if (isempty(this.tof_))
                this.tof_ = this.choosers.choose_tof; end
            obj = this.tof_;
        end
        function this = set.ep2d(this, obj)
            this.ep2d_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.ep2d(this)
            if (isempty(this.ep2d_))
                this.ep2d_ = this.choosers.choose_ep2d; end
            obj = this.ep2d_;
        end
        function this = set.ep2dMeanvol(this, obj)
            this.ep2dMeanvol_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.ep2dMeanvol(this)
            if (isempty(this.ep2dMeanvol_))
                this.ep2dMeanvol_ = this.choosers.choose_ep2dMeanvol; end
            obj = this.ep2dMeanvol_;
        end
        function this = set.h15o(this, obj)
            this.h15o_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.h15o(this)
            if (isempty(this.h15o_))
                this.h15o_ = this.choosers.choose_h15o; end
            obj = this.h15o_;
        end
        function this = set.imageObjType(this, typ)
            assert(lstrfind(mlchoosers.ImagingChoosers.SUPPORTED_IMAGE_TYPES, typ)); 
            this.imageObjType_ = typ;
        end
        function typ  = get.imageObjType(this)
            assert(lstrfind(mlchoosers.ImagingChoosers.SUPPORTED_IMAGE_TYPES, this.imageObjType_)); % paranoia
            typ = this.imageObjType_;
        end
        function this = set.o15o(this, obj)
            this.o15o_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.o15o(this)
            if (isempty(this.o15o_))
                this.o15o_ = this.choosers.choose_o15o; end
            obj = this.o15o_;
        end        
        function this = set.h15oMeanvol(this, obj)
            this.h15oMeanvol_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.h15oMeanvol(this)
            if (isempty(this.h15oMeanvol_))
                this.h15oMeanvol_ = this.choosers.choose_h15oMeanvol; end
            obj = this.h15oMeanvol_;
        end
        function this = set.o15oMeanvol(this, obj)
            this.o15oMeanvol_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.o15oMeanvol(this)
            if (isempty(this.o15oMeanvol_))
                this.o15oMeanvol_ = this.choosers.choose_o15oMeanvol; end
            obj = this.o15oMeanvol_;
        end
        function this = set.c15o(this, obj)
            this.c15o_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.c15o(this)
            if (isempty(this.c15o_))
                this.c15o_ = this.choosers.choose_c15o; end
            obj = this.c15o_;
        end
        function this = set.tr(this, obj)
            this.tr_ = imcast(obj, this.imageObjType);
        end
        function obj  = get.tr(this)
            if (isempty(this.tr_))
                this.tr_ = this.choosers.choose_tr; end
            obj = this.tr_;
        end
    end
    
    methods 
        function p    = theInputParser(this, varargin)
            p = this.choosers.theInputParser(varargin{:});
        end
        function this = clearCache(this)
            this.t1_          = [];
            this.t2_          = [];
            this.ir_       = [];
            this.ir_abs_   = [];
            this.gre_         = [];
            this.tof_         = [];
            this.ep2d_        = [];
            this.ep2dMeanvol_ = [];
            this.h15o_        = [];
            this.o15o_        = [];
            this.h15oMeanvol_ = [];
            this.o15oMeanvol_ = [];
            this.c15o_        = [];
            this.tr_          = [];
        end 
    
 		function this = ImagingParser(fslpth)
 			%% IMAGINGPARSER 
 			%  Usage:  this = ImagingParser(fsl_path)

            assert(lexist(fslpth, 'dir'));
            this.choosers_    = mlchoosers.ImagingChoosers(fslpth);
            this.t1_          = this.choosers.choose_t1;
            this.t2_          = this.choosers.choose_t2;
            this.ir_          = this.choosers.choose_ir;
            this.ir_abs_      = this.choosers.choose_ir_abs;
            this.gre_         = this.choosers.choose_gre;
            this.tof_         = this.choosers.choose_tof;
            this.ep2d_        = this.choosers.choose_ep2d;
            this.ep2dMeanvol_ = this.choosers.choose_ep2dMeanvol;
            this.h15o_        = this.choosers.choose_h15o;
            this.o15o_        = this.choosers.choose_o15o;
            this.h15oMeanvol_ = this.choosers.choose_h15oMeanvol;
            this.o15oMeanvol_ = this.choosers.choose_o15oMeanvol;
            this.c15o_        = this.choosers.choose_c15o;
            this.tr_          = this.choosers.choose_tr;
 		end % ctor 
    end 
    
    %% PRIVATE
    
    properties (Access='private')
        choosers_
        adc_
        asl_
        dwi_
        t1_
        t2_
        ir_
        ir_abs_
        gre_
        tof_
        ep2d_
        ep2dMeanvol_
        h15o_
        imageObjType_ = 'fqfilename';
        o15o_
        h15oMeanvol_
        o15oMeanvol_
        c15o_
        tr_
 	end

 
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

