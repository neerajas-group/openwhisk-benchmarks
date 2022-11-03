import sys
import os
import json

minio_config = {}
minio_config['endpoint'] = '10.52.2.166:9002' # ath-5
minio_config['access_key'] = 'testkey'
minio_config['secret_key'] = 'testsecret'
minio_config['bucket'] = 'openwhisk'

with open('./minio_config.json', 'w+') as f:
    json.dump(minio_config, f, indent=4, sort_keys=True)
