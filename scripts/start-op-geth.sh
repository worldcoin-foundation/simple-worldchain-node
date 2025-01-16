#!/bin/sh
set -e

# Determine syncmode based on GETH_NODE_TYPE
if [ -z "$GETH_SYNCMODE" ]; then
  if [ "$GETH_NODE_TYPE" = "full" ]; then
    export GETH_SYNCMODE="snap"
  else
    export GETH_SYNCMODE="full"
  fi
fi

# Determine holocene timestamp based on mainnet or testnet
# Remove this block and --override.holocene arg after holocene timestamp merged into superchain registry and new version of op-geth released
if [ "$NETWORK_NAME" = "worldchain-mainnet" ]; then
  export HOLOCENE_TIMESTAMP=1738238400
elif [ "$NETWORK_NAME" = "worldchain-sepolia" ]; then
  export HOLOCENE_TIMESTAMP=1737633600
fi

# Start op-geth.
exec geth \
  --datadir=/data \
  --http \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.api=web3,debug,eth,txpool,net,engine \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.origins="*" \
  --ws.api=debug,eth,txpool,net,engine,web3 \
  --metrics \
  --metrics.influxdb \
  --metrics.influxdb.endpoint=http://influxdb:8086 \
  --metrics.influxdb.database=opgeth \
  --syncmode="$SYNCMODE" \
  --gcmode="$GETH_NODE_TYPE" \
  --authrpc.vhosts="*" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.jwtsecret=/shared/jwt.txt \
  --rollup.sequencerhttp="$SEQUENCER_HTTP" \
  --rollup.disabletxpoolgossip=true \
  --port="${PORT__EXECUTION_P2P:-39393}" \
  --discovery.port="${PORT__EXECUTION_P2P:-39393}" \
  --db.engine=pebble \
  --state.scheme=hash \
  --op-network="$NETWORK_NAME" \
  --override.holocene="$HOLOCENE_TIMESTAMP"
