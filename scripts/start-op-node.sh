#!/bin/sh
set -e

# Determine holocene timestamp based on mainnet or testnet
# Remove this block and --override.holocene arg after holocene timestamp merged into superchain registry and new version of op-geth released
if [ "$NETWORK_NAME" = "worldchain-mainnet" ]; then
  export HOLOCENE_TIMESTAMP=1738238400
elif [ "$NETWORK_NAME" = "worldchain-sepolia" ]; then
  export HOLOCENE_TIMESTAMP=1737633600
fi

# Start op-node.
exec op-node \
  --l1=$OP_NODE__RPC_ENDPOINT \
  --l2="http://op-${COMPOSE_PROFILES}:8551" \
  --l2.enginekind=$COMPOSE_PROFILES \
  --rpc.addr=0.0.0.0 \
  --rpc.port=9545 \
  --l2.jwt-secret=/shared/jwt.txt \
  --l1.trustrpc \
  --l1.rpckind=$OP_NODE__RPC_TYPE \
  --l1.beacon=$OP_NODE__L1_BEACON \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7300 \
  --syncmode=execution-layer \
  --network=$NETWORK_NAME \
  --rollup.load-protocol-versions=true \
  --rollup.halt=major \
  --override.holocene="$HOLOCENE_TIMESTAMP"
