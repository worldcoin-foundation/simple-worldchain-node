# Simple World Chain Node

> Anyone running a World Chain node is encouraged to join this Telegram channel for notifications of required software updates or other relevant information: [World Chain Node Updates Telegram Channel](https://t.me/world_chain_updates)

A simple Docker Compose script for launching a World Chain node.

> Forked from [simple-optimism-node](https://github.com/smartcontracts/simple-optimism-node).

## Recommended Hardware

- 8+ CPU Cores (Prioritize clock speed over more cores)
- 32GB+ RAM (More is better)
- \>4TB NVMe SSD
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
* **NODE_TYPE** - Choose the type of node you want to run:
    * `archive` - An Archive node stores the complete history of the blockchain, including historical states.
    * `full` - A Full node contains ~10,000 recent blocks without historical states.
    * `minimal` - A Minimal node prunes as aggressively as possible, using the least storage.
* **L1_RPC_ENDPOINT** - Specify the endpoint for the RPC of Layer 1 (e.g., Ethereum mainnet).
* **L1_BEACON_RPC_ENDPOINT** - Specify the beacon endpoint of Layer 1.
* **L1_RPC_TYPE** - Specify the service provider for the RPC endpoint you've chosen in the previous step. The available options are:
    * `alchemy` - Alchemy
    * `quicknode` - Quicknode
    * `erigon` - Erigon
    * `basic` - Other providers

### Optional configurations

* **FLASHBLOCKS_ENABLED** - Enable Flashblocks when using the `world-chain` client
    * `true` - Flashblocks enabled (Default)
    * `false` - Flashblocks disabled
* **DOWNLOAD_SNAPSHOT** - Whether to use snapshots for initial sync of the `world-chain` client
    * `true` - Download snapshot if datadir is empty (Default)
    * `false` - Skip downloading snapshot (not recommended)
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
docker compose logs -f <CONTAINER_NAME> --tail 10
```

To view logs for a specific container. Most commonly used values for `<CONTAINER_NAME>` are `world-chain` and `op-node`. 

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

Grafana is exposed at [http://localhost:3000](http://localhost:3000) and comes with a pre-loaded dashboard for `world-chain`.

- [OP-Reth Dashboard](http://localhost:3000/d/2k8BXz24x/op-reth-dashboard)
