export writexml

####### WRITEXML ###########
writexml(node, f) = writexml(stdout, node, f)

function writexml(io::IO, doc::Document,f::String)
    f=open(f, "w")    
    write(f,"""<?xml version="1.0" encoding="UTF-8"?> \n""")
    if hasroot(doc)
        f=writexml(io, root(doc), f,0)
    else
        @warn "No root found"        
    end
    close(f)
end

function writexml(io::IO, n::TextNode,f::IOStream)
    write(f,n.content)
    return f
end

function writexml(io::IO, n::Node,f::IOStream, depth::Integer = 0)    
    @warn "Unknown node type"    
end

function writexml(io::IO, n::AttributeNode,f::IOStream)   
   write(f,n.name*"=\""*n.value*"\"")
   return f
end

function writexml(io::IO, n::TextNode,f::IOStream, depth::Integer)   
    write(f,"    "^depth*n.content * " \n")
    return f
end

function writexml(io::IO, parent::ElementNode,f::IOStream, depth::Integer = 0)   
    tag = nodename(parent)    
    write(f,"    "^depth*"<$tag")

    attrs = map(x -> x.name * "=\"$(x.value)\"", attributes(parent))
    attr_str = join(attrs, " ")
    if !isempty(attr_str)
        write(f," "*attr_str)        
    end

    children = nodes(parent)
    len = length(children)

    if len == 0
        write(f,"/> \n")        
    elseif len == 1 && istext(first(children))
        write(f,">")
        for n in children 
            f=writexml(io, n,f)
        end
    else        
        write(f,"> \n")
        for n in children
            f=writexml(io, n,f,depth + 1)
        end
        write(f,"    "^depth)
    end    

    if len != 0        
        write(f,"</$tag> \n")
    end

    return f   
end