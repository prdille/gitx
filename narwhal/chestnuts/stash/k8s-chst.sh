##k8s-chestnuts

########################
## get a password 
########################
$ kubectl get secret -n dev-gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

###### kubeconfig?
##### kubeconfig
#####  creates the ability to connect to a cluster
######

########################
## run a command...
########################

###### DB command
$ kubectl exec -it -n devops-psql $DB_POD -- psql -h localhost -d postgres -U tooling-prod -c "DROP DATABASE gitlabhq_dev;"
  
     ###### needed to drop the DB to redeploy instance after an iac change

########################
## Create secrets
########################

###### Create kubeconfig
$ gcloud container clusters get-credentials test-tooling --zone=us-central1-a --prject=hits-decops-tooling

###### Create namespace
$ kubectl creat ns {NAMESPACE}

###### Create gitlab tls secret
$ kubectl create secret tls {DNS}-tls \
 --cert=/tmp/{DNS}.app.med.umich.edu.crt \
 --key=/tmp/{DNS}.app.med.umich.edu.key \
 --namespace={NAMESPACE}

###### Create registry tls secret
$ kubectl create secret tls registry-test-tls \
 --cert=/tmp/{DNS}.app.med.umich.edu.crt \
 --key=/tmp/{DNS}.app.med.umich.edu.key \
 --namespace={NAMESPACE}
 

----------------------------
----------------------------
--- RANDOS...............---
----------------------------
----------------------------

$ kubectl get pods -n dev-gitlab
$ kubectl logs -n dev-gitlab gitlab-cert-manager-54c959c65d-xgfhz
$ kubectl get certificate -A
$ kubectl get -n dev-gitlab orders
$ kubectl get -n dev-gitlab challenges
$ kubectl delete -n dev-gitlab certificate gitlab-gitlab-tls
$ kubectl delete -n dev-gitlab certificate gitlab-registry-tls
$ kubectl logs -n dev-gitlab gitlab-cert-manager-54c959c65d-xgfhz -f 

 
########################
## GENERAL k8s  NOTES ##
########################

workloads (more of a ui thing)
    - various ways to run pods
    - some form of group pods together
    - types of doing work in k8s
    - smallest unit of work in k8s is a pod



