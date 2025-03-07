# Tests to simulate traits

## Get a network and make it ultrametric
net = readTopology("(((Ag:5,(#H1:1::0.056,((Ak:2,(E:1,#H2:1::0.004):1):1,(M:2)#H2:1::0.996):1):1):1,(((((Az:1,Ag2:1):1,As:2):1)#H1:1::0.944,Ap:4):1,Ar:5):1):1,(P:4,20:4):3,165:7);");
#plot(net, useEdgeLength = true,  showEdgeNumber=true)

@testset "Simulate function against fixed values" begin

## Simulate a BM
Random.seed!(17920921); # fix the seed
pars = ParamsBM(1, 0.1); # params of a BM
@test_logs show(devnull, pars)

sim = simulate(net, pars); # simulate according to a BM
@test_logs show(devnull, sim)
@test_throws ErrorException sim[:Tips, :Broken]

# Extract simulated values
traitsTips = sim[:Tips]
traitsNodes = sim[:InternalNodes]
# values simulated under julia v1.6.4
#traitsTipsExp = [0.6455995230091043,-0.22588106270381064,0.05703904710270408,-0.692650796714688,1.578622599565194,1.4106438068675058,1.9166557600811194,1.0579005662214953,1.2340762902144904,1.4130757789427886,0.7115737497673081,2.201943319276716];
#traitsNodesExp = [-0.3481603206484607,-0.6698437934551933,-0.018135478212541654,-0.33844527112230455,-0.0717742134084467,0.19417331380691694,1.3919535151447147,1.5106942025265466,1.2526948727806593,1.1552248152172964,1.224823113083187,1.0617270280846993,1.0436547766241817,1.0];
@test length(traitsTips) == 12
@test length(traitsNodes) == 14
@test traitsNodes[end] == 1.0 # ancestral state
@test 0 < sum(traitsNodes)/14 < 2
@test 0 < sum(traitsTips)/14 < 2

end

###############################################################################
## Test of distibution
###############################################################################
@testset "Simulate test distribution" begin

## Generate some values
Random.seed!(18480224); # fix the seed
pars = ParamsBM(1, 0.1); # params of a BM
N = 50000
S = length(tipLabels(net));
values = zeros(Float64, (S, N));
for i = 1:N
    values[:,i] = simulate(net, pars)[:Tips]
end

## Check that each tip has same mean (1)
for s in 1:S
    @test mean(values[s, :]) ≈ pars.mu atol=0.01
end

## Check for variances
V = sharedPathMatrix(net);
Sig = V[:Tips] * pars.sigma2;
for s in 1:S
    for t in s:S
        @test cov(values[s, :], values[t, :]) ≈ Sig[s, t] atol=0.01
    end
end

end
###############################################################################
## With Shifts
###############################################################################
@testset "Simulate with Shifts" begin
global net
net = readTopology("(A:2.5,((B:1,#H1:0.5::0.4):1,(C:1,(D:0.5)#H1:0.5::0.6):1):0.5);")

## Test construction function
@test_throws ErrorException ShiftNet(net.edge[7], 3.0,  net) # can't put a shift on hybrid branch
@test_throws ErrorException ShiftNet(net.node[6], 3.0,  net) # can't put a shift on hybrid branch
@test ShiftNet(net).shift ≈ zeros(length(net.node))
@test ShiftNet(net.edge[8], 3.0,  net).shift ≈ ShiftNet([net.edge[8]], [3.0],  net).shift
@test ShiftNet(net.edge[8], 3.0,  net).shift ≈ ShiftNet(net.node[7], 3.0,  net).shift
@test ShiftNet(net.node[7], 3.0,  net).shift ≈ ShiftNet([net.node[7]], [3.0],  net).shift

## Concatenate function
sh1 = ShiftNet(net.node[7], 3.0,  net)*ShiftNet(net.node[9], -2.1,  net)
@test sh1.shift ≈ ShiftNet([net.node[7], net.node[9]], [3.0, -2.1],  net).shift
@test_throws ErrorException sh1*ShiftNet(net.edge[7], 2.0,  net) # can't concatenate if the two affect the same edges
@test sh1.shift ≈ (sh1*ShiftNet([net.node[7]], [3.0],  net)).shift

## Values and edge numbers functions
sh = ShiftNet(net.node[7], 3.0,  net)
@test getShiftEdgeNumber(sh) == [8]
@test all(getShiftValue(sh) .== [3.0])

## Hybrid shifts
@test shiftHybrid([2.0], net).shift ≈ ShiftNet(net.edge[6], 2.0, net).shift
@test shiftHybrid(2.0, net).shift ≈ shiftHybrid([2.0], net).shift

## Test simulate

# No shift on root
@test_throws ErrorException simulate(net, ParamsBM(1.0, 0.1, ShiftNet(net.node[9], 3.0,  net)))

@test ParamsBM(1.0, 1.0, net).shift.shift ≈ ParamsBM(1.0, 1.0, ShiftNet(net)).shift.shift

pars = ParamsBM(1, 0.1, ShiftNet(net.edge[8], 3.0,  net)); # params of a BM
@test_logs show(devnull, pars)
@test_logs show(devnull, pars.shift)

Random.seed!(17920921); # fix the seed
sim = simulate(net, pars); # simulate according to a BM
@test_logs show(devnull, sim)

traitsTips = sim[:Tips];
traitsNodes = sim[:InternalNodes];
meansTips = sim[:Tips, :Exp];
meansNodes = sim[:InternalNodes, :Exp];
@test meansTips == [1.,1.,1.0+3,1.0+3.0*0.6]
@test meansNodes == [1., 1.0+3.0*0.6, 1.0+3, 1., 1.]
@test length(traitsTips)  == 4
@test length(traitsNodes) == 5
@test traitsNodes[end] == 1.0 # ancestral state
@test all(-1.0 .< traitsNodes-meansNodes .< 1.0)
@test all(-1.0 .< traitsTips-meansTips .< 1.0)

# Test same as MultiBM
pars = ParamsMultiBM([1.0], 0.1*ones(1,1), ShiftNet(net.edge[8], 3.0,  net));
simMulti = simulate(net, pars); 
@test simMulti[:Tips, :Exp] ≈ sim[:Tips, :Exp]'
@test simMulti[:InternalNodes, :Exp] ≈ sim[:InternalNodes, :Exp]'

###############################################################################
## Test of distibution - with shifts
###############################################################################

## Generate some values
Random.seed!(18480224); # fix the seed
@test_throws ErrorException ParamsBM(1, 0.1, ShiftNet(net.edge[8], [3.0, 1.0],  net))
pars = ParamsBM(1, 0.1, ShiftNet(net.edge[8], 3.0,  net)); # params of a BM
N = 50000
S = length(tipLabels(net));
values = zeros(Float64, (S, N));
for i = 1:N
    values[:,i] = simulate(net, pars)[:Tips]
end

## Check that each tip has same mean (1)
expectations = simulate(net, pars)[:Tips,:Exp]
for s in 1:S
    @test mean(values[s, :]) ≈ expectations[s] atol=1e-2
end

## Check for variances
V = sharedPathMatrix(net);
Sig = V[:Tips] * pars.sigma2;
for s in 1:S
    for t in s:S
        @test cov(values[s, :], values[t,:]) ≈ Sig[s, t] atol=1e-2
    end
end

end
