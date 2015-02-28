% NIIPUBLISH shows or prints NIfTI data for publications.
%
% Instantiation:    obj = mlfourd.NiiPublish(nii)
%
%                   nii: NIfTI struct
%
% Requires:  mlniftitools, diplib (for debug_, showNii)
%
% Created by John Lee on 2008-12-21.
% Copyright (c) 2008 Washington University School of Medicine.  All rights reserved.
% Report bugs to bugs.perfusion.neuroimage.wustl.edu@gmail.com.

classdef NiiPublish
    
    properties
        debug_             = true;
        nii_               = struct([]);
        niib_              = 0;
        mask_              = [];
        mask1_             = [];
        blur_              = [10 10 0];
        range_             = [];  % for parameter maps
        slices_            = {6}; % index for double arrays
        scaling_           = 'NONE';
        cmap_              = [];
        cbits_             = 8;
        cbar_              = true;
        cbarlabel_         = '';  % '\mu_{\sigma}(k \cdot \text{CBF})';
        cbarpos_           = [10 32 10 192];
        cbartextpos_       = [128 22];
        cbartextpos2_      = [14 14];
        cbarfont_          = 'AvantGarde';
        cbarfontsize_      = 12;
        zoom_              = 100;
        dpi_               = 600; % dots per inch for printing
        print_frmt_        = 'epsc2';
        print_file_ending_ = '.eps';
        colormode_         = 'cmyk';
        pnum_               = 'vc4437';
    end
    
    
    properties (Access = 'private')
        SCALINGS = ['FRAC_MEAN' 'DIFF_MEAN' 'FRAC_MEAN_DIFF' 'STD_MOMENT' 'NONE'];
    end
    
    
    methods
        
        %%%%%%%% CTOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Usage: obj = NiiPublish(nii, blur, msk, msk1, rangve, slices, scaling)
        %        all args are optional
        function obj = NiiPublish(nii, blur, msk, msk1, range, slices, scaling)
            
            % set default props           
            obj.cmap_ = jet(2^obj.cbits_);
            
            % check input
            if (0 == nargin); return; end % Matlab requirement
            if (nargin > 0)
                SUFF = '.4dfp';
                if (ischar(nii))
                    fname = nii;
                    try
                        nii = mlfourd.NIfTI.load(fname);
                    catch ME
                        try
                            disp(ME)
                            disp(['trying to read ' fname SUFF]);
                            nii         = mlfourd.NIfTI.load([fname SUFF]);
                        catch ME1
                            error('mlfourd:InputParamErr', ...
                                ['NiiPublish.ctor could not recognize ' fname ' or ' fname SUFF]);
                        end
                    end
                end
                assert(isstruct(nii), 'NiiPublish.ctor.nii');
                obj.nii_  = nii;
            end
            if (nargin > 1)
                assert(isnumeric(blur));
                obj.blur_ = blur;
            end
            if (2 == nargin)
                msk      = ones(size(obj.nii_.img));
                msk1     = ones(size(obj.nii_.img));
                obj.nii_ = obj.niiblur(msk, msk1);
            end
            if (nargin > 2)
                assert(isnumeric(msk));
                assert(numel(nii.img) == numel(msk),  ...
                    'mlfourd:InputParamErr:ArraySizeErr', ...
                    ['size of NiiPublish.nii.img -> ' num2str(size(nii.img)) ', '  ...
                     'size of                msk -> ' num2str(size(msk))]);
                obj.mask_ = msk;
            end
            if (3 == nargin)
                obj.nii_ = obj.niiblur(msk);
            end
            if (nargin > 3)
                assert(isnumeric(msk1));
                assert(numel(obj.nii_.img) == numel(msk1),  ...
                    'mlfourd:InputParamErr:ArraySizeErr', ...
                    ['size of obj.nii_.img  -> ' num2str(size(obj.nii_.img)) ', '  ...
                     'size of          msk1 -> ' num2str(size(msk1))]);
                obj.mask1_ = msk1;
                obj.nii_   = obj.niiblur(msk, msk1);
            end
            if (nargin > 4)
                assert(isnumeric(range));
                obj.range_ = range;
            end
            if (nargin > 5)
                if (isnumeric(slices))
                    slices = {slices}; end
                assert(iscell(slices));
                obj.slices_ = slices;
            end
            if (nargin > 6)
                assert(ischar(scaling));
                assert(obj.checkScaling(scaling));
                obj.scaling_ = scaling;
            end
            if (nargin > 7); error(help('mlfourd.NiiPublish')); end
            
            % do business 
            
            import mlfourd.*;
            img          = double(isfinite(obj.nii_.img)) .* obj.nii_.img;
            niib         = NiiBrowser(obj.nii_, obj.blur_);            
            vec          = niib.sampleVoxels(msk);
            if (obj.debug_)
                disp(['mean niib.sampleVoxels(msk) -> ' num2str(mean(vec))]);
                disp(['std                         -> ' num2str( std(vec))]);
                disp(['min                         -> ' num2str( min(vec))]);
                disp(['max                         -> ' num2str( max(vec))]);
                disp(['sample size                 -> ' num2str( sum(vec))]);
            end
            meanimg = mean(vec);
            stdimg  = std(vec);
            switch (obj.scaling_)
                case 'NONE'
                case 'FRAC_MEAN'
                    img = img/meanimg;
                case 'FRAC_DIFF'
                    img = img  - meanimg*ones(size(img));
                case 'FRAC_MEAN_DIFF'
                    img = img/meanimg  - ones(size(img));
                case 'STD_MOMENT'
                    img = (img - meanimg*ones(size(img)))/stdimg;
                otherwise
                    error('mlfourd:InternalErr', ...
                         ['NiiPublish.ctor could not recognize ' obj.scaling_]);
            end
            img      = NiiPublish.limit_range(img, obj.range_);
            obj.nii_ = obj.nii_.makeSimilar(img, ...
                       ' -> NiiPublish.ctor', ...
                       'NiiPublish.nil_');            
            obj.niib_    = niib;
        end % ctor
        
        
        %% NIIBLUR applies a blurring algorithm to the NIFTI struct.  
        %  Only aniso. Gaussian blurring is supported at present.
        %
        %  Usage:  nii1 = niiblur(msk, msk1)
        %
        %          nii1, nii:      NIfTI struct (cf. help load_nii)
        %          msk:            double mask to apply prior to blurring (opt)
        %          msk1:           double mask ...      after blurring    (opt)
        function nii1 = niiblur(obj, msk, msk1)
            
            DESCRIP = ' -> niiblur';
            
            if (1 == nargin)
                msk  = ones(size(obj.nii_.img));
                msk1 = ones(size(obj.nii_.img));
            end
            if (nargin > 1)
                assert(numel(obj.nii_.img) == numel(msk),  ...
                    'NIL:niiblur:SizeErr:incompatibleSize', ...
                    ['size of nii_.img -> ' num2str(size(obj.nii_.img)) ', ' ...
                    'size of msk      -> ' num2str(size(msk))]);
            end
            if (2 == nargin)
                msk1 = obj.doubleblur(msk);
            end
            if (nargin > 2)
                assert(numel(obj.nii_.img) == numel(msk1),  ...
                    'NIL:niiblur:SizeErr:incompatibleSize', ...
                    ['size of nii_.img -> ' num2str(size(obj.nii_.img)) ', ' ...
                    'size of msk1     -> ' num2str(size(msk1))]);
            end
            if (nargin > 3)
                error('NIL:niiblur:ctor:PassedParamsErr:numberOfParamsUnsupported', ...
                    help('niiblur'));
            end
            
            % do business            
            nii1 = obj.make_nii_self(msk1 .* double(gaussAnisofFwhh(obj.nii_.img .* msk, obj.blur_, obj.mmppix)), ...
                [obj.nii_.hdr.hist.descrip DESCRIP]);
            nii1 = mlfourd.NIfTI(nii1);
            if (obj.debug_)
                disp(['DEBUG:       obj.nii_     -> '         class(obj.nii_)]);
                disp(['DEBUG:       obj.nii_.img -> '         class(obj.nii_.img)]);
                disp(['DEBUG:  size obj.nii_.img -> ' num2str(size( obj.nii_.img))]);
                disp( 'DEBUG:  dip_image will show obj.nii_.img');
                %dip_image(msk)          % DEBUG
                %dip_image(msk1)         % DEBUG
                %dip_image(obj.nii_.img) % DEBUG
            end
        end % function niiblur
                
        %% DIPBLUR blurs dip or double images and always returns dip
        function dip1 = dipblur(obj, dip)
            % gAF accepts dip_image or double; always returns dip_image
            dip1 = gaussAnisofFwhh(dip, obj.blur_, obj.mmppix);
            assert(isa(dip1, 'dip_image'));
        end
               
        %% DOUBLEBLUR blurs double or dip images and always returns double
        function dbl1 = doubleblur(obj, dbl)
            % gAF accepts dip_image or double; always returns dip_image
            dbl1 = double(gaussAnisofFwhh(dbl, obj.blur_, obj.mmppix));
        end
               
        %% NIIMAKE_SELF is a wrapper for mlniftitools.make_nii
        function nii1 = make_nii_self(obj, img, desc)
            nii1 = obj.makeSimilar(img, desc);
        end
        
        %% MAKE_DIP displays nii_.img on screen as a 3D/4D dip_image
        function [h dip] = make_dip(obj)
            
            dimedim = obj.nii_.hdr.dime.dim;
            dims3   = [dimedim(2) dimedim(3) dimedim(4)];
            if (1 == numel(obj.slices_))
                dip = dip_image(obj.nii_.img(:,:,obj.slices_{1})');
            else
                dip = newim(dims3);
                for z = 0:dims3(3)-1 
                    % transform to radiological convention
                    dip(:,:,z) = dip_image(obj.nii_.img(:,:,z+1)');
                end
            end
            
            if (obj.debug_)
                disp(['min dip -> ' num2str(min(dip))]);
                disp(['max dip -> ' num2str(max(dip))]);
            end
            
            h = dipfig('dip');
            dipshow(dip, obj.range_, obj.cmap_);
            obj.make_colorbar;
        end % function make_dip
        
        %% SHOW_NII displays 2D nii_ images on screen 
        function h = show_nii(obj, slice)

            NRGB    = 3;
            dimedim = obj.nii_.hdr.dime.dim;
            dimc    = [dimedim(2) dimedim(3) NRGB];
            dblc    = zeros(dimc);
            if (isa(dip_image(obj.nii_.img), 'dip_image_array') && ...
                    3 == length(obj.nii_.img)) %%%%%%%% KLUDG to discover rbg-array of images
                disp('NiiPublish.show_nii found dip_image_array in dip_image(nii_.img)');
                for rgb = 1:NRGB
                    dblc(:,:,rgb) = obj.nii_.img{rgb}(:,:,slice)';
                end
            elseif (isa(dip_image(obj.nii_.img), 'dip_image')) %%%%%%%% another KLUDGE
                disp('NiiPublish.show_nii found dip_image in dip_image(nii_.img)');
                dblc = obj.nii_.img(:,:,slice)';
            end
            
            h = obj.make_figure(dblc);
                obj.make_colorbar;
            if (obj.debug_)
                disp(['min dbl(:,:,' num2str(slice) ') -> ' num2str(min(dip_image(dblc)))]);
                disp(['max dbl(:,:,' num2str(slice) ') -> ' num2str(max(dip_image(dblc)))]);
            end
        end % function nii_show
       
        %% PRINT_NII prints 2D nii_ images to a filesystem
        %
        %  Usage:  h = print_nii(obj, filename, newslices)
        %          newslices:   cell-array replaces internal obj.slices_
        function   h = print_nii(obj, filename, newslices)
            
            switch (nargin)
                case 1
                    filename = ['print_nii_' datestr(now, 30)];
                case 2
                    assert(ischar(filename));
                case 3
                    assert(iscell(newslices));
                    obj.slices_ = newslices;
                otherwise
            end
                              
            NRGB    = 3;
            dimedim = obj.nii_.hdr.dime.dim;
            dims    = [dimedim(2) dimedim(3) dimedim(4)];
            nslices = dims(3);
            dblc    = cell(1,nslices);
            dbl     = zeros(dims);
            if (isa(dip_image(obj.nii_.img), 'dip_image_array') && ...
                  3 == length(obj.nii_.img)) %%%%%%%% KLUDG to discover rbg-array of images
                disp('NiiPublish found dip_image_array in dip_image(nii_.img)');
                for rgb = 1:NRGB
                    for slice = 1:nslices
                        dblc{slice}(:,:,rgb) = obj.nii_.img{rgb}(:,:,slice)';
                    end
                end
            elseif (isa(dip_image(obj.nii_.img), 'dip_image')) %%%%%%%% another KLUDGE
                disp('NiiPublish found dip_image in dip_image(nii_.img)');
                for sl1 = 1:nslices
                    dblc{sl1} = obj.nii_.img(:,:,sl1)';
                end
            end
            
            h = cell(1,nslices);
            for sl2 = 1:nslices
                if (0 == numel(obj.slices_) || iselement(sl2, obj.slices_))
                    h{sl2} = obj.make_figure(dblc{sl2});
                             obj.make_colorbar;
                    if (nargin > 1)
                        disp(['Printing ' obj.print_frmt_ ' in ' obj.colormode_ ' to ' ...
                              pwd '/' filename '_slice' num2str(sl2) obj.print_file_ending_]);
                        print(gcf, ['-d'  obj.print_frmt_], ['-' obj.colormode_], ['-r' num2str(obj.dpi_)], ...
                                   [pwd '/' filename '_slice' num2str(sl2) '.eps']);
                    end
                    dbl(:,:,sl2) = dblc{sl2};
                end 
                if (obj.debug_)
                    disp(['min dbl(:,:,' num2str(sl2) ') -> ' num2str(min(dip_image(dbl(:,:,sl2))))]);
                    disp(['max dbl(:,:,' num2str(sl2) ') -> ' num2str(max(dip_image(dbl(:,:,sl2))))]);
                end
            end % for sl2
        end % function print_nii
        
        %% MMPPIX return pixel dimensions
        function triplet = mmppix(obj)
            triplet = [obj.nii_.hdr.dime.pixdim(2) ...
                obj.nii_.hdr.dime.pixdim(3) ...
                obj.nii_.hdr.dime.pixdim(4)];
        end % function mmppix
        
        %% NIITRUESIZE zoom displayed or printed images
        function nii1 = niitruesize(obj, pcnt, handle)  
            if (pcnt < 1); pcnt  = pcnt*100; end
            assert(1 == length(pcnt))
            obj.zoom_ =  pcnt;
            if (100 == pcnt); return; end
            
            sizevec   = (pcnt/100)*[size(obj.nii_.img,1) size(obj.nii_.img,2)];
            if (3 == nargin)
                truesize(handle, sizevec); 
            else
                truesize(sizevec); % apply to active figure window
            end
            nii1 = obj.nii_;
        end % function niitruesize
        
        %% MAKE_FIGURE plots a figure to screen
        function h = make_figure(obj, img)
            assert(isnumeric(img));
            figure( ...
                        'Units',             'pixels', ...
                        'Color',             'White', ...
                        'PaperPositionMode', 'auto');
            h = imshow(img, ...
                        'Border',               'tight', ...
                        'InitialMagnification',  obj.zoom_, ...
                        'DisplayRange',          obj.range_);
        end
        
        %% MAKE_COLORBAR writes a colorbar on the active figure
        function make_colorbar(obj)
            if (numel(obj.cmap_) > 0)
                colormap(obj.cmap_); end
            if (obj.cbar_)                
                colorbar(...
                        'XColor',   'White', ...
                        'YColor',   'White', ...
                        'Units',    'pixels', ...
                        'location', 'West', ...
                        'Position',  obj.cbarpos_, ...
                        'TickDir',  'in', ...
                        'FontName',  obj.cbarfont_, ...
                        'FontSize',  obj.cbarfontsize_);
                text(obj.cbartextpos_(1), obj.cbartextpos_(2), obj.cbarlabel_, ...
                        'Color',      'White', ...
                        'Position',    obj.cbartextpos2_, ...
                        'FontName',    obj.cbarfont_, ....
                        'FontSize',    obj.cbarfontsize_, ...
                        'FontWeight', 'bold', ...
                        'Rotation',    0);
                set(gca, ...
                        'Color',      'White', ...
                        'FontName',    obj.cbarfont_, ...
                        'FontSize',    obj.cbarfontsize_, ...
                        'FontWeight', 'bold');
            end
        end % end function make_colorbar
    end % methods
    
    
    methods (Static)
        
        %% Static JUSTPRINT_PATIENT_SET is a convenience method
        %
        %  Usage:  mlpublish.NiiPublish.justprint_patient_set(pnum, slices)
        %
        %          pnum:     vc-number or p-number
        %          slices:  cell-array
        function                        justprint_patient_set(pnum, slices)
            
            METRICS = { ...
                'petcbf',      'petcbv',        'petmtt',         'petoef', ...
                'petcmro2',    'mlemcbf',       'mlemcbv',        'mlemmtt', ...
                'laifAlpha',   'laifBeta',      'laifF',          'laifCBV', ...
                'laifFracC',   'laifFracRec',   'laifFractDrop',  'laifMtt', ...
                'laifNoiseSd', 'laifProbModel', 'laifProbSignal',            ... %%%'laifprobs0', ...
                'laifS0',      'laifS1',        'laifT0',         'laifT02', ...
                'T1_cbv' };
            
            niifg = mlfourd.NIfTI.load(mlfourd.NiiPublish.fqfn(pnum, 'fg'));
            for i = 1:length(METRICS)
                if (    strncmp('t1',  lower(METRICS{i}), 2))
                    nii = mlfourd.NIfTI.load(mlfourd.NiiPublish.fqfn(pnum, 'T1_cbv'));
                elseif (strncmp('pet', lower(METRICS{i}), 3))
                    nii = mlpet.PETBuilder.PETfactory(pnum, METRICS{i});
                else
                    fname = '';
                    switch (METRICS{i}(1:4))
                        case 'mlem'
                            fname = getMlemFilename(pnum, METRICS{i}(5:7));
                        case 'laif'
                            fname = getLaifFilename(pnum, METRICS{i}(5:end));
                        otherwise
                            warning('mlfourd:InternalDataErr', ...
                                   ['justprint_patient_set did not recognize ' METRICS{i}]);
                    end
                    nii = mlfourd.NIfTI.load(fname);
                end
                try
                    mlfourd.NiiPublish.justprint(nii, niifg.img, METRICS{i}, pnum, slices);
                catch ME
                    disp(ME);
                end
            end
        end
        
        function fn = fqfn(pnum, tag)
            pnumpath = [db('basepath', pnum) pid2np(pnum) '/' pnum '/'];
            switch (tag(1:2))
                case 'fg'
                    fn = [pnumpath 'ROIs/Xr3d/fg.4dfp'];
                case {'t1', 'T1'}
                    fn = [pnumpath '4dfp/' tag '_xr3d.4dfp'];
                otherwise
                    error('mlfourd:InputParamErr', ...
                         ['fqfn did not recognize tag ' tag]);
            end
        end
        
        %% Static JUSTPRINT is a convenience method
        %  Usage:  obj = mlpublish.NiiPublish.justprint(nii, msk, fname, pnum, slices)
        function   obj =                      justprint(nii, msk, fname, pnum, slices)
            import mlfourd.NiiPublish;
            obj         = NiiPublish(nii, dbblur, msk);
            obj.pnum_    = pnum;
            obj.slices_ = slices;
            obj.print_nii(fname);
        end
           
        %% Static LIMIT_RANGE
        %  Usage:  img1 = mlpublish.NiiPublish.limit_range(img, range);
        function   img1 =                      limit_range(img, range)
            assert(isnumeric(img));
            assert(isnumeric(range));
            if (0 == numel(range))
                img1 = img; return; end
            keep     = double(img > range(1)) .* double(img < range(2));
            img1     = keep .* img; 
        end
        
        %% Static DBBLUR
        %  Usage:  blue = mlpublish.NiiPublish.dbblur;
        function   blur =                      dbblur()
            if (sum(db('petblur')) > sum(db('mrblur')))
                blur = db('petblur');
            else
                blur = db('mrblur');
            end
        end
        
        %% Static NIIMAKE is a wrapper for mlniftitools.make_nii
        %  Usage: nii1 = mlpublish.NiiPublish.niimake(img, pixdim, origin, datype, desc);
        function  nii1 =                      niimake(img, pixdim, origin, datype, desc)
            nii1 = make_nii(img, pixdim, origin, datype, desc);
        end
        
        %% Static GETNII
        %  Usage:  nii = mlpublish.NiiPublish.getNii(pnum, tags)
        function   nii =                      getNii(pnum, tags)
            
            import mlfourd.*;
            assert(iscell(tags))
            for t = 1:length(tags)
                assert(ischar(tags{t}));
            end
            
            switch lower(tags{1})
                case 'pet'
                    nii = mlpet.PETBuilder.PETfactory(pnum, tags{2});
                    return;
                case {'mlem','mr mlem','mrmlem'}
                    switch lower(tags{2})
                        case 'cbf'
                            nii = mlfourd.NIfTI.load(getMlemFilename(pnum, 'cbf'));
                        case 'cbv'
                            nii = mlfourd.NIfTI.load(getMlemFilename(pnum, 'cbv'));
                        case 'mtt'
                            nii = mlfourd.NIfTI.load(getMlemFilename(pnum, 'mtt'));
                        otherwise
                            error('mlfourd:NiiPublish:getNii', [tags{1} ' ' tags{2} ' was unrecognizable']);
                    end
                case {'laif','mr laif','mrlaif'}
                    switch lower(tags{2})
                        case {'cbf','f'}
                            nii = mlfourd.NIfTI.load(getLaifFilename(pnum, 'F'));
                        case 'cbv'
                            nii = mlfourd.NIfTI.load(getLaifFilename(pnum, 'CBV'));
                        case 'mtt'
                            nii = mlfourd.NIfTI.load(getLaifFilename(pnum, 'Mtt'));
                        otherwise
                            error('mlfourd:NiiPublish:getNii', [tags{1} ' ' tags{2} ' was unrecognizable']);
                    end
                otherwise
                    error('mlfourd:NiiPublish:getNii', [tags{1} ' was unrecognizable']);
            end          
            
        end % function getNiis
        
        function pth = getPidPath(pnum)
            sid = pid2np(pnum);
            pth = [db('basepath', sid) sid '/' pnum '/'];
        end
        
        function niis = getMaskNiis(pnum, tags)
            
            import mlfourd.*;
            assert(iscell(tags))
            niis  = cell(1,length(tags));
            for t = 1:length(tags)
                assert(ischar(tags{t}));
                switch (lower(tags{t}))
                    case {'fg'}
                        niis{t} = NiiPublish.tryLoadMask(pnum, 'fg');
                    case {'tissue', 'tissues'}
                        niis{t} = NiiPublish.tryLoadMask(pnum, 'tissue');
                    case {'artery', 'arteries'}
                        niis{t} = NiiPublish.tryLoadMask(pnum, 'arteries');
                    case {'csf'}
                        niis{t} = NiiPublish.tryLoadMask(pnum, 'csf');
                    case {'grey','gray'}
                        niis{t} = NiiPublish.tryLoadMask(pnum, 'grey');
                    case {'white'}
                        niis{t} = NiiPublish.tryLoadMask(pnum, 'white');
                    otherwise
                        niis{t} = NiiPublish.tryLoadMask(pnum, tags{t});
                        %error('mlpublish:InputParamErr', [tags{t} ' was not recognized']);
                end
            end
        end
        
        function nii = tryLoadMask(pnum, prefix)
            
            import mlfourd.*;
            MASK_SUBPATH = 'ROIs/2009jan27/';
            try
                nii = mlfourd.NIfTI.load([NiiPublish.getPidPath(pnum) MASK_SUBPATH prefix '_xr3d.4dfp']);
            catch ME1
                try
                    nii = mlfourd.NIfTI.load([NiiPublish.getPidPath(pnum) MASK_SUBPATH prefix '_Xr3d.4dfp']);
                catch ME2
                    try
                        nii = mlfourd.NIfTI.load([NiiPublish.getPidPath(pnum) MASK_SUBPATH prefix 'Xr3d.4dfp']);
                    catch ME3
                        try
                            nii = mlfourd.NIfTI.load([NiiPublish.getPidPath(pnum) MASK_SUBPATH prefix '.4dfp']);
                        catch ME4
                            disp(ME4.message);
                            error('mlfourd:IOErr', ['NiiPublish.tryLoadMask could not load ' ...
                                NiiPublish.getPidPath(pnum) MASK_SUBPATH prefix '*.4dfp']);
                        end
                    end
                end
            end
        end
        
        function Ns = getMaskNs(mskniis)
            Ns = cell(1,length(mskniis));
            for s = 1:length(mskniis)
                Ns{s} = sum(dip_image(mskniis{s}.img));
            end
        end
    end % static methods
    
    
    methods (Access = 'private')
        
        %% CHECKSCALING checks that the scaling scheme requested is supported
        function checkScaling(scal)
            found = 0;
            for i = 1:length(obj.SCALINGS)
                if (strcmp(scal, obj.SCALINGS(i))); found = found + 1; end
            end
            assert(sc > 0, ['could not recognize requested scaling:  ' scal]);
        end
    end
    
end % class
