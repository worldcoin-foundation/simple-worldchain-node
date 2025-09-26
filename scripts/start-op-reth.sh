#!/bin/bash
set -eu

#set chain name for op-reth config
if [ "$NETWORK_NAME" = "worldchain-mainnet" ]; then
  export CHAIN_NAME="worldchain"
else
  export CHAIN_NAME="$NETWORK_NAME"
fi

exec op-reth node \
  --datadir=/data \
  --ws \
  --ws.origins="*" \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.api=debug,eth,net,txpool \
  --http \
  --http.corsdomain="*" \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.api=debug,eth,net,txpool \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.jwtsecret=/shared/jwt.txt \
  --metrics=0.0.0.0:6060 \
  --chain="${CHAIN_NAME}" \
  --rollup.disable-tx-pool-gossip \
  --port="${PORT__EXECUTION_P2P:-30303}" \
