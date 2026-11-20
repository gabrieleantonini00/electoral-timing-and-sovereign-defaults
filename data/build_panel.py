"""Construct annual default transitions and the legislative term clock."""

import json
from pathlib import Path

import numpy as np
import pandas as pd
from openpyxl import load_workbook

DATA = Path(__file__).resolve().parent
RAW = DATA / "raw"
PROCESSED = DATA / "processed"
KEY = ["iso3", "year"]


def default_status(cell):
    amount = cell.value
    if amount is None or amount in ("", "****"):
        return np.nan
    if not isinstance(amount, (int, float)):
        raise ValueError(f"Unexpected default stock at {cell.coordinate}: {amount!r}")
    if amount < 0:
        return np.nan
    if amount == 0:
        color = cell.font.color
        if color and color.type == "rgb" and color.rgb[-6:] == "FF0000":
            return 1
    return int(amount > 0)


def read_defaults():
    book = load_workbook(RAW / "defaults.xlsx", read_only=True, data_only=True)
    try:
        # The second identifier in the machine-readable sheet contains ISO3.
        codes = {str(r[2]).strip(): r[1].split("_")[0] for r in book["Debt_2026.csv"].values
                 if r[4] == 2025 and r[2] != "World"}
        rows = iter(book["2026 in progress"].rows)
        columns = [(i, int(str(c.value).removesuffix("p"))) for i, c in enumerate(next(rows))
                   if isinstance(c.value, int) or c.value == "2025p"]
        if [year for _, year in columns] != list(range(1960, 2026)):
            raise ValueError("Unexpected year columns in the 2026 workbook")
        records = []
        for row in rows:
            if not isinstance(row[0].value, int):
                continue
            name = str(row[1].value or "").strip()
            if name == "Anguila":
                name = "Anguilla"
            if row[0].value == 157 and not name:
                name = "USSR/Russian Federation"
            for index, year in columns:
                records.append((codes[name], year, default_status(row[index])))
    finally:
        book.close()
    panel = pd.DataFrame(records, columns=KEY + ["in_default"])
    if panel.duplicated(KEY).any() or panel.iso3.nunique() != len(codes):
        raise ValueError("Issuer keys do not reconcile across workbook sheets")
    prior = panel.rename(columns={"in_default": "prior_default"}).assign(year=panel.year + 1)
    panel = panel.merge(prior, on=KEY, how="left", validate="one_to_one")
    panel["onset"] = panel.in_default.where(panel.prior_default.eq(0))
    return panel


def legislative_calendar():
    elections = pd.read_csv(RAW / "etad.csv", parse_dates=["held_date"])
    votes = elections.loc[elections.etype2.eq("legislative") & elections.held_date.notna()]
    records = []
    for iso3, country in votes.groupby("iso3"):
        country = country.sort_values("held_date")
        held_years = set(country.held_date.dt.year)
        # Work forward from elections already observed before 1 January.
        prior_years = country.groupby(country.held_date.dt.year).tail(1)
        for year in range(max(1961, min(held_years) + 1), 2024):
            previous = prior_years.loc[prior_years.held_date.dt.year < year].iloc[-1]
            due = previous.held_date.year + previous.termlength
            if pd.isna(due) or year > due:
                continue
            records.append((iso3, year, previous.held_date.date(), int(due - year),
                            int(due == year), int(year in held_years), previous.parliamentarism))
    return pd.DataFrame(records, columns=KEY + ["last_vote", "years_to_term_end",
                        "term_due", "vote_held", "prior_system"])


def lagged_indicator(name):
    _, rows = json.loads((RAW / f"{name}.json").read_bytes())
    values = [(r["countryiso3code"], int(r["date"]) + 1, r["value"]) for r in rows
              if r["countryiso3code"]]
    return pd.DataFrame(values, columns=KEY + [f"lag_{name}"])


def dated_defaults():
    """Identify dated missed payments in the completed and ongoing case lists."""
    book = load_workbook(RAW / "restructurings.xlsx", read_only=True, data_only=True)
    try:
        cases = [(r[5], r[12].year) for r in book["DATASET Defaults & Restruct."].values
                 if isinstance(r[1], int) and r[11] == 1 and r[12] is not None]
        ongoing = {"Venezuela": "VEN", "Republic of Congo (Glencore and Trafigura Loans)": "COG",
                   "Lebanon": "LBN"}
        for row in book["Ongoing cases as of Sept20"].values:
            if row[2] == "Post-default" and row[3] is not None:
                cases.append((ongoing[row[1]], row[3].year))
    finally:
        book.close()
    events = pd.DataFrame(cases, columns=KEY)
    events["iso3"] = events.iso3.replace({"CRO": "HRV", "ROM": "ROU", "SLO": "SVN"})
    return events.drop_duplicates()


def main():
    PROCESSED.mkdir(exist_ok=True)
    defaults = read_defaults()
    panel = defaults.merge(legislative_calendar(), on=KEY, validate="one_to_one")
    for name in ("income", "growth"):
        panel = panel.merge(lagged_indicator(name), on=KEY, how="left", validate="one_to_one")
    panel["lag_log_income"] = np.log(panel.lag_income.where(panel.lag_income > 0))
    events = dated_defaults()
    panel = panel.merge(events.assign(dated_payment_default=1), on=KEY, how="left",
                        validate="one_to_one")
    # 2020 is a partial year. Three issuers have post-default cases without a date.
    covered = (panel.year.between(1970, 2019) & panel.in_default.notna()
               & ~panel.iso3.isin(["CRI", "MAR", "MOZ"]))
    panel["dated_payment_default"] = panel.dated_payment_default.fillna(0).where(covered)
    panel.sort_values(KEY).to_csv(PROCESSED / "panel.csv", index=False)

    # Count the cases that a stock-based transition can and cannot capture.
    comparison = events.merge(defaults, on=KEY, how="left", validate="one_to_one")
    comparison.to_csv(PROCESSED / "dated_defaults.csv", index=False)
    print(f"{len(panel):,} matched country-years, {panel.onset.notna().sum():,} at risk")


if __name__ == "__main__":
    main()
