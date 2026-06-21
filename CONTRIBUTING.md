# Contributing to Unified Terminal

Thank you for considering a contribution. This project is small, hand-coded, and intentionally has zero runtime dependencies — please keep that spirit in mind when proposing changes.

---

## Table of contents

- [How to ask a question](#how-to-ask-a-question)
- [How to report a bug](#how-to-report-a-bug)
- [How to propose a feature](#how-to-propose-a-feature)
- [How to submit code](#how-to-submit-code)
- [Project conventions](#project-conventions)
- [Adding a new data source](#adding-a-new-data-source)
- [Adding a new UI panel or tab](#adding-a-new-ui-panel-or-tab)
- [Running locally](#running-locally)
- [Testing](#testing)
- [Documentation](#documentation)
- [License of your contribution](#license-of-your-contribution)

---

## How to ask a question

Open an issue using the **Question** template, or check first:

1. The on-screen `F1` help modal — symbols, commands, shortcuts.
2. [SETUP.pdf](SETUP.pdf) — install, customization, troubleshooting.
3. [Terminal Architecture.pdf](Terminal%20Architecture.pdf) — every endpoint, every data source.
4. [FEATURES.md](FEATURES.md) — what each tab does, by asset class.
5. Existing issues — search closed ones first.

---

## How to report a bug

Use the **Bug report** issue template. A great bug report includes:

- **What you expected to happen.**
- **What actually happened** (screenshots are gold for UI bugs).
- **Steps to reproduce** (which ticker? which tab? after which action?).
- **Your environment**: OS, Python version (`python3 --version`), browser, whether you have any API keys configured.
- **Console output** from the Python server window or `terminal_server.log` (logs live next to the script).
- **Browser DevTools console errors** (F12 → Console).

Especially helpful: if a data source has gone stale or changed shape, paste a `curl` (or `Invoke-WebRequest`) example showing the actual upstream response so we can update the parser.

---

## How to propose a feature

Use the **Feature request** issue template. Before writing code, please open an issue and describe:

- **What problem you're trying to solve.** Not "add X" but "I can't see Y, so I'd like X."
- **Where it should live** — which tab, which panel, when does it appear.
- **What data source would back it.** If it's a paid API or one with restrictive Terms of Service, please call that out — this project deliberately stays on free / public sources.

Discussion before code lets us catch architectural conflicts early.

---

## How to submit code

1. Fork, branch, code, commit, push, open a pull request.
2. Keep PRs small and focused — one logical change per PR is much easier to review.
3. Reference the issue number in the PR title (`Fixes #42: ...`).
4. Run the server locally and verify the affected page still loads cleanly.
5. If you touched `markets_data_api.py`, run `python3 -c "import ast; ast.parse(open('markets_data_api.py').read())"` to confirm it still parses.

---

## Project conventions

### Backend (`markets_data_api.py`)

- **Standard library only.** No `pip install`, no third-party imports. If a feature truly needs a library, open an issue first — the answer is usually "we can do it with `urllib` + `xml.etree.ElementTree`."
- **Every network call is cached.** Use the existing `_cache_get` / `_cache_put` helpers with a per-key TTL. Quote endpoints: 10–60 seconds. Fundamentals: hours. SEC company-facts: 24 h.
- **Every network call is rate-limited.** Use `_polite_fetch(url, host=..., ...)` instead of raw `urllib.request.urlopen`. The polite layer enforces a per-host minimum interval (see `_HOST_INTERVAL` at the top of the file).
- **Every failure path is silent.** Network errors, bad JSON, missing fields — return `None` / `{}` / `[]` and let the caller decide. Don't raise into the response handler.
- **No PII, no secrets.** API keys live in `keys.json` only; never log them. No analytics, no telemetry.
- **Comments explain *why*, not what.** Especially around the garbage detector, the unified resolver, and the proxy rewrite logic — they catch subtle upstream regressions and the comments are what let future-you debug them.

### Frontend (the HTML pages)

- **Vanilla JS only.** No bundler, no framework, no build step. Everything is plain DOM + `fetch`.
- **CSS variables for theming.** Anything color-related goes through `var(--text)` / `var(--muted)` / `var(--orange)` etc. Defined at the top of each file in `:root { ... }`.
- **Sandboxed iframes.** The shell uses `sandbox="allow-scripts allow-same-origin allow-forms allow-popups-to-escape-sandbox"`. Don't add capabilities without a strong reason — the sandbox is what keeps proxied third-party pages safe to embed.
- **Stable IDs.** Tab data attributes, button IDs, and panel IDs are what the keyboard shortcuts and other scripts hook into. Don't rename them lightly.

---

## Adding a new data source

1. **Read the upstream's Terms of Service first.** This project stays on sources that allow scraping or have an explicit "free / no auth" tier. If the ToS says no, don't add it.
2. **Add a fetcher in `markets_data_api.py`** with the standard shape:
   ```python
   def my_source_quote(sym):
       """Brief docstring describing what it returns."""
       cache_key = f"mysrc::{sym}"
       cached = _cache_get(cache_key)
       if cached is not None:
           return cached
       url = f"https://example.com/api/quote?symbol={quote(sym)}"
       code, body = _polite_fetch(url, host="example.com",
                                  accept="application/json", timeout=10)
       if code != 200 or not body:
           _cache_put(cache_key, None, ttl=30)
           return None
       try:
           data = json.loads(body)
       except Exception:
           _cache_put(cache_key, None, ttl=30)
           return None
       # ... shape into our normalized dict ...
       _cache_put(cache_key, shape, ttl=60)
       return shape
   ```
3. **Wire it into the relevant chain.** Quotes go into `shape_quote()` and/or `resolve_prices()`. News goes into `fetch_news_all()`. Filings go into the SEC chain.
4. **Add the source to the "Sources" strip** at the bottom of `markets.html` so users know it's in the mix.
5. **Update `Terminal Architecture.pdf`** (section 2 — Data sources). The PDF generator lives in the `/tmp/build_pdfs.py` flow described in the architecture doc; or simply edit the source list and rebuild.

---

## Adding a new UI panel or tab

1. New top-level tab → add a row to `SYSTEM_TABS` in `terminal.html` and create a new HTML file under the project root.
2. New bottom tab inside Markets → add a `<div class="b" data-tab="...">` in `markets.html`'s `botnav`, then a `case '...':` branch in `renderBottom()`, then a `renderXxx(body, s)` function.
3. New side panel → add an `<input>` + `<button>` + `<table>` block, then a `refreshXxx()` async function. Persist user-edited contents in `localStorage` under a stable key (the existing panels use `terminal_idx`, `terminal_fx`, `terminal_cx`).

---

## Running locally

```bash
# macOS / Linux
python3 markets_data_api.py --port 8787

# Windows
python markets_data_api.py --port 8787
```

Useful flags:

| Flag | Effect |
|---|---|
| `--port 9000` | Bind to a different port (auto-increments if busy) |
| `--no-browser` | Don't auto-open the browser at startup |
| `--tab` | Open in a normal browser tab instead of a standalone PWA-style window |
| `--host 0.0.0.0` | Bind to all interfaces (be careful — anyone on your network can hit it) |

For SEC EDGAR fetches in production, set your contact email so the SEC fair-access policy is satisfied:

```bash
export SEC_USER_AGENT="My Company me@mycompany.com"
```

---

## Testing

There's no formal test suite — the project is small enough that manual verification per change is fine. A useful smoke test:

```bash
python3 -c "import ast; ast.parse(open('markets_data_api.py').read())" && echo OK
```

For more thorough verification, load AAPL, NVDA, ^GSPC, EURUSD=X, BTC-USD, SOL-USD in the Markets tab and confirm every panel populates. Open the F1 modal and run a couple of Bloomberg-style commands (`AAPL DES`, `WEI`, `FXC`). Click a news headline and a SEC filing to confirm the in-app tab proxy still works.

---

## Documentation

- **Code comments** — explain the *why* around tricky logic.
- **PDF docs** (`SETUP.pdf`, `Terminal Architecture.pdf`) — the source for these is the ReportLab Platypus script in the project history; if you make architecturally-significant changes, please refresh the PDFs.
- **CHANGELOG.md** — bump the version + add a dated entry summarizing user-visible changes.
- **README.md / FEATURES.md** — keep the feature lists current.

---

## License of your contribution

By submitting a pull request you agree that your contribution is licensed under the same [MIT License](LICENSE) as the rest of the project. You retain copyright in your contribution; you're granting the project the right to redistribute it under MIT.

---

Thanks again for contributing. Even tiny fixes (a typo, a clearer comment, a stale data source) are very welcome.
                                                                                                                                                                                                             