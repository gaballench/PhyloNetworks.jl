runall = false;
@testset "Testing traitLikDiscrete" begin
global net, n1, n2, d
@testset "Testing Substitution Models, P and Q matrices" begin

m1 = BinaryTraitSubstitutionModel(1.0, 2.0);
@test_logs show(devnull, m1)
m1 = BinaryTraitSubstitutionModel(1.0,2.0, ["carnivory", "non-carnivory"]);
@test nstates(m1)==2
@test PhyloNetworks.nparams(m1)==2
@test_logs show(devnull, m1)
@test_throws ErrorException PhyloNetworks.BinaryTraitSubstitutionModel(-1.0,2.0)
m2 = EqualRatesSubstitutionModel(4, 3.0);
@test nstates(m2)==4
@test PhyloNetworks.nparams(m2)==1
m2 = EqualRatesSubstitutionModel(4, 3.0, ["S1","S2","S3","S4"]);
@test_logs show(devnull, m2)
@test_throws AssertionError PhyloNetworks.EqualRatesSubstitutionModel(2, 0.001, ["abs"]);
@test_throws AssertionError PhyloNetworks.EqualRatesSubstitutionModel(1, 0.001, ["abs"]);
m3 = TwoBinaryTraitSubstitutionModel([2.0,1.2,1.1,2.2,1.0,3.1,2.0,1.1],
["carnivory", "noncarnivory", "wet", "dry"]);
@test_logs show(devnull, m3)
@test nstates(m3)==4
@test PhyloNetworks.nparams(m3)==8

@test Q(m1) == SMatrix{2,2}(-1.0, 2.0, 1.0, -2.0)
@test Q(m2) == SMatrix{4,4}(-9.0, 3, 3, 3, 3, -9, 3, 3, 3, 3, -9, 3, 3, 3, 3, -9)
@test Q(m3) ≈ SMatrix{4,4}(-3.0, 3.1, 1.2, 0.0, 1.0, -4.2, 0.0, 2.2, 2.0, 0.0, -3.2, 1.1, 0.0, 1.1, 2.0, -3.3) atol=1e-4
@test P(m1, 0.5) ≈ SMatrix{2,2}(0.7410433867161432,0.5179132265677134,0.2589566132838567,0.4820867734322865) atol=1e-15
@test P(m2, 0.1) ≈ SMatrix{4,4}(0.4758956589341516,0.17470144702194956,0.17470144702194962,0.17470144702194945,0.17470144702194956,0.47589565893415153,0.17470144702194967,0.17470144702194945,0.17470144702194962,0.17470144702194967,0.4758956589341516,0.17470144702194945,0.17470144702194945,0.17470144702194945,0.17470144702194945,0.4758956589341518) atol=1e-15
@test P(m3, 0.5) ≈ SMatrix{4,4}(0.39839916380463375,0.36847565707393248,0.23055614536582461,0.22576141081414305,0.1545971371424259,0.25768553619230444,0.14816051303688715,0.24300762748855972,0.29194735222005136,0.20198250750421617,0.35349416558860958,0.20267178083856716,0.15505634683288913,0.17185629922954704,0.26778917600867863,0.32855918085873009) atol=1e-15
#@test P(m3, 0.5) ≈ [0.22313 1.64872 2.71828 1.0; 4.71147 0.122456 1.0 1.73325; 1.82212 1.0 0.201897 2.71828; 1.0 3.00417 1.73325 0.19205] atol=1e-4
#@test P(m1, [0.02,0.01]) ≈ Array{Float64,2}[[0.980588 0.0194118; 0.0388236 0.961176], [0.990149 0.00985149; 0.019703 0.980297]] atol=1e-6
#@test P(m2, [0.02,0.01]) ≈ Array{Float64,2}[[0.839971 0.053343 0.053343 0.053343; 0.053343 0.839971 0.053343 0.053343; 0.053343 0.053343 0.839971 0.053343; 0.053343 0.053343 0.053343 0.839971], [0.91519 0.0282699 0.0282699 0.0282699; 0.0282699 0.91519 0.0282699 0.0282699; 0.0282699 0.0282699 0.91519 0.0282699; 0.0282699 0.0282699 0.0282699 0.91519]] atol=1e-6

end

@testset "types of RVAS" begin
# no rate variation
rv = RateVariationAcrossSites()
@test nparams(rv) == 0
@test_logs show(devnull, rv)
@test rv.ratemultiplier == [1.0]
# +G model
rv = RateVariationAcrossSites(alpha=1.0, ncat=4)
@test nparams(rv) == 1
@test_logs show(devnull, rv)
@test rv.ratemultiplier ≈ [0.146, 0.513, 1.071, 2.27] atol=.002
PhyloNetworks.setalpha!(rv, 2.0)
@test rv.ratemultiplier ≈ [0.319, 0.683, 1.109, 1.889] atol=.002
@test all(rv.lograteweight .≈ -1.3862943611198906)
@test_logs PhyloNetworks.setparameters!(rv, [10.])
@test PhyloNetworks.getparameters(rv) == [10]
@test PhyloNetworks.getparamindex(rv) == [2]
# +I model
rv = RateVariationAcrossSites(pinv=0.3)
@test nparams(rv) == 1
@test_logs show(devnull, rv)
@test rv.ratemultiplier ≈ [0, 1.429] atol=.002
@test rv.lograteweight ≈ [-1.2039728043259361,-0.35667494393873245]
PhyloNetworks.setpinv!(rv, 0.05)
@test rv.ratemultiplier ≈ [0, 1.053] atol=.002
@test rv.lograteweight ≈ [-2.995732273553991,-0.05129329438755058]
@test_logs PhyloNetworks.setparameters!(rv, [0.1])
@test PhyloNetworks.getparameters(rv) == [0.1]
@test PhyloNetworks.getparamindex(rv) == [1]
# +G+I model
rv = RateVariationAcrossSites(pinv=0.3, alpha=2.0, ncat=4)
@test nparams(rv) == 2
@test_logs show(devnull, rv)
@test rv.ratemultiplier ≈ [0.0, 0.456, 0.976, 1.584, 2.698] atol=.002
@test rv.lograteweight ≈ [-1.204, -1.743, -1.743, -1.743, -1.743] atol=.002
PhyloNetworks.setalpha!(rv, 3.0)
@test rv.ratemultiplier ≈ [0.0, 0.6, 1.077, 1.584, 2.454] atol=.002
PhyloNetworks.setpinv!(rv, 0.05)
@test rv.ratemultiplier ≈ [0.0, 0.442, 0.793, 1.167, 1.808] atol=.002
@test rv.lograteweight ≈ [-2.996, -1.438, -1.438, -1.438, -1.438] atol=.002
@test_logs PhyloNetworks.setparameters!(rv, [0.1,2.0])
@test PhyloNetworks.getparameters(rv) == [0.1,2.0]
@test PhyloNetworks.getparamindex(rv) == [1,2]
# test for errors
@test_throws AssertionError PhyloNetworks.setalpha!(rv, -0.05)
@test_throws AssertionError PhyloNetworks.setpinv!(rv, -0.05)
@test_throws ErrorException RateVariationAcrossSites(ncat=4)
@test_throws AssertionError RateVariationAcrossSites(alpha=-2.0, ncat=4)
@test_throws AssertionError RateVariationAcrossSites(pinv=1.5)
@test_throws AssertionError RateVariationAcrossSites(pinv=-0.01)
@test_throws AssertionError RateVariationAcrossSites(pinv=0.5, alpha=-2., ncat=2)
@test_throws AssertionError RateVariationAcrossSites(pinv=-0.1, alpha=2., ncat=2)
# default object from symbol
@test typeof(RateVariationAcrossSites(:noRV)) == PhyloNetworks.RVASGamma{1}
@test typeof(RateVariationAcrossSites(:G)) == PhyloNetworks.RVASGamma{4}
@test typeof(RateVariationAcrossSites(:I)) == PhyloNetworks.RVASInv
@test typeof(RateVariationAcrossSites(:GI)) == PhyloNetworks.RVASGammaInv{5}
@test_throws ErrorException RateVariationAcrossSites(:unknown)
end

