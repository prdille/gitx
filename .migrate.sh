#!/bin/bash

for i in `find ./x -type d|awk -F '/' '{print $4}'|sort -u`
  do
#  echo $i
  cp -Rp narwhal/gke/gcp/* $i
done
