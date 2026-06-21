# Features

A complete feature matrix for Unified Terminal, organized by tab and asset class.
Everything listed here works **without** any API keys; the keyed columns describe what *extra* depth keys unlock.

---

## Top-level tabs

| Tab | Purpose | Auto-refresh |
|---|---|---|
| **TERMINAL** | The shell. Tab manager + `+ GO URL` for arbitrary URLs. | n/a |
| **MARKETS** | Watchlist + quote desk + side panels + bottom data tabs. | Watchlist every 30 s |
| **WATCHLIST FEED** | Aggregated news + press + filings + earnings for every ticker on your watchlist. | Every 5 min |
| **POLICY WATCH** | Regulatory + legislative + central-bank + macro calendar. | Every 10 min |

Plus the built-in dynamic tabs that spawn when you click an SEC filing, press release, news article, or any URL through `+ GO URL`.

---

## Markets tab — what each panel does

### Top strip (auto-scrolling indices)
Live mini-quotes for S&P, DOW, NASDAQ, Russell 2000, VIX, FTSE, Nikkei, HSI, DAX, Gold, Silver, WTI, NatGas, Copper, DXY, US 10Y, BTC, ETH, EUR/USD, USD/JPY, GBP/USD. Click any chip to load that symbol in the main panel.

### Left column — Watchlist + Indices + FX + Crypto
Four editable side panels with `ADD TICKER`, `× remove`, and `CLR all`. State persists in `localStorage`.

| Panel | Format | Default population |
|---|---|---|
| **WATCHLIST** | Any Yahoo-shaped symbol | Empty — add your own |
| **INDICES** | `^GSPC` style | S&P, DOW, NASDAQ, RUS2K, VIX, FTSE, DAX, CAC, NIKKEI, HSI, STOXX50, US10Y, US30Y, US5Y |
| **FX** | `EURUSD=X` style | EUR, GBP, JPY, CHF, AUD, CAD, NZD, CNY, MXN, INR, BRL, EURGBP |
| **CRYPTO** | `BTC-USD` style | BTC, ETH, SOL, BNB, XRP, ADA, DOGE, AVAX, DOT, LINK, MATIC, LTC |

### Center hero
Symbol, name, big animated price (flashes green/red on tick), change, % change, exchange badge, currency, market state, NY market clock with regular/pre/post/closed regions.

### Center bottom tabs (changes by asset class)

| Tab | Stocks | Indices | FX | Crypto | Futures |
|---|---|---|---|---|---|
| **OVERVIEW** | ✅ | hidden | hidden | hidden | ✅ |
| **INCOME** | ✅ | hidden | hidden | hidden | hidden |
| **BALANCE** | ✅ | hidden | hidden | hidden | hidden |
| **CASH FLOW** | ✅ | hidden | hidden | hidden | hidden |
| **EARNINGS** | ✅ | hidden | hidden | hidden | hidden |
| **NEWS** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **PRESS REL** | ✅ | hidden | hidden | hidden | hidden |
| **PROFILE** | ✅ | hidden | hidden | hidden | hidden |
| **SEC FILINGS** | ✅ | hidden | hidden | hidden | hidden |

### Right column — SUMMARY + COMPANY + TOP NEWS

| Block | Stocks | Non-stocks |
|---|---|---|
| **SUMMARY** | Last, change, %, open, prev close, day hi/lo, volume, avg vol, market cap, shares out, 52W H/L, beta, trailing PE, forward PE, EPS (TTM), Div/Share, yield, currency, exchange | Same, but only the relevant fields |
| **COMPANY** | Sector, industry, country, employees, website, address, phone, CEO + 50+ ratio rows (beta, PE, PEG, P/S, P/B, EV/EBITDA, margins, ROA, ROE, revenue, growth, EPS, FCF, debt, dividend, ex-div, analyst targets, recommendation) | Name, symbol, class (Index/Currency Pair/Cryptocurrency/Futures), currency, exchange |
| **TOP NEWS** | 5 most recent headlines, click to open in-app | Same |

