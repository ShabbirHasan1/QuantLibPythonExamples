#ifndef ql_engines_barrier_i
#define ql_engines_barrier_i

%include ../ql/types.i
%include ../ql/common.i
%include ../ql/alltypes.i
%include ../ql/base.i

%{
using QuantLib::AnalyticBarrierEngine;
using QuantLib::AnalyticBinaryBarrierEngine;
using QuantLib::AnalyticDoubleBarrierEngine;
using QuantLib::MCBarrierEngine;
using QuantLib::FdBlackScholesBarrierEngine;
using QuantLib::FdBlackScholesRebateEngine;
using QuantLib::FdHestonBarrierEngine;
using QuantLib::FdHestonRebateEngine;
using QuantLib::BinomialBarrierEngine;
using QuantLib::DiscretizedDermanKaniBarrierOption;
using QuantLib::VannaVolgaBarrierEngine;
using QuantLib::FdHestonDoubleBarrierEngine;
using QuantLib::WulinYongDoubleBarrierEngine;
using QuantLib::VannaVolgaDoubleBarrierEngine;
using QuantLib::AnalyticDoubleBarrierBinaryEngine;
using QuantLib::BinomialDoubleBarrierEngine;
using QuantLib::DiscretizedDermanKaniDoubleBarrierOption;
using QuantLib::MakeMCBarrierEngine;
%}

%shared_ptr(AnalyticBarrierEngine)
class AnalyticBarrierEngine : public PricingEngine {
  public:
    AnalyticBarrierEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process);
};

%shared_ptr(AnalyticBinaryBarrierEngine)
class AnalyticBinaryBarrierEngine : public PricingEngine {
  public:
    AnalyticBinaryBarrierEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process);
};

%shared_ptr(MCBarrierEngine<PseudoRandom>);
%shared_ptr(MCBarrierEngine<LowDiscrepancy>);
template <class RNG>
class MCBarrierEngine : public PricingEngine {
  public:
    MCBarrierEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process,
        Size timeSteps,
        Size timeStepsPerYear,
        bool brownianBridge,
        bool antitheticVariate,
        Size requiredSamples,
        Real requiredTolerance,
        Size maxSamples,
        bool isBiased,
        BigNatural seed);
};

%template(MCPRBarrierEngine) MCBarrierEngine<PseudoRandom>;
%template(MCLDBarrierEngine) MCBarrierEngine<LowDiscrepancy>;

template <class RNG>
class MakeMCBarrierEngine {
  public:
    MakeMCBarrierEngine(ext::shared_ptr<GeneralizedBlackScholesProcess>);
    // named parameters
    MakeMCBarrierEngine& withSteps(Size steps);
    MakeMCBarrierEngine& withStepsPerYear(Size steps);
    MakeMCBarrierEngine& withBrownianBridge(bool b = true);
    MakeMCBarrierEngine& withAntitheticVariate(bool b = true);
    MakeMCBarrierEngine& withSamples(Size samples);
    MakeMCBarrierEngine& withAbsoluteTolerance(Real tolerance);
    MakeMCBarrierEngine& withMaxSamples(Size samples);
    MakeMCBarrierEngine& withBias(bool b = true);
    MakeMCBarrierEngine& withSeed(BigNatural seed);
    // conversion to pricing engine
    %extend {
        ext::shared_ptr<PricingEngine> makeEngine() const {
            return (ext::shared_ptr<PricingEngine>)(* $self);
        }
    }
};

%template(MakeMCPRBarrierEngine) MakeMCBarrierEngine<PseudoRandom>;
%template(MakeMCLDBarrierEngine) MakeMCBarrierEngine<LowDiscrepancy>;

%shared_ptr(FdBlackScholesBarrierEngine)
class FdBlackScholesBarrierEngine : public PricingEngine {
  public:
    FdBlackScholesBarrierEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process,
        Size tGrid = 100,
        Size xGrid = 100,
        Size dampingSteps = 0,
        const FdmSchemeDesc& schemeDesc = FdmSchemeDesc::Douglas(),
        bool localVol = false,
        Real illegalLocalVolOverwrite = -Null<Real>());
};

%shared_ptr(FdBlackScholesRebateEngine)
class FdBlackScholesRebateEngine : public PricingEngine {
  public:
    FdBlackScholesRebateEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process,
        Size tGrid = 100, Size xGrid = 100, Size dampingSteps = 0,
        const FdmSchemeDesc& schemeDesc = FdmSchemeDesc::Douglas(),
        bool localVol = false,
        Real illegalLocalVolOverwrite = -Null<Real>());
};

%shared_ptr(FdHestonBarrierEngine)
class FdHestonBarrierEngine : public PricingEngine {
  public:
    FdHestonBarrierEngine(
        const ext::shared_ptr<HestonModel>& model,
        Size tGrid = 100, Size xGrid = 100, Size vGrid = 50, Size dampingSteps = 0,
        const FdmSchemeDesc& schemeDesc = FdmSchemeDesc::Hundsdorfer(),
        const ext::shared_ptr<LocalVolTermStructure>& leverageFct = ext::shared_ptr<LocalVolTermStructure>(),
        const Real mixingFactor = 1.0);
};

