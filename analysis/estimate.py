"""Estimate annual default-onset probabilities with country and year effects."""

from pathlib import Path
import shutil

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf
from scipy.stats import t
from statsmodels.stats.outliers_influence import variance_inflation_factor

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "results"
CONTROLS = ["lag_growth", "lag_log_income"]


def estimation_sample(frame, regressors, outcome="onset"):
    data = frame.dropna(subset=[outcome, *regressors]).copy()
    # A singleton has zero residual variation after absorbing its fixed effect.
    while True:
        keep = (data.groupby("iso3").year.transform("size").gt(1)
                & data.groupby("year").iso3.transform("size").gt(1))
        if keep.all():
            return data.sort_values(["iso3", "year"])
        data = data.loc[keep]


def fit(name, sample, regressors, hac=False, outcome="onset"):
    model = smf.ols(outcome + " ~ " + " + ".join(regressors + ["C(iso3)", "C(year)"]), data=sample)
    result = model.fit()
    if model.rank != model.exog.shape[1]:
        raise ValueError(f"{name}: the fixed-effects design is rank deficient")
    groups = sample.iso3.nunique()
    years = sample.year.nunique()
    covariances = [("Country cluster", groups - 1, result.get_robustcov_results(
        cov_type="cluster", groups=sample.iso3, use_correction=True))]
    if hac:
        # Driscoll-Kraay sums scores across countries at each calendar year.
        time = (sample.year - sample.year.min()).to_numpy()
        if len(np.unique(time)) != time.max() + 1:
            raise ValueError("The HAC specification requires consecutive sample years")
        covariances.append(("Driscoll-Kraay (3 lags)", years - 1, result.get_robustcov_results(
            cov_type="hac-groupsum", time=time, maxlags=3, kernel="bartlett", use_correction="hac")))
    estimates = []
    for covariance, df, robust in covariances:
        for term in regressors:
            idx = model.exog_names.index(term)
            beta, se = robust.params[idx], robust.bse[idx]
            margin = t.ppf(.975, df) * se
            estimates.append(dict(model=name, outcome=outcome, covariance=covariance, term=term, coefficient=beta,
                                  std_error=se, lower_95=beta-margin, upper_95=beta+margin,
                                  p_value=2*t.sf(abs(beta/se), df), n=len(sample), countries=groups,
                                  years=years, first_year=sample.year.min(), last_year=sample.year.max(),
                                  event_years=int(sample[outcome].sum())))
    return estimates


def main():
    OUT.mkdir(exist_ok=True)
    panel = pd.read_csv(ROOT / "data/processed/panel.csv")
    if panel.duplicated(["iso3", "year"]).any():
        raise ValueError("Country-year identifiers must be unique")
    panel["due_next_year"] = panel.years_to_term_end.eq(1).astype(int)
    risk = panel.loc[panel.onset.notna()]
    base_terms = ["term_due", *CONTROLS]
    sample = estimation_sample(risk, base_terms)
    wide = estimation_sample(risk, ["term_due"])
    fixed = estimation_sample(sample.loc[sample.prior_system.eq("presidentialism")], base_terms)
    market = estimation_sample(panel, base_terms, outcome="dated_payment_default")
    estimates = [
        *fit("Unadjusted, full risk sample", wide, ["term_due"]),
        *fit("Unadjusted, common sample", sample, ["term_due"]),
        *fit("Baseline", sample, base_terms, hac=True),
        *fit("Election held", sample, ["vote_held", *CONTROLS]),
        *fit("Final two years", sample, ["term_due", "due_next_year", *CONTROLS]),
        *fit("Fixed legislative terms", fixed, base_terms),
        *fit("Dated payment defaults", market, base_terms, outcome="dated_payment_default"),
    ]
    pd.DataFrame(estimates).to_csv(OUT / "estimates.csv", index=False)

    # Project each slope regressor on the same dummies used in the baseline.
    within = np.column_stack([smf.ols(f"{term} ~ C(iso3) + C(year)", data=sample).fit().resid
                              for term in base_terms])
    vif = [variance_inflation_factor(within, i) for i in range(len(base_terms))]
    pd.DataFrame({"term": base_terms, "within_vif": vif}).to_csv(OUT / "vif.csv", index=False)
    sample.groupby("term_due").agg(country_years=("onset", "size"), onsets=("onset", "sum"),
                                   onset_share=("onset", "mean"), vote_share=("vote_held", "mean")
                                   ).to_csv(OUT / "descriptives.csv")
    stages = {"Matched calendar": panel, "Observed current and prior stock": panel.dropna(
        subset=["in_default", "prior_default"]), "Previously outside default": risk,
        "Macro controls observed": risk.dropna(subset=CONTROLS), "Baseline sample": sample}
    pd.DataFrame([{"stage": label, "country_years": len(rows), "countries": rows.iso3.nunique()}
                  for label, rows in stages.items()]).to_csv(OUT / "coverage.csv", index=False)

    cases = pd.read_csv(ROOT / "data/processed/dated_defaults.csv")
    categories = np.select(
        [cases.onset.eq(1), cases.prior_default.eq(1), cases.onset.eq(0)],
        ["BoC-BoE onset", "Already in default last year", "No BoC-BoE onset"],
        default="Unknown transition")
    pd.Series(categories, name="status").value_counts().rename("country_years").to_csv(
        OUT / "dated_event_overlap.csv")
    shutil.copyfile(ROOT / "data/raw/sources.json", OUT / "sources.json")
    print(pd.DataFrame(estimates).query("model == 'Baseline' and term == 'term_due'").to_string(index=False))


if __name__ == "__main__":
    main()
