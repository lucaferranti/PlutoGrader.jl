using PlutoGrader
using Documenter

DocMeta.setdocmeta!(PlutoGrader, :DocTestSetup, :(using PlutoGrader); recursive=true)

makedocs(;
    modules=[PlutoGrader],
    authors="Luca Ferranti",
    repo="https://github.com/lucaferranti/PlutoGrader.jl/blob/{commit}{path}#{line}",
    sitename="PlutoGrader.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://lucaferranti.github.io/PlutoGrader.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/lucaferranti/PlutoGrader.jl",
    devbranch="main",
)
