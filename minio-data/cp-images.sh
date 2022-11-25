du -ah | while read line; do
    size=$(echo $line | cut -d' ' -f1)
    image_slash=$(echo $line | cut -d' ' -f2)
    image=$(echo $line | cut -d'/' -f2)
    cp $image_slash "../image-process-sizes/$size-$image"
done