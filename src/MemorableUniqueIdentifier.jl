module MemorableUniqueIdentifier

export create, animal, validate, difficulty, search, mine_until, MiningResult

import JSON
import SHA
using Pkg.Artifacts

# Load the animals
corpus = JSON.parsefile(joinpath(artifact"animals", "animals.json"), dicttype=Dict, inttype=Int8)

"Hash the passed key and return the result in hex"
function bhash(key)
    SubString(bytes2hex(SHA.sha256(key)), 1, 32)
end

"Return the animal name from the specified key"
function animal(key)
    search(bhash(key))
end

"Check to see if the key is a memorable unique identifier"
function validate(key)
    animal(key) !== nothing
end


"The difficulty or length of the passed key"
function difficulty(key)
    a = animal(key)
    if a === nothing
        0
    else
        length(replace(a, " " => ""))
    end
end

"The result of minding for a Muid"
mutable struct MiningResult
    key::String
    hash::String
    length::UInt
    pretty::String

    function MiningResult(key, hash, length, pretty)
        new(key, hash, length, pretty)
    end
end

"Create new Muids of the specified difficulty until the quota is reached"
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

"Create a new memorable unique identifier with the specified difficulty"
function create(difficulty)
    mine_until(difficulty, 1)[1]
end

"Return the spirit animal given the public identity"
function search(code)
    for k = 15:-1:6
        short = SubString(code, 1, k)
        if haskey(corpus, short)
            return pretty(short, corpus[short]...)
        end
    end
    return nothing
end

"Return the pretty animal name of the code"
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
