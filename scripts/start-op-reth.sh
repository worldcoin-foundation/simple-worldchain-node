#!/bin/bash
set -e

# set chain name for op-reth config
if [ "$NETWORK_NAME" = "worldchain-mainnet" ]; then
  export CHAIN_NAME="worldchain"
else
  export CHAIN_NAME="$NETWORK_NAME"
fi

# download snapshot if datadir is empty
if [ "$DOWNLOAD_SNAPSHOT" = "false" ]; then
  echo "Snapshot download disabled"
elif [ "$( ls -A '/data' )" ]; then
  echo "Skipping snapshot download due to existing datadir"
elif [ "$( uname -m )" != "x86_64" ]; then
  echo "Skipping snapshot download due to incompatible CPU architecture"
else
  if [ "$NETWORK_NAME" = "worldchain-mainnet" ]; then
    export BUCKET="world-chain-snapshots"
  else
    export BUCKET="world-chain-testnet-snapshots"
  fi
  if [ "$NODE_TYPE" = "full" ] || [ "$NODE_TYPE" = "minimal" ]; then
    export FILE_NAME="reth_full.tar.lz4"
  else
    export FILE_NAME="reth_archive.tar.lz4"
  fi

  cd /data
  echo "Downloading $NETWORK_NAME $NODE_TYPE snapshot, please be patient!"
  aws s3 cp --no-sign-request s3://${BUCKET}/${FILE_NAME} "${FILE_NAME}"
  echo "Snapshot downloaded, extracting..."
  tar --use-compress-program="lz4 -d" -xf "${FILE_NAME}"
  mv /data/reth/* /data && rm -r /data/reth "${FILE_NAME}"
  echo "Snapshot downloadeded and extracted! Restarting container to proceed to sync."
  exit 0
fi

exec world-chain node \
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
  --rollup.sequencer-http=https://${NETWORK_NAME}-sequencer.g.alchemy.com \
  --rollup.disable-tx-pool-gossip \
  --port="${PORT__EXECUTION_P2P:-30303}" \
  $( ( [ "$NODE_TYPE" = "full" ] && echo --full ) || ( [ "$NODE_TYPE" = "minimal" ] && echo --minimal ) ) \
  $( [ "$FLASHBLOCKS_ENABLED" = "true" ] && echo --flashblocks.enabled ) \