@testset "Testing random discrete trait simulation" begin

m1 = BinaryTraitSubstitutionModel(1.0,2.0, ["carnivory", "non-carnivory"]);
m2 = EqualRatesSubstitutionModel(4, [3.0], ["S1","S2","S3","S4"]);
# on a single branch
Random.seed!(1234);
anc = [1,2,1,2,2]
@test sum(randomTrait(m1, 0.1, anc) .== anc) >= 4
Random.seed!(12345);
anc = [1,3,4,2,1]
@test sum(randomTrait(m2, 0.05, anc) .== anc) >= 4
# on a network
net = readTopology("(A:1.0,(B:1.0,(C:1.0,D:1.0):1.0):1.0);")
Random.seed!(21);
a,b = randomTrait(m1, net)
@test size(a) == (1, 7)
@test all(x in [1,2] for x in a)
@test sum(a .== 1) >=2 && sum(a .== 2) >= 2
@test b == ["-2", "-3", "-4", "D", "C", "B", "A"]
if runall
    for e in net.edge e.length = 10.0; end
    @time a,b = randomTrait(m1, net; ntraits=100000) # ~ 0.014 seconds
    sum(a[:,1])/100000 # expect 1.5 at root
    sum(a[:,2])/100000 # expect 1.333 at other nodes
    @time a,b = randomTrait(m2, net; ntraits=100000) # ~ 0.02 seconds
    length([x for x in a[:,1] if x==4])/length(a[:,1]) # expect 0.25
    length([x for x in a[:,2] if x==4])/length(a[:,2])
    length([x for x in a[:,3] if x==4])/length(a[:,3])
    length([x for x in a[:,4] if x==4])/length(a[:,4])
    length([x for x in a[:,5] if x==4])/length(a[:,5])
    length([x for x in a[:,6] if x==4])/length(a[:,6])
    length([x for x in a[:,7] if x==4])/length(a[:,7]) # expect 0.25
end

net2 = readTopology("(((A:4.0,(B:1.0)#H1:1.1::0.9):0.5,(C:0.6,#H1:1.0):1.0):3.0,D:5.0);")
Random.seed!(496);
a,b = randomTrait(m1, net2; keepInternal=false)
@test a == [1  1  1  2]
@test b == ["D", "C", "B", "A"]
Random.seed!(496);
a,b = randomTrait(m1, net2; keepInternal=true)
@test size(a) == (1, 9)
@test all(x in [1,2] for x in a)
@test b == ["-2", "D", "-3", "-6", "C", "-4", "H1", "B", "A"]
if runall
    for e in net2.edge
        if e.hybrid 
            e.length = 0.0
        end
    end
    a,b = randomTrait(m1, net2; ntraits=100000)
    # plot(net2, showNodeNumber=true) shows: H1 listed 7th, parents listed 4th and 6th
    c = map( != , a[:, 4],a[:, 6] ); # traits when parents have different traits
    n1 = sum(map( ==, a[c,7],a[c,6] )) # 39644 traits: hybrid ≠ major parent
    n2 = sum(map( ==, a[c,7],a[c,4] )) #  4401 traits: hybrid ≠ minor parent
    n1/sum(c) # expected 0.9
    n2/sum(c) # expected 0.1
    for e in net2.edge
        e.length = 0.0
    end
    net2.edge[4].length = 10.0
    a,b = randomTrait(m1, net2; ntraits=100000);
    a[:, 1] == a[:, 2]  # true: root = leaf D, as expected
    a[:, 1] == a[:, 5]  # true: root = leaf C
    sum(a[:, 6])/100000 # expected 1.3333
    a[:, 6] == a[:, 9] # true: major hybrid parent node = leaf A
end

end

@testset "Test discrete likelihood, fixed topology" begin

