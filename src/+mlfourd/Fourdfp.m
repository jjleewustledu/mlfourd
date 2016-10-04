classdef Fourdfp < mlfourd.NIfTI
	%% FOURDFP wraps I/O for NIfTI objects to be compliant with Avi Snyder's suite of 4dfp software
	%  $Revision: 2608 $
 	%  was created $Date: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/Fourdfp.m $, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id: Fourdfp.m 2608 2013-09-08 00:14:08Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Constant)
        FILETYPE = '4DFP';
        FILETYPE_EXT = '.4dfp.ifh';
        SUPPORTED_EXTENSIONS = {'.4dfp.ifh'};
    end
    
    properties
        filetype = 0;
    end
    
	properties (Dependent, Hidden)
 		converter;
    end

    methods (Static)
        function fdfp = load(fqfn)
            fdfp = [];
            error('mlfourd:notImplemented', 'Fourdfp.load(%s)', fqfn);
        end
    end
    
    methods %% SET/GET
        function cvtr = get.converter(this) %#ok<MANU>
            cvtr = fullfile(getenv('FSLDIR'), 'bin', 'fslchfiletype');
        end
    end
    
	methods 
        function        save(this)
            save@mlfourd.NIfTI;
            error('mlfourd:notImplemented', 'Fourdfp.save %s', this.fqfilename);
        end
 		function this = Fourdfp(varargin) 
 			%% FOURDFP 
 			%  Usage:  obj = Fourdfp() 

 			this = this@mlfourd.NIfTI(varargin{:}); 
            this.filesuffix = this.FILETYPE_EXT;
 		end %  ctor 
    end 
    
    methods (Access = 'private')
        function convert2NIfTI(~, fqfn)
            convertFile(fqfn, mlfourd.INIfTI.FILETYPE);
        end
        function convert2Fourdfp(~, fqfn)
            convertFile(fqfn, 'ANALYZE');
        end
        function convertFile(this, fqfn, newtype)
            assert(lexist(fqfn, 'file'));
            mlbash(sprintf('%s %s %s', this.converter, newtype, fqfn));
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

