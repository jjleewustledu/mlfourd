classdef DirToolComponent
    %% DIRTOOLCOMPONENT is the abstraction DirTool to include DirTools within a composite design pattern;
    %  the listing struct-array from dir is the canonical data structure
    %  See also:  dir
    
    properties (Abstract)
        itsPath
        itsListing
    end
    
    methods (Abstract) 
        
        sarr = files2sa(this, idx)
        sarr = directories2sa(this, idx)
        sarr = invisibleFiles2sa(this, idx)
        sarr = invisibleDirectories2sa(this, idx)
        
        pp = paths(this, idx)
        ff = fqfns(this, idx)
        ff = fns(this, idx)
        ff = fqdns(this, idx)
        ff = dns(this, idx)
        len = length(this)
    end    
end

