using Pkg; Pkg.activate(".")
using JLD2, Plots, SolverBenchmark
using PyPlot
pyplot()

@load "ipopt_dcildl_fps_percival_82_equality.jld2" stats
solved(df) = (df.status .== :first_order)

for solver in keys(stats)
  @show "Number of problems solved by $(solver)"
  @show sum(solved(stats[solver]))
end

tim_dci = stats[:dcildl][solved(stats[:dcildl]), :elapsed_time]
tim_ipopt = stats[:ipopt][solved(stats[:dcildl]), :elapsed_time]
tim_fps = stats[:fps][solved(stats[:dcildl]), :elapsed_time]
tim_fpsff = stats[:fpsff][solved(stats[:dcildl]), :elapsed_time]
# Number of problems where Ipopt is fastest
@show sum(tim_dci .> tim_ipopt) # 20
# Number of problems where DCI is fastest
@show sum(tim_dci .< tim_ipopt) # 51

obj_dci = stats[:dcildl][solved(stats[:dcildl]), :neval_obj]
obj_ipopt = stats[:ipopt][solved(stats[:dcildl]), :neval_obj]
con_dci = stats[:dcildl][solved(stats[:dcildl]), :neval_cons]
con_ipopt = stats[:ipopt][solved(stats[:dcildl]), :neval_cons]
# Number of problems where Ipopt use less evaluations
@show sum((obj_dci .+ con_dci) .> (obj_ipopt .+ con_ipopt)) # 50
# Number of problems where DCI use less evaluations
@show sum((obj_dci .+ con_dci) .< (obj_ipopt .+ con_ipopt)) # 17
# Number where it is a tie
@show sum((obj_dci .+ con_dci) .== (obj_ipopt .+ con_ipopt)) # 4

obj_fps = stats[:fps][solved(stats[:dcildl]), :neval_obj]
con_fps = stats[:fps][solved(stats[:dcildl]), :neval_cons]
obj_fpsff = stats[:fpsff][solved(stats[:dcildl]), :neval_obj]
con_fpsff = stats[:fpsff][solved(stats[:dcildl]), :neval_cons]

costs = [
  df -> .!solved(df) * Inf + df.elapsed_time,
  df -> .!solved(df) * Inf + df.neval_obj + df.neval_cons,
]
costnames = ["Time", "Evaluations of obj + cons"]
p = profile_solvers(stats, costs, costnames, width=400, height=400)
# plot!(xticks = ([0.0, 5.0, 10.0, 15.0], ["2⁰", "2⁵", "2¹⁰", "2¹⁵"]))
plot!(xtickfontsize=9)
png(p, "ipopt_dcildl_fps_82")
