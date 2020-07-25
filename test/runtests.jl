using Muid, Test

@testset "basic" begin
    @test create(6) !== nothing
end