# This script will register 4 functions that will be run 
# using the FaasProfiler for our image process experiment. 
# Default memory, cpu, and parameters are provided for each function

wsk -i action delete encrypt
wsk -i action delete linpack
wsk -i action delete image_process
wsk -i action delete mobilenet
wsk -i action delete matmult

# Register Linpack
cd /home/cc/openwhisk-benchmarks/functions/linpack
wsk -i action create linpack linpack.py \
    --docker psinha25/python3-ow \
    --web raw \
    --memory 1024 --cpu 5 \
    --param N 2000 \

# Register Matmult 
cd /home/cc/openwhisk-benchmarks/functions/matmult
wsk -i action create matmult matmult.py \
    --docker psinha25/python3-ow \
    --web raw \
    --memory 1024 --cpu 5 \
    --param N 3000 \

# Register Encryption
cd /home/cc/openwhisk-benchmarks/functions/encryption
wsk -i action create encrypt encrypt.py \
    --docker psinha25/python3-ow \
    --web raw \
    --memory 1024 --cpu 5 \
    --param length 5000 \
    --param iteration 30 \

# Setup Minio Images
cd /home/cc/openwhisk-benchmarks/minio
python3 make-minio-config.py
python3 setup-minio.py --minio-config minio_config.json

# Register Mobilenet
cd /home/cc/openwhisk-benchmarks/functions/mobilenet
wsk -i action create mobilenet mobilenet.py \
    --docker psinha25/mobilenet-ow \
    --web raw \
    --memory 1024 --cpu 5 \
    --param endpoint "10.52.3.213:9002" \
    --param access_key "testkey" \
    --param secret_key "testsecret" \
    --param bucket "openwhisk" \
    --param image "2.4M-building.jpg" \
