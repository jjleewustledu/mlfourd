classdef Hemispheres
    
    properties
        cvl_path  = '/Volumes/LLBQuadra/cvl/';
        pnum       = 'p7377';
        roiPath
        roi_fp     = 'parenchyma';
        template % NIfTI
    end
    
    methods
        
        function this = Hemispheres(pnum, pfolder, fg)
            
            import mlfourd.*;
            assert(nargin >= 2);
            this.pnum                 = pnum;
            this.roiPath             = fullfile(this.cvl_path, 'qBOLD', pfolder, 'fsl');
            disp(['Hemispheres.ctor:  working from ' cd(this.roiPath)]); 
            this.template            = ensureNii(fg);
            this.template.fileprefix = 'hemispheres_template';
            this.template.descrip    = 'Hemispheres ctor template';
        end

        function tf = isrightto(this, pts, cfield)
            
            %% ISRIGHT expects dip_image indexing
            %  Usage:  tf = isrightto(this, pts[, cfield])
            %          ^ bool               ^ from dipgetcoords, matlab double
            %                                     ^ NIfTI or fn of NIfTI
            %  cf. method 3 of
            %  http://en.wikipedia.org/wiki/Plane_(geometry)#Define_a_plane_through_three_points
            assert(isnumeric(pts));
            if (~exist('cfield', 'var')); cfield = ''; end
            templ  = this.template.dip_image;
            sz     = size(templ);
            dip1s  = newim(sz) + 1;
            skinny = reshape(dip1s, [prod(sz) 1]);      
            n      = mlfourd.Hemispheres.normalto(pts); % "   
            if (size(n,1) > size(n,2)); n = n'; end     % ensure row-vector
            
            cfield  = this.coordfield1(cfield);
            assert(isa(cfield, 'mlfourd.ImageInterface'));
            cfield  = cfield.dip_image;
            cfield  = reshape(cfield, [prod(sz) 3]);    % prod(sz)(x)3
            X       = 1; Y = 2; Z = 3;
            cfieldx = cfield(:,X-1);
            cfieldy = cfield(:,Y-1);
            cfieldz = cfield(:,Z-1);
            clear     cfield;
            
            tf      = n(X)*cfieldx + n(Y)*cfieldy + n(Z)*cfieldz  - dot(n, pts(1,:))*skinny; % prod(sz)
            tf      = reshape(tf, [sz(X) sz(Y) sz(Z)]);
            %tf    = permute(tf, [2 1 3]); % empirically found           
        end
        
        function f3d = coordfield1(this, saved)
            
            %% COORDFIELD1 returns sz(1) (x) sz(2) (x) sz(3) (x) 3 using diplib indexing
            %  Usage:  f3d = coordfield1(this[, saved])
            %          ^ dip                    ^ NIfTI or filename
            import mlfourd.*;
            templ     = this.template.dip_image;
            sz        = size(templ);
            if (exist('saved', 'var') && ~isempty(saved))
                saved = ensureNii(saved);
                assert(all(saved.size == sz));
                f3d   = saved;
                return
            end
            
            tic
            f3d = newim(sz(1), sz(2), sz(3), 3);
            for r = 0:2
                f3d(:,:,:,r) = ramp(sz, r+1, 'corner');
            end
            disp('Hemispheres.coordfield1.f3d:   time to make:');
            toc
            fp  = ['coordfield_' sz(1) 'x' sz(2) 'x' sz(3)];
            f3d = NIfTI(f3d, fp, fp, [this.template.pixdim 1]);
        end
        
        function f3d = constfield1(this, v)
            
            %% CONSTFIELD1 returns sz(1) (x) sz(2) (x) sz(3) (x) 3, using dip indexing 
            %  Usage:  f3d = constfield1(this, v)
            %          ^ dip                   ^ matlab 3-vector
            assert(isnumeric(v));
            assert(3 == length(v));
            templ  = this.template.dip_image;
            sz     = size(templ);
            f3d = newim(sz(1), sz(2), sz(3), 3);
            for o = 0:sz(3)-1
                for n = 0:sz(2)-1
                    for m = 0:sz(1)-1
                        f3d(m,n,o,:) = v;
                    end
                end
            end
        end
    end
    
    methods (Static)
        
        function str = triplestr(pts)
            assert(isnumeric(pts));
            str = sprintf('[%i %i %i], [%i %i %i], [%i %i %i]', ...
                pts(1,1), pts(1,2), pts(1,3), pts(2,1), pts(2,2), pts(2,3), pts(3,1), pts(3,2), pts(3,3));
        end
        
        function pts = swapxy(pts)
            
            %% swap x,y indices for points in rows of pts
            assert(isnumeric(pts));
            tmp = pts;
            pts(:,2) = tmp(:,1);
            pts(:,1) = tmp(:,2);
        end
        
        function check(side, t1)
            
            import mlfourd.*;
            side   = ensureNii(side);
            t1     = ensureNii(t1);
            t1.img = t1.img + t1.dipmax*side.img/10;
            t1.dipshow
        end
        
        function n = normalto(pts)
            
            %% NORMALTO 
            %  Usage:   n = Hemispheres.normalto(pts, )
            %           ^                        ^ matlab double
            import mlfourd.*;
            assert(isnumeric(pts));
            p1  = pts(1,:);  % 1(x)3 dip
            p2  = pts(2,:);
            p3  = pts(3,:);
            n   = cross(p2 - p1, p3 - p1); % 1(x)3, cross-product is a matlab double
        end
        
        function right = make_right(pnum, pfolder, fg, pts)
            
            %% MAKE_RIGHT using dip indexing scheme
            %  Usage:   right = Hemispheres.make_right(pnum, pfolder, fg, pts)
            %           ^ NIfTI                                            ^ from dipgetcoords, double
            import mlfourd.*;
            assert(isnumeric(pts));
            if (~exist('cfield', 'var')); cfield = ''; end
            hemi = Hemispheres(pnum, pfolder, fg);
            tf   = hemi.isrightto(pts, cfield);
            assert(isa(tf, 'dip_image'));
            tf = double(tf > 0);
            right = hemi.template.makeSimilar( ...
                    tf, ['right of selected points ' Hemispheres.triplestr(pts)], 'right');
        end
        
        function left = make_left(pnum, pfolder, fg, pts)
            
            %% MAKE_LEFT using dip indexing scheme
            %  Usage:   left = Hemispheres.make_left(pnum, pfolder, fg, pts)
            %           ^ NIfTI                                          ^ from dipgetcoords, double
            if (~exist('cfield', 'var')); cfield = ''; end
            left = 1 - mlfourd.Hemispheres.make_right(pnum, pfolder, fg, pts);
        end
    end 
end
