"""Download the public research inputs and record their SHA-256 digests."""

import argparse
import hashlib
import json
from pathlib import Path
from tempfile import NamedTemporaryFile

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

RAW = Path(__file__).resolve().parent / "raw"
WDI = "https://api.worldbank.org/v2/country/all/indicator"
INDICATORS = {"growth": "NY.GDP.MKTP.KD.ZG", "income": "NY.GDP.PCAP.KD"}
SOURCES = {
    "defaults.xlsx": "https://www.bankofcanada.ca/wp-content/uploads/2026/10/BoC-BoE-Database-2026.xlsx",
    "etad.csv": "https://yukiyanai.github.io/data_etad/ETAD_v_1_0_0.csv",
    "restructurings.xlsx": "https://docs.google.com/spreadsheets/d/16NPCuwXk7KzY1peEOHZkRKUETkPdYse2/export?format=xlsx",
    **{f"{name}.json": f"{WDI}/{code}?source=2&date=1960:2022&format=json&per_page=30000"
       for name, code in INDICATORS.items()},
}


def validate(name, body):
    if name.endswith(".json"):
        meta, rows = json.loads(body)
        if int(meta["pages"]) != 1 or len(rows) != int(meta["total"]):
            raise ValueError(f"Incomplete WDI response for {name}")
    elif name.endswith(".xlsx") and not body.startswith(b"PK"):
        raise ValueError(f"Expected an Excel workbook for {name}")
    elif name == "etad.csv" and b'"held_date"' not in body.splitlines()[0]:
        raise ValueError("Unrecognised ETAD header")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--refresh", action="store_true", help="Replace cached downloads.")
    args = parser.parse_args()
    RAW.mkdir(exist_ok=True)
    records = {}
    retries = Retry(total=3, backoff_factor=1, status_forcelist=(429, 500, 502, 503, 504))
    with requests.Session() as session:
        session.mount("https://", HTTPAdapter(max_retries=retries))
        for name, url in SOURCES.items():
            path = RAW / name
            if args.refresh or not path.exists():
                response = session.get(url, timeout=(15, 120))
                response.raise_for_status()
                body = response.content
                validate(name, body)
                with NamedTemporaryFile(dir=RAW, delete=False) as tmp:
                    tmp.write(body)
                Path(tmp.name).replace(path)
            else:
                body = path.read_bytes()
                validate(name, body)
            records[name] = {"url": url, "sha256": hashlib.sha256(body).hexdigest()}
            print(f"{name}: {records[name]['sha256']}")
    (RAW / "sources.json").write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
