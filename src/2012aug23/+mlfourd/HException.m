classdef HException < MException
    
	%% HEXCEPTION is an facade to MException that allows customized exception handling 
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/HException.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: HException.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
    end 
    
    methods (Static)
        
        function hwarning(varargin)
        end
        function herror(varargin)
        end
        function hassert(varargin)
        end
    end

	methods 
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 

 		function this = HException(varargin) 
            
 			%% HEXCEPTION (ctor) 
 			%  Usage:  Prefer static methods:  HException.hwarning( id, msg, ...)
            %                                  HException.herror(   id, msg, ...)
            %                                  HException.hassert(  id, msg, ...)
            %                                  HException.handexcept(exception, id2, msg2, ...)
            %          Replace MException with subclass HException in situ
			this = this@MException(varargin{:});
 		end % HException (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