%shared_ptr(FdHestonRebateEngine)
class FdHestonRebateEngine : public PricingEngine {
  public:
    FdHestonRebateEngine(
        const ext::shared_ptr<HestonModel>& model,
        Size tGrid = 100, Size xGrid = 100, Size vGrid = 50, Size dampingSteps = 0,
        const FdmSchemeDesc& schemeDesc = FdmSchemeDesc::Hundsdorfer(),
        const ext::shared_ptr<LocalVolTermStructure>& leverageFct = ext::shared_ptr<LocalVolTermStructure>(),
        const Real mixingFactor = 1.0);
};

%feature("docstring") BinomialBarrierEngine "Binomial Engine for barrier options.
Features different binomial models, selected by the type parameters.
Uses Boyle-Lau adjustment for optimize steps and Derman-Kani optimization to speed
up convergence.
Type values:
    crr or coxrossrubinstein:        Cox-Ross-Rubinstein model
    jr  or jarrowrudd:               Jarrow-Rudd model
    eqp or additiveeqpbinomialtree:  Additive EQP model
    trigeorgis:                      Trigeorgis model
    tian:                            Tian model
    lr  or leisenreimer              Leisen-Reimer model
    j4  or joshi4:                   Joshi 4th (smoothed) model

Boyle-Lau adjustment is controlled by parameter max_steps.
If max_steps is equal to steps Boyle-Lau is disabled.
Il max_steps is 0 (default value), max_steps is calculated by capping it to
5*steps when Boyle-Lau would need more than 1000 steps.
If max_steps is specified, it would limit binomial steps to this value.
"

%shared_ptr(BinomialBarrierEngine<CoxRossRubinstein, DiscretizedDermanKaniBarrierOption>);
%shared_ptr(BinomialBarrierEngine<JarrowRudd, DiscretizedDermanKaniBarrierOption>);
%shared_ptr(BinomialBarrierEngine<AdditiveEQPBinomialTree, DiscretizedDermanKaniBarrierOption>);
%shared_ptr(BinomialBarrierEngine<Trigeorgis, DiscretizedDermanKaniBarrierOption>);
%shared_ptr(BinomialBarrierEngine<Tian, DiscretizedDermanKaniBarrierOption>);
%shared_ptr(BinomialBarrierEngine<LeisenReimer, DiscretizedDermanKaniBarrierOption>);
%shared_ptr(BinomialBarrierEngine<Joshi4, DiscretizedDermanKaniBarrierOption>);
template <class T, class U>
class BinomialBarrierEngine : public PricingEngine {
  public:
    BinomialBarrierEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process,
        Size steps,
        Size max_steps = 0);
};

%template(BinomialCRRBarrierEngine) BinomialBarrierEngine<CoxRossRubinstein, DiscretizedDermanKaniBarrierOption>;
%template(BinomialJRBarrierEngine) BinomialBarrierEngine<JarrowRudd, DiscretizedDermanKaniBarrierOption>;
%template(BinomialEQPBarrierEngine) BinomialBarrierEngine<AdditiveEQPBinomialTree, DiscretizedDermanKaniBarrierOption>;
%template(BinomialTrigeorgisBarrierEngine) BinomialBarrierEngine<Trigeorgis, DiscretizedDermanKaniBarrierOption>;
%template(BinomialTianBarrierEngine) BinomialBarrierEngine<Tian, DiscretizedDermanKaniBarrierOption>;
%template(BinomialLRBarrierEngine) BinomialBarrierEngine<LeisenReimer, DiscretizedDermanKaniBarrierOption>;
%template(BinomialJ4BarrierEngine) BinomialBarrierEngine<Joshi4, DiscretizedDermanKaniBarrierOption>;

%shared_ptr(VannaVolgaBarrierEngine)
class VannaVolgaBarrierEngine : public PricingEngine {
  public:
    VannaVolgaBarrierEngine(
        Handle<DeltaVolQuote> atmVol,
        Handle<DeltaVolQuote> vol25Put,
        Handle<DeltaVolQuote> vol25Call,
        Handle<Quote> spotFX,
        Handle<YieldTermStructure> domesticTS,
        Handle<YieldTermStructure> foreignTS,
        bool adaptVanDelta = false,
        Real bsPriceWithSmile = 0.0);
};

%feature("docstring") AnalyticDoubleBarrierEngine "
Double barrier engine implementing Ikeda-Kunitomo series."

%shared_ptr(AnalyticDoubleBarrierEngine)
class AnalyticDoubleBarrierEngine : public PricingEngine {
  public:
    AnalyticDoubleBarrierEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process,
        int series = 5);
};

%shared_ptr(FdHestonDoubleBarrierEngine)
class FdHestonDoubleBarrierEngine : public PricingEngine {
  public:
    FdHestonDoubleBarrierEngine(
        const ext::shared_ptr<HestonModel>& model,
        Size tGrid = 100, Size xGrid = 100,
        Size vGrid = 50, Size dampingSteps = 0,
        const FdmSchemeDesc& schemeDesc = FdmSchemeDesc::Hundsdorfer(),
        ext::shared_ptr<LocalVolTermStructure> leverageFct = ext::shared_ptr<LocalVolTermStructure>(),
        Real mixingFactor = 1.0);
};

%shared_ptr(WulinYongDoubleBarrierEngine)
class WulinYongDoubleBarrierEngine : public PricingEngine {
  public:
    WulinYongDoubleBarrierEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process,
        int series = 5);
};

%feature("docstring") VannaVolgaDoubleBarrierEngine "
Vanna-Volga engine for double barrier options.
Supports different double barrier engines, selected by the type parameters.
Type values:
    ik or analytic:  Ikeda-Kunitomo standard engine (default)
    wo:              Wulin-Yong engine
"

%shared_ptr(VannaVolgaDoubleBarrierEngine<AnalyticDoubleBarrierEngine>);
%shared_ptr(VannaVolgaDoubleBarrierEngine<WulinYongDoubleBarrierEngine>);
template <class E>
class VannaVolgaDoubleBarrierEngine : public PricingEngine {
  public:
    VannaVolgaDoubleBarrierEngine(
        Handle<DeltaVolQuote> atmVol,
        Handle<DeltaVolQuote> vol25Put,
        Handle<DeltaVolQuote> vol25Call,
        Handle<Quote> spotFX,
        Handle<YieldTermStructure> domesticTS,
        Handle<YieldTermStructure> foreignTS,
        const bool adaptVanDelta = false,
        const Real bsPriceWithSmile = 0.0,
        int series = 5);
};

%template(VannaVolgaIKDoubleBarrierEngine) VannaVolgaDoubleBarrierEngine<AnalyticDoubleBarrierEngine>;
%template(VannaVolgaWODoubleBarrierEngine) VannaVolgaDoubleBarrierEngine<WulinYongDoubleBarrierEngine>;

%shared_ptr(AnalyticDoubleBarrierBinaryEngine)
class AnalyticDoubleBarrierBinaryEngine : public PricingEngine {
  public:
    AnalyticDoubleBarrierBinaryEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process);
};

%feature("docstring") BinomialDoubleBarrierEngine "Binomial Engine for double barrier options.
Features different binomial models, selected by the type parameters.
Uses Derman-Kani optimization to speed up convergence.
Type values:
    crr or coxrossrubinstein:        Cox-Ross-Rubinstein model
    jr  or jarrowrudd:               Jarrow-Rudd model
    eqp or additiveeqpbinomialtree:  Additive EQP model
    trigeorgis:                      Trigeorgis model
    tian:                            Tian model
    lr  or leisenreimer              Leisen-Reimer model
    j4  or joshi4:                   Joshi 4th (smoothed) model
"

%shared_ptr(BinomialDoubleBarrierEngine<CoxRossRubinstein, DiscretizedDermanKaniDoubleBarrierOption>);
%shared_ptr(BinomialDoubleBarrierEngine<JarrowRudd, DiscretizedDermanKaniDoubleBarrierOption>);
%shared_ptr(BinomialDoubleBarrierEngine<AdditiveEQPBinomialTree, DiscretizedDermanKaniDoubleBarrierOption>);
%shared_ptr(BinomialDoubleBarrierEngine<Trigeorgis, DiscretizedDermanKaniDoubleBarrierOption>);
%shared_ptr(BinomialDoubleBarrierEngine<Tian, DiscretizedDermanKaniDoubleBarrierOption>);
%shared_ptr(BinomialDoubleBarrierEngine<LeisenReimer, DiscretizedDermanKaniDoubleBarrierOption>);
%shared_ptr(BinomialDoubleBarrierEngine<Joshi4, DiscretizedDermanKaniDoubleBarrierOption>);
template <class T, class U>
class BinomialDoubleBarrierEngine : public PricingEngine {
  public:
    BinomialDoubleBarrierEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process,
        Size steps);
};

%template(BinomialCRRDoubleBarrierEngine) BinomialDoubleBarrierEngine<CoxRossRubinstein, DiscretizedDermanKaniDoubleBarrierOption>;
%template(BinomialJRDoubleBarrierEngine) BinomialDoubleBarrierEngine<JarrowRudd, DiscretizedDermanKaniDoubleBarrierOption>;
%template(BinomialEQPDoubleBarrierEngine) BinomialDoubleBarrierEngine<AdditiveEQPBinomialTree, DiscretizedDermanKaniDoubleBarrierOption>;
%template(BinomialTrigeorgisDoubleBarrierEngine) BinomialDoubleBarrierEngine<Trigeorgis, DiscretizedDermanKaniDoubleBarrierOption>;
%template(BinomialTianDoubleBarrierEngine) BinomialDoubleBarrierEngine<Tian, DiscretizedDermanKaniDoubleBarrierOption>;
%template(BinomialLRDoubleBarrierEngine) BinomialDoubleBarrierEngine<LeisenReimer, DiscretizedDermanKaniDoubleBarrierOption>;
%template(BinomialJ4DoubleBarrierEngine) BinomialDoubleBarrierEngine<Joshi4, DiscretizedDermanKaniDoubleBarrierOption>;

#endif
