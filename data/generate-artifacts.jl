# Typical usage: run `generate_artifacts.jl . --deploy` from within the directory that contains the files
using Pkg.Artifacts, LibGit2, ghr_jll

deploy = true
if deploy && !haskey(ENV, "GITHUB_TOKEN")
    error("For automatic github deployment, export GITHUB_TOKEN!")
end

data_dir = @__DIR__

if deploy
    # Where we will put our tarballs
    tempdir = mktempdir()

    function get_git_remote_url(repo_path::String)
        repo = LibGit2.GitRepo(repo_path)
        origin = LibGit2.get(LibGit2.GitRemote, repo, "github")
        return LibGit2.url(origin)
    end

    # Try to detect where we should upload these weights to (or just override
    # as shown in the commented-out line)
    origin_url = get_git_remote_url(dirname(@__DIR__))
    deploy_repo = "$(basename(dirname(origin_url)))/$(splitext(basename(origin_url))[1])"

    # deploy_repo = "staticfloat/ObjectDetector.jl"
    tag = "v0.0.2"
end

jsonfiles = filter(x -> endswith(x, ".json"), readdir(data_dir))

for jsonfile in jsonfiles
    name = splitext(jsonfile)[1]
    @info("Generating artifact for $(jsonfile)")
    # Create a local artifact
    hash = create_artifact() do artifact_dir
        # Copy in weights
        cp(joinpath(data_dir, jsonfile), joinpath(artifact_dir, jsonfile))
    end

    # Spit tarballs to be hosted out to local temporary directory:
    if deploy
        tarball_hash = archive_artifact(hash, joinpath(tempdir, "$(name).tar.gz"))

        # Calculate tarball url
        tarball_url = "https://github.com/$(deploy_repo)/releases/download/$(tag)/$(name).tar.gz"

        # Bind this to an Artifacts.toml file
        @info("Binding $(name) in Artifacts.toml...")
        bind_artifact!(joinpath(@__DIR__, "..", "Artifacts.toml"), name, hash; download_info=[(tarball_url, tarball_hash)], lazy=true, force=true)
    end
end

if deploy
    # Upload tarballs to a special github release
    @info("Uploading tarballs to $(deploy_repo) tag `$(tag)`")
    ghr() do ghr_exe
        run(`$ghr_exe -u rustyconover -r $(basename(deploy_repo)) $(tag) $(tempdir)`)
    end

    @info("Artifacts.toml file now contains all bound artifact names")
end