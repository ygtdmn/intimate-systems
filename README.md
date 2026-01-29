# Intimate Systems Smart Contracts

This repository contains the Foundry harness and Solidity contracts that render the Intimate Systems show on-chain website via `web3://` (ERC-5219). The renderer serves an index page plus per‑sculpture media routes to keep gas use low.

## Install
```bash
bun install
```

## Build
```bash
bun run build
```

## Generate HTML output (mainnet fork)
This writes a static snapshot into `html_output/`:
- `html_output/index.html`
- `html_output/sculpture-media/{i}/index.html`

```bash
export RPC_URL="https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY"

forge test --match-test testRenderMainnetToFile -vvv --gas-limit 10000000000000 --memory-limit 500000000000000
```

## View locally
```bash
cd html_output && python -m http.server 8000
```

Open:
- `http://localhost:8000`

## Notes
- Media iframes resolve from `/sculpture-media/{index}` on-chain; the fork test mirrors those paths under `html_output/sculpture-media/{index}/index.html`.
