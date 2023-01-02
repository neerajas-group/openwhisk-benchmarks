import sys
import os
import subprocess
import argparse
from minio import Minio
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--minio-config', dest='minio_config', type=str, required=True)
data_top_dir =  Path.cwd() / '..' / 'minio-data'
image_dir = data_top_dir / 'image-process'
sentiment_dir = data_top_dir / 'sentences'
video_dir = data_top_dir / 'videos'
lr_dir = data_top_dir / 'logistic-regression'
audio_dir = data_top_dir / 'audio'

print(data_top_dir)
print(image_dir)
print(sentiment_dir)
print(video_dir)
print(lr_dir)
# -----------------------------------------------------------------------
# parse args
# -----------------------------------------------------------------------
args = parser.parse_args()
minio_config_f = args.minio_config
with open(minio_config_f ,'r') as f:
    minio_config = json.load(f)
    endpoint = minio_config['endpoint']
    access_key = minio_config['access_key']
    secret_key = minio_config['secret_key']

# deploy minio
cmd = 'docker compose -f docker-compose.yml up -d'
subprocess.run(cmd, shell=True)
minio_client = Minio(endpoint=endpoint,
                     access_key=access_key,
                     secret_key=secret_key,
                     secure=False)
bucket_name = "openwhisk"
found = minio_client.bucket_exists(bucket_name)
if not found:
    minio_client.make_bucket(bucket_name)
else:
    print("Bucket '%s' already exists" %bucket_name)

for img in os.listdir(str(image_dir)):
    img_path = image_dir / img
    print(img_path)
    minio_client.fput_object(bucket_name=bucket_name,
                       object_name=img,
                       file_path=str(img_path))

for sentence in os.listdir(str(sentiment_dir)):
    if "json" in sentence:
        sentence_path = sentiment_dir / sentence
        print(sentence_path)
        minio_client.fput_object(bucket_name=bucket_name,
                             object_name=sentence,
                             file_path=str(sentence_path))

for vid in os.listdir(str(video_dir)):
    vid_path = video_dir / vid
    print(vid_path)
    minio_client.fput_object(bucket_name=bucket_name,
                       object_name=vid,
                       file_path=str(vid_path))

for file in os.listdir(str(lr_dir)):
    file_path = lr_dir / file
    print(file_path)
    minio_client.fput_object(bucket_name=bucket_name,
                    object_name=file,
                    file_path=str(file_path))

for audio in os.listdir(str(audio_dir)):
    audio_path = audio_dir / audio
    print(audio_path)
    minio_client.fput_object(bucket_name=bucket_name,
                    object_name=audio,
                    file_path=str(audio_path))