

function add_one_variable(poly, newparent)
    R = parent(poly)
    base = base_ring(R)

    t = last(gens(newparent))

    polybuilder = MPolyBuildCtx(newparent)
    for (e, c) in zip(exponent_vectors(poly), coefficients(poly))
        push_term!(polybuilder, c, [e..., 0])
    end

    return finish(polybuilder), t
end

function erase_last_variable(poly, newparent)
    # assuming poly is indepent of last variable

    R = parent(poly)
    base = base_ring(R)

    polybuilder = MPolyBuildCtx(newparent)
    for (e, c) in zip(exponent_vectors(poly), coefficients(poly))
        push_term!(polybuilder, c, e[1:end-1])
    end

    return finish(polybuilder)
end

# TODO : todo
function change_parent_ring(poly, newparent)
    original = parent(poly)
    originalnvars = nvars(original)
    
    parentnvars = nvars(newparent)
    
    if originalnvars == parentnvars
        
    elseif originalnvars + 1 == parentnvars
        return add_one_variable(poly, newparent) 
    elseif originalnvars == parentnvars + 1
        return erase_last_variable(poly, newparent)
    else
        @warn "failed to coerce polynomial $poly from $original to $parent"
    end
end


function unknown2known(u)
    libSingular.julia(libSingular.cast_number_to_void(u.ptr))    
end

function singular2aa(poly::Singular.spoly{T}; base=false, new_ring=false) where {T}
    nvariables = length(gens(parent(poly)))
    xstrings = ["x$i" for i in 1:nvariables]
    if base == false
        base = base_ring(poly)
    end
    if new_ring == false
        new_ring, = AbstractAlgebra.PolynomialRing(base, xstrings)
    end
    change_base_ring(base, poly, parent=new_ring)
end

function double_singular2aa(poly::spoly{Singular.n_unknown{spoly{T}}}; base=false, new_ring=false) where {T}
    outer_change = singular2aa(poly)

    basebase = base_ring(parent(unknown2known(collect(coeffs(poly))[1])))

    nvariables = length(gens(parent(outer_change)))
    ystrings = ["y$i" for i in 1:nvariables]
    new_ring, = AbstractAlgebra.PolynomialRing(basebase, ystrings)

    inner_change = map_coefficients(
                      c -> singular2aa(unknown2known(c), base=basebase, new_ring=base),
                      outer_change)
    inner_change
end


function aa2singular(poly::MPoly{T}; base=false, new_ring=false) where {T}
    nvariables = length(gens(parent(poly)))
    xstrings = ["x$i" for i in 1:nvariables]
    if base == false
        base = base_ring(poly)
    end
    if new_ring == false
        new_ring, = Singular.PolynomialRing(base, xstrings)
    end
    change_base_ring(base, poly, parent=new_ring)    
end

function double_aa2singular(poly::MPoly{T}; base=false, new_ring=false) where {T}
    nvariables = length(gens(parent(poly)))
    ystrings = ["y$i" for i in 1:nvariables]
    xstrings = ["x$i" for i in 1:nvariables]
    basebase = base_ring(base_ring(parent(poly)))
    if base == false
        base, = Singular.PolynomialRing(basebase, xstrings)
    end
    if new_ring == false
        new_ring, = Singular.PolynomialRing(base, ystrings)
    end
    change_base_ring(base_ring(new_ring), poly, parent=new_ring)
end

function Nemo.degree(f::AbstractAlgebra.Generic.Frac{T}) where {T}
    return max(degree(denominator(f)), degree(numerator(f)))
end

function Nemo.isconstant(f::AbstractAlgebra.Generic.Frac{T}) where {T}
    return isconstant(denominator(f)) && isconstant(numerator(f))
end

function Nemo.degrees(f::AbstractAlgebra.Generic.Frac{T}) where {T}
    return degrees(denominator(f)) + degrees(numerator(f))
end

function Base.length(x::Frac{T}) where {T}
    return max(length(numerator(x)), length(denominator(x)))
end

function tosingular(F::AbstractAlgebra.Generic.Rationals)
    Singular.QQ
end

function tosingular(F)
    F
end

function toaa(::Singular.Rationals)
    AbstractAlgebra.Generic.QQ
end

function iota(n)
    return [i for i in 1:n]
end

###############################################################################




