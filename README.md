# Usage
Before registering functions, make sure the custom docker image is available on Docker Hub. See [this doc](https://github.com/neerajas-group/openwhisk-benchmarks/blob/master/docs/docker-actions.md) for how to create a custom Docker image and use it with OpenWhisk actions.

- matmult
```console
$ wsk action create matmult matmult.py --docker psinha25/python3-ow --web raw --memory 512
$ wsk action invoke matmult -i -p N 100 -r -v
```
- image processing
```console
$ wsk action create image_process image-process.py --docker psinha25/python3-ow --web raw --memory 512
$ wsk action invoke image_process -i -p endpoint "10.52.2.166:9002" -p access_key "testkey" -p secret_key "testsecret" -p bucket "openwhisk" -p image "mj.jpg" -r -v
```