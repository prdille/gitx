export PROJECT_ID=hits-devops-containerregi-4cb7
echo $PROJECT_ID
gcloud config set project $PROJECT_ID
gcloud config get-value project
cd /tmp
git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples\ncd kubernetes-engine-samples/hello-app\n
ls
docker build -t us-docker.pkg.dev/${PROJECT_ID}/the-red-keep/hello-app:v1 .\n
brew list
which docker
brew link docker
brew link --overwrite docker
which docker
docker build -t us-docker.pkg.dev/${PROJECT_ID}/the-red-keep/hello-app:v1 .\n
docker images
gcloud auth configure-docker us-docker.pkg.dev\n
docker push us-docker.pkg.dev/${PROJECT_ID}/the-red-keep/hello-app:v1\n
history
vi 22-09-2021.sh
echo $PROJECT_ID
cd ~/git/devops/hits-gitlab/ci-tutorials-sandbox
ls
cat lab1-deployment.yml
history|grep gcloud
gcloud container clusters get-credentials test-gitlab --zone us-central1-a --project hits-devops-cicd-8690
gcloud config set project hits-devops-cicd-8690
kubectl apply -f lab1-deployment.yml
gcloud container clusters get-credentials test-gitlab --zone us-central1-a --project hits-devops-cicd-8690 \\n && kubectl port-forward --namespace gke-tutorials $(kubectl get pod --namespace gke-tutorials --selector="app=hello-world" --output jsonpath='{.items[0].metadata.name}') 8080:8080
kubectl port-forward --namespace gke-tutorials $(kubectl get pod --namespace gke-tutorials --selector="app=hello-world" --output jsonpath='{.items[0].metadata.name}') 8080:8080
kubectl port-forward --namespace gke-tutorials hello-world-766d9f878d-nlzrd 8080:8080
