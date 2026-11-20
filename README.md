# Electoral Timing and Sovereign Defaults

Starting from my MSc thesis on the political determinants of sovereign default, I examine whether governments are more likely to enter default as a national legislative election approaches. The Python analysis follows the legislative calendar known from the previous election and compares default risk within countries over time. The original Stata programs for default probability and sovereign haircuts are in [thesis/](thesis/).

## Findings

The [executed Jupyter notebook](analysis/electoral_timing.ipynb) adds four lagged controls to the original growth and income specification: gross general government debt (% of GDP), annual CPI inflation (%), the current-account balance (% of GDP), and the WGI Rule of Law score (0–100). The current account measures external financing needs. Rule of Law captures perceptions of contract enforcement, property rights and respect for legal rules. The debt series comes from the October 2026 IMF WEO. The remaining controls come from the World Bank. [IMF WEO](https://data.imf.org/datasets/WEO) · [WGI series definition](https://databank.worldbank.org/metadataglossary/world-development-indicators/series/GOV_WGI_RL_SC)

| Model on the same 747 country-years | Election-year difference, pp | Country-clustered 95% CI, pp | p-value |
| --- | ---: | ---: | ---: |
| Growth and income | −0.87 | [−7.42, 5.67] | 0.790 |
| Add debt, inflation and current account | −0.83 | [−7.32, 5.67] | 0.800 |
| Add rule of law | −1.10 | [−7.60, 5.41] | 0.737 |

The extended model covers 56 countries and 89 onsets in 24 observed years between 1997 and 2023. The largest VIF after removing country and year effects is 1.92 (log real income per capita). Years with missing controls are excluded. Because early governance scores have gaps, the notebook also compares clustered and Driscoll–Kraay inference on the consecutive 2003–2023 period. [Complete estimates](results/estimates.csv) · [VIF by specification](results/vif.csv)

### Original baseline and robustness checks

In 1,693 country-years at risk across 96 countries between 1962 and 2023, there were 209 new default episodes. The estimated change in annual default probability in the expected final year of a legislative term is **−0.50 percentage points**. The country-clustered 95% confidence interval runs from **−5.07 to +4.07 points**. The data are compatible with meaningful shifts in either direction.

| Measure of electoral timing | Outcome | Country-years | Difference in probability, pp | 95% CI, pp |
| --- | --- | ---: | ---: | ---: |
| Term due this year | BoC–BoE onset | 1,693 | −0.50 | [−5.07, 4.07] |
| Legislative vote actually held | BoC–BoE onset | 1,693 | +0.24 | [−4.13, 4.61] |
| Term due this year, fixed-term systems | BoC–BoE onset | 911 | −3.11 | [−9.71, 3.49] |
| Term due this year | Dated payment default, Asonuma–Trebesch | 3,982 | +0.20 | [−0.93, 1.33] |

The dates of actual votes provide a check on the term clock. In the baseline sample, a vote took place in 83% of years when a term was due and in 9% of other years. The raw onset rates were 11.6% and 12.5%, respectively. [Descriptive statistics](results/descriptives.csv) · [Full coefficient table](results/estimates.csv)

## Measuring the electoral cycle and default

**Electoral timing.** At the start of year *t*, the expected expiry year equals the year of the most recent legislative election before January 1 plus the term length recorded for that election. A term is due when its expected expiry year equals *t*. An early vote resets the clock the following January. Years before the first observed vote, years with unknown term length, and overdue years are excluded. This clock approximates the ordinary term deadline. Dissolutions, constitutional changes and suspensions can break the link to the actual polling date. ETAD v1.0.0 covers legislative and presidential elections through 2023. The analysis uses the legislative series to maintain continuity with the thesis. [ETAD data and codebook](https://yukiyanai.github.io/data_etad/)

**Default onset.** The October 2026 BoC–BoE release covers 1960–2025. An issuer enters the annual risk set when it has zero debt in default in *t*−1 and observable status in *t*. The outcome equals one if its total debt in default becomes positive. The workbook preserves explicit zeros, small positive stocks displayed as red zeros, and missing values. Blanks, unquantified amounts and negative totals have unknown status. Countries absent from the issuer table stay outside the sample. This outcome can include arrears to official creditors and distressed exchanges. Dating is annual, so a vote and a default in the same year cannot be ordered. The data measure debt outcomes and do not identify a government's willingness or ability to pay. [BoC–BoE 2026 release and methodology](https://www.bankofcanada.ca/2026/10/staff-analytical-paper-2026-48/)

**Dated payment defaults.** A second outcome counts country-years containing a dated missed payment in an Asonuma–Trebesch post-default restructuring involving foreign banks or bondholders. Multiple cases in one country-year count once. The sample covers complete years from 1970 to 2019, includes dated ongoing cases, and excludes Costa Rica, Morocco and Mozambique because each has a post-default case without a default date. A zero means no qualifying event was recorded. An issuer may miss a payment to these creditors while already in default to another creditor, so this specification includes years of ongoing distress. Of 110 distinct dated country-years across the source, 98 followed a year in which BoC–BoE already recorded debt in default. [Asonuma–Trebesch data, September 2020 update](https://www.kielinstitut.de/kiel-institute-data-hub/) · [Event overlap](results/dated_event_overlap.csv)

## Estimation and identification

The baseline is an OLS linear probability model with country and calendar-year fixed effects. The controls are real GDP growth and log real GDP per capita from the preceding calendar year. Both come from World Development Indicators. Each eligible country-year has equal weight. The panel is unbalanced. The baseline uses observations with complete controls and removes singleton fixed-effect groups. The two unadjusted specifications show how much the estimate changes when the complete-case restriction is imposed. [Sample construction](results/coverage.csv) · [World Development Indicators](https://databank.worldbank.org/source/world-development-indicators)

Country-clustered standard errors allow arbitrary dependence within a country over time. The baseline also reports Driscoll–Kraay standard errors with a Bartlett kernel and three annual lags to allow cross-country dependence. Its 95% interval is [−5.03, +4.03] percentage points. VIFs are calculated after projecting each regressor on both sets of fixed effects. In the baseline, all three are below 1.01. [Inference and specifications](analysis/estimate.py) · [Within-sample VIFs](results/vif.csv)

Fiscal distress may prompt an early election or delay a scheduled one. Using the previous election and its term length avoids defining exposure from the future voting date. The analysis also estimates separate coefficients for the final and penultimate years and restricts one specification to systems ETAD classifies as having fixed legislative terms. Prior election timing, term reforms and time-varying fiscal shocks may still be endogenous. The coefficients therefore have an associational interpretation.

## Reproduce the analysis

From the repository root, use Python 3.13 in a virtual environment and run:

```sh
python -m pip install -r requirements.txt
python -m jupyterlab analysis/electoral_timing.ipynb
```

In JupyterLab, select the project environment and run all cells. For the command-line replication and CSV exports:

```sh
python data/download.py
python data/build_panel.py
python analysis/estimate.py
```

[The downloader](data/download.py) retrieves the public inputs without API keys and caches them in `data/raw/`. Use `--refresh` to replace cached copies. [The panel builder](data/build_panel.py) writes country-year observations and the dated-event comparison to `data/processed/`. Aggregate estimates and diagnostics are in [results/](results/). The [source manifest](results/sources.json) records the URLs and SHA-256 hashes for the published run. The World Bank can revise its historical series.

The [archived Stata scripts](thesis/) require the thesis-era input dataset, which was not part of the original repository. The Python analysis builds its own panel from the sources above.
