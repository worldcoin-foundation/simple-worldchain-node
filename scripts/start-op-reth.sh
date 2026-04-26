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
elif [ -f "/data/reth.toml" ]; then
  echo "Skipping snapshot download due to existing datadir"
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
  DL_SIZE=$(curl -sI https://${BUCKET}.s3.eu-central-2.amazonaws.com/${FILE_NAME} | awk -F': ' '/Content-Length/{print $2}' | tr -d '\r')
  AVAIL_SPACE=$(df -B 1 --output=avail /data | tail -n 1)
  if (( $AVAIL_SPACE < ( $DL_SIZE * 3 / 2 ) )); then
    echo "Aborting snapshot snapshot download due to limited disk space"
    echo "Estimated disk space required: $( numfmt --to=iec $(( $DL_SIZE * 3 / 2 )) )"
    echo "Available disk space: $( numfmt --to=iec $AVAIL_SPACE )"
    exit 1
  elif (( $AVAIL_SPACE > ( $DL_SIZE * 5 / 2 ) )); then
    echo "Downloading $NETWORK_NAME $NODE_TYPE snapshot, please be patient!"
    apt update -qq > /dev/null 2>&1
    apt install -y -qq --no-install-recommends aria2 > /dev/null 2>&1
    aria2c --file-allocation=falloc --show-console-readout false --download-result=hide --summary-interval=5 -x 16 -s 16 https://${BUCKET}.s3.eu-central-2.amazonaws.com/${FILE_NAME}
    echo "Snapshot downloaded, extracting..."
    tar --strip-components=1 -I lz4 -xvf "${FILE_NAME}"
    rm "${FILE_NAME}"
  else
    echo "Downloading $NETWORK_NAME $NODE_TYPE snapshot with streamed decompression due to limited disk space, please be patient!"
    curl https://${BUCKET}.s3.eu-central-2.amazonaws.com/${FILE_NAME} | lz4 -dc | tar --strip-components=1 -xvf - 
  fi
  echo "Snapshot downloaded and extracted! Restarting container to proceed to sync."
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
  --chain="/chainconfig/genesis.json" \
  --rollup.sequencer-http=https://${NETWORK_NAME}-sequencer.g.alchemy.com \
  --rollup.disable-tx-pool-gossip \
  --port="${PORT__EXECUTION_P2P:-30303}" \
  $( ( [ "$NODE_TYPE" = "full" ] && echo --full ) || ( [ "$NODE_TYPE" = "minimal" ] && echo --minimal ) ) \
  $( [ "$FLASHBLOCKS_ENABLED" = "true" ] && echo --flashblocks.enabled ) \
