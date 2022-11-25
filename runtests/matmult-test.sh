# !/bin/bash
cd ~/openwhisk-benchmarks/functions/matmult

for i in 500 1000 2000 3000 4000 5000 6000 7000 8000 8500
do
    echo "Matrix Size: $i"
    for j in {1..10}
    do

        LAT_LINE=$(wsk action invoke matmult -i -p N ${i} -r | grep "latency")
        L_LINE=($LAT_LINE)
        LATENCY=${L_LINE[1]}
        echo "latency: $LATENCY"

        # 2. Collect max memory usage
        CONTAINER_LINE=$(ssh 129.114.109.229 " docker ps --no-trunc | grep psinha25")
        C_LINE=($CONTAINER_LINE)
        CONTAINER_ID=${C_LINE[0]}
        MAX_MEM=$(ssh 129.114.109.229 "cat /sys/fs/cgroup/memory/docker/$CONTAINER_ID/memory.max_usage_in_bytes")
        echo "max_mem: $MAX_MEM"

    done
done
