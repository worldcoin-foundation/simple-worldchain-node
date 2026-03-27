# Simple World Chain Node

> Anyone running a World Chain node is encouraged to join this Telegram channel for notifications of required software updates or other relevant information: [World Chain Node Updates Telegram Channel](https://t.me/world_chain_updates)

A simple Docker Compose script for launching full / archive node for World Chain.

> Forked from [simple-optimism-node](https://github.com/smartcontracts/simple-optimism-node).

## Recommended Hardware

- 8+ CPU Cores
- 32GB+ RAM (More is better)
- Storage:
    - \>4TB NVMe SSD (Reth, Geth with Path-Based Storage)
    - \>16TB NVMe SSD (Geth with Hash-Based Storage)
- 100mbps+ Download Speed

## Installation and Configuration

> Note: Tested on Ubuntu 24.04. This README assumes you already have Docker installed in your environment. If not, please consult resources for your specific environment.

### Clone the Repository

```sh
git clone https://github.com/worldcoin-foundation/simple-worldchain-node.git
cd simple-worldchain-node
```

### Copy .env.example to .env

Make a copy of `.env.example` named `.env`.

```sh
cp .env.example .env
```

Open `.env` with your editor of choice.

### Mandatory configurations

> Note: Mentions of `reth` or `op-reth` refer to the customized `world-chain` client, which is an extension of `op-reth`. Usage of `op-reth` throughout this repository is for continuity. You can find the `world-chain` codebase [here](https://github.com/worldcoin/world-chain).

* **NETWORK_NAME** - Choose which World Chain network you want to operate on:
    * `worldchain-mainnet` - World Chain Mainnet
    * `worldchain-sepolia` - World Chain Sepolia
* **COMPOSE_PROFILES** - Choose which Execution Client you want to run:
    * `reth` - op-reth with World Chain-specific customizations. This is the default option.
    * `geth` - op-geth, support ending on May 31, 2026.
* **NODE_TYPE** - Choose the type of node you want to run:
    * `full` (Full node) - A Full node contains ~10,000 recent blocks without historical states.
    * `archive` (Archive node) - An Archive node stores the complete history of the blockchain, including historical states.
    * `minimal` (`op-reth` only, minimal node) - A Minimal node prunes as aggressively as possible, using the least storage. Only supported on `op-reth`.
* **L1_RPC_ENDPOINT** - Specify the endpoint for the RPC of Layer 1 (e.g., Ethereum mainnet).
* **L1_BEACON_RPC_ENDPOINT** - Specify the beacon endpoint of Layer 1.
* **L1_RPC_TYPE** - Specify the service provider for the RPC endpoint you've chosen in the previous step. The available options are:
    * `alchemy` - Alchemy
    * `quicknode` - Quicknode (ETH only)
    * `erigon` - Erigon
    * `basic` - Other providers

### Optional configurations

* **FLASHBLOCKS_ENABLED** - Enable Flashblocks when using the `world-chain` client
    * `true` - Flashblocks enabled (Default)
    * `false` - Flashblocks disabled
* **DOWNLOAD_SNAPSHOT** - Whether to use snapshots for initial sync of the `world-chain` client
    * `true` - Download snapshot if datadir is empty (Default)
    * `false` - Skip downloading snapshot (not recommended)
* **GETH_SYNCMODE** - Specify sync mode for op-geth
    * Unspecified - Use default snap sync for full node and full sync for archive node
    * `snap` - Snap Sync (recommended for full node)
    * `full` - Full Sync (highly recommended for archive node)
* **GETH_STATE_SCHEME** - Specify storage scheme for `op-geth`
    * `path` - Path-based Storage Scheme (Default)
        * PBSS is now supported for `op-geth` archive nodes as of v1.101602.0. The `eth_getProof` RPC method is not supported when using PBSS.
    * `hash` - Hash-based storage (For archive node, not recommended for full node)
        * Hash-based storage is only recommended when support for the `eth_getProof` RPC method is required.
> `GETH_STATE_SCHEME` must be set upon first start of your node. Changing this value later will have no effect. Migration from hash- to path-based storage (or vice versa) is not possible, the node must be re-synced from scratch.

* **PORT__[...]** - Use custom port for specified components.

## Operating the Node

### Start

```sh
docker compose up -d
```

Will start the node in a detatched shell (`-d`), meaning the node will continue to run in the background.

### View logs

```sh
docker compose logs -f --tail 10
```

To view logs of all containers.

```sh
docker compose logs <CONTAINER_NAME> -f --tail 10
```

To view logs for a specific container. Most commonly used `<CONTAINER_NAME>` are:
* op-reth (or op-geth)
* op-node

### Stop

```sh
docker compose down
```

Will shut down the node without wiping any volumes.
You can safely run this command and then restart the node again.

### Restart

```sh
docker compose restart
```

Will restart the node safely with minimal downtime but without upgrading the node.

### Upgrade

Pull the latest updates from GitHub, and Docker Hub and rebuild the container.

```sh
git pull
docker compose pull
docker compose up -d
```

Will upgrade your node with minimal downtime.

### Wipe [DANGER]

```sh
docker compose down -v
```

Will shut down the node and WIPE ALL DATA. Proceed with caution!

## Monitoring

### Grafana dashboard

Grafana is exposed at [http://localhost:3000](http://localhost:3000) and comes with two pre-loaded dashboards, one each for `op-reth` and `op-geth`.
The OP-Reth Dashboard includes in-depth information about the performance and sync state of `op-reth`.
The OP-Geth Dashboard includes basic node information and will tell you if your node ever falls out of sync with the reference L2 node or if a state root fault is detected.


The following links will take you directly to your dashboard of choice.
- [OP-Reth Dashboard](http://localhost:3000/d/2k8BXz24x/op-reth-dashboard)
- [OP-Geth Dashboard](http://localhost:3000/d/fNH7uZ97k/op-geth-dashboard)

## Troubleshooting

### Walking back L1Block with curr=0x0000...:0 next=0x0000...:0

If you experience "walking back L1Block with curr=0x0000...:0 next=0x0000...:0" for a long time after the Ecotone upgrade, consider these fixes:
1. Wait for a few minutes. This issue usually resolves itself after some time.
2. Restart docker compose: `docker compose down` and `docker compose up -d`
3. If it's still not working, try setting `GETH_SYNCMODE=full` in .env and restart docker compose
