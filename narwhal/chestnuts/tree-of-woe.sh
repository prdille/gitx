#!/tree/of/woe

export ENV=dev

helm uninstall gitlab --namespace $ENV-gitlab && kubectl delete ns $ENV-gitlab

for i in $(k get -n $ENV-gitlab Orders -o jsonpath='{..metadata.name}'); do echo $i;k delete -n $ENV-gitlab Orders $i; done;
for i in $(k get -n $ENV-gitlab Challenges -o jsonpath='{..metadata.name}'); do echo $i;k delete -n $ENV-gitlab Challenges $i; done;
kubectl delete -f gitlab_manifest.yml && kubectl delete -n $ENV-gitlab -f gitlab_manifest.yml && kubectl delete ns $ENV-gitlab;






export CLUSTER=prod-tooling
export PROJ=hits-devops-tooling
export DB_USER=tooling-prod
export ENV=dev