---

## Data sources by asset class

| Asset class | Primary | Fallback chain |
|---|---|---|
| **US Stocks** | Yahoo v7 batch | Finnhub → FMP → Yahoo v8 chart → Stooq → Yahoo HTML → Finviz → StockAnalysis |
| **International Stocks** | Yahoo v7 batch | FMP → Yahoo v8 chart → Stooq → Yahoo HTML → StockAnalysis (intl ADR coverage) |
| **Indices** | Yahoo v7 → Yahoo v8 chart | **MarketWatch** (scoped to `intraday__data`) → **CNBC** (`quote.cnbc.com`) → Twelve Data (`SPX:INDX`) → FMP → Stooq |
| **FX** | Yahoo v7 → Yahoo v8 chart | Twelve Data (`EUR/USD`) → **frankfurter.app** (ECB USD-based table, no key) → open.er-api.com → Stooq |
| **Commodities (futures)** | Yahoo v7 → Yahoo v8 chart | Stooq |
| **Crypto** | **CoinGecko** (one batch HTTP) | **Binance** (no key, `ticker/24hr` per symbol) — Yahoo is explicitly skipped to prevent BTC-price contamination |

---

## Watchlist Feed tab

Per-ticker rolling stream that combines:

| Source | What it provides |
|---|---|
| Yahoo Finance RSS | Publisher's direct article URLs (preferred — no redirect chain) |
| Google News RSS | Symbol-keyed coverage. URLs auto-decoded to publisher's URL via the embedded protobuf token |
| MarketWatch RSS | Top stories filtered to the symbol |
| Finnhub `/company-news` | (Optional key) symbol-specific feed |
| FMP `/stock_news` | (Optional key) broader news index |
| SEC EDGAR | 8-K, 10-K, 10-Q, S-1, etc. (links direct to the actual document, not the landing page) |
| SEC Form 4 | Insider transactions, parsed and human-readable |
| Nasdaq `/api/calendar` | Next earnings date with EPS consensus + annual forecast |
| `rich_earnings` aggregator | Combined: next date + period + EPS estimate + history + market cap + logo |

All headlines are deduped by URL and sorted newest first.

---

## Policy Watch tab

Seven sub-views, refreshed every 10 min:

| View | Contents | Source |
|---|---|---|
| **All** | Unified chronological stream | All below, merged + sorted |
| **Committee Hearings** | Senate Banking, Senate Ag, House Fin Services, House Ag | RSS feeds |
| **Federal Register** | SEC, CFTC, Fed, Treasury proposed + final rules with comment deadlines | `federalregister.gov/api/v1` |
| **Regulators** | SEC press, CFTC news, Fed FOMC/policy, Treasury OFAC | Each agency's RSS |
| **Central Banks (Intl)** | ECB decisions + Lagarde calendar, BoE rate decisions + news | ECB, BoE RSS |
| **BTC + ETH ETF Flows** | Daily net flows per fund + total | Farside.co.uk scrape |
| **All Sources** | Clickable directory of **54 curated links** (regulatory, macro, on-chain, ETF, international, market data, trackers) | Built-in |

---

## Bitcoin Intelligence tab

Real-time BTC dashboard:

| Block | Source |
|---|---|
| Price · market cap · 24h volume · 1h / 24h / 7d / 30d / 1y change · ATH · ATH distance · circulating supply | CoinGecko |
| BTC dominance | CoinGecko `/global` |
| Fear & Greed Index | alternative.me |
| Block height · current hash rate · mempool size · next-block fee · half-hour fee · hour fee · Lightning capacity | mempool.space |
| BTC treasury equity baskets (MSTR, RIOT, MARA, CLSK, HUT, CORZ, GLXY, …) | Yahoo v7 + Stooq |
| Cross-asset comparison chart | Yahoo v8 charts |

---

## In-app tab proxy

Every external link the terminal renders opens as a new in-app tab — never Chrome:

