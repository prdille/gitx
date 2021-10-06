## 
## 
## Looping over the results of a find/awk
## registering the output to $i
## 
## 
for i in `find . -type d -name "hits*"|grep -v personal|awk -F '/' '{print $4}'`; do echo gcloud container binauthz policy export --project=$i; done
for i in `find . -type d -name "hits*"|grep -v personal|awk -F '/' '{print $4}'`; do echo $i; gcloud container binauthz policy export --project=$i | grep metrics; done
