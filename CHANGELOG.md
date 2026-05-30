# Changelog — Phase 2

This is a summary of every change made to extend the Phase 1 base terminal
into the unified-terminal you see now. Phase 1 was the two original
terminals (a markets data terminal and a Bitcoin Intelligence dashboard).
Phase 2 is everything below — fusing them and adding the policy / news
intelligence layer.

## Architecture

- **Unified shell** with a top tab bar (`terminal.html`). Three pinned
  tabs: Markets, Watchlist Feed, Policy Watch. Every external link the
  user clicks opens as a new in-app tab — no browser window is ever
  spawned.
- **In-app tab proxy** (`/api/proxy?url=...`). Fetches external pages
  server-side, strips frame-blocking headers (`X-Frame-Options`,
  `frame-ancestors`), injects a `<base>` tag and a click-interceptor so
  navigation inside the iframe also pops new in-app tabs, plus a CSS
  reset so degraded pages still render readably.

## Markets tab

- Patched `terminal_ui.html` to route every `window.open(url, '_blank')`
  and every `<a target="_blank">` through a `postMessage` to the parent
  shell. The shell creates a new in-app tab via the proxy.
- **Finnhub is now the primary source for the watchlist**. Parallel
  `fh_quote` over a `ThreadPoolExecutor(max_workers=8)`. Yahoo is the
  fallback rather than the primary.
- **Garbage detector inside `yahoo_v7_quotes_batch`**: when Yahoo returns
  a degraded-mode response where more than 50% of the requested tickers
  share an identical price, the whole batch is rejected and the fallback
  chain kicks in. This fixes the symptom where AAPL/MSFT/NVDA/SPY all
  showed the same `$11.78` or `$12.30` value.
- **`fh_metrics(sym)` helper**. Finnhub `/quote` only returns
  price/open/high/low/change. `fh_metrics` calls `/stock/metric` and
  populates marketCap, sharesOutstanding, trailing/forward P/E, EPS TTM,
  beta, dividend yield, dividend rate, 52-week high/low, average volume.
  These are merged into the watchlist response so the SUMMARY panel on
  the right populates every field.
- **Non-stock routing**. `is_non_stock(sym)` returns True for `^*`
  (indices), `=X` (FX), `=F` (commodity futures), `DX-Y.NYB` (DXY), and
  crypto. `_shape_quote_inner` skips Finnhub and FMP for these — they go
  straight from Yahoo v7 → Yahoo v8 → Stooq, the only sources that
  actually carry indices and FX.
- **One unified Yahoo v7 batch call** for stocks + non-stocks together,
  so the garbage detector operates on the whole bag.
- **Editable Indices / FX / Crypto panels**. Each side panel has an inline
  add input, a remove × per row, and a CLR link in the header. The lists
  persist in `localStorage` as `terminal_idx`, `terminal_fx`,
  `terminal_cx`.

## SEC proxy fix

- Proper SEC User-Agent (`Unified-Terminal contact@example.com`)
  per their fair-access policy.
- White-background CSS reset injected into proxied pages so they render
  readably even when the original stylesheet 404s inside the iframe.
- `<base href>` set from the **final** URL after redirects, so relative
  resources resolve.
- Stripped inline `<meta http-equiv="content-security-policy">`,
  `x-frame-options`, and `refresh` tags.
- `X-Frame-Options: ALLOWALL` and `Content-Security-Policy: frame-ancestors *`
  forced on responses, overriding upstream.

## Watchlist Feed tab (`calendar.html`)

- Replaces the old generic Calendar tab.
- Reads the watchlist from `localStorage["terminal_wl"]` (same storage
  the Markets tab writes to — pages share localStorage because they're
  served from the same origin).
- Per ticker, fetches `/api/news-all`, `/api/press`, `/api/summary`
  (SEC filings), and `/api/earningsdate` in parallel. Concurrency
  capped at 8 to keep the backend polite.
- Six sub-views: All · News · Press Releases · SEC Filings · Earnings
  Dates · By Ticker.
