using MemorableUniqueIdentifier, Test

@testset "basic" begin
    @test create(6) !== nothing
    @test animal("1200000000000000000000010c6228c1") === "Gloomless Fly"
    @test search("fe3a1eb0bca7542150e37ce4022a366b") === "Female Bobcat"
    @test validate("1200000000000000000000010c6228c1") === true
    @test difficulty("1200000000000000000000010c6228c1") === 12
    @test length(mine_until(6, 3)) === 3
end