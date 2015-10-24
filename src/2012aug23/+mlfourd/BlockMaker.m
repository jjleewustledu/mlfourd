%% BLOCKMAKER defines the abstract context of a strategy design pattern
%             concrete strategy classes will be tailored for different data sets

classdef BlockMaker

    properties
        db = 0;
        context = 0; % must assign a concrete strategy
        tol = 0.01; 
    end % properties
    
    methods
        
        %% CTOR
        function obj = BlockMaker(pnum)            
            obj.db = mlfsl.ImagingComponent.createStudyFromPnum(pnum);
            obj.context = obj.strategyFactory(obj.db.npnum);
        end % ctor
        
        %% SOLVEBLOCKVALUES {X_{r,b} | r in R, b in B} for ROIs R, e.g., grey, white, csf, arteries, 
        %%                                             for blocks B, 1 < size(B) < N, N native pixels,
        %%                   given probability maps {P_{r,b} | r in R, b in B}.
        %%                   Directly observed values are {Y_b | b in B}. 
        %
        %      size(B) = 1:  Y   = Sigma_{r=1}^size(R)                     P_r      * X_r
        %  1 < size(B) < N:  Y_b = Sigma_{r=1}^size(R) Sigma_{b=1}^size(B) P_{r,b} .* X_{r,b} 
        %      size(B) = N:  Y_b = Sigma_{r=1}^size(R) Sigma_{b=1}^N       P_{r,b} .* X_{r,b} 
        function X_B = solveBlockValues(obj, B, setP_B)
            R = length(setP_B);
        end
        
        %% FOREGROUNDSUMS checks that the sum of nii.image and sum of blocknii.image are consistent
        %                                        sum1                 sum2
        %  if blocknii cannot be found, it is constructed
        function [sum1 sum2] = foregroundSums(obj, fg_filename)
            try
                fg_nii  = load_nii(fg_filename);
            catch ME
                error('mlfourd:FileNotFound', ['please make ' fg_filename]);
            end
            try
                fg_bnii = load_nii(fg_filename);
            catch
                disp([fg_filename ' not found; making it...........']);
                fg_bnii = obj.makeBlocked(fg_nii);
            end
            [sum1 sum2] = obj.checkBlockMaskSums(fg_nii, fg_bnii);         
        end
        
        %% CHECKBLOCKMASKSUMS checks that a mask and its blocked mask have commensurate integrals
        function [sum1 sum2] = checkBlockMaskSums(obj, nii, bnii)

            sum1 = dipsum( nii.img);
            sum2 = dipsum(bnii.img)*dipprod(obj.db.blockSize);
            assert(abs(sum1 - sum2)/abs(min(sum1, sum2)) < obj.tol, ...
                 ['integrals of ' nii.filestem ...
                  ':  sum{img}->' num2str(sum1) ', sum{blockimg}->' num2str(sum2) ...
                  ', block->' obj.db.blockSize]);
        end
        
        %% MAKEBLOCKED
        function bnii = makeBlocked(obj, nii)
            blkSize = floor(obj.db.blockSize);
            switch (nargin)
                case 2
                    assert(isa(blkSize,'double'), ...
                        'mlfourd:TypeErr:UnrecognizedType', ...
                        ['type of blkSize was unexpected: ' class(blkSize)]);
                    assert(length(size(nii.img)) == length(blkSize), ...
                        'mlfourd:ArraySizeErr', ...
                        ['array mismatch:  size(nii.img) -> ' ...
                        num2str(size(nii.img)) ...
                        ', but blkSize -> ' ...
                        num2str(blkSize)]);
                otherwise
                    error('mlfourd:InputParamsErr:TooManyParams', ...
                          help('mlfourd.BlockMaker.makeBlocked'));
            end
            assert(length(blkSize) == 3, ['BlockMaker.makeBlocked:  unsupported size of nii.img->' num2str(length(blkSize))]);
            disp(['BlockMaker.makeBlocked:  making ' ...
                   num2str(blkSize(1)) ' X ' ...
                   num2str(blkSize(2)) ' X ' ...
                   num2str(blkSize(3)) ' blocks of voxels for nii->' nii.hdr.hist.descrip]);
            disp( '                         please wait ...................');
            
            % row-major ordering for dipimage
            dipImg  = dip_image(double(nii.img)); % x-y swap
            outSize = floor(size(nii.img) ./ obj.db.blockSize);
            %assert(outSize .* obj.db.blockSize <= size(nii.img), ...
            %      ['mlfourd:ArraySizeErr', num2str(outSize .* obj.db.blockSize) ' ~< ' num2str(size(nii.img))])
            bDipImg = newim([outSize(2) outSize(1) outSize(3)]); % blocked dipimage
            tic
            maxdi = max(dipImg);
            for z = 0:(outSize(3) - 1)
                for y = 0:(outSize(2) - 1)
                    for x = 0:(outSize(1) - 1) 
                        x2 = x*blkSize(1);
                        y2 = y*blkSize(2);
                        z2 = z*blkSize(3);
                        % bDipImg, dipImg only are in dip frame
                        bDipImg(y,x,z) = mlfourd.BlockMaker.TimsThresholder(dipImg, maxdi, [y2 x2 z2], blkSize);
%                         bDipImg(y,x,z) = sum(dipImg(  ... 
%                             y2:(y2 + blkSize(1)-1),   ...
%                             x2:(x2 + blkSize(2)-1),   ...
%                             z2:(z2 + blkSize(3)-1)) / ...
%                             prod(blkSize));
                    end
                end
            end
            toc            
            
            desc     = [nii.hdr.hist.descrip  '; ' num2str(blkSize) ];
            fnsuffix = [' ' num2str(blkSize(1)) 'x' ...
                            num2str(blkSize(2)) 'x' ...
                            num2str(blkSize(3)) ' blocks'];
            bnii     = mlfourd.NiiBrowser.make_nii_like( ...
                                               nii, double(bDipImg), desc, fnsuffix);
        end      
        
    end % methods
    
    
    
    methods (Static)
        
        function scal = TimsThresholder(dipImg, maxImg, coord, blkSize)
            
            FRAC_THRESHOLD = 0.01;
            threshVal      = FRAC_THRESHOLD * maxImg;
            x2 = coord(1);
            y2 = coord(2);
            z2 = coord(3);
            x3 = x2:(x2 + blkSize(1)-1);
            y3 = y2:(y2 + blkSize(2)-1);
            z3 = z2:(z2 + blkSize(3)-1);
            threshKrnl = dipImg(x3, y3, z3) > threshVal;
            if (sum(threshKrnl) > 10) 
                dipImg(x3, y3, z3) = dipImg(x3, y3, z3) .* threshKrnl;
                scal = sum(dipImg(  ... 
                    x2:(x2 + blkSize(1)-1),   ...
                    y2:(y2 + blkSize(2)-1),   ...
                    z2:(z2 + blkSize(3)-1)) / ...
                    prod(blkSize)); 
            else
                scal = 0;
            end
        end
        
        %% STRATEGYFACTORY
        function strt = strategyFactory(sid)
            
            import mlfourd.*;
            switch (sid)
                case 'np797'
                    % strt = BlockStrategyNp797;
                case 'np287'
                    % strt = BlockStrategyNp287;
                otherwise
                    error('mlfourd:ParamOutOfRange', ['could not recognize ' sid]);
            end
            strt = 0;
        end
    end % static methods
    
    
    
    
    
    
    
    

    
end % classdef