# test on a tree
#=
likelihood calculated in R using a fixed Q matrix, first with ace() then
with fitdiscrete(), then with fitMK(). problem: they give different results,
see http://blog.phytools.org/2015/09/the-difference-between-different.html
- ace: misses log(#states) in its log-likelihood
- fitdiscrete in geiger: uses empirical prior at root, not stationary dist,
  but "lik" object is very flexible
- fitMk is correct. also great for 2 correlated binary traits
library(ape)
mytree = read.tree(text = "(A:3.0,(B:2.0,(C:1.0,D:1.0):1.0):1.0);")
states = c(1,1,2,2)
names(states)  = mytree$tip.label
fitER = ace(states, mytree, model="ER", type="discrete")
print(fitER$loglik, digits=17) # log-likelihood = -1.9706530878326345
print(fitER$loglik - log(2), digits=17) #         -2.6638002683925799
print(fitER$rates, digits=17)  # rates = 0.3743971742794559
print(fitER$lik.anc, digits=17)# posterior probs of states at nodes: 3x2 matrix (3 internal nodes, 2 states)
library(geiger)
fitER = fitdiscrete(mytree, states, model="ER")
print(fitER$opt$q12, digits=17) # rates = 0.36836216513047726
print(fitER$opt$lnL, digits=17) # log-likelihood = -2.6626566310743804
lik = fitER$lik
lik(0.3743971742794559, root="given",root.p=c(.5,.5)) # -2.6638002630818232: same as ace + log(2)
library(phytools)
Q2 = matrix(c(-1,1,1,-1),2,2)*fitER$opt$q12
fit2 = fitMk(mytree, states, model="ER", fixedQ=Q2)
print(fit2$logLik, digits=17) # log-likelihood = -2.6638637960257574
fitER = fitdiscrete(mytree, states, model="ARD")
lik = fitER$lik
Q = c(0.29885191850718751, 0.38944304456937912) # q12, q21
lik(Q, root="given", root.p=Q[2:1]/sum(Q)) # -2.6457428692377234
lik(Q, root="flat") # -2.6447321523303113
Q = c(0.2, 0.3) # q12, q21
lik(Q, root="flat") # -2.6754091090953693 .1,.7: -3.3291679800706073
optim(Q, lik, lower=1e-8, control=list(fnscale=-1), root="flat")
# rates = 0.29993140042699212 0.38882902905265493 loglik=-2.6447247349802496
states=c(1,2,1); names(states)=c("A","B","D")
fitER = fitdiscrete(mytree, states, model="ARD"); lik = fitER$lik
lik(Q, root="flat") # -2.1207856874033491
=#

net = readTopology("(A:3.0,(B:2.0,(C:1.0,D:1.0):1.0):1.0);");
tips = Dict("A" => "lo", "B" => "lo", "C" => "hi", "D" => "hi"); #? this is supposed to be an AbstractVector, is a Dict{String,String}
m1 = EqualRatesSubstitutionModel(2,[0.36836216513047726], ["lo", "hi"]);
fit1 = (@test_logs fitdiscrete(net, m1, tips; optimizeQ=false, optimizeRVAS=false));
@test_logs show(devnull, fit1)
@test StatsBase.loglikelihood(fit1) ≈ -2.6638637960257574 atol=2e-4
@test StatsBase.dof(fit1) == 1
species = ["G","C","A","B","D"]
dat1 = DataFrame(trait = ["hi","hi","lo","lo","hi"], species = species)
m2 = BinaryTraitSubstitutionModel(0.2, 0.3, ["lo", "hi"])
fit2 = (@test_logs fitdiscrete(net, m2, dat1; optimizeQ=false, optimizeRVAS=false))
@test fit2.trait == [[1],[1],[2],[2]]
@test StatsBase.loglikelihood(fit2) ≈ -2.6754091090953693 atol=2e-4
originalstdout = stdout
redirect_stdout(devnull)
#OPTIMIZES RATES
fit2 = @test_logs fitdiscrete(net, m2, dat1; optimizeQ=true, optimizeRVAS=false, verbose=true) # 65 iterations
redirect_stdout(originalstdout)
@test fit2.model.rate ≈ [0.29993140042699212, 0.38882902905265493] atol=2e-4
@test StatsBase.loglikelihood(fit2) ≈ -2.6447247349802496 atol=2e-4
m2.rate[:] = [0.2, 0.3];
dat2 = DataFrame(trait1= ["hi","hi","lo","lo","hi"], trait2=["hi",missing,"lo","hi","lo"]);
fit3 = (@test_logs fitdiscrete(net, m2, species, dat2; optimizeQ=false, optimizeRVAS=false))

@test fit3.loglik ≈ (-2.6754091090953693 - 2.1207856874033491)
PhyloNetworks.fit!(fit3; optimizeQ=true, optimizeRVAS=false)
@test fit3.model.rate ≈ [0.3245645980184735, 0.5079500171263976] atol=1e-4
PhyloNetworks.fit!(fit3; optimizeQ=true, optimizeRVAS=true)
fit3.net = readTopology("(A,(B,(C,D):1.0):1.0);"); # no branch lengths
@test_throws ErrorException PhyloNetworks.fit!(fit3; optimizeQ=true, optimizeRVAS=true)
# fit() catches the error (due to negative branch lengths)

# test on a network, 1 hybridization
net = readTopology("(((A:4.0,(B:1.0)#H1:1.1::0.9):0.5,(C:0.6,#H1:1.0::0.1):1.0):3.0,D:5.0);")
# function below used to check that simulation proportions == likelihood
m1 = BinaryTraitSubstitutionModel([1.0, 2.0], [1,2]) # model.label = model.index
function traitprobabilities(model, net, ntraits=10)
    res, lab = randomTrait(model, net; ntraits=ntraits)
    tips = findall(in(tipLabels(net)), lab) # indices of tips: columns in res
    dat = DataFrame(species = lab[tips])
    tmp = StatsBase.countmap([res[i,tips] for i in 1:ntraits])
    i = 0
    prop = Float64[]
    for (k,v) in tmp
        i += 1
        dat[Symbol("x",i)] = k
        push!(prop, v/ntraits)
    end
    npatterns = i
    lik = Float64[]
    for i in 1:npatterns
        fit = fitdiscrete(net, model, dat[[:species, Symbol("x",i)]]; optimizeQ=false, optimizeRVAS=false)
        push!(lik, fit.loglik)
    end
    return dat, prop, lik
end
#=
using PhyloNetworks, StatsBase, DataFrames
d, p, ll = traitprobabilities(m1, net, 100000000);
all(isapprox.(log.(p), ll, atol=1e-3)) # true
hcat(log.(p), ll)
 -1.62173  -1.62184
 -3.00805  -3.00807
 -4.39506  -4.39436
 -3.00747  -3.0082 
 -3.70119  -3.70121
 -3.00759  -3.0082 
 -2.31516  -2.31505
 -2.31554  -2.31499
 -3.0083   -3.0082 
 -3.008    -3.0082 
 -2.31475  -2.31505
 -3.702    -3.70135
 -3.00836  -3.00813
 -3.70033  -3.70121
 -2.31546  -2.31499
 -3.70124  -3.70135
=#
d = DataFrame(species=["D","C","B","A"], x1=[1,1,1,1], x2=[1,2,2,1], x3=[2,2,2,2], x4=[1,1,2,2],
    x5=[2,2,2,1], x6=[2,2,1,1], x7=[1,1,2,1], x8=[2,1,1,1], x9=[2,1,2,1], x10=[1,2,1,2],
    x11=[1,2,1,1], x12=[2,2,1,2], x13=[2,1,1,2], x14=[1,2,2,2], x15=[1,1,1,2], x16=[2,1,2,2])
lik = Float64[]
for i in 1:16
    fit = fitdiscrete(net, m1, d[!,[:species, Symbol("x",i)]]; optimizeQ=false, optimizeRVAS=false)
    push!(lik, fit.loglik)
end
traitloglik_all16 = [-1.6218387598967712, -3.008066347196894, -4.3943604143403245, -3.008199100743402,
    -3.70121329832901, -3.0081981601869483, -2.315051933868397, -2.314985711030534,
    -3.0081988850020873, -3.0081983709272504, -2.3150512090547584, -3.70134532205944,
    -3.008132923628349, -3.7012134632082083, -2.3149859724945876, -3.7013460518770915]
@test lik ≈ traitloglik_all16
fit1 = fitdiscrete(net, m1, d[!,:species], d[!,2:17]; optimizeQ=false, optimizeRVAS=false)
@test fit1.loglik ≈ sum(traitloglik_all16) # log of product = sum of logs

# with parameter estimation
net = readTopology("(((A:2.0,(B:1.0)#H1:0.1::0.9):1.5,(C:0.6,#H1:1.0::0.1):1.0):0.5,D:2.0);")
m1 = BinaryTraitSubstitutionModel([1.0, 1.0], ["lo", "hi"])
dat = DataFrame(species=["C","A","B","D"], trait=["hi","lo","lo","hi"])
fit1 = fitdiscrete(net, m1, dat; optimizeQ=false, optimizeRVAS=false)
@test fit1.loglik ≈ -2.77132013004859
PhyloNetworks.fit!(fit1; optimizeQ=true, optimizeRVAS=false)
@test fit1.model.rate ≈ [0.2722263130324768, 0.34981109618902395] atol=1e-4
@test fit1.loglik ≈ -2.727701700695741
# for information only: function used locally to check for correct parameter estimation
function simulateManyTraits_estimate(ntraits)
    m1 = BinaryTraitSubstitutionModel([1.0, 0.5], [1,2])
    res, lab = randomTrait(m1, net; ntraits=ntraits)
    tips = findall(in(tipLabels(net)), lab) # indices of tips: columns in res
    dat = DataFrame(transpose(res[:,tips])); species = lab[tips]
    return fitdiscrete(net, m1, species, dat; optimizeRVAS = false)
end
# simulateManyTraits_estimate(100000)
# α=1.1124637623451075, β=0.5604529225895175, loglik=-25587.1  with ntraits=10000
# α=0.9801472136310236, β=0.4891696992781437, loglik=-255755.6 with ntraits=100000
# time with ntraits=100000: 907.2s = 15min 7s (one single processor, no binning of traits with same pattern)

# ancestral state reconstruction - fixit!!
fit1.model.rate[1] = 0.2722263130324768;
fit1.model.rate[2] = 0.34981109618902395;
@test_throws ErrorException ancestralStateReconstruction(fit1, 4) # 1 trait, not 4: error
asr = ancestralStateReconstruction(fit1)
@test DataFrames.propertynames(asr) == [:nodenumber, :nodelabel, :lo, :hi]
@test asr[!,:nodenumber] == collect(1:9)
@test asr[!,:nodelabel] == ["A","B","C","D","5","6","7","8","H1"]
@test asr[!,:lo] ≈ [1.,1.,0.,0., 0.28602239466671175, 0.31945742289603263,
    0.16855042517785512, 0.7673588716207436, 0.7827758475866091] atol=1e-5
@test asr[!,:hi] ≈ [0.,0.,1.,1.,0.713977605333288, 0.6805425771039674,
    0.8314495748221447, 0.23264112837925616, 0.21722415241339132] atol=1e-5
pltw = [-0.08356534477069566, -2.5236181051014333]
@test PhyloNetworks.posterior_logtreeweight(fit1) ≈ pltw atol=1e-5
@test PhyloNetworks.posterior_logtreeweight(fit1, 1:1) ≈ reshape(pltw, (2,1)) atol=1e-5

end # end of testset, fixed topology

@testset "testing readfastatodna" begin
fastafile = joinpath(@__DIR__, "..", "examples", "test_8_withrepeatingsites.aln")
#fastafile = abspath(joinpath(dirname(Base.find_package("PhyloNetworks")), "..", "examples", "test_8_withrepeatingsites.aln"))
dat, weights = readfastatodna(fastafile, true);
@test weights ==  [3.0, 1.0, 1.0, 2.0, 1.0]
#check that no columns are repeated, only correct columns removed
@test size(dat,2) == 6

#test on data with no repeated site patterns
fastafile = joinpath(@__DIR__, "..", "examples", "Ae_bicornis_8sites.aln")
#fastafile = abspath(joinpath(dirname(Base.find_package("PhyloNetworks")), "..", "examples", "Ae_bicornis_8sites.aln"))
dat, weights = readfastatodna(fastafile, true);
#check that weights are correct
@test weights == ones(Float64, 8)
#check that no columns are repeated, only correct columns removed
@test size(dat,2) == 9
end #testing readfastatodna

@testset "NucleicAcidSubsitutionModels" begin

#test NASM models basics
mJC69 = JC69(0.5, false);
@test Q(mJC69) ≈ [-0.5        0.166667   0.166667   0.166667;
                    0.166667  -0.5        0.166667   0.166667;
                    0.166667   0.166667  -0.5        0.166667;
                    0.166667   0.166667   0.166667  -0.5] atol=1e-5
@test P(mJC69, 1.0) ≈ [0.635063  0.121646  0.121646  0.121646;
                        0.121646  0.635063  0.121646  0.121646;
                        0.121646  0.121646  0.635063  0.121646;
                        0.121646  0.121646  0.121646  0.635063] atol=1e-5

@test_throws ErrorException HKY85([0.5, 0.5], [0.25, 0.25, 0.25, 0.25], true)
@test_throws ErrorException HKY85([.1,.1,.1], [0.25, 0.25, 0.25, 0.25], false)
@test_throws ErrorException HKY85([0.5], [0.25, 0.25, 0.25, 0.25], false)
#= HKY matrix from simulations with seq-gen
echo '(t1:0,t2:0.1);' > twotaxon.phy
seq-gen -m HKY -l 10000 -t 1.1145320197044333 -f 0.37 0.40 0.05 0.18 -of < twotaxon.phy > twotaxon_10000.fas
seq-gen -m HKY -l 100000000 -t 1.1145320197044333 -f 0.37 0.40 0.05 0.18 -of < twotaxon.phy > twotaxon.fas
# transition/transversion ratio = 1.11453 (K=3)
# tstv = kappa (here we want 3) * (pa*pg + pc*pt)/(py*pr) = 1.1145320197044333
system.time(dat <- phyDat(read.dna("twotaxon.fas", format="fasta"))) # 99 seconds
bf = baseFreq(dat) # 0.36996372 0.40000796 0.04997551 0.18005282
w = attr(dat, "weight")
acgt = attr(dat, "levels")
mat = matrix(NA,4,4, dimnames=list(acgt, acgt))
for (pattern in 1:16){
    i = dat[[1]][pattern]
    j = dat[[2]][pattern]
    mat[i,j] = w[pattern]
}
mat/sum(w) # joint probabilities
           a          c          g          t
a 0.34529570 0.01368654 0.00483382 0.00615715
c 0.01366887 0.36582571 0.00185338 0.01864593
g 0.00483558 0.00185214 0.04245549 0.00083627
t 0.00615407 0.01865763 0.00082884 0.15441288
m = (mat/sum(w) + t(mat/sum(w)))/2 # symmetric: we know it should be bc reversible
           a          c           g           t
a 0.34529570 0.01367771 0.004834700 0.006155610
c 0.01367771 0.36582571 0.001852760 0.018651780
g 0.00483470 0.00185276 0.042455490 0.000832555
t 0.00615561 0.01865178 0.000832555 0.154412880
m/bf # transition probabilities
           a          c           g          t
a 0.93332315 0.03697040 0.013068038 0.01663842
c 0.03419358 0.91454609 0.004631808 0.04662852
g 0.09674139 0.03707336 0.849525983 0.01665926
t 0.03418780 0.10359060 0.004623949 0.85759765
@time dna_dat, dna_weights = readfastatodna("twotaxon_10000.fas", true);
# 1000 sites: 0.009950 seconds. 10_000 sites: 0.272987 seconds
# takes forever with 100_000_000 sites: far from linear
=#
mHKY85 = HKY85([0.5, 0.5], [0.25, 0.25, 0.25, 0.25], false)
@test Q(mHKY85) ≈ [ -0.375   0.125   0.125   0.125;
                    0.125  -0.375   0.125   0.125;
                    0.125   0.125  -0.375   0.125;
                    0.125   0.125   0.125  -0.375] atol=1e-5
@test P(mHKY85, 1.0) ≈ [0.704898   0.0983673  0.0983673  0.0983673;
                        0.0983673  0.704898   0.0983673  0.0983673;
                        0.0983673  0.0983673  0.704898   0.0983673;
                        0.0983673  0.0983673  0.0983673  0.704898] atol=1e-5

@test P!(P(mHKY85, 1.0), mHKY85, 3.0) ≈ [0.417348  0.194217  0.194217  0.194217;
                                        0.194217  0.417348  0.194217  0.194217;
                                        0.194217  0.194217  0.417348  0.194217;
                                        0.194217  0.194217  0.194217  0.417348] atol=1e-5

mHKY85rel = HKY85(3.0, [.37,.40,.05,.18])
@test Q(mHKY85rel) ≈ [-.7086 .388274 .145603 .174723;
    .359154 -.931858  .0485343 .52417;
    1.07746  .388274  -1.64046 .174723;
    .359154  1.16482  .0485343 -1.57251] atol=1e-3
@test PhyloNetworks.P(HKY85([3.0], [.37,.40,.05,.18]), 0.1) ≈
  [.93332315 .03697040 .013068038 .01663842; # values: from seq-gen simulations
   .03419358 .91454609 .004631808 .04662852;
   .09674139 .03707336 .849525983 .01665926;
   .03418780 .10359060 .004623949 .85759765] atol=1e-3

@test P!(P(mJC69, 1.0), mJC69, 3.5) ≈ [0.322729  0.225757  0.225757  0.225757;
                                        0.225757  0.322729  0.225757  0.225757;
                                        0.225757  0.225757  0.322729  0.225757;
                                        0.225757  0.225757  0.225757  0.322729] atol=1e-5

@test_logs show(devnull, mJC69)
@test_logs show(devnull, mHKY85)
end # end of testing NASMs

@testset "fitdiscrete for NucleicAcidSubsitutionModels & RateVariationAcrossSites" begin
# test fitdiscrete with NASM #
    # based on 3 alignments in PhyloNetworks/examples
net = readTopology("(A:3.0,(B:2.0,(C:1.0,D:1.0):1.0):1.0);");
tips = Dict("A" => BioSymbols.DNA_A, "B" => BioSymbols.DNA_A, "C" => BioSymbols.DNA_G, "D" => BioSymbols.DNA_G);

# JC without optimization (confirmed with ape ace() function and phangorn)
mJC69 = JC69(0.2923350741254221, false) #ace() gives Q matrix cell, not rate. lambda = (1.0/3.0)*obj.rate[1] so rate = 3*0.097445024708474035 = 0.2923350741254221
                                        #phangorn gives rate =  0.292336
fitJC69 = fitdiscrete(net, mJC69, tips; optimizeQ=false);
@test loglikelihood(fitJC69) ≈ -4.9927386890207304 atol=2e-6 #ace() from ape pkg and our method agree here.
                                #from ace() + log(4)

# JC without optimize at 0.25
mJC69 = JC69([0.25], false)
fitJC69 = fitdiscrete(net, mJC69, tips; optimizeQ=false);
@test loglikelihood(fitJC69) ≈ -4.99997 atol=2e-3 #from phangorn

# JC with optimization (confirmed with ape ace() function and phangorn)
mJC69 = JC69([0.25], false)
fitJC69 = fitdiscrete(net, mJC69, tips; optimizeQ=true)
@test Q(fitJC69.model)[1,2] ≈ 0.097445024708474035 atol = 2e-3 #confirmed with ace() in ape pkg (ace calls Q matrix rate)
@test loglikelihood(fitJC69) ≈ -4.9927386890207304 atol=2e-6 #confirmed with ape pkg ace() + log(4) and phangorn optim.pml

#= HKY without optimization, confirmed with phangorn R code:
library(phangorn)
mytree = read.tree(text = "(A:3.0,(B:2.0,(C:1.0,D:1.0):1.0):1.0);")
states = factor(c(1,1,3,3), levels=c("1","2","3","4"))
names(states)  = mytree$tip.label
mydata <- as.phyDat(states)
# likelihood without optimization
fitHKY_phan <- pml(mytree, mydata, model = "HKY") #this is equivalent to rate = [4/3, 4/3]
print(fitHKY_phan$logLik, digits = 10) # -5.365777014
fitHKY_phan$rate # 1
=#
mHKY85 = HKY85([4.0/3, 4.0/3], [0.25, 0.25, 0.25, 0.25], false); # absolute
fitHKY85 = fitdiscrete(net, mHKY85, tips; optimizeQ=false);
@test loglikelihood(fitHKY85) ≈ -5.365777014 atol = 2e-8 # equivalent to phangorn $logLik
mHKY85 = HKY85([1.0], [0.25, 0.25, 0.25, 0.25], true); # relative
fitHKY85 = fitdiscrete(net, mHKY85, tips; optimizeQ=false);
@test loglikelihood(fitHKY85) ≈ -5.365777014 atol = 2e-8 # equivalent to above b/c transversion/transition rates equal

#= HKY85 with optimization, confirmed with ape ace() in R
# NOTE: ace does not include log(#states) in its log-likelihood
library(ape)
mytree = read.tree(text = "(A:3.0,(B:2.0,(C:1.0,D:1.0):1.0):1.0);")
states = factor(c(1,1,3,3), levels=c("1","2","3","4"))
names(states)  = mytree$tip.label
HKYQ <- matrix(c(0,2,1,2,  2,0,2,1, 1,2,0,2, 2,1,2,0), 4)
fitHKY = ace(states, mytree,  type = "discrete", model=HKYQ)
print(fitHKY$loglik - log(4), digits=17) # -3.3569474489525244
print(fitHKY$rates*4, digits=17) # 1.4975887229148119 0.0
=#
mHKY85 = HKY85([0.5, 0.1], [0.25, 0.25, 0.25, 0.25], false); # absolute
fitHKY85 = fitdiscrete(net, mHKY85, tips; optimizeQ=true)
@test fitHKY85.model.rate[1] ≈ 1.4975887229148119 atol = 2e-4 # equivalent to ape ace() rate * 4
@test loglikelihood(fitHKY85) ≈ -3.3569474489525244 atol = 2e-8 # equivalent to ape ace() fitHKY$loglik - log(4)

# test RateVariationAcrossSites with NASM
rv = RateVariationAcrossSites(alpha=1.0, ncat=4)
rv.ratemultiplier[:] = [0.1369538, 0.4767519, 1.0000000, 2.3862944] # NOTE: phangorn calculates gamma quantiles differently, so I assign them for testing
mJC69 = JC69([1.0], true)
fitJC69rv = fitdiscrete(net, mJC69, rv, tips; optimizeQ=false, optimizeRVAS=false, ftolRel=1e-20);
@test loglikelihood(fitJC69rv) ≈ -5.26390008 atol = 2e-8
@test dof(fitJC69rv) == 1 # relative JC: 0, rate variation: 1

fitJC69rvOpt = fitdiscrete(net, mJC69, rv, tips, optimizeQ=false, optimizeRVAS=true);

mHKY85 = HKY85([4.0/3, 4.0/3], [0.25, 0.25, 0.25, 0.25], false);
fitHKY85rv = fitdiscrete(net, mHKY85, rv, tips; optimizeQ=false, optimizeRVAS=false);
@test loglikelihood(fitHKY85rv) ≈ -5.2639000803742979 atol = 2e-5 #from phangorn
@test dof(fitHKY85rv) == 3 # absolute HKY (fixed base freqs.): 2, rate variation: 1

fitHKY85rvOpt = fitdiscrete(net, mHKY85, rv, tips; optimizeQ=false, optimizeRVAS=true);

## TEST WRAPPERS ##
#for species, trait data
net_dat = readTopology("(((A:2.0,(B:1.0)#H1:0.1::0.9):1.5,(C:0.6,#H1:1.0::0.1):1.0):0.5,D:2.0);")
dat = DataFrame(species=["C","A","B","D"], trait=["hi","lo","lo","hi"])
species_alone = ["C","A","B","D"]
dat_alone = DataFrame(trait=["hi","lo","lo","hi"])
net_tips = readTopology("(A:3.0,(B:2.0,(C:1.0,D:1.0):1.0):1.0);");
@test_throws ErrorException fitdiscrete(net_dat, :bogus, species_alone, dat_alone);
@test_throws ErrorException fitdiscrete(net_dat, BinaryTraitSubstitutionModel([1.,1.], ["lo","hi"]), dat_alone);
s1 = fitdiscrete(net_dat, :ERSM, species_alone, dat_alone; optimizeQ=false)
@test_logs show(devnull, s1)
s1 = fitdiscrete(net_dat, :ERSM, species_alone, dat_alone, :G; optimizeQ=false, optimizeRVAS=false)
@test_logs show(devnull, s1)
s2 = fitdiscrete(net_dat, :BTSM, species_alone, dat_alone; optimizeQ=false, optimizeRVAS=false)
@test_logs show(devnull, s2)
@test_throws ErrorException fitdiscrete(net_dat, :TBTSM, species_alone, dat_alone; optimizeQ=false, optimizeRVAS=false)
dna_alone = DataFrame(trait=['A','C','C','A'])
s3 = fitdiscrete(net_dat, :JC69, species_alone, dna_alone, :G; optimizeRVAS=false, ftolRel=.1,ftolAbs=.2,xtolRel=.1,xtolAbs=.2) # 1 site: no info to optimize RVAS
@test s3.model.relative
@test s3.ratemodel.alpha == [1.0]
@test_logs show(devnull, s3)
s4 = fitdiscrete(net_dat, :HKY85, species_alone, dna_alone, :G; optimizeRVAS=false, ftolRel=.1,ftolAbs=.2,xtolRel=.1,xtolAbs=.2)
@test s4.model.relative
@test s4.model.pi == [3,3,1,1]/8
@test s4.ratemodel.alpha == [1.0]
@test_logs show(devnull, s4)

#for dna data (output of fastatodna)
fastafile = joinpath(@__DIR__, "..", "examples", "Ae_bicornis_Tr406_Contig10132.aln")
#fastafile = abspath(joinpath(dirname(Base.find_package("PhyloNetworks")), "..", "examples", "Ae_bicornis_Tr406_Contig10132.aln"))
dna_dat, dna_weights = readfastatodna(fastafile, true);
net_dna = readTopology("((((((((((((((Ae_caudata_Tr275,Ae_caudata_Tr276),Ae_caudata_Tr139))#H1,#H2),(((Ae_umbellulata_Tr266,Ae_umbellulata_Tr257),Ae_umbellulata_Tr268),#H1)),((Ae_comosa_Tr271,Ae_comosa_Tr272),(((Ae_uniaristata_Tr403,Ae_uniaristata_Tr357),Ae_uniaristata_Tr402),Ae_uniaristata_Tr404))),(((Ae_tauschii_Tr352,Ae_tauschii_Tr351),(Ae_tauschii_Tr180,Ae_tauschii_Tr125)),(((((((Ae_longissima_Tr241,Ae_longissima_Tr242),Ae_longissima_Tr355),(Ae_sharonensis_Tr265,Ae_sharonensis_Tr264)),((Ae_bicornis_Tr408,Ae_bicornis_Tr407),Ae_bicornis_Tr406)),((Ae_searsii_Tr164,Ae_searsii_Tr165),Ae_searsii_Tr161)))#H2,#H4))),(((T_boeoticum_TS8,(T_boeoticum_TS10,T_boeoticum_TS3)),T_boeoticum_TS4),((T_urartu_Tr315,T_urartu_Tr232),(T_urartu_Tr317,T_urartu_Tr309)))),(((((Ae_speltoides_Tr320,Ae_speltoides_Tr323),Ae_speltoides_Tr223),Ae_speltoides_Tr251))H3,((((Ae_mutica_Tr237,Ae_mutica_Tr329),Ae_mutica_Tr244),Ae_mutica_Tr332))#H4))),Ta_caputMedusae_TB2),S_vavilovii_Tr279),Er_bonaepartis_TB1),H_vulgare_HVens23);");
@test PhyloNetworks.startingrate(net_dna) ≈ 0.02127659574468085 # 1/length(net_dna.leaf)
for edge in net_dna.edge # adds branch lengths
    setLength!(edge,1.0)
    if edge.gamma < 0
        setGamma!(edge, 0.5)
    end
end

d1 = (@test_logs (:warn, r"^the network contains taxa with no data") fitdiscrete(net_dna,
  :ERSM, dna_dat, dna_weights; optimizeQ=false, optimizeRVAS=false))
@test_logs show(devnull, d1)
@test_throws ErrorException fitdiscrete(net_dna, :BTSM, dna_dat, dna_weights; optimizeQ=false, optimizeRVAS=false);
@test_throws ErrorException fitdiscrete(net_dna, :TBTSM, dna_dat, dna_weights; optimizeQ=false, optimizeRVAS=false);
@test_throws ErrorException fitdiscrete(net_dna, :bogus, dna_dat, dna_weights; optimizeQ=false, optimizeRVAS=false);
d2 = (@test_logs (:warn, r"^the network contains taxa with no data") fitdiscrete(net_dna,
  :JC69, dna_dat, dna_weights; optimizeQ=false, optimizeRVAS=false))
@test_logs show(devnull, d2)
d2 = (@test_logs (:warn, r"^the network contains taxa with no data") fitdiscrete(net_dna,
  :JC69, dna_dat, dna_weights, :GI; optimizeQ=false, optimizeRVAS=false))
@test_logs show(devnull, d2)
d3 = (@test_logs (:warn, r"^the network contains taxa with no data") fitdiscrete(net_dna,
  :HKY85, dna_dat, dna_weights; optimizeQ=false, optimizeRVAS=false))
@test_logs show(devnull, d3)

end #testing fitdiscrete for NucleicAcidSubsitutionModels & RateVariationAcrossSites

@testset "readfastatodna with NASM and RateVariationAcrossSites" begin
fastafile = joinpath(@__DIR__, "..", "examples", "Ae_bicornis_Tr406_Contig10132.aln")
#fastafile = abspath(joinpath(dirname(Base.find_package("PhyloNetworks")), "..", "examples", "Ae_bicornis_Tr406_Contig10132.aln"))
dna_dat, dna_weights = readfastatodna(fastafile, true);

dna_net_top = readTopology("((((((((((((((Ae_caudata_Tr275,Ae_caudata_Tr276),Ae_caudata_Tr139))#H1,#H2),(((Ae_umbellulata_Tr266,Ae_umbellulata_Tr257),Ae_umbellulata_Tr268),#H1)),((Ae_comosa_Tr271,Ae_comosa_Tr272),(((Ae_uniaristata_Tr403,Ae_uniaristata_Tr357),Ae_uniaristata_Tr402),Ae_uniaristata_Tr404))),(((Ae_tauschii_Tr352,Ae_tauschii_Tr351),(Ae_tauschii_Tr180,Ae_tauschii_Tr125)),(((((((Ae_longissima_Tr241,Ae_longissima_Tr242),Ae_longissima_Tr355),(Ae_sharonensis_Tr265,Ae_sharonensis_Tr264)),((Ae_bicornis_Tr408,Ae_bicornis_Tr407),Ae_bicornis_Tr406)),((Ae_searsii_Tr164,Ae_searsii_Tr165),Ae_searsii_Tr161)))#H2,#H4))),(((T_boeoticum_TS8,(T_boeoticum_TS10,T_boeoticum_TS3)),T_boeoticum_TS4),((T_urartu_Tr315,T_urartu_Tr232),(T_urartu_Tr317,T_urartu_Tr309)))),(((((Ae_speltoides_Tr320,Ae_speltoides_Tr323),Ae_speltoides_Tr223),Ae_speltoides_Tr251))H3,((((Ae_mutica_Tr237,Ae_mutica_Tr329),Ae_mutica_Tr244),Ae_mutica_Tr332))#H4))),Ta_caputMedusae_TB2),S_vavilovii_Tr279),Er_bonaepartis_TB1),H_vulgare_HVens23);");
for edge in dna_net_top.edge #adds branch lengths
    setLength!(edge,1.0)
end

nasm_model = JC69([0.3], false);       # relative=false: absolute version
rv = RateVariationAcrossSites(alpha=1.0, ncat=2); # 2 rates to go faster
# below: error because missing gammas, after warning for extra taxa
(@test_logs (:warn, r"pruned") @test_throws ErrorException fitdiscrete(dna_net_top, nasm_model, dna_dat, dna_weights; optimizeQ=false, optimizeRVAS=false))
# set gamma at the 3 reticulations, to fix error above
setGamma!(dna_net_top.edge[6],0.6)
setGamma!(dna_net_top.edge[7],0.6)
setGamma!(dna_net_top.edge[58],0.6)

dna_net = (@test_logs (:warn, r"^the network contains taxa with no data") fitdiscrete(dna_net_top,
    nasm_model, dna_dat, dna_weights; optimizeQ=false))
@test dna_net.model.rate == nasm_model.rate
@test dna_net.ratemodel.ratemultiplier == [1.0]
dna_net_optQ = (@test_logs (:warn, r"^the network contains taxa with no data") fitdiscrete(dna_net_top,
    nasm_model, rv, dna_dat, dna_weights; optimizeQ=true, optimizeRVAS=false, ftolRel=.1, ftolAbs=.2, xtolRel=.1, xtolAbs=.2))
@test dna_net_optQ.model.rate != nasm_model.rate
@test dna_net_optQ.ratemodel.alpha[1] == 1.0
dna_net_optRVAS = (@test_logs (:warn, r"^the network contains taxa with no data") fitdiscrete(dna_net_top,
    nasm_model, rv, dna_dat, dna_weights; optimizeQ=false, optimizeRVAS=true, ftolRel=.1, ftolAbs=.2, xtolRel=.1, xtolAbs=.2))
@test dna_net_optRVAS.model.rate == nasm_model.rate
@test dna_net_optRVAS.ratemodel.alpha[1] != 1.0
@test dna_net_optRVAS.ratemodel.ratemultiplier ≈ [0.02, 1.98] atol=0.05
originalstdout = stdout
redirect_stdout(devnull)
dna_net_opt_both = (@test_logs (:warn, r"^the network contains taxa with no data") fitdiscrete(dna_net_top,
    nasm_model, rv, dna_dat, dna_weights; optimizeQ=true, optimizeRVAS=true, closeoptim=true, ftolRel=.1, ftolAbs=.2, xtolRel=.1, xtolAbs=.2, verbose=true))
redirect_stdout(originalstdout)
@test dna_net_opt_both.model.rate != nasm_model.rate
@test dna_net_opt_both.ratemodel.alpha[1] != 1.0
# for this example: all NaN values if no lower bound on RVAS's alpha, because it goes to 0
@test dna_net_opt_both.ratemodel.ratemultiplier ≈ [1e-4, 2.0] atol=0.02
@test dna_net_opt_both.loglik > -3800.
# should be ~ -3708.1 -- but low tolerance: just check it's not horrible.
# with default tol: alpha=0.05, JC rate=0.00288, loglik=-3337.413
# under wrong model where all traits have evolved under same (unknown) displayed tree:
# should be ~ -2901.3 -- but low tolerance: just check it's > -3100.
# with default strict tolerance values: takes *much* longer, alpha=0.05, JC rate = 0.00293, loglik = -2535.618
end # of testing readfastatodna with NASM and RateVariationAcrossSites

@testset "stationary and empiricalDNAfrequencies" begin

BTSM_1 = BinaryTraitSubstitutionModel(1.0, 2.0);
ERSM_1 = EqualRatesSubstitutionModel(4, 3.0, ["S1","S2","S3","S4"]);
@test PhyloNetworks.stationary(BTSM_1) ≈ [0.6666666666666666, 0.3333333333333333] atol=1e-6
@test PhyloNetworks.stationary(ERSM_1) == [0.25, 0.25, 0.25, 0.25]

JC69_1 = JC69(0.5, false);
@test PhyloNetworks.stationary(JC69_1) == [0.25, 0.25, 0.25, 0.25]
HKY85_1 = HKY85([0.5, 0.5], [0.2, 0.3, 0.25, 0.25], false)
@test PhyloNetworks.stationary(HKY85_1) == [0.2, 0.3, 0.25, 0.25]

# test empiricalDNAfrequencies with string type
# Bayesian correction by default: more stable and avoids zeros
dna_String = view(DataFrame(A = ["s1", "s2"], site1 = ["A", "A"], site2 = ["G", "T"]), :, 2:3)
@test PhyloNetworks.empiricalDNAfrequencies(dna_String, [1, 1]) ≈ [3,1,2,2]/(4+4)
# with char type
dna_Char = view(DataFrame(A = ["s1", "s2"], site1 = ['A', 'A'], site2 = ['G', 'T']), :, 2:3)
@test PhyloNetworks.empiricalDNAfrequencies(dna_Char, [1, 1]) ≈ [3,1,2,2]/(4+4)
# uncorrected estimate
@test PhyloNetworks.empiricalDNAfrequencies(dna_Char, [1, 1], false) ≈ [2,0,1,1]/4
# with ambiguous sites
dna_Char = DataFrame(site1 = ['A','A','Y'], site2 = ['G','T','V'])
@test PhyloNetworks.empiricalDNAfrequencies(dna_Char, [1, 1], false, false) ≈ [2,0,1,1]/4
@test PhyloNetworks.empiricalDNAfrequencies(dna_Char, [1, 1], false) ≈ [2+1/3,1/2+1/3,1+1/3,1+1/2]/6
# with DNA type and weights
#fastafile = abspath(joinpath(dirname(Base.find_package("PhyloNetworks")), "..", "examples", "test_8_withrepeatingsites.aln"))
fastafile = joinpath(@__DIR__, "..", "examples", "test_8_withrepeatingsites.aln")
dat, weights = readfastatodna(fastafile, true);
@test PhyloNetworks.empiricalDNAfrequencies(view(dat, :, 2:6), weights) ≈ [0.21153846153846154, 0.3076923076923077, 0.40384615384615385, 0.07692307692307693] atol=1e-9

#test PhyloNetworks.empiricalDNAfrequencies with bad type
dna_bad = view(DataFrame(A = ["s1", "s2"], trait1 = ["hi", "lo"], trait2 = ["lo", "hi"]), :, 2:3)
@test_throws ErrorException PhyloNetworks.empiricalDNAfrequencies(dna_bad, [1, 1])

end #testing stationary and empiricalDNAfrequencies functions

@testset "startingBL!" begin
fastafile = joinpath(@__DIR__, "..", "examples", "Ae_bicornis_8sites.aln") # 8 sites only
# locally: fastafile = joinpath(@__DIR__, "../../dev/PhyloNetworks/", "examples", "Ae_bicornis_8sites.aln") #small data
dna_dat, dna_weights = readfastatodna(fastafile, true);
# 22 species, 3 hybrid nodes, 103 edges
dna_net = readTopology("((((((((((((((Ae_caudata_Tr275,Ae_caudata_Tr276),Ae_caudata_Tr139))#H1,#H2),(((Ae_umbellulata_Tr266,Ae_umbellulata_Tr257),Ae_umbellulata_Tr268),#H1)),((Ae_comosa_Tr271,Ae_comosa_Tr272),(((Ae_uniaristata_Tr403,Ae_uniaristata_Tr357),Ae_uniaristata_Tr402),Ae_uniaristata_Tr404))),(((Ae_tauschii_Tr352,Ae_tauschii_Tr351),(Ae_tauschii_Tr180,Ae_tauschii_Tr125)),(((((((Ae_longissima_Tr241,Ae_longissima_Tr242),Ae_longissima_Tr355),(Ae_sharonensis_Tr265,Ae_sharonensis_Tr264)),((Ae_bicornis_Tr408,Ae_bicornis_Tr407),Ae_bicornis_Tr406)),((Ae_searsii_Tr164,Ae_searsii_Tr165),Ae_searsii_Tr161)))#H2,#H4))),(((T_boeoticum_TS8,(T_boeoticum_TS10,T_boeoticum_TS3)),T_boeoticum_TS4),((T_urartu_Tr315,T_urartu_Tr232),(T_urartu_Tr317,T_urartu_Tr309)))),(((((Ae_speltoides_Tr320,Ae_speltoides_Tr323),Ae_speltoides_Tr223),Ae_speltoides_Tr251))H3,((((Ae_mutica_Tr237,Ae_mutica_Tr329),Ae_mutica_Tr244),Ae_mutica_Tr332))#H4))),Ta_caputMedusae_TB2),S_vavilovii_Tr279),Er_bonaepartis_TB1),H_vulgare_HVens23);");
# create trait object
dat2 = PhyloNetworks.traitlabels2indices(dna_dat[!,2:end], JC69([0.5]))
o, dna_net = @test_logs (:warn, "the network contains taxa with no data: those will be pruned") match_mode=:any PhyloNetworks.check_matchtaxonnames!(dna_dat[:,1], dat2, dna_net)
trait = view(dat2, o)
PhyloNetworks.startingBL!(dna_net, trait, dna_weights)
@test maximum(e.length for e in dna_net.edge) > 0.03
@test_logs PhyloNetworks.startingBL!(dna_net, trait) # no dna_weights

dna_dat, dna_weights = readfastatodna(fastafile, true);
dna_net = readTopology("((((((((((((((Ae_caudata_Tr275,Ae_caudata_Tr276),Ae_caudata_Tr139))#H1,#H2),(((Ae_umbellulata_Tr266,Ae_umbellulata_Tr257),Ae_umbellulata_Tr268),#H1)),((Ae_comosa_Tr271,Ae_comosa_Tr272),(((Ae_uniaristata_Tr403,Ae_uniaristata_Tr357),Ae_uniaristata_Tr402),Ae_uniaristata_Tr404))),(((Ae_tauschii_Tr352,Ae_tauschii_Tr351),(Ae_tauschii_Tr180,Ae_tauschii_Tr125)),(((((((Ae_longissima_Tr241,Ae_longissima_Tr242),Ae_longissima_Tr355),(Ae_sharonensis_Tr265,Ae_sharonensis_Tr264)),((Ae_bicornis_Tr408,Ae_bicornis_Tr407),Ae_bicornis_Tr406)),((Ae_searsii_Tr164,Ae_searsii_Tr165),Ae_searsii_Tr161)))#H2,#H4))),(((T_boeoticum_TS8,(T_boeoticum_TS10,T_boeoticum_TS3)),T_boeoticum_TS4),((T_urartu_Tr315,T_urartu_Tr232),(T_urartu_Tr317,T_urartu_Tr309)))),(((((Ae_speltoides_Tr320,Ae_speltoides_Tr323),Ae_speltoides_Tr223),Ae_speltoides_Tr251))H3,((((Ae_mutica_Tr237,Ae_mutica_Tr329),Ae_mutica_Tr244),Ae_mutica_Tr332))#H4))),Ta_caputMedusae_TB2),S_vavilovii_Tr279),Er_bonaepartis_TB1),H_vulgare_HVens23);");
dat2 = PhyloNetworks.traitlabels2indices(dna_dat[!,2:end], HKY85([0.5], [0.25, 0.25, 0.25, 0.25], true))
o, dna_net = @test_logs (:warn, "the network contains taxa with no data: those will be pruned") match_mode=:any PhyloNetworks.check_matchtaxonnames!(dna_dat[:,1], dat2, dna_net)
trait = view(dat2, o)
PhyloNetworks.startingBL!(dna_net, trait, dna_weights)
@test maximum(e.length for e in dna_net.edge) > 0.03
@test_logs PhyloNetworks.startingBL!(dna_net, trait) # no dna_weights
end # of startingBL!

@testset "testing prep and wrapper functions" begin
# read in data
#at home: fastafile = joinpath(@__DIR__, "../../dev/PhyloNetworks/", "examples", "Ae_bicornis_Tr406_Contig10132.aln") #small data
fastafile = joinpath(@__DIR__, "..", "examples", "Ae_bicornis_Tr406_Contig10132.aln")
dna_dat, dna_weights = readfastatodna(fastafile, true);

dna_net_top = readTopology("((((((((((((((Ae_caudata_Tr275,Ae_caudata_Tr276),Ae_caudata_Tr139))#H1,#H2),(((Ae_umbellulata_Tr266,Ae_umbellulata_Tr257),Ae_umbellulata_Tr268),#H1)),((Ae_comosa_Tr271,Ae_comosa_Tr272),(((Ae_uniaristata_Tr403,Ae_uniaristata_Tr357),Ae_uniaristata_Tr402),Ae_uniaristata_Tr404))),(((Ae_tauschii_Tr352,Ae_tauschii_Tr351),(Ae_tauschii_Tr180,Ae_tauschii_Tr125)),(((((((Ae_longissima_Tr241,Ae_longissima_Tr242),Ae_longissima_Tr355),(Ae_sharonensis_Tr265,Ae_sharonensis_Tr264)),((Ae_bicornis_Tr408,Ae_bicornis_Tr407),Ae_bicornis_Tr406)),((Ae_searsii_Tr164,Ae_searsii_Tr165),Ae_searsii_Tr161)))#H2,#H4))),(((T_boeoticum_TS8,(T_boeoticum_TS10,T_boeoticum_TS3)),T_boeoticum_TS4),((T_urartu_Tr315,T_urartu_Tr232),(T_urartu_Tr317,T_urartu_Tr309)))),(((((Ae_speltoides_Tr320,Ae_speltoides_Tr323),Ae_speltoides_Tr223),Ae_speltoides_Tr251))H3,((((Ae_mutica_Tr237,Ae_mutica_Tr329),Ae_mutica_Tr244),Ae_mutica_Tr332))#H4))),Ta_caputMedusae_TB2),S_vavilovii_Tr279),Er_bonaepartis_TB1),H_vulgare_HVens23);");
for edge in dna_net_top.edge #adds branch lengths
    setLength!(edge,1.0)
end
#Fixes the gamma error (creates a network)
setGamma!(dna_net_top.edge[6],0.6)
setGamma!(dna_net_top.edge[7],0.6)
setGamma!(dna_net_top.edge[58],0.6)

# tests #
net_dat = readTopology("(((A:2.0,(B:1.0)#H1:0.1::0.9):1.5,(C:0.6,#H1:1.0::0.1):1.0):0.5,D:2.0);")
dat = DataFrame(species=["C","A","B","D"], trait=["hi","lo","lo","hi"])

jmod = PhyloNetworks.defaultsubstitutionmodel(dna_net_top, :JC69, dna_dat, dna_weights)
@test jmod.rate == [1.0]
emod = PhyloNetworks.defaultsubstitutionmodel(dna_net_top, :ERSM, dna_dat, dna_weights)
@test emod.rate[1] ≈ 0.009708737864077669
@test typeof(emod) == EqualRatesSubstitutionModel{DNA}
hmod = PhyloNetworks.defaultsubstitutionmodel(dna_net_top, :HKY85, dna_dat, dna_weights)
@test typeof(hmod) == HKY85
bmod = PhyloNetworks.defaultsubstitutionmodel(dna_net_top, :BTSM, dat, [1.0, 1.0, 1.0, 1.0])
@test typeof(bmod) == BinaryTraitSubstitutionModel{String}
@test_throws ErrorException PhyloNetworks.defaultsubstitutionmodel(dna_net_top, :QR, dat, [1.0, 1.0, 1.0, 1.0])


test_SSM = (@test_logs (:warn, r"pruned") match_mode=:any PhyloNetworks.StatisticalSubstitutionModel(dna_net_top, fastafile, :JC69))
@test typeof(test_SSM.model) == JC69
@test test_SSM.nsites == 209
@test test_SSM.siteweight[1:5] == [23.0, 18.0, 13.0, 16.0, 1.0]

end #of testing prep and wrapper functions

@testset "testing fit! functions for full network optimization" begin
# read in data #
#test
#fastafile = joinpath(@__DIR__, "../../dev/PhyloNetworks/", "examples", "Ae_bicornis_Tr406_Contig10132.aln") #small data
fastafile = joinpath(@__DIR__, "..", "examples", "Ae_bicornis_Tr406_Contig10132.aln")
dna_dat, dna_weights = readfastatodna(fastafile, true);

dna_net_top = readTopology("((((((((((((((Ae_caudata_Tr275,Ae_caudata_Tr276),Ae_caudata_Tr139))#H1,#H2),(((Ae_umbellulata_Tr266,Ae_umbellulata_Tr257),Ae_umbellulata_Tr268),#H1)),((Ae_comosa_Tr271,Ae_comosa_Tr272),(((Ae_uniaristata_Tr403,Ae_uniaristata_Tr357),Ae_uniaristata_Tr402),Ae_uniaristata_Tr404))),(((Ae_tauschii_Tr352,Ae_tauschii_Tr351),(Ae_tauschii_Tr180,Ae_tauschii_Tr125)),(((((((Ae_longissima_Tr241,Ae_longissima_Tr242),Ae_longissima_Tr355),(Ae_sharonensis_Tr265,Ae_sharonensis_Tr264)),((Ae_bicornis_Tr408,Ae_bicornis_Tr407),Ae_bicornis_Tr406)),((Ae_searsii_Tr164,Ae_searsii_Tr165),Ae_searsii_Tr161)))#H2,#H4))),(((T_boeoticum_TS8,(T_boeoticum_TS10,T_boeoticum_TS3)),T_boeoticum_TS4),((T_urartu_Tr315,T_urartu_Tr232),(T_urartu_Tr317,T_urartu_Tr309)))),(((((Ae_speltoides_Tr320,Ae_speltoides_Tr323),Ae_speltoides_Tr223),Ae_speltoides_Tr251))H3,((((Ae_mutica_Tr237,Ae_mutica_Tr329),Ae_mutica_Tr244),Ae_mutica_Tr332))#H4))),Ta_caputMedusae_TB2),S_vavilovii_Tr279),Er_bonaepartis_TB1),H_vulgare_HVens23);");
for edge in dna_net_top.edge #adds branch lengths
    setLength!(edge,1.0)
end
#Fixes the gamma error (creates a network)
setGamma!(dna_net_top.edge[6],0.6)
setGamma!(dna_net_top.edge[7],0.6)
setGamma!(dna_net_top.edge[58],0.6)
@test_logs (:warn, r"pruned") match_mode=:any PhyloNetworks.StatisticalSubstitutionModel(dna_net_top, fastafile, :JC69)
end #of testing fit! functions for full network optimization

end # of nested testsets
