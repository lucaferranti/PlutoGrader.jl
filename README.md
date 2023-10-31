# PlutoGrader

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://lucaferranti.github.io/PlutoGrader.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://lucaferranti.github.io/PlutoGrader.jl/dev/)
[![Build Status](https://github.com/lucaferranti/PlutoGrader.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lucaferranti/PlutoGrader.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/lucaferranti/PlutoGrader.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/lucaferranti/PlutoGrader.jl)

`PlutoGrader.jl` is inspired by [nbgrader](https://nbgrader.readthedocs.io/en/stable/) and the idea is to make it easy to prepare and grade exercises / exams in Pluto.

## Quick Start

0. Import `PlutoGrader` with `using PlutoGrader`.

1. Write your exam assignment as Pluto notebook. You can mark model solutions (e.g. for function implementations) between the comments

```
#= solution starts =#
#= solution ends =#
```

2. Once you are ready, run `generate_assignment("path/to/your_notebook_path.jl)`. This will create a file called `instructions_your_notebook_path.jl`.

3. Send it to your students

4. Collect all your students assignments and put them in a folder, e.g. `submissions`

4. Prepare the notebooks for grading with `start_grading("submissions")`. This will add the cells for grading to the exercises

5. Each feedback cell will have some precomputed grade, but you can overwrite it with your custom grade and give feedback to students. Note that feedback and grade are stored in the cell metadata, so they are persistent.

