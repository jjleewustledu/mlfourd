classdef ImgRecorder < mlpipeline.Logger
	%% IMGRECORDER  

	%  $Revision$
 	%  was created 11-Dec-2015 18:57:32
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties (Constant)
 		IMGREC_EXT = '.img.rec'
 	end

	methods 		  
 		function this = ImgRecorder(imgObj, varargin)
 			%% IMGRECORDER
 			%  Usage:  this = ImgRecorder(imaging_object[, callback])
            %                                              ^ reference to calling object

 			this = this@mlpipeline.Logger( ...
                mlfourd.ImgRecorder.obj2fqfn(imgObj), varargin{:});
            
            this.filesuffix = this.IMGREC_EXT;
 		end
    end 
    
    %% PROTECTED
    
    methods (Static, Access = 'protected')
        function fqfn = obj2fqfn(obj)
            
            import mlfourd.*;
            if (isa(obj, 'mlfourd.ImagingContext2'))
                obj  = obj.clone;
                fqfn = [obj.fqfileprefix ImgRecorder.IMGREC_EXT];
                return
            end
            if (isa(obj, 'mlio.IOInterface'))
                fqfn = [obj.fqfileprefix ImgRecorder.IMGREC_EXT];
                return
            end
            error('mlfourd:unsupportedTypeclass', 'ImgRecorder.obj2fqfn.obj is a %s', class(obj));
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

