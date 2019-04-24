# file intended to be sourced by other shell scripts

TEST_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

IMAGE_TAG=$($TEST_DIR/../tools/image-tag)

COMMON_ARGS="-consul.hostname=consul:8500"
STORAGE_ARGS="-chunk.storage-client=aws -dynamodb.chunk-table.from=2019-01-01 -dynamodb.url=dynamodb://dynamodb -s3.url=placeholder"
INGESTER_ARGS="$COMMON_ARGS $STORAGE_ARGS -ingester.num-tokens=4 -ingester.min-ready-duration=1s -ingester.claim-on-rollout=true"
RUN_ARGS="--net=cortex"

# Execute command $1 repeatedly until it returns true; description in $2, optional repeat limit in $3
wait_for() {
    reps=${3:-10}
    for i in $(seq 1 $reps); do
        echo "Waiting for $2"
        if $1; then
            return
        fi
        sleep 1
    done
    echo "Timed out waiting for $2" >&2
    exit 1
}

container_ip() {
    docker inspect -f "{{.NetworkSettings.Networks.cortex.IPAddress}}" $@
}