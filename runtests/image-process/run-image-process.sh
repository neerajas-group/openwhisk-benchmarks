# !/bin/bash

# Check if parameters were provided
if (( $# < 3 ))
  then
    echo "Usage: ./run-image-process.sh <cpu count> <memory count> <image>"
    exit 1
fi

cd ~/openwhisk-benchmarks/functions/image-processing

CPU=$1
MEM=$2
FILE_IMAGE=$3

# Register matrix multiplication function with our OpenWhisk setup
echo "Experiment Setup:"
echo "-----------------"
ACTIONS=$(wsk -i action list)
FXN='image-process'
ACTION_OP='create'
if [[ "$ACTIONS" == *"$FXN"* ]]; then
    ACTION_OP='update'
fi
wsk -i action $ACTION_OP $FXN $FXN.py \
    --docker psinha25/main-python \
    --web raw \
    --memory $MEM --cpu $CPU \
    --param endpoint "10.52.3.213:9002" \
    --param access_key "testkey" \
    --param secret_key "testsecret" \
    --param bucket "openwhisk" \

# Start up the faas profiler running other 4 functions as noise
cd ~/faas-profiler
./WorkloadInvoker -c ~/openwhisk-benchmarks/runtests/image-process/image-process-config.json &
sleep 10
echo ""

echo "Experiment Details:"
echo "-------------------"
echo "CPU: $CPU"
echo "MEM: $MEM"
echo ""

# Begin experiment
echo "Experiment Begins:"
echo "------------------"
for image in $FILE_IMAGE; do 
    echo "Image: $image"
    STATS_PID=$(ssh 129.114.109.238 " python3 -u ~/stats-collector.py >> docker-stats-$CPU-$MEM-$image-${FXN}.txt & jobs -p")

    # Do 10 runs per matrix
    for run in {1..10} ; do

        # 1. Get latency of critical section of function
        LAT_LINE=$(wsk action invoke $FXN -i -p image ${image} -r | grep "latency")
        echo $LAT_LINE
        L_LINE=($LAT_LINE)
        LATENCY=${L_LINE[1]}
        echo "latency: $LATENCY"

        # 2. Collect max memory usage
        CONTAINER_LINE=$(ssh 129.114.109.238 " docker ps --no-trunc | grep main-python ")
        C_LINE=($CONTAINER_LINE)
        CONTAINER_ID=${C_LINE[0]}
        MAX_MEM=$(ssh 129.114.109.238 "cat /sys/fs/cgroup/memory/docker/$CONTAINER_ID/memory.max_usage_in_bytes")
        echo "max_mem: $MAX_MEM"
        sleep 5
    done
    ssh 129.114.109.238 " kill $STATS_PID "
done

# Stop all container created by FaasProfiler
ssh 129.114.109.238 " docker ps | grep psinha25 | cut -d ' ' -f1 | xargs -I {} docker stop -t 1 {} "
sleep 10
ssh 129.114.109.238 " docker ps | grep psinha25 | cut -d ' ' -f1 | xargs -I {} docker stop -t 1 {} "
sleep 10
ssh 129.114.109.238 " docker ps | grep psinha25 | cut -d ' ' -f1 | xargs -I {} docker stop -t 1 {} "
sleep 10
ssh 129.114.109.238 " docker ps | grep psinha25 | cut -d ' ' -f1 | xargs -I {} docker stop -t 1 {} "

# rm image-process-16-2048-384K.txt
# rm image-process-16-2048-440K.txt
# rm image-process-16-2048-860K.txt
# rm image-process-16-2048-928K.txt
# rm image-process-16-2048-1.2M.txt

# rm image-process-48-2048-80K.txt
# rm image-process-48-2048-244K.txt
# rm image-process-48-2048-384K.txt
# rm image-process-48-2048-608K.txt
# rm image-process-48-2048-756K.txt
# rm image-process-48-2048-1.2M.txt

# rm image-process-64-2048-184K.txt 

# rm image-process-80-2048-928K.txt

# rm image-process-96-2048-244K.txt
# rm image-process-96-2048-440K.txt
# rm image-process-96-2048-12K.txt

