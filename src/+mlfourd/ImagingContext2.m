classdef ImagingContext2 < handle & matlab.mixin.Copyable & mlio.HandleIOInterface
	%% ImagingContext2 is the context and AbstractImagingTool is the state forming a state design pattern for imaging
    %  tools.  It's intent is to improve the expressivity of tools for imaging objects, much as state-dependent tools
    %  for editing graphical objects improve expressivity of grpahics workflows.  See also AbstactImagingTool.
    
	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingContext2.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a).  Copyright 2017 John Joowon Lee.
 	%  $Id: ImagingContext2.m 2627 2013-09-16 06:18:10Z jjlee $ 
    
    properties (Constant)
        IMAGING_TYPES  = { ...
            'ext' ...
            'fileprefix' 'filename' 'fqfileprefix' 'fqfilename' 'fp' 'fn' 'fqfp' 'fqfn' ...
            'ImagingContext2' 'mlfourd.ImagingContext2' ...
            'mgh' 'mgz' ...
            'nii' 'nii.gz' ...
            'v' 'v.hdr' 'v.mhdr' 'mhdr' ...
            '4dfp.hdr' '4dfp.ifh' '4dfp.img' '4dfp.img.rec' ...
            '.4dfp.hdr' '.4dfp.ifh' '.4dfp.img' '.4dfp.img.rec' ...
            'folder' 'path' 'double' 'single'}
    end
    
    properties 
        verbosity = 0;
    end
    
	properties (Dependent)
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp
        noclobber
        
        imagingInfo
        imgrec
        innerTypeclass
        logger
        viewer
        
        stateTypeclass
    end
    
    methods (Static)
        function this = fread(varargin)
            ip = inputParser;
            addRequired(ip, 'filename', @isfile)
            addOptional(ip, 'size', [], @isnumeric)
            addOptional(ip, 'precision', 'single', @ischar)
            addParameter(ip, 'hdr', [], @isstruct)
            addParameter(ip, 'format', 'luckett', @ischar) 
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            fid = fopen(ipr.filename, 'r');            
            img = single(fread(fid, ipr.precision));
            fclose(fid);
            
            hk = {348; ''; ''; 0; 0; 'r'; 0};
            hkHeadings = {'sizeof_hdr', 'data_type', 'db_name', 'extents', 'session_error', 'regular', 'dim_info'};
            dime = {[3 48 64 48 1 1 1 1]; ...
                     0; 0 ;0; 0; 16; ...
                     32; 0; [1 3 3 3 1 1 1 1]; 352; 0; ...
                     0; 0; 0; 10; 0; ...
                     0; 0; 0; 3649; 0};
            dimeHeadings = {'dim', ...
                            'intent_p1', 'intent_p2', 'intent_p3', 'intent_code', 'datatype', ...
                            'bitpix', 'slice_start', 'pixdim', 'vox_offset', 'scl_slope', ...
                            'scl_inter', 'slice_end', 'slice_code', 'xyzt_units', 'cal_max', ...
                            'cal_min', 'slice_duration', 'toffset', 'glmax', 'glmin'};
            hist = {''; ''; 0; 1; 0; ...
                    0; 0; -71; -95; -71; ...
                    [3 0 0 -71]; [0 3 0 -95]; [0 0 3 -71]; ''; 'n+1'; ...
                    [72 96 72]};
            histHeadings = {'descrip', 'aux_file', 'qform_code', 'sform_code', 'quatern_b', ...
                            'quatern_c', 'quatern_d', 'qoffset_x', 'qoffset_y', 'qoffset_z', ...
                            'srow_x', 'srow_y', 'srow_z', 'intent_name', 'magic', ... 
                            'originator'};
            extra = { ...
                'DT_FLOAT32'; 'NIFTI_INTENT_NONE'; ''; 'NIFTI_XFORM_SCANNER_ANAT'; 'NIFTI_XFORM_UNKNOWN'; ...
                'NIFTI_UNITS_MM'; 'NIFTI_UNITS_SEC'; 'NIFTI_UNITS_UNKNOWN'; 0; 0; ...
                0; 'NIFTI_SLICE_UNKNOWN'; 0; 0; 0};
            extraHeadings = { ...
                'NIFTI_DATATYPES', 'NIFTI_INTENT_CODES', 'NIFTI_INTENT_NAMES', 'NIFTI_SFORM_CODES', 'NIFTI_QFORM_CODES', ...
                'NIFTI_SPACE_UNIT', 'NIFTI_TIME_UNIT', 'NIFTI_SPECTRAL_UNIT', 'NIFTI_FREQ_DIM', 'NIFTI_PHASE_DIM', ...
                'NIFTI_SLICE_DIM', 'NIFTI_SLICE_ORDER', 'NIFTI_VERSION', 'NIFTI_ONEFILE', 'NIFTI_5TH_DIM'};

            switch numel(img)
                case 48*64*48
                    img = reshape(img, [48 64 48]);
                    ipr.hdr = struct( ...
                        'hk', cell2struct(hk, hkHeadings, 1), ...
                        'dime', cell2struct(dime, dimeHeadings, 1), ...
                        'hist', cell2struct(hist, histHeadings, 1), ...
                        'extra', cell2struct(extra, extraHeadings, 1));
                case 128*128*75
                    img = reshape(img, [128 128 75]);
                case 176*208*176
                    img = reshape(img, [176 208 176]);
                case 256*256*256
                    img = reshape(img, [256 256 256]);
                otherwise
            end

            ifc = mlfourd.ImagingFormatContext(img);
            [p,f] = myfileparts(ipr.filename);
            switch ipr.format
                case 'nifti'
                    ipr.filename = fullfile(p, [f '.nii.gz']);
                case 'fourdfp'
                    ipr.filename = fullfile(p, [f '.4dfp.hdr']);
                case 'luckett'
                    ifc.img = flip(ifc.img, 2);
                    ipr.filename = fullfile(p, [f '.4dfp.hdr']);
                case 'mgz'
                    ipr.filename = fullfile(p, [f '.mgz']);
                otherwise
                    error('mlfourd:ValueError', 'ImagingContext2.fread() does not support format %s', ipr.format)
            end
            ifc.filename = ipr.filename;
            if ~isempty(ipr.hdr)
                ifc.hdr = ipr.hdr;
            end
            this = mlfourd.ImagingContext2(ifc);
        end
        
        %% For use in static workspaces (e.g., while debugging static functions)
        
        function this = static_fsleyes(varargin)
            this = mlfourd.ImagingContext2(varargin{:});
            this.fsleyes;
        end
        function this = static_fslview(varargin)
            this = mlfourd.ImagingContext2(varargin{:});
            this.fslview;
        end
        function this = static_freeview(varargin)
            this = mlfourd.ImagingContext2(varargin{:});
            this.freeview;
        end
        
        %% Typeclass utilities
        
        function im   = imagingType(typ, obj)
            %% IMAGINGTYPE returns imaging data cast as a requested representative type detailed below.
            %  @param typ is the requested representation:  'filename', 'fn', fqfilename', 'fqfn', 'fileprefix', 'fp',
            %  'fqfileprefix', 'fqfp', 'folder', 'path', 'ext', 'ImagingContext2', 
            %  '4dfp.hdr', '4dfp.ifh', '4dfp.img', '4dfp.img.rec', 'v', 'v.hdr', 'v.mhdr'. 
            %  @param obj is the representation of imaging data provided by the client.  
            %  @returns im is the imaging data obj cast as the requested representation.
            %  See also mlfourd.ImagingContext2
            
            import mlfourd.*;
            if ischar(obj) && isfolder(obj)
                im = ImagingContext2.locationType(typ, obj);
                return
            end
            
            obj = ImagingContext2(obj);
            switch typ
                case {'4dfp.hdr' '.4dfp.hdr'}
                    im = [obj.fqfileprefix '.4dfp.hdr'];
                case {'4dfp.ifh' '.4dfp.ifh'}
                    im = [obj.fqfileprefix '.4dfp.ifh'];
                case {'4dfp.img' '.4dfp.img'}
                    im = [obj.fqfileprefix '.4dfp.img'];
                case {'4dfp.img.rec' '.4dfp.img.rec'}
                    im = [obj.fqfileprefix '.4dfp.img.rec'];
                case  'ext'
                    [~,~,im] = myfileparts(obj.filename);
                case  'folder'
                    [~,im] = fileparts(obj.filepath);
                case {'filepath' 'path'}
                    im = obj.filepath;
                case {'fileprefix' 'fp'}
                    im = obj.fileprefix;
                case {'filename' 'fn'}
                    im = obj.filename;
                case {'fourdfp' 'Fourdfp' 'mlfourdfp.Fourdfp'}
                    im = obj.fourdfp;
                case {'fqfilename' 'fqfn'}
                    im = obj.fqfilename;
                case {'fqfileprefix' 'fqfp' 'fdfp' '4dfp'}
                    im = obj.fqfileprefix;                  
                case {'ImagingContext2' 'mlfourd.ImagingContext2'}
                    im = mlfourd.ImagingContext2(obj);
                case {'ImagingFormatContext' 'mlfourd.ImagingFormatContext'}
                    im = mlfourd.ImagingFormatContext(obj);
                case {'mgz' '.mgz'}
                    im = [obj.fqfileprefix '.mgz'];
                case {'mhdr' '.mhdr'}
                    im = [obj.fqfileprefix '.mhdr'];                  
                case {'nii' '.nii'}
                    im = [obj.fqfileprefix '.nii'];
                case {'nii.gz' '.nii.gz'}
                    im = [obj.fqfileprefix '.nii.gz'];
                case {'mgh' 'MGH' 'mlsurfer.MGH'}
                    im = obj.mgh;
                case {'nifti' 'NIfTI'}
                    im = obj.nifti;
                case {'niftid' 'NIfTId' 'mlfourd.NIfTId'}
                    im = obj.niftid;
                case {'numericalNiftid' 'NumericalNIfTId' 'mlfourd.NumericalNIfTId'}
                    im = obj.numericalNiftid;
                case {'v' '.v'}
                    im = [obj.fqfileprefix '.v'];
                case {'v.hdr' '.v.hdr'}
                    im = [obj.fqfileprefix '.v.hdr'];
                case {'v.mhdr' '.v.mhdr'}
                    im = [obj.fqfileprefix '.v.mhdr'];
                case 'double'
                    if contains(obj.filesuffix, '4dfp')
                        im = double(obj.fourdfp.img);
                    elseif contains(obj.filesuffix, 'mgh')
                        im = double(obj.mgh.img);
                    elseif contains(obj.filesuffix, 'mgz')
                        im = double(obj.mgz.img);
                    else
                        im = double(obj.nifti.img);
                    end
                case 'single'
                    if contains(obj.filesuffix, '4dfp')
                        im = single(obj.fourdfp.img);
                    elseif contains(obj.filesuffix, 'mgh')
                        im = single(obj.mgh.img);
                    elseif contains(obj.filesuffix, 'mgz')
                        im = single(obj.mgz.img);
                    else
                        im = single(obj.nifti.img);
                    end
                otherwise
                    error('mlfourd:insufficientSwitchCases', ...
                          'ImagingContext2.imagingType.obj->%s not recognized', obj);
            end
        end
        function tf   = isImagingType(t)
            tf = lstrcmp(t, mlfourd.ImagingContext2.IMAGING_TYPES);
        end
        function tf   = isLocationType(t)
            tf = lstrcmp(t, {'folder' 'path'});
        end
        function loc  = locationType(typ, loc0)
            %% LOCATIONTYPE returns location data cast as a requested representative type detailed below.
            %  @param typ is the requested representation:  'folder', 'path'.
            %  @param loc0 is the representation of location data provided by the client.  
            %  @returns loc is the location data loc0 cast as the requested representation.
            
            assert(ischar(loc0));
            switch typ
                case 'folder'
                    loc = mybasename(loc0);
                case 'path'
                    loc = loc0;
                otherwise
                    error('mlfourd:insufficientSwitchCases', ...
                          'ImagingContext2.locationType.loc0->%s not recognized', loc0);
            end
        end
    end
    
	methods
        
        %% GET/SET
        
        function f = get.filename(this)
            f = this.state_.filename;
        end
        function f = get.filepath(this)
            f = this.state_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.state_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.state_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.state_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.state_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.state_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.state_.fqfp;
        end
        function g = get.imagingInfo(this)
            g = this.state_.imagingInfo;
        end
        function f = get.imgrec(this)
            f = this.state_.imgrec;
        end
        function g = get.innerTypeclass(this)
            g = this.state_.innerTypeclass;
        end 
        function f = get.logger(this)
            f = this.state_.logger;
        end
        function f = get.noclobber(this)
            f = this.state_.noclobber;
        end
        function c = get.stateTypeclass(this)
            c = class(this.state_);
        end
        function v = get.viewer(this)
            v = this.state_.viewer;
        end
        
        function set.filename(this, f)
            this.selectImagingFormatTool();
            this.state_.filename = f;
        end
        function set.filepath(this, f)
            this.selectImagingFormatTool();
            this.state_.filepath = f;
        end        
        function set.fileprefix(this, f)
            this.selectImagingFormatTool();
            this.state_.fileprefix = f;
        end        
        function set.filesuffix(this, f)
            this.selectImagingFormatTool();
            this.state_.filesuffix = f;
        end        
        function set.fqfilename(this, f)
            this.selectImagingFormatTool();
            this.state_.fqfilename = f;
        end        
        function set.fqfileprefix(this, f)
            this.selectImagingFormatTool();
            this.state_.fqfileprefix = f;
        end        
        function set.fqfn(this, f)
            this.selectImagingFormatTool();
            this.state_.fqfn = f;
        end        
        function set.fqfp(this, f)
            this.selectImagingFormatTool();
            this.state_.fqfp = f;
        end
        function set.noclobber(this, f)
            this.state_.noclobber = f;
        end        
        function set.viewer(this, v)
            assert(ischar(v));
            this.state_.viewer = v;
        end
        
        %% various casting of mlfourd.ImagingFormatContext
        
        function ifc = fourdfp(this)
            this.selectImagingFormatTool;
            ifc = this.state_.fourdfp;
        end
        function ifc = mgh(this)
            this.selectImagingFormatTool;
            ifc = this.mgz;
        end
        function ifc = mgz(this)
            this.selectImagingFormatTool;
            ifc = this.state_.mgz;
        end
        function ifc = nifti(this)
            this.selectImagingFormatTool;
            ifc = this.state_.nifti;
        end
        
        %% select states
        
        function this = selectBlurringTool(this)
            this.state_.selectBlurringTool(this);
        end
        function this = selectDynamicsTool(this)
            this.state_.selectDynamicsTool(this);
        end
        function this = selectFilesystemTool(this)
            this.state_.selectFilesystemTool(this);
        end
        function this = selectFourdfp(this)
            %% mutates state to be 4dfp

            that = mlfourd.ImagingContext2(this.fourdfp);
            this.state_ = copy(that.state_);
            this.addLog('mlfourd.ImagingContext2.selectFourdfp mutated state')
        end
        function this = selectIsNumericTool(this)
            this.state_.selectIsNumericTool(this);
        end
        function this = selectImagingFormatTool(this)
            this.state_.selectImagingFormatTool(this);
        end
        function this = selectMaskingTool(this)
            this.state_.selectMaskingTool(this);
        end
        function this = selectMgh(this)
            %% mutates state to be mgh
            
            that = mlfourd.ImagingContext2(this.mgh);
            this.state_ = copy(that.state_);
            this.addLog('mlfourd.ImagingContext2.selectMgh mutated state')
        end
        function this = selectMgz(this)
            %% mutates state to be mgz
            
            that = mlfourd.ImagingContext2(this.mgz);
            this.state_ = copy(that.state_);
            this.addLog('mlfourd.ImagingContext2.selectMgz mutated state')
        end
        function this = selectNifti(this)
            %% mutates state to be NIfTI
            
            that = mlfourd.ImagingContext2(this.nifti);
            this.state_ = copy(that.state_);
            this.addLog('mlfourd.ImagingContext2.selectNifti mutated state')
        end
        function this = selectNumericalTool(this)
            this.state_.selectNumericalTool(this);
        end
        function this = selectRegistrationTool(this)
            this.state_.selectRegistrationTool(this);
        end    
        
        %% mlpatterns.HandleNumerical
        
        function that = abs(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.abs;
        end
        function that = acos(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.acos(b);            
        end
        function that = acosh(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.acosh();            
        end
        function that = asin(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.asin(b);            
        end
        function that = asinh(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.asinh();            
        end
        function that = atan(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.atan(b);            
        end
        function that = atan2(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.atan2(b);            
        end
        function that = atanh(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.atanh();            
        end
        function that = cos(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.cos();            
        end
        function that = cosh(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.cosh();            
        end
        function that = bsxfun(this, pfun, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.bsxfun(pfun, b);
        end   
        function that = dice(this, b, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.dice(b, varargin{:});
        end
        function that = exp(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.exp();            
        end
        function that = flip(this, adim)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.flip(adim);            
        end
        function that = rdivide(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.rdivide(b);
        end
        function that = ldivide(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.ldivide(b);
        end        
        function that = hypot(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.hypot(b);
        end              
        function that = jsdiv(this, b, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.jsdiv(b, varargin{:});
        end
        function that = kldiv(this, b, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.kldiv(b, varargin{:});
        end            
        function that = log(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.log();            
        end
        function that = log10(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.log10();            
        end
        function that = max(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.max(b);
        end
        function that = min(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.min(b);
        end
        function that = minus(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.minus(varargin{:});
        end
        function that = mod(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.mod(b);
        end
        function that = mpower(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.mpower(b);
        end
        function that = mldivide(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.mldivide(b); 
        end
        function that = mrdivide(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.mrdivide(b);         
        end
        function that = mtimes(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.mtimes(b); 
        end
        function that = plus(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.plus(b);
        end
        function that = power(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.power(b);
        end
        function that = rem(this, b)
            %% remainder after division
            
            this.selectNumericalTool;
            that = copy(this);
            that.state_.rem(b);
        end
        function that = sin(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.sin();            
        end
        function that = sinh(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.sinh();            
        end
        function that = sum(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.sum(varargin{:});            
        end
        function that = tan(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.tan();            
        end
        function that = tanh(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.tanh();            
        end
        function that = times(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.times(b);
        end
        function that = ctranspose(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.ctranspose;
        end
        function that = transpose(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.transpose;
        end        
        function that = uminus(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.uminus();
        end
        function that = usxfun(this, pfun)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.usxfun(pfun);
        end        
        
        function that = numeq(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.eq(b);
        end
        function that = numne(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.ne(b);
        end
        function that = numlt(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.lt(b);
        end
        function that = numle(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.le(b);
        end
        function that = numgt(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.gt(b);
        end
        function that = numge(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.ge(b);
        end
        function that = and(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.and(b);
        end
        function that = isequal(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.isequal(b);
        end
        function that = isequaln(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.isequaln(b);
        end
        function that = isfinite(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.isfinite;
        end
        function that = isinf(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.isinf;
        end
        function that = isnan(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.isnan;
        end
        function that = or(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.or(b);
        end
        function that = xor(this, b)
            that = copy(this);
            that.state_.xor(b);
        end
        function that = not(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.not;
        end        
        
        
        function that = false(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.false(varargin{:});
        end
        function that = find(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.find(varargin{:});
        end
        function that = nan(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_ = this.state_.nan(varargin{:});
        end
        function that = ones(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.ones(varargin{:});
        end
        function that = reshape(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.reshape(varargin{:});
        end
        function that = scrubNanInf(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.scrubNanInf;
        end
        function that = true(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.true(varargin{:});
        end
        function that = zeros(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.zeros(varargin{:});
        end
        
        %% mlpatterns.HandleDipNumerical
         
        function d = dipiqr(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipiqr;
        end
        function d = dipisfinite(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipisfinite;
        end
        function d = dipisinf(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipisinf;
        end
        function d = dipisnan(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipisnan;
        end
        function d = dipisreal(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipisreal;
        end
        function d = diplogprod(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.diplogprod;
        end
        function d = dipmad(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmad;
        end        
        function d = dipmax(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmax;
        end
        function d = dipmean(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmean;
        end
        function d = dipmedian(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmedian;
        end
        function d = dipmin(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmin;
        end
        function d = dipmode(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmode;
        end
        function d = dipprctile(this, b)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipprctile(b);
        end
        function d = dipprod(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipprod;
        end
        function d = dipquantile(this, b)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipquantile(b);
        end
        function d = dipstd(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipstd;
        end
        function d = dipsum(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipsum;
        end
        function d = diptrimmean(this, b)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.diptrimmean(b);
        end
        
        %% BlurringTool
        
        function that = blurred(this, varargin)
            %% BLURRED
            %  @param fwhh specifies an isotropic Gaussian blurring.
            %  @param [fwhh_x fwhh_y fwhh_z] \in \mathbb{R}^3 specifies an anisotropic Gaussian blurring.
            %  @return the blurred image
            %  @return this if varargin{1} is empty || varargin{1} == 0.
            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            if (varargin{1} < eps);    that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.blurred(varargin{:});
        end 
        function that = bwskel(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.bwskel(varargin{:});
        end
        function that = bwperim(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.bwperim(varargin{:});
        end 
        function that = imbothat(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imbothat(varargin{:});
        end 
        function that = imclose(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imclose(varargin{:});
        end 
        function that = imdilate(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imdilate(varargin{:});
        end 
        function that = imerode(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imerode(varargin{:});
        end 
        function that = imopen(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imopen(varargin{:});
        end 
        function that = imtophat(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imtophat(varargin{:});
        end 
        
        %% DynamicsTool
        
        function that = corrcoef(this, varargin)
            %% CORRCOEF finds the corrcoef for time-series.
            %  @param mask is interpretable by the ctor and is 3D;
            %         default := fullfil(getenv(), 'gm3d.nii.gz').
            %  @param rsn_labels is interpretable by the ctor and is 3D; 
            %         default := fullfile(getenv('REFDIR'), 'Yeo2011_7Networks_333.nii.gz').
            %  See also imagesc.
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.corrcoef(varargin{:});
        end
        function that = coeffvar(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.coeffvar(varargin{:});
        end
        function that = del2(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.del2(varargin{:});
        end
        function that = diff(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.diff(varargin{:});
        end
        function that = gradient(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.gradient(varargin{:});
        end
        function that = interp1(this, varargin)
            %% MAKIMA
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.interp1(varargin{:});
        end
        function that = makima(this, varargin)
            %% MAKIMA
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.makima(varargin{:});
        end
        function that = mean(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.mean(varargin{:});
        end
        function that = median(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.median(varargin{:});
        end
        function that = mode(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.mode(varargin{:});
        end
        function that = pchip(this, varargin)
            %% PCHIP
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.pchip(varargin{:});
        end
        function that = Q(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.Q(varargin{:});
        end
        function that = std(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.std(varargin{:});
        end        
        function that = timeAveraged(this, varargin)
            %% TIMEAVERAGED
            %  @param optional closed interval T \in {\Bbb R}.
            %  @return ic := \int_T \text{this.state\_}(t) / \int_T.
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.timeAveraged(varargin{:});
        end
        function that = timeContracted(this, varargin)
            %% TIMECONTRACTED
            %  @param optional closed interval T \in {\Bbb R}.
            %  @return ic := \int_T this.state_(t).
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.timeContracted(varargin{:});
        end
        function [times,that] = timeShifted(this, times, Dt)
            %% TIMESHIFTED
            %  @param required times is numeric, possibly nonuniform.
            %  @param required Dt is scalar.
            %  @return times & copy(this) shifted forwards (Dt > 0) or backwards (Dt < 0) in time.
            
            this.selectDynamicsTool;
            that = copy(this);
            [times,that] = that.state_.timeShifted(times, Dt);
        end
        function that = timeSummed(this, varargin)
            %% TIMESUMMED 
            %  @param optional closed interval T \in {\Bbb R}.
            %  @return ic := \int_T \text{this.state\_}(t).
            
            that = this.timeContracted(varargin{:});
        end
        function that = var(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.var(varargin{:});
        end
        function that = volumeAveraged(this, varargin)
            %% VOLUMEAVERAGED
            %  @param optional mask specifies some closed \Omega \in {\Bbb R}^3.
            %  @return that := \int_{\Omega} \text{this.state\_} (\text{mask}, t) / \int_{\Omega} \text{mask}.
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.volumeAveraged(varargin{:});
        end
        function that = volumeContracted(this, varargin)
            %% VOLUMECONTRACTED
            %  @param optional mask specifies some closed \Omega \in {\Bbb R}^3.
            %  @return that := \int_{\Omega} \text{this.state\_} (\text{mask}, t).
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.volumeContracted(varargin{:});
        end
        function that = volumeSummed(this, varargin)
            %% VOLUMESUMMED 
            %  @param optional mask specifies some closed \Omega \in {\Bbb R}^3.
            %  @return that := \int_{\Omega} \text{this.state\_} (\text{mask}, t).
            
            that = this.volumeContracted(varargin{:});
        end
        
        %% MaskingTool
        
        function that = binarized(this)
            %% BINARIZED
            %  @return internal image is binary: values are only 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.binarized;
        end
        function that = binarizeBlended(this, varargin)
            %% BINARIZEBLENDED
            %  @return internal image is binary: values are only 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.binarized;
            that.selectBlurringTool;
            that.state_.blurred(varargin{:});
        end
        function c    = count(this)
            this.selectMaskingTool;
            c = this.state_.count;
        end
        function that = imfill(this, varargin)
            %% IMFILL binarizes, then calls Matlab's imfill.

            this.selectMaskingTool;
            that = copy(this);
            that.state_.imfill(varargin{:});
        end
        function that = maskBlended(this, varargin)
            this.selectMaskingTool;
            that = copy(this);
            that.state_.maskBlended(varargin{:});
        end
        function that = masked(this, varargin)
            %% MASKED
            %  @param INIfTI of a mask with values [0 1], not required to be binary.
            %  @return internal image is masked.
            %  @warning mflourd:possibleMaskingError
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.masked(varargin{:});
        end
        function that = maskedMaths(this, varargin)
            %% MASKEDMATHS
            %  @param INIfTI of a mask with values [0 1], not required to be binary.
            %  @return internal image is masked.
            %  @warning mflourd:possibleMaskingError
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.maskedMaths(varargin{:});
        end
        function that = maskedByZ(this, varargin)
            %% MASKEDBYZ
            %  @param rng = [low-z high-z], typically equivalent to [inferior superior];
            %  @return internal image is cropped by rng.  
            %  @throws MATLAB:assertion:failed for rng out of bounds.
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.maskedByZ(varargin{:});
        end
        function that = msktgen(this, varargin)
            this.selectMaskingTool;
            that = copy(this);
            that.state_.msktgen(varargin{:});
        end
        function that = roi(this, varargin)
            that = this.zoomed(varargin{:});
        end
        function that = thresh(this, varargin)
            %% THRESH
            %  @param t:  use t to threshold current image (zero anything below the number)
            %  @return t, the modified imaging context
            %  @return copy(this) if t == 0 or t is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.thresh(varargin{:});
        end
        function that = threshp(this, varargin)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            %  @returns p, the modified imaging context
            %  @return copy(this) if p == 0 or p is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.threshp(varargin{:});
        end
        function that = uthresh(this, varargin)
            %% UTHRESH
            %  @param u:  use u to upper-threshold current image (zero anything above the number)
            %  @returns u, the modified imaging context
            %  @return copy(this) if u == 0 or u is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.uthresh(varargin{:});
        end
        function that = uthreshp(this, varargin)
            %% UTHRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything above the number)
            %  @returns p, the modified imaging context
            %  @return copy(this) if u == 0 or u is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.uthreshp(varargin{:});
        end        
        function that = zoomed(this, varargin)
            %% ZOOMED parameters resembles fslroi, but indexing starts with 1 and passing -1 for a size will set it to 
            %  the full image extent for that dimension.
            %  @param xmin|fac is required.  Solitary fac symmetrically sets Euclidean (not time) size := fac*size and
            %                                symmetrically sets all min.
            %  @param xsize is optional.
            %  @param ymin  is optional.
            %  @param ysize is optional.
            %  @param zmin  is optional.
            %  @param zsize is optional.
            %  @param tmin  is optional.  Solitary tmin with tsize is supported.
            %  @param tsize is optional.
            %  @returns copy(this)
            
            %error('mlfourd:IncompleteImplementationError', 'ImagingContext2.zoomed');
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.zoomed(varargin{:});
        end
        
        %% mfourdfp.RegistrationTool
        
        %% mlfourd.ImagingFormatTool
        
        function this = addImgrec(this, varargin)
            this.selectImagingFormatTool;
            this.state_.addImgrec(varargin{:});
        end
        function this = addLog(this, varargin)
            %% ADDLOG
            %  @param varargin are log entries for the imaging state
            
            if ~isempty(this.state_.logger)
                this.state_.logger.add(varargin{:});
            end
        end
        function this = addLogNoEcho(this, varargin)
            %% ADDLOGNOECHO
            %  @param varargin are log entries for the imaging state
            
            if ~isempty(this.state_.logger)
                this.state_.logger.addNoEcho(varargin{:});
            end
        end  
        function c    = char(this)
            this.selectImagingFormatTool;
            c = this.state_.char;
        end
        function d    = double(this)
            this.selectImagingFormatTool;
            d = this.state_.double;
        end
        function        ensureDouble(this)
            this.selectImagingFormatTool;
            this.state_.ensureDouble;
        end
        function        ensureSaved(this)
            %% ENSURESAVED saves the imaging state as this.fqfilename on the filesystem if not already saved.
            
            if (~lexist(this.fqfilename))
                this.save;
            end
        end
        function        ensureSingle(this)
            this.selectImagingFormatTool;
            this.state_.ensureSingle;
        end
        function        export(this, varargin)
            this.selectImagingFormatTool;
            this.state_.export(varargin{:});
        end
        function        freeview(this, varargin)
            this.selectImagingFormatTool;
            this.state_.freeview(varargin{:});
        end
        function        fslview(this, varargin)
            this.selectImagingFormatTool;
            this.state_.fslview(varargin{:});
        end
        function        fsleyes(this, varargin)
            this.selectImagingFormatTool;
            this.state_.fsleyes(varargin{:});
        end
        function        hist(this, varargin)
            this.selectImagingFormatTool;
            this.state_.hist(varargin{:});
        end
        function h    = histogram(this, varargin)
            this.selectImagingFormatTool;
            h = this.state_.histogram(varargin{:});
        end
        function h    = imagesc(this, varargin)
            this.selectImagingFormatTool;
            h = this.state_.imagesc(varargin{:});
        end
        function tf   = isempty(this)
            %% ISEMPTY
            %  @return tf is boolean for state emptiness
            
            this.selectImagingFormatTool;
            tf = this.state_.isempty;
        end
        function l    = length(this)
            %% LENGTH
            %  @return l is the length of a composite imaging state
            
            this.selectImagingFormatTool;
            l = this.state_.length;
        end
        function l    = logical(this)
            this.selectImagingFormatTool;
            l = this.state_.logical;
        end
        function s    = mat2str(this, varargin)
            this.selectImagingFormatTool;
            s = this.state_.mat2str(varargin{:});
        end
        function n    = ndims(this)
            this.selectImagingFormatTool;
            n = this.state_.ndims;
        end
        function n    = numel(this)
            this.selectImagingFormatTool;
            n = this.state_.numel;
        end        
        function p    = pointCloud(this, varargin)
            ip = inputParser;
            addParameter(ip, 'thresh', [], @isscalar)
            addParameter(ip, 'uthresh', [], @isscalar)
            addParameter(ip, 'threshp', [], @isscalar)
            addParameter(ip, 'uthreshp', [], @isscalar)
            parse(ip, varargin{:})
            ipr = ip.Results;            
            if ~isempty(ipr.thresh)
                this = this.thresh(ipr.thresh);
            end
            if ~isempty(ipr.uthresh)
                this = this.uthresh(ipr.uthresh);
            end
            if ~isempty(ipr.threshp)
                this = this.threshp(ipr.threshp);
            end
            if ~isempty(ipr.uthreshp)
                this = this.uthreshp(ipr.uthreshp);
            end
            
            this.selectImagingFormatTool;
            p = this.state_.pointCloud;
        end
        function r    = rank(this)
            %% DEPRECATED; use ndims.
            
            this.selectImagingFormatTool;
            r = this.ndims;
        end
        function        save(this)
            %% SAVE saves the imaging state as this.fqfilename on the filesystem.
            
            this.selectImagingFormatTool;
            this.state_.save;
        end
        function this = saveas(this, varargin)
            %% SAVEAS saves the imaging state as this.fqfilename on the filesystem.
            %  @param filename is a string that is compatible with requirements of the filesystem;
            %  @return this for compatibility with non-handle interfaces.
            %  it replaces internal filename & filesystem information.

            this.selectImagingFormatTool;
            this.state_ = this.state_.saveas(varargin{:});
        end   
        function s    = single(this)
            this.selectImagingFormatTool;
            s = this.state_.single;
        end  
        function s    = size(this, varargin)
            s = this.state_.size(varargin{:});
        end 
        function tf   = sizeEq(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for equal size

            this.selectImagingFormatTool;
            tf = this.state_.sizeEq(ic);
        end
        function tf   = sizeGt(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for > size

            this.selectImagingFormatTool;
            tf = this.state_.sizeGt(ic);
        end
        function tf   = sizeLt(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for < size

            this.selectImagingFormatTool;
            tf = this.state_.sizeLt(ic);
        end
        function this = updateImagingFormatTool(this, u)
            %  first call {fourdfp,mgz,nifti}, make adjustments, then call updateImagingFormatTool for fine-grained aufbau.
            %  @param u is mlfourd.ImagingFormatContext.
            
            this.selectImagingFormatTool;
            this.state_.updateInnerImaging(u);
        end
        function        view(this, varargin)
            %% VIEW
            %  @param are additional filenames and other arguments to pass to the viewer, 
            %  which will be saved to the filesystem as needed.
            %  @return new window with a view of the imaging state
            
            this.selectImagingFormatTool;
            this.state_.view(varargin{:});
        end
        
        %%
        
        function this = ImagingContext2(obj, varargin)
            %% ImagingContext2 
            %  @param obj is imaging data:  ImagingContext2, ImagingContext, char, data supported by ImagingFormatTool.
            %  @return initialized context for a state design pattern.  
            
            import mlfourd.*;
            if 0 == nargin % must support empty ctor
                this.state_ = ImagingFormatTool(this);
                return
            end
            if isa(obj, 'mlfourd.ImagingContext2')
                this = copy(obj);
                return
            end            
            if ischar(obj)
                this.state_ = FilesystemTool(this, obj);
                return
            end
            if islogical(obj)
                obj = single(obj);
            end
            if ~isdeployed
                if isa(obj, 'mlfourd.ImagingContext') % legacy objects
                    this.state_ = ImagingFormatTool(this, struct(obj.niftid), varargin{:});
                    return
                end
            end
            this.state_ = ImagingFormatTool(this, obj, varargin{:});
        end
        function that = clone(this)
            that = copy(this);
        end
    end  
    
    %% PROTECTED
    
    properties (Access = protected)
        state_ = []
    end 
    
    methods (Access = protected)
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
            that.state_ = copy(this.state_);
        end
    end
        
    %% HIDDEN
    
	methods (Hidden)
        function changeState(this, s)
            %% should only be accessed by AbstractImagingTool.
            
            assert(isa(s, 'mlfourd.AbstractImagingTool'));
            this.state_ = s;
        end
    end
    
    %% DEPRECATED
    
    methods (Hidden)
        function ifc = niftid(this)
            this.selectImagingFormatTool;
            ifc = this.nifti;
        end
        function ifc = numericalNiftid(this)
            this.selectNumericalTool;
            ifc = this.nifti;
        end 
    end  
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

