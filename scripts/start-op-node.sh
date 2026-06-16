#!/bin/sh
set -e

# Start op-node.
exec op-node \
  --l1=$L1_RPC_ENDPOINT \
  --l2="http://world-chain:8551" \
  --l2.enginekind=reth \
  --rpc.addr=0.0.0.0 \
  --rpc.port=9545 \
  --l2.jwt-secret=/shared/jwt.txt \
  --l1.trustrpc \
  --l1.rpckind=$L1_RPC_TYPE \
  --l1.beacon=$L1_BEACON_RPC_ENDPOINT \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7300 \
  --p2p.listen.tcp="${PORT__CONSENSUS_P2P:-9222}" \
  --syncmode=execution-layer \
  --network=$NETWORK_NAME \
  --p2p.useragent=worldchain \
