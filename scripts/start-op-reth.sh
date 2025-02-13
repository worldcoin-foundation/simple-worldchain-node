#!/bin/bash
set -eu

exec op-reth node \
  --datadir=/data \
  --log.stdout.format log-fmt \
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
  --chain "/chainconfig/genesis.json" \
  --rollup.sequencer-http=$SEQUENCER_HTTP \
  --rollup.disable-tx-pool-gossip \
  --enable-discv5-discovery \
  --port="${PORT__EXECUTION_P2P:-30303}" \
