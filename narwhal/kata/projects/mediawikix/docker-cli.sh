docker login registry-prod.app.med.umich.edu
docker build -t registry-prod.app.med.umich.edu/devops/gcp-iac .
docker push registry-prod.app.med.umich.edu/devops/gcp-iac
