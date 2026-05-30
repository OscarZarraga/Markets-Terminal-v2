# Unified Terminal

A Bloomberg-style desktop financial terminal that runs entirely from a single
self-contained Python file plus a handful of HTML pages. No build step, no
framework, no Electron, no `pip install`. Everything is rendered in your
default browser.

**Copyright (c) 2026 Oscar Zarraga Perez. Released under the MIT License.**

## What you get

Three pinned tabs inside one window, with in-app sub-tabs for anything you
click (SEC filings, press releases, news articles — all stay inside the
terminal):

- **Markets** — full equity terminal: watchlist, price chart, key stats,
  income / balance / cash flow, earnings, news, press releases, SEC filings,
  company profile. Editable Indices / FX / Crypto side panels (add/remove
  tickers, persisted to `localStorage`).

- **Watchlist Feed** — aggregated news, press releases, SEC filings, and
  next-earnings-date for every ticker in your watchlist. Includes a
  TradingView-style earnings table with EPS estimate vs actual and surprise %
  for the most recent quarter.

- **Policy Watch** — today's regulatory and macro calendar: Senate Banking,
  Senate Ag, House Financial Services and House Ag committee hearings,
  Federal Register rule publications + comment deadlines, SEC / CFTC / Fed /
  Treasury press releases, ECB / Bank of England news, daily Bitcoin & Ethereum
  spot ETF flows from Farside, plus a curated directory of every regulatory,
  macro, on-chain, ETF, and international source.

## Run it

```bash
python3 markets_data_api.py
```

Or on **macOS / Linux**: double-click `start_mac_linux.command`.
On **Windows**: double-click `start_windows.bat`.

Then open <http://127.0.0.1:8787/>.

Python 3.9+ is required. No `pip install` is needed — the entire backend
runs on the standard library.

## Optional: API keys

The terminal works fully without any API keys, but four free-tier providers
expand the data depth (deeper company fundamentals, more reliable quote
fallbacks, news, financials).

The simplest path: open **`HOW_TO_ADD_API_KEYS.txt`** in this folder and
follow the five numbered steps.

Short version — copy `keys.json.example` to `keys.json` and paste your keys:

```bash
cp keys.json.example keys.json
```

| Provider | Free tier | Sign-up |
|---|---|---|
| Finnhub | 60/min | <https://finnhub.io/register> |
| Financial Modeling Prep | 250/day | <https://site.financialmodelingprep.com/developer/docs> |
| Twelve Data | 8/min, 800/day | <https://twelvedata.com/register> |
| Alpha Vantage | 5 req/min, 500/day | <https://www.alphavantage.co/support/#api-key> |

**Never commit `keys.json` to a public repo.** The included `.gitignore`
blocks it by default.

## Data sources

Free / no-key:
- Yahoo Finance v7 + v8 (quotes, charts, financials)
- Stooq CSV (historical data fallback)
- CoinGecko (Bitcoin and crypto)
- mempool.space (Bitcoin chain health)
- alternative.me (Fear & Greed Index)
- SEC EDGAR (filings, insider transactions, company facts)
- Nasdaq public calendar API (earnings, economic, IPO, dividends, splits)
- Federal Register public API (rules, comment deadlines)
- Federal Reserve / SEC / CFTC / Treasury press RSS
- Senate Banking, Senate Ag, House Financial Services, House Ag RSS
- ECB and Bank of England press RSS
- Farside (BTC & ETH ETF flows)
- Google News RSS, Yahoo Finance RSS, MarketWatch RSS

Optional / keyed (used as fallbacks or for richer fields):
- Alpha Vantage, Financial Modeling Prep, Finnhub, Twelve Data

## In-app tab proxy

Click any external link inside the terminal (SEC filing, press release,
committee hearing notice, news article, Federal Register notice) and it opens
as a new tab inside the terminal itself, fetched server-side and stripped of
`X-Frame-Options` so it can be embedded. No browser window is ever spawned.

## File structure

```
Unified-Terminal-Public/
├── markets_data_api.py        # The entire backend (~8,900 lines, stdlib only)
├── terminal.html              # The shell — tab manager
├── markets.html               # Markets tab UI
├── calendar.html              # Watchlist Feed tab UI
├── policy.html                # Policy Watch tab UI
├── start_mac_linux.command    # Mac / Linux launcher
├── start_windows.bat          # Windows launcher
├── keys.json.example          # API keys template (copy → keys.json, paste keys)
├── HOW_TO_ADD_API_KEYS.txt    # Plain-text 5-step guide to setting up keys
├── LICENSE                    # MIT
├── README.md                  # This file
├── CHANGELOG.md               # Phase 2 changelog
├── SETUP.pdf                  # Step-by-step setup guide (with cover + disclaimer)
└── Terminal Architecture.pdf  # Cover + disclaimer + full technical documentation
```

See **SETUP.pdf** for installation instructions and **Terminal
Architecture.pdf** for the full architecture deep-dive.

## License

MIT — do whatever you want, just keep the copyright notice. See `LICENSE`.
