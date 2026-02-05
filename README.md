# Intimate Systems Smart Contracts

This repository contains the Foundry harness and Solidity contracts that render the Intimate Systems show on-chain website via `web3://` protocol.

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

## Credits

- Intimate Systems curated by [Jonooo](https://x.com/im_jonooo) with [SuperRare](https://superrare.com/curation/exhibitions/intimate-systems)
- Artists: [0xG](https://0xg.xyz/), [dav](https://x.com/producedbydav), [diid](https://diid.art/), [FelixFelixFelix](https://x.com/I____felix____I), [Nahiko](https://x.com/nahiiko), [ripe0x.eth](https://ripe.wtf/), [Takens Theorem](https://takenstheorem.github.io/), [tokenfox](https://x.com/tokenfox1), [Yigit Duman](https://yigitduman.com/)
- Essay by [Luke Weaver](https://x.com/lukeweaver_eth)
- Special thanks to [0xfff](https://0xfff.love/) et al. for lighting the path with [World Computer Sculpture Garden](https://worldcomputersculpture.garden)