- **TradingView-style earnings table**. Two stacked tables (Upcoming
  Earnings, Reported Most Recent Quarter) with columns for date, time
  (BMO/AMC pill), ticker, company name + logo, period, EPS estimate,
  EPS actual, surprise % (color-coded green/red), and market cap.
  Powered by `rich_earnings(sym)` which combines Finnhub history,
  Nasdaq next-date forecast, and Finviz time-of-day classification.
- Auto-refresh every 5 minutes.

## Policy Watch tab (`policy.html`)

- New tab aggregating today's regulatory + macro events.
- Seven sub-views: All, Committee Hearings, Federal Register,
  Regulators (SEC/CFTC/Fed/Treasury), Central Banks Intl, BTC + ETH
  ETF Flows, All Sources.
- **Federal Register public JSON API** for rules, proposed rules, and
  notices from the SEC, CFTC, Fed, and Treasury — including comment
  deadline color coding (red ≤3 days, amber ≤10 days).
- **RSS aggregators** for Federal Reserve, Treasury, SEC, CFTC,
  Senate Banking, Senate Ag, House Financial Services, House Ag,
  ECB, and Bank of England.
- **Farside scraper** for daily Bitcoin and Ethereum spot ETF net
  flows. Uses Python's `html.parser` (not regex) and tries multiple
  Farside URLs per asset (`/btc/`, `/bitcoin-etf-flow-all-data/`,
  `/?p=997`).
- **54-link directory** in the "All Sources" view, organized into
  Regulatory & Legislative · Macro & Economic Data · BTC Treasury
  Companies · ETF Flows & Derivatives · Market Price & On-Chain ·
  International · Specialized Trackers. Every link opens as an in-app
  tab via the proxy.
- 15-minute per-source cache; 10-minute UI refresh.

## Performance & reliability

- **Provider separation**: Markets watchlist on Finnhub primary →
  Yahoo backup; Policy and Watchlist Feed each have their own paths.
  No tab can saturate the rate-limit budget of another.
- **Per-source TTL caches** for the Bitcoin Intel endpoints (later
  reused by Policy Watch). Each source has its own cache and its own
  expiration so any single slow source doesn't block the response.
- **Stale-while-error policy**. When an upstream fetch fails on
  refresh, the last known good value is served instead of replacing
  it with empty data. Prices never blank out, they go stale and stay
  visible.
- **Watchlist row cache** with a 50% price-jump detector. A single
  ticker swinging more than 50% between refreshes is almost always
  bad data (Yahoo degraded mode); the cached row is preferred in
  that case.
- **`fh_quotes_batch_parallel`**, **`fmp_quotes_batch`**, and
  **`td_quotes_batch`** — concurrent / true-batch helpers so 10+
  ticker watchlists complete in one round-trip per provider.

## Bitcoin Intel (folded into other tabs)

An early Phase-2 Bitcoin Intel tab was built and then removed from the
pinned tab bar in favor of the Watchlist Feed and Policy Watch tabs.
The page file was deleted from the public build; the backend
`/api/btc/intel` endpoint still works for anyone who wants to add the
tab back.

Phase-2 enrichment that was added before the tab was retired:

- CoinGecko deep-stats fetch (ATL, FDV, total/max supply, dev activity,
  sentiment up/down votes, public interest score, market cap rank).
- BTC vs fiat row (USD, EUR, GBP, JPY, CNY, CHF, AUD, CAD).
- Halving countdown computed locally from current block height
  (210,000-block schedule), no network call needed.
- Basket equities (treasury cos, miners, ETFs) now use free Yahoo + Stooq
  primary, with FMP only as a last-resort fallback.

## Public-build (this folder)

- Sanitized SEC default User-Agent from a personal email to
  `contact@example.com`.
- Removed `keys.json`; replaced with `keys.json.example` template.
- Added `LICENSE` (MIT, copyright Oscar Zarraga Perez).
- Added `.gitignore` blocking `keys.json`, `__pycache__/`, `.env`,
  IDE folders, OS files.
- Added this `CHANGELOG.md`, plus `SETUP.pdf` and `Terminal
  Architecture.pdf` (cover + disclaimer + full technical documentation),
  and `HOW_TO_ADD_API_KEYS.txt` (5-step plain-text guide).
