##k8s-chestnuts

#get a password
kubectl get secret -n dev-gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

# kubeconfig?
kubeconfig
  creates the ability to connect to a cluster


# run a command...
# DB command
kubectl exec -it -n devops-psql $DB_POD -- psql -h localhost -d postgres -U tooling-prod -c "DROP DATABASE gitlabhq_dev;"
  # needed to drop the DB to redeploy instance after an iac change



# looking in GKE for the nodes and pods
# to eventually delete

 1104  kubectl get pods -n dev-gitlab
 1105  kubectl logs -n dev-gitlab gitlab-cert-manager-54c959c65d-xgfhz
 1106  kubectl get certificate -A
 1107  kubectl get -n dev-gitlab orders
 1108  kubectl get -n dev-gitlab challenges
 1109  kubectl delete -n dev-gitlab certificate gitlab-gitlab-tls
 1110  kubectl delete -n dev-gitlab certificate gitlab-registry-tls
 1111  kubectl logs -n dev-gitlab gitlab-cert-manager-54c959c65d-xgfhz -f 
 
 
 # create secrets
   # 1st.... create kubeconfig
 gcloud container clusters get-credentials test-tooling --zone=us-central1-a --prject=hits-decops-tooling
   # create namespace
 kubectl creat ns test-gitlab
   # create gitlab tls secret
 kubectl create secret tls gitlab-test-tls \
 --cert=/tmp/gitlab-test.app.med.umich.edu.crt \
 --key=/tmp/gitlab-test.app.med.umich.edu.key \
 --namespace=test-gitlab
   # create registry tls secret
 kubectl create secret tls registry-test-tls \
 --cert=/tmp/gitlab-test.app.med.umich.edu.crt \
 --key=/tmp/gitlab-test.app.med.umich.edu.key \
 --namespace=test-gitlab
 
 
workloads (more of a ui thing)
  - various ways to run pods
  - some form of group pods together
  - types of doing work in k8s
    - smallest unit of work in k8s is a pod