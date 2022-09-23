#ifndef ql_engines_bond_i
#define ql_engines_bond_i

%include ../ql/types.i
%include ../ql/common.i
%include ../ql/alltypes.i
%include ../ql/base.i

%define QL_TYPECHECK_BOOL                        7220    %enddef

%typemap(in) boost::optional<bool> {
	if($input == Py_None)
		$1 = boost::none;
	else if ($input == Py_True)
		$1 = true;
	else
		$1 = false;
}

%typecheck (QL_TYPECHECK_BOOL) boost::optional<bool> {
    if (PyBool_Check($input) || Py_None == $input)
    	$1 = 1;
    else
    	$1 = 0;
}

%{
using QuantLib::DiscountingBondEngine;
using QuantLib::TreeCallableFixedRateBondEngine;
using QuantLib::TreeCallableZeroCouponBondEngine;
using QuantLib::BlackCallableFixedRateBondEngine;
using QuantLib::BinomialConvertibleEngine;
using QuantLib::RiskyBondEngine;
%}

%shared_ptr(DiscountingBondEngine)
class DiscountingBondEngine : public PricingEngine {
  public:
    DiscountingBondEngine(
        Handle<YieldTermStructure> discountCurve = Handle<YieldTermStructure>(),
        boost::optional<bool> includeSettlementDateFlows = boost::none);
    Handle<YieldTermStructure> discountCurve() const;
};

%shared_ptr(TreeCallableFixedRateBondEngine)
class TreeCallableFixedRateBondEngine : public PricingEngine {
  public:
    TreeCallableFixedRateBondEngine(
        const ext::shared_ptr<ShortRateModel>& model,
        Size timeSteps,
        const Handle<YieldTermStructure>& termStructure = Handle<YieldTermStructure>());
    TreeCallableFixedRateBondEngine(
        const ext::shared_ptr<ShortRateModel>& model,
        const TimeGrid& grid,
        const Handle<YieldTermStructure>& termStructure = Handle<YieldTermStructure>());
};

%shared_ptr(TreeCallableZeroCouponBondEngine)
class TreeCallableZeroCouponBondEngine : public TreeCallableFixedRateBondEngine {
  public:
    TreeCallableZeroCouponBondEngine(
        const ext::shared_ptr<ShortRateModel>& model,
        const Size timeSteps,
        const Handle<YieldTermStructure>& termStructure = Handle<YieldTermStructure>());

    TreeCallableZeroCouponBondEngine(
        const ext::shared_ptr<ShortRateModel>& model,
        const TimeGrid& timeGrid,
        const Handle<YieldTermStructure>& termStructure = Handle<YieldTermStructure>());
};

%shared_ptr(BlackCallableFixedRateBondEngine)
class BlackCallableFixedRateBondEngine : public PricingEngine {
  public:
    BlackCallableFixedRateBondEngine(
        const Handle<Quote>& fwdYieldVol,
        Handle<YieldTermStructure> discountCurve);
    BlackCallableFixedRateBondEngine(
        Handle<CallableBondVolatilityStructure> yieldVolStructure,
        Handle<YieldTermStructure> discountCurve);
};

%shared_ptr(BinomialConvertibleEngine<CoxRossRubinstein>)
%shared_ptr(BinomialConvertibleEngine<JarrowRudd>)
%shared_ptr(BinomialConvertibleEngine<AdditiveEQPBinomialTree>)
%shared_ptr(BinomialConvertibleEngine<Trigeorgis>)
%shared_ptr(BinomialConvertibleEngine<Tian>)
%shared_ptr(BinomialConvertibleEngine<LeisenReimer>)
%shared_ptr(BinomialConvertibleEngine<Joshi4>)
template <class T>
class BinomialConvertibleEngine : public PricingEngine {
  public:
    BinomialConvertibleEngine(
        ext::shared_ptr<GeneralizedBlackScholesProcess> process,
        Size timeSteps,
        const Handle<Quote>& creditSpread,
        DividendSchedule dividends = DividendSchedule());
};

%template(BinomialCRRConvertibleEngine) BinomialConvertibleEngine<CoxRossRubinstein>;
%template(BinomialJRConvertibleEngine) BinomialConvertibleEngine<JarrowRudd>;
%template(BinomialEQPConvertibleEngine) BinomialConvertibleEngine<AdditiveEQPBinomialTree>;
%template(BinomialTrigeorgisConvertibleEngine) BinomialConvertibleEngine<Trigeorgis>;
%template(BinomialTianConvertibleEngine) BinomialConvertibleEngine<Tian>;
%template(BinomialLRConvertibleEngine) BinomialConvertibleEngine<LeisenReimer>;
%template(BinomialJ4ConvertibleEngine) BinomialConvertibleEngine<Joshi4>;

%shared_ptr(RiskyBondEngine)
class RiskyBondEngine : public PricingEngine {
  public:
    RiskyBondEngine(
        Handle<DefaultProbabilityTermStructure> defaultTS,
        Real recoveryRate,
        Handle<YieldTermStructure> yieldTS);
    Handle<DefaultProbabilityTermStructure> defaultTS() const;
    Real recoveryRate() const;
    Handle<YieldTermStructure> yieldTS() const;
};

#endif
