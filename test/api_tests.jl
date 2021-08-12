
using .RationalFunctionFields: RationalFunctionField, compute_groebner!,
                    contains_using_groebner

logger = Logging.SimpleLogger(stderr, Logging.Debug)
Logging.global_logger(logger)


@testset "Basics tests" begin

end

@testset "Contains tests" begin
    FF = Sing.GF(2^31 - 1)
    R, (a, b) = AA.PolynomialRing(Sing.QQ, ["a", "b"])
    set = [ (a^2 + b^2) // 1, a*b // 1 ]

    FF = RationalFunctionField(set)
    compute_groebner!(FF)  
    
    contains_using_groebner(FF, a // b)

end