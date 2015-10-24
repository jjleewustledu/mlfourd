% PETBROWSER
%
% Instantiation:  this = mlfourd.PetBrowser(petnii)
%
%                 petnii: petnii
%
% Created by John Lee on 2009-01-15.
% Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
% Report bugs to <>.

classdef PetBrowser

	properties (Access = 'private')
        petConverter_ = struct([]);
	end

	methods

		%%%%%%%% CTOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function obj = PetBrowser(pid)
	
			switch (nargin)
				case 0
					return;
				case 1
					assert(ischar(pid), ...
						'mlfourd.PetBrowser:ctor:TypeErr:unrecognizedType', ...
						['type of pid was unexpected: ' class(pid)]);
                    obj.petConverter_ = mlfourd.PETconverter(pid);
				otherwise
					error('mlfourd:PassedParamsErr:numberOfParamsUnsupported', ...
						help('mlfourd.PetBrowser'));
			end
        end
        
        
	end
end