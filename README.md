# Markets Terminal

A free, self-hosted, Bloomberg-style markets terminal.
Quotes, financials, news, SEC filings, policy events, BTC + crypto, all in one window — no broker account, no API keys required, no Chrome pop-ups.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python 3.9+](https://img.shields.io/badge/Python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![No dependencies](https://img.shields.io/badge/dependencies-stdlib%20only-brightgreen.svg)](markets_data_api.py)
[![Platform: macOS · Linux · Windows](https://img.shields.io/badge/platform-macOS%20·%20Linux%20·%20Windows-lightgrey.svg)]()

> **Created by Oscar Zarraga Perez** · Released under the MIT License.

---

## What is this?

A single-file Python backend (~9,500 lines, **standard library only**) plus four static HTML pages that together render a real-time markets desk in your browser.

| Tab | What's inside |
|---|---|
| **Markets** | Watchlist, indices, FX, crypto, full equity desk (quote · income · balance · cash flow · earnings · news · press releases · profile · SEC filings) |
| **Watchlist Feed** | Per-ticker news / press / filings / earnings aggregator |
| **Policy Watch** | Federal Register, SEC / CFTC / Fed / Treasury press, congressional hearings, BTC + ETH ETF flows, ECB / BoE — 54 curated sources |
| **Bitcoin Intel** | BTC price + market cap + dominance, fear & greed, mempool, hash rate, treasury baskets |

Click any SEC filing, press release, or news article — it opens as a new tab **inside the terminal**, not in Chrome. There's no Electron, no `pip install`, no build step.

---

## Quick start

### macOS

```bash
./start_mac_linux.command
```

Right-click → Open the first time (Gatekeeper). The script silently launches the server in the background and auto-closes the Terminal window once the browser is up.

### Windows

Double-click `start_windows.vbs` (recommended — no console window).
Or `start_windows.bat` (delegates to the same launcher).

### Any shell

```bash
python3 markets_data_api.py --port 8787
```

Open <http://127.0.0.1:8787/> and you're done.

> **Requires:** Python 3.9+. No `pip install` needed — everything runs on the standard library.

---

## Features

### Free out of the box
The whole terminal works with **zero configuration**. It pulls from 23+ free, no-key data sources:

> Yahoo Finance · Stooq · CoinGecko · Binance · MarketWatch · CNBC · frankfurter.app · SEC EDGAR · Nasdaq calendar · Federal Register · Fed / SEC / CFTC / Treasury RSS · Senate Banking + Ag · House FinSvcs + Ag · ECB · Bank of England · Farside · Finviz · StockAnalysis · mempool.space · alternative.me · Google News · MarketWatch RSS

### Add free-tier keys for more depth (optional)
Drop your free-tier keys into `keys.json` to unlock deeper fundamentals and a richer fallback chain:

| Provider | Free tier | What it adds |
|---|---|---|
| **Finnhub** | 60 req/min | Real-time quotes, deep metrics, earnings history |
| **Financial Modeling Prep** | 250 req/day | Ratios TTM, wider equity universe, ADR coverage |
| **Twelve Data** | 8/min · 800/day | Index batch (`:INDX`), FX (`EUR/USD`), extended statistics |
| **Alpha Vantage** | 5/min · 500/day | Company OVERVIEW (sector, industry, fundamentals) |

Keys are auto-reloaded within 2 seconds of editing `keys.json` — no ser
