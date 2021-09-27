  409  export PROJECT_ID=hits-devops-containerregi-4cb7
  410  echo $PROJECT_ID
  411  gcloud config set project $PROJECT_ID
  412  gcloud config get-value project
  413  cd /tmp
  414  git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples\ncd kubernetes-engine-samples/hello-app\n
  415  ls
  416  docker build -t us-docker.pkg.dev/${PROJECT_ID}/the-red-keep/hello-app:v1 .\n
  417  brew list
  418  which docker
  419  brew link docker
  420  brew link --overwrite docker
  421  which docker
  422  docker build -t us-docker.pkg.dev/${PROJECT_ID}/the-red-keep/hello-app:v1 .\n
  423  docker images
  424  gcloud auth configure-docker us-docker.pkg.dev\n
  425  docker push us-docker.pkg.dev/${PROJECT_ID}/the-red-keep/hello-app:v1\n
  426  history
  427  vi 22-09-2021.sh
  428  echo $PROJECT_ID
  429  cd ~/git/devops/hits-gitlab/ci-tutorials-sandbox
  430  ls
  431  cat lab1-deployment.yml
  432  history|grep gcloud
  433  gcloud container clusters get-credentials test-gitlab --zone us-central1-a --project hits-devops-cicd-8690
  434  gcloud config set project hits-devops-cicd-8690
  435  kubectl apply -f lab1-deployment.yml
  436  gcloud container clusters get-credentials test-gitlab --zone us-central1-a --project hits-devops-cicd-8690 \\n && kubectl port-forward --namespace gke-tutorials $(kubectl get pod --namespace gke-tutorials --selector="app=hello-world" --output jsonpath='{.items[0].metadata.name}') 8080:8080
  437  kubectl port-forward --namespace gke-tutorials $(kubectl get pod --namespace gke-tutorials --selector="app=hello-world" --output jsonpath='{.items[0].metadata.name}') 8080:8080
  438  kubectl port-forward --namespace gke-tutorials hello-world-766d9f878d-nlzrd 8080:8080