- **SEC filings** → custom `data.sec.gov` renderer (the SEC SPA doesn't iframe-boot)
- **Press releases** → BusinessWire, GlobeNewswire, PR Newswire, Yahoo Finance
- **News articles** → Bloomberg, Reuters, MarketWatch, CNBC, Yahoo Finance, MarketBeat, Stocktwits, Trefis, 24/7 Wall St., GuruFocus, Investopedia, etc. — Google News tokens are decoded to publisher URLs at fetch time
- **Federal Register documents** → server-rendered HTML with the original layout
- **ETF flow dashboards** → Farside.co.uk
- **Any URL** → enter it via `+ GO URL` (top-right) or `Ctrl/Cmd+L`

The proxy handles `gzip`/`deflate` decompression, strips `X-Frame-Options`/`Content-Security-Policy`, rewrites links so nested clicks also pop in-app tabs, and routes Google's consent walls past with a pre-set cookie.

---

## Keyboard shortcuts

| Key | Action |
|---|---|
| `F1` | Open help modal |
| `/` | Focus the command bar |
| `Esc` | Close help / clear input |
| `1` – `9` | Jump to bottom tab N |
| `Ctrl/Cmd + L` | + GO URL |
| `Ctrl/Cmd + W` | Close current dynamic tab |
| Middle-click on a tab | Close that tab |

---

## Bloomberg-style commands (Markets tab command bar)

Type a ticker followed by a function key — e.g. `AAPL DES <Enter>`.

| Command | Action |
|---|---|
| `<sym> GO` | Load the symbol |
| `<sym> DES` | Open PROFILE tab |
| `<sym> GIP` | Open OVERVIEW (price desk) |
| `<sym> FA` | Open financials (INCOME tab) |
| `<sym> CN` | Open NEWS |
| `<sym> HDS` | Open holders (Nasdaq institutional + Form 4 insiders) |
| `<sym> INS` | Open insider transactions |
| `<sym> EE` | Open earnings tab |
| `<sym> RV` | Show peers / sector relative-value |
| `WEI` | Switch to INDICES focus |
| `FXC` | Switch to FX focus (loads EUR/USD) |
| `HEAT` | Sector heatmap |
| `MOST` | Most-active movers |
| `ECO` | Economic calendar (today + next 7 days) |
| `HELP` | Open help modal |

---

## Reliability features (why prices never blank out)

| Layer | Behavior |
|---|---|
| **Multi-pass garbage detector** | Rejects Yahoo v7 batches where >50% of returned prices match exactly, where ≥40% cluster within 1% of the median, or where any single row's price differs from its own previous close by >50% |
| **Race-condition guard** | `_LOAD_TOKEN` discards in-flight responses for symbols the user already moved past |
| **Stale-while-error** | Empty fetches never overwrite real cached data — prices go stale, not blank |
| **Per-symbol Yahoo-v8 verification** | Rejects chart responses whose `meta.symbol` doesn't match the request (BTC-on-SOL contamination guard) |
| **MarketWatch regex scoping** | Limits to the `intraday__data` block, so the markets-overview strip at the top of every page doesn't leak DJI's price into every index |
| **Yahoo HTML symbol-match** | Walks every `QuoteSummaryStore` on the page, accepts the one whose `price.symbol` matches; only refuses when every embedded store carries an explicit different symbol (the original BTC-on-AAPL contamination case) |

---

## What's deliberately NOT included

- **No paid APIs.** Free / public sources only.
- **No analytics, telemetry, or external phone-home.** The Python server only talks to upstream data sources.
- **No login, no accounts.** Localhost only; bind to all interfaces only if you mean it.
- **No build step.** Vanilla JS, vanilla CSS, stdlib Python.
- **No external JS dependencies.** No React, no jQuery, no charts library. Everything is hand-written.

If you'd like one of those things, please open a feature request and explain the trade-off you're proposing — the no-deps stance is a design choice, not an oversight.
                                                                                                                                                                                                                                                                    