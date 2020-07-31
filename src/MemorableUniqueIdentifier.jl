module MemorableUniqueIdentifier

export create, animal, validate, difficulty, search, mine_until, MiningResult

import JSON
import SHA
using Pkg.Artifacts

# Load the animals
corpus = JSON.parsefile(joinpath(artifact"animals", "animals.json"), dicttype=Dict, inttype=Int8)

"""
    bhash(key)

Hash the passed key using SHA256 and hex encoded
the result and return the first 32 bytes.

"""
function bhash(key)
    SubString(bytes2hex(SHA.sha256(key)), 1, 32)
end

"""
    animal("40db1854b0d8664b1f1baf3f6ddb6377")

Return the animal name from the specified key.

# Examples
```julia-repl
julia> animal("40db1854b0d8664b1f1baf3f6ddb6377")
"Eme Cod"
```
"""
function animal(key)
    search(bhash(key))
end

"""
    validate("40db1854b0d8664b1f1baf3f6ddb6377")

Check to see if the key is a memorable unique identifier

# Examples
```julia-repl
julia> validate("40db1854b0d8664b1f1baf3f6ddb6377")
true
```
"""
function validate(key)
    animal(key) !== nothing
end

"""
    difficulty("40db1854b0d8664b1f1baf3f6ddb6377")

Return the difficulty or length of the passed key, zero
if the key is not valid.

# Examples
```julia-repl
julia> difficulty("40db1854b0d8664b1f1baf3f6ddb6377")
6
```
"""
function difficulty(key)
    a = animal(key)
    if a === nothing
        0
    else
        length(replace(a, " " => ""))
    end
end

"""
    struct MiningResult
        key::String
        hash::String
        length::UInt
        pretty::String
    end

A struct containing the result of mining for a key.
"""
struct MiningResult
    "The key found from mining"
    key::String
    "The hash value of the key"
    hash::String
    "The length of the key that was mined"
    length::UInt
    "The pretty name of the key that was mined"
    pretty::String

    function MiningResult(key, hash, length, pretty)
        new(key, hash, length, pretty)
    end
end

"""
    mine_until(6, 10)

Mine new memorable unique identifiers until the quota is
statisfied, return an array of [`MiningResult`](@ref) structs.

# Examples
```julia-repl
julia> mine_until(6, 3)
3-element Array{MiningResult,1}:
 MiningResult("fd4482e12aa6f335f6c7cd7bf6e25fbd", "6a6c0d0240f64a044a57e8dcbd05b30f", 0x0000000000000006, "Hah Cod")
 MiningResult("dd540c82c49a983254c341b8e75f6290", "a1bf14daf63cc7e6cd4b0d17925b6320", 0x0000000000000006, "Alb Fly")
 MiningResult("4f97d7d6b65c8d4debe0baf3ec7695ad", "10bf08107ba1414cc4882f4e1b61277e", 0x0000000000000006, "Lob Fox")
```
"""
function mine_until(difficulty, quota)
    results = MiningResult[]
    while length(results) < quota
        key = string(rand(UInt128), base=16)
        hashed = bhash(key)

        short = SubString(String(hashed), 1, difficulty)

        if haskey(corpus, short)
            push!(results, MiningResult(key, hashed, difficulty, pretty(hashed, corpus[short]...)))
        end
    end
    results
end

"""
    create(6)

Create a new memorable unique identifier with the specified
difficulty.  Returns a [`MiningResult`](@ref) struct.

# Examples
```julia-repl
julia> create(6)
MiningResult("6278483d0d444cf841e500ace6d5d9cb", "0ddd09f61175c875bc53953759683e9c", 0x0000000000000006, "Odd Dog")
```
"""
function create(difficulty)
    mine_until(difficulty, 1)[1]
end

"""
    search(code)

Return the spirit animal from the given public identity.

# Examples
```julia-repl
julia> search("e3ec0d444d8d4b7ed9762380de7618de")
"Eme Cod"
```
"""
function search(code)
    for k = 15:-1:6
        short = SubString(code, 1, k)
        if haskey(corpus, short)
            return pretty(short, corpus[short]...)
        end
    end
    return nothing
end

"""
    pretty(code, length1, length2)

Return the animal name of code using the lengths from the corpus

"""
function pretty(code, k1, k2)
    w1 = to_readable_hex(SubString(code, 1, k1))
    w2 = to_readable_hex(SubString(code, k1 + 1, k2 + k1))
    titlecase(join([w1, w2], " "))
end

# A lookup table from hex values to characters
to_hex_dict = Dict(
"0" => "o",
"1" => "l",
"2" => "z",
"3" => "m",
"4" => "y",
"5" => "s",
"6" => "h",
"7" => "t",
"8" => "x",
"9" => "g")

from_hex_dict = Dict(value => key for (key, value) in to_hex_dict)

to_readable_hex(word) = replace(word, r"[0-9]" => c -> to_hex_dict[c])
from_readable_hex(word) = replace(word, r"[olzmyshtxg]", c -> from_hex_dict[c])

end # module
