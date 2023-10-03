module PlutoGrader

using Reexport
using PlutoUI
using Markdown
using Pluto
@reexport using PlutoTeachingTools
@reexport using Test
@reexport using HypertextLiteral

import Test: record, finish

export generate_assignment, ExerciseScore, grading_form, start_grading

const SOLUTION =
    r"(?i)#=\s*solution\s*starts\s*=((?s)(?!#=\s*solution\s*ends\s*=#).)*#=\s*solution\s*ends\s*=#"

const HIDDEN_TEST =
    r"(?i)\s*#=\s*hidden\s*test\s*starts\s*=((?s)(?!#=\s*hidden\s*test\s*ends\s*=#).)*#=\s*hidden\s*test\s*ends\s*=#"

function generate_assignment(fname::AbstractString; output = "")
    folder_name = dirname(fname)
    notebook_name = basename(fname)
    open(fname) do f
        notebook = read(f, String)
        notebook = replace(notebook, SOLUTION => "missing")
        #     notebook = replace(notebook, HIDDEN_TEST => "")
        output = if isempty(output)
            "instructions_" * notebook_name
        else
            splitext(output)[1] * ".jl"
        end
        output = joinpath(folder_name, output)
        write(output, notebook)
    end
    @info "Assignment instructions written to $(pwd())/$output"
end

function start_grading(dirname)
    for (root, _, files) in walkdir(dirname)
        notebooks = filter(Pluto.is_pluto_notebook, joinpath.(root, files))
        for notebook in notebooks
            nb = Pluto.load_notebook(notebook)
            for c in nb.cells
                if occursin("@testset", c.code) && !occursin("grading_form", c.code)
                    c.code = """
                    let
                      t = $(c.code)
                      grading_form(t)
                    end
                    """
                    c.code_folded = true
                end
            end
            Pluto.save_notebook(nb)
        end
    end
end
struct ExerciseScore <: Test.AbstractTestSet
    description::String
    results::Vector
    maxscore::Number
end
ExerciseScore(s::String; maxscore = 0) = ExerciseScore(s, [], maxscore)

record(g::ExerciseScore, r::Test.Result) = push!(g.results, r)
finish(g::ExerciseScore) = g
Base.length(ex::ExerciseScore) = length(ex.results)
maxscore(ex::ExerciseScore) = iszero(ex.maxscore) ? length(ex.results) : ex.maxscore
score(ex::ExerciseScore) = count(Base.Fix2(isa, Test.Pass), ex.results)
grade(ex::ExerciseScore) = score(ex) / length(ex) * maxscore(ex)

function Base.show(io::IO, mime::MIME"text/html", ex::ExerciseScore)
    num_passed = score(ex)
    numtests = length(ex)
    numtests > 0 && println(io, "<b>$num_passed / $numtests tests passed</b></br>")
    for (i, r) in enumerate(ex.results)
        if r isa Test.Pass
            println(io, "Test $i passed! 🎉</br>")
        elseif r isa Test.Fail
            println(
                io,
                """
    <details>
       <summary>Test $i failed 😞</summary>
    Expression: $(r.orig_expr)</br>
    <b>Evaluated</b>: $(r.data)
    </details>
    """,
            )
        else
            if r.test_type != :test_nonbool
                backtrace_lines = split(r.backtrace, "\n")
                idx = findfirst(Base.Fix1(occursin, "Stacktrace:"), backtrace_lines)
                backtrace_header = @htl """
                $([
                	@htl("""<b>$line</b></br>""")
                	for line in backtrace_lines[1:idx-1]
                ])
                """
                backtrace = join(backtrace_lines[idx+1:end], "\n")
                details = @htl """
                <div>
                <details>
                <summary>Test $i errored 😱 </summary>
                $backtrace_header
                   </details>
                <script>
                let ansi_up_lib = await import("https://esm.sh/ansi_up@5.2.1")
                let ansi_up = new ansi_up_lib.default()

                let t = $(string(backtrace))

                const cdiv = document.createElement("div")
                	
                t.split("\\n").map(line => {
                const el = document.createElement("div")
                el.innerHTML = ansi_up.ansi_to_html(line)
                cdiv.appendChild(el)
                })
                currentScript.parentElement.querySelector("details").appendChild(cdiv)
                </script>
                </div>
                """
                println(io, details)
            else

                println(
                    io,
                    """
        <details>
           <summary>Test $i errored 😱</summary>
        <b>Expression evaluated to non boolean</b></br>
        Expression: $(r.orig_expr)</br>
        <b>Evaluated</b>: $(r.value)
        </details>
        """,
                )
            end
        end
    end
end

function grading_form(ex::ExerciseScore)
    autoscore = grade(ex)
    title = "Grading $(ex.description)"

    grade_line = @htl """
    <div> 
    <b>Grade:</b> <input type="number" value="$autoscore"> / $(maxscore(ex))</br>
    <b>Feedback:</b></br>
    <textarea cols="30" rows="3" placeholder="Give student feedback"></textarea>
    </br>

    <script>
     const div = currentScript.closest("div")
     const textarea = div.querySelector("textarea")
     const input = div.querySelector("input")
     input.value = getCellMetadataExperimental("grading")?.grade ?? $autoscore
     textarea.value = getCellMetadataExperimental("grading")?.feedback ?? ""
     	const button = document.createElement("button")
   button.addEventListener("click", () => {
     setCellMetadataExperimental("grading", {feedback: textarea.value, grade: input.value})
   })
   button.innerText = "Save"
   return button
    </script>
    </div>
    """
    Markdown.MD(Markdown.Admonition("info", title, [grade_line, ex]))
end

end