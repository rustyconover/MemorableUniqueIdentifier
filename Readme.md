# Memorable Unique Identifier

An implementation of [Memorable Unique Identifiers](https://github.com/microprediction/muid) (Muids) in Julia.

## Usage

```julia
julia> using MemorableUniqueIdentifier

# Create a new memorable unique identifier
julia> muid = create(6)
MiningResult("19e3c5e2d69b3e4085fdf41c627a687e", "574beebdb679bc4e7e6b6d963570257e", 0x0000000000000006, "Sty Bee")

julia> muid.key
"19e3c5e2d69b3e4085fdf41c627a687e"

julia> muid.hash
"574beebdb679bc4e7e6b6d963570257e"

julia> muid.pretty
"Sty Bee"

```
