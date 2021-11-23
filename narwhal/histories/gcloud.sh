ansible-playbook bootstrap_product_instance.yml -e project_id=`gcloud config get-value project` -e customer=$CUSTOMER -e
docker run -ti --name gcloud-config google/cloud-sdk /bin/bash   
docker run -ti --name gcloud-config google/cloud-sdk bash   
docker run -ti --name gcloud-config google/cloud-sdk gcloud auth login 
docker run -ti google/cloud-sdk:latest gcloud version    
gcloud auth configure-docker us-docker.pkg.dev\n      
gcloud compute networks create test-vpc --project=hits-see-glaucoma-a584 --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional\ngcloud compute
gcloud compute networks subnets delete test-subnet && gcloud compute networks
gcloud config get-value project      
gcloud config set project $PROJECT_ID     
gcloud config set project $PROJ_ID     
gcloud config set project hits-devops-cicd-8690     
gcloud config set project hits-devops-pdille-cfc5     
gcloud config set project hits-see-glaucoma-a584     
gcloud container clusters create tmpcluster --workload-pool=$PROJ_ID.svc.id.goog --zone=us-central1-a --network um-default --subnetwork
gcloud container clusters create tmpcluster --workload-pool=[$PROJ_ID].svc.id.goog --zone=us-central1-a --network um-default --subnetwork
gcloud container clusters create tmpcluster --workload-pool=[PROJ_ID].svc.id.goog --zone=us-central1-a --network um-default --subnetwork
gcloud container clusters create tmpcluster --workload-pool=hits-devops-pdille-cfc5.svc.id.goog --zone=us-central1-a --network um-default --subnetwork
gcloud container clusters create tmpcluster --workload-pool=hits-see-glaucoma-a584.svc.id.goog --zone=us-central1-a --network test-vpc --subnetwork
gcloud container clusters create tmpcluster --workload-pool={{ project_id }}.svc.id.goog --zone=us-central1-a --network
gcloud container clusters delete tmpcluster --zone=us-central1-a && gcloud compute networks
gcloud container clusters get-credentials test-gitlab --zone us-central1-a --project hits-devops-cicd-8690 
gcloud container clusters get-credentials test-gitlab --zone us-central1-a --project hits-devops-cicd-8690 \\n
gcloud get secrets       
gcloud projects list       
gcloud secrets create oath-client --data-file=/Users/pdille/tmp/client_secret_128914795476-gf14jrq0j0u0a78hcb05tirn46htb92l.apps.googleusercontent.com.json --replication-policy=user-managed --locations=us-central1,us-east1   
gcloud secrets create oath-client --data-file=~/tmp/client_secret_128914795476-gf14jrq0j0u0a78hcb05tirn46htb92l.apps.googleusercontent.com.json --replication-policy=user-managed --locations=us-central1,us-east1   
gcloud secrets create oath-client-test --data-file=/Users/pdille/tmp/client_secret_128914795476-gf14jrq0j0u0a78hcb05tirn46htb92l.apps.googleusercontent.com.json     
gcloud secrets create oath-client-uscrust --data-file=/Users/pdille/tmp/client_secret_128914795476-gf14jrq0j0u0a78hcb05tirn46htb92l.apps.googleusercontent.com.json --locations=us-central1,us-east1    
gcloud secrets list       
gcloud secrets versions access latest -- secret-gke-tutorials-cert   
gcloud secrets versions access latest --secret-gke-tutorials-cert    
gcloud secrets versions access latest --secret=gke-tutorials-cert    
gcloud secrets versions access latest --secret=oath-client    
gcloud secrets versions access latest --secret=oauth-client    
git commit -m "[ADD] replaced kubectl commands with gcloud secrets
grep -R "gcloud config" *     
