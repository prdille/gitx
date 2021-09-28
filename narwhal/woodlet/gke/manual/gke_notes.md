# Background
The Devops Team has created a Google Cloud Project for your environment.  Contained in that project is a [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview) instance and a [Cloud SQL Database](https://cloud.google.com/sql) instance that is configured to be able to connect to your GKE cluster. 

In order to deploy applications to this cluster, you need to have some basic knowledge of Kubernetes and Google Cloud Platform.  This document is not a comprehensive training, but is closer to a `Quick Start` based on knowledge of the platform.  Ownership of the Kubernetes manifests  and the container is solely the responibility of the developer.

# Document Conventions
Throughout this document, we give some example code blocks for various GKE configuration manifests. They contain a shell command similar to `cat <<EOF`. This acts as a very simple template where the "variables" you `export` are applied and a manifest is generated from them.  The idea is that you may copy these code blocks, including the export statements, modify them to meet your needs and then run them to see some example output.  You may take that output, and if you have access to a GKE cluster,  you could do something like the following to actually apply the generated manifest:

```

```

# Prerequisites
## External Ips

The Devops Team manages external ip addresses and can configure them for you when your application is ready for deployment.  You can create a "external ip" name, which can then be connected to an GKE Ingress to allow for your app to be publicly accessible.

### Things needed from developers
* a user-defined name for the ip address (less than 62 chars consisting only of lowercase letters, numbers, or hypens)

## Database Connections in Kubernetes (Workload Identity)

This document assumes that  you have already configured your project's [Cloud SQL](https://cloud.google.com/sql/docs) instance with a username and password for your application. We grant permission to the Cloud SQL instance via a process known as [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity).  Some background on Workload Identity is [here](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications).

To understand what is happening at a basic level, we are binding a Google Service Account (with just enough privileges to access a database instance) to a [Kubernetes Service Account](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/).

Some more information and examples are available [here](https://cloud.google.com/sql/docs/postgres/connect-kubernetes-engine#workload-identity).

The Devops team creates the service account of your specification, and then when you are deploying your application, you link your kubernetes Service Account to the Google one that Devops creates.

### Things needed from developers
* A kubernetes namespace the app will be deployed in
* A kubernetes service-account name that should be tied to a role with access to your `Cloud SQL` instance.

# Secrets

[Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) are a method for Kubernetes to store and manage sensitive information without putting it directly in a manifest file.  While by default, they are not intrinsically "secure" (they are encoded, not encrypted), they are better than putting them verbatim in a container image or a kubernetes manifest file.

## Database Login secrets
For each account that will be used to access a database, add an [Opaque](https://kubernetes.io/docs/concepts/configuration/secret/#use-cases) type secret with kubectl that can include arbitrary key-value pairs. See [Deployment](#deployment) section below for an example of referencing a secret in pod spec environment variables.
```
export SECRET_NAME=super-secret-db
export NAMESPACE=mynamespace
export DB_NAME=my-db
export DB_PASSWORD=my-pass
export DB_USER=user1

cat <<EOF 
apiVersion: v1
kind: Secret
metadata:
  name: ${SECRET_NAME}
  namespace: ${NAMESPACE}
type: Opaque
data:
  database: $(echo -n "${DB_NAME}" | base64)
  password: $(echo -n "${DB_PASSWORD}" | base64)
  username: $(echo -n "${DB_USER}" | base64)
EOF
```

## Secrets for other accounts
For each account that will need defined credentials (i.e. provisioning a user account to persist when the pod is restarted), add a [Basic Authentication Secret](https://kubernetes.io/docs/concepts/configuration/secret/#basic-authentication-secret) with kubectl.
```
export SECRET_NAME=myapp-admin
export GKE_NAMESPACE=mynamespace
export USER_NAME=admin
export USER_PASSWORD=t0p-Secret

cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${SECRET_NAME}
  namespace: ${GKE_NAMESPACE}
type: kubernetes.io/basic-auth
stringData:
  password: $(echo -n "${USER_NAME}" | base64)
  username: $(echo -n "${USER_PASSWORD}" | base64)
EOF
```

## TLS Certificate Management
For each pod that will have an ingress defined, you should add a [TLS Secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets) that contains the certificate and key for the service that will use it.  Assuming that you have generated a certificate and have it available locally, you can add it as a secret in GKE like this:
```
kubectl create secret tls <service name>-tls-secret \
  --cert=path/to/cert/file \
  --key=path/to/key/file \
  --namespace=<gke-namespace>
```

# Service Accounts
## Service Account with Database access
A [ServiceAccount](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) must be defined for each deployment that needs to access your Cloud SQL database. You must specify an annotation for each ServiceAccount in your cluster that will link it to the corresponding GCP Service Account using a feature called [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity). The DevOps team has provided GCP Service Accounts based on the list of deployments that are identified by you as needing database access and will setup the accounts for Workload Identity.  All you need to do is annotate the ServiceAccount in your manifest.
```
export NAMESPACE=mynamespace
export GOOGLE_SERVICE_ACCOUNT_NAME=gcp-service-account@project.iam.gserviceaccount.com
export APP_NAME=CHANGEME-myapp

cat <<EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${APP_NAME}-sa
  namespace: ${NAMESPACE}
  annotations:
    iam.gke.io/gcp-service-account: ${GOOGLE_SERVICE_ACCOUNT_NAME}
EOF
```
# Initial Database Setup

The devops team creates a user account with access to your PostgreSQL cloud database instance. 
To deploy a Pod that you can use to initialize your database and schemas, you can run something
like this:

```

export NAMESPACE=devops-psql
export PROJECT_ID=hits-spi-prod-cbdc
export GOOGLE_SERVICE_ACCOUNT_NAME=devops-psql@${PROJECT_ID}.iam.gserviceaccount.com
export DB_CONNECTION_STRING=hits-spi-prod-cbdc:us-central1:mynamespace-prod-psql-d646a035
cat <<EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: devops-psql-sa
  namespace: ${NAMESPACE}
  annotations:
    iam.gke.io/gcp-service-account: ${GOOGLE_SERVICE_ACCOUNT_NAME}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-interface
  namespace: ${NAMESPACE}
spec:
  selector:
    matchLabels:
      app: db-interface
  replicas: 0
  template:
    metadata:
      labels:
        app: db-interface
    spec:
      serviceAccountName: devops-psql-sa
      containers:
      - name: postgres
        image: us-docker.pkg.dev/hits-devops-containerregi-4cb7/the-red-keep/postgres:13
        command:
          - sleep
          - "3000"
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "100m"
      - name: cloud-sql-proxy
        image: us-docker.pkg.dev/hits-devops-containerregi-4cb7/the-red-keep/cloudsql-docker/gce-proxy:1.19.0
        imagePullPolicy: IfNotPresent
        command:
          - /cloud_sql_proxy
          - "-instances=${DB_CONNECTION_STRING}=tcp:5432"
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "100m"
EOF
```
Then to access the postgresql command line, you can run something like this:

```
kubectl exec -ti -n ${NAMESPACE} db-interface -- /bin/bash
psql
```
# Deployment Examples

## General Deployment Example (no database)
```
# The name of the application to deploy
export APP_NAME=myapp

# The name of a secret that will be used for environment variable creation
export SECRET_CREDS_NAME=admin-user-password 

# The name of and path to a container image that resides in your Artifact Registry
export APP_IMAGE=us-docker.pkg.dev/path/to/${APP_NAME}:1.0.0

cat <<EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
  namespace: mynamespace
  labels:
    app: ${APP_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
    spec:
      containers:
      - name: ${APP_NAME}
        image: ${APP_IMAGE} 
        env:
        - name: APP_NAME_ADMIN_USER # Here is an example of using a secret in a deployment as an env variable
          valueFrom:
            secretKeyRef:
              name: ${SECRET_CREDS_NAME}
              key: username
        - name: APP_NAME_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: ${SECRET_CREDS_NAME}
              key: password"
        - name: PROXY_ADDRESS_FORWARDING
          value: "true"
        ports:
        - name: http
          containerPort: 8080
        - name: https
          containerPort: 8443
        readinessProbe:
          httpGet:
            path: /auth/realms/master
            port: 8080
EOF
```
## Deployment With Database Access

Having defined a database secret and Workload identity above, here is an example of adding access to the database via a `side car` pattern:
```
# The name of the application that will be deployed
export APP_NAME=CHANGEME-myapp
# The Google project ID used for artifact registry
export PROJECT_ID=CHANGEME-id-223
# The instance of the artifact registry that contains the app's container image
export ARTIFACT_REG=my-artifact-registry
# The full path to the app's container imae
export APP_IMAGE=us-docker.pkg.dev/${PROJECT_ID}/${ARTIFACT_REG}/${APP_NAME}:latest
# The image location for cloud sql proxy  
export CLOUD_SQL_PROXY_IMAGE=us-docker.pkg.dev/path/to/cloudsql-docker/gce-proxy:1.19.0
# The "Instance Connection Name" obtained from something like the following command:
#  gcloud sql instances describe ${INSTANCE_NAME}
export CLOUD_SQL_CONN_STRING=project:region:databaseinstance

cat <<EOF 
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/part-of: ${APP_NAME}-app
    app.kubernetes.io/name: ${APP_NAME}
    app.kubernetes.io/version: 1.0-rc.1
  name: ${APP_NAME}
  namespace: mynamespace
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/part-of: ${APP_NAME}-app
      app.kubernetes.io/name: ${APP_NAME}
      app.kubernetes.io/version: 1.0-rc.1
  template:
    metadata:
      labels:
        app.kubernetes.io/part-of: ${APP_NAME}-app
        app.kubernetes.io/name: ${APP_NAME}
        app.kubernetes.io/version: 1.0-rc.1
    spec:
      containers:
      - env:
        - name: KUBERNETES_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: DB_USER_USERNAME
          valueFrom:
            secretKeyRef:
              name: ${APP_NAME}-user
              key: username
        - name: DB_USER_PASSWORD
          valueFrom:
            secretKeyRef:
              name: ${APP_NAME}-user
              key: password
        - name: DB_NAME
          valueFrom:
            secretKeyRef:
              name: ${APP_NAME}-user
              key: database
        image: ${APP_IMAGE}
        imagePullPolicy: Always
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 0
          periodSeconds: 30
          successThreshold: 1
          timeoutSeconds: 10
        name: ${APP_NAME}
        command:
          - "./application"
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 20
          periodSeconds: 45
          successThreshold: 1
          timeoutSeconds: 10
      - name: cloud-sql-proxy
        image: ${CLOUD_SQL_PROXY_IMAGE}
        imagePullPolicy: IfNotPresent
        command:
          - /cloud_sql_proxy
          - "-instances=${CLOUD_SQL_CONN_STRING}=tcp:5432"
        resources: {}
        securityContext:
          runAsNonRoot: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      serviceAccount: ${APP_NAME}-sa
EOF
```

# Service
Along with a Deployment, FrontendConfig, and Load Balancer(Ingress) definitions in your manifest, you need to define a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) that persistent access point for your deployment.  The code below is an example of a Service definition.
```
export SERVICE_NAME=myapp
export APP_NAME=myapp
export GKE_NAMESPACE=mynamespace

cat <<EOF
---
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
  namespace: ${GKE_NAMESPACE}
  labels:
    app: ${APP_NAME}
  annotations:
    cloud.google.com/neg: '{"ingress": true}'
spec:
  ports:
  - name: http
    port: 8080
    targetPort: 8080
  selector:
    app: ${APP_NAME}
  type: ClusterIP
EOF
```

# FrontendConfig/Load Balancer
see: https://github.com/GoogleCloudPlatform/gke-networking-recipes/blob/master/ingress/secure-ingress/secure-ingress.yaml
A FrontendConfig and Ingress definition will expose your service for user access.  The DevOps team provides an SSL Policy (tlsmodernprofile) for you to use in your FrontendConfig.  You should give your Ingress a name and provide the GKE namespace in which to deploy these components. An example of defining a [TLS Secret](#tls-certificate-management) can be found above. Also, we discuss external ips [here](#external-ips)
```
export SERVICE_NAME=myapp
export GKE_NAMESPACE=mynamespace
export EXTERNAL_IP_NAME=demo-kc-test
export INGRESS_NAME=myapp-ingress
export TLS_SECRET_NAME=myapp-tls-secret

cat <<EOF
---
apiVersion: networking.gke.io/v1beta1
kind: FrontendConfig
metadata:
  name: "tls12modernprofile"
  namespace: ${GKE_NAMESPACE}
  annotations:
    devops.documentation: "https://cloud.google.com/load-balancing/docs/https/setting-up-http-https-redirect"
spec:
  sslPolicy: "tls12modernprofile" # provided by Devops team
  redirectToHttps: # these lines redirect all unencrypted traffic to the HTTPS port
    enabled: true
    responseCodeName: PERMANENT_REDIRECT
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    devops.documentation: "https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features"
    kubernetes.io/ingress.global-static-ip-name: ${EXTERNAL_IP_NAME}
    networking.gke.io/v1beta1.FrontendConfig: "tls12modernprofile"
  name: ${INGRESS_NAME}
  namespace: ${GKE_NAMESPACE}
spec:
  tls:    
    - secretName: ${TLS_SECRET_NAME}
  backend:
    serviceName: ${SERVICE_NAME}
    servicePort: 8080
EOF
```

# Manual upload to artifact registry with docker

```
export PROJ_ID=hits-devops-cicd-8690 # replace with your project ID
export PRODUCT=molecule # replace with your product instance
docker pull myusername/myapp:10.0.2 # not needed if you are building locally
docker images # note which image tag corresponds to your container
# tag your image with the correct external image name for your artifact registry instance
docker tag 7c73b1330a30 us-docker.pkg.dev/$PROJ_ID/$PRODUCT-ar/myusername/myapp:10.0.2
# Get credentials to push to artifact registry
gcloud auth configure-docker us-docker.pkg.dev
# push to artifact registry
docker push us-docker.pkg.dev/$PROJ_ID/$PRODUCT-ar/myusername/myapp:10.0.2
```


# Identity Aware Proxy
## Description
The [Identity Aware Proxy](https://cloud.google.com/iap) is part of Google Cloud's [BeyondCorp Enterprise Model](https://cloud.google.com/beyondcorp-enterprise), which is set up for organizations to be able to secure applications without the need for a VPN. Its usage in GKE is documented here: https://cloud.google.com/iap/docs/enabling-kubernetes-howto

Please note that if you would like to Turn IAP off, you will need to disable it first (versus just remove the configuration from your deployment manifests). More info [here](https://cloud.google.com/iap/docs/enabling-kubernetes-howto#iap-turn-off)

Below is a [Setup](#iap-setup) section followed by two options for Deployment.  [Deployment: Google Managed Certificate](#deployment-google-managed-certificate) uses [Google Managed Certificates](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs), which do require some setup and have some caveats, but do not need to be manually updated or renewed. [Deployment: Manual TLS Certificate](#deployment-manual-tls-certificate) uses a TLS secret generated per [TLS Certificate Management](#tls-certificate-management).

## IAP Setup
* Create the Project-level OAuth Consent screen [here](https://console.cloud.google.com/apis/credentials/consent) per the [kubernetes howto](https://cloud.google.com/iap/docs/enabling-kubernetes-howto#oauth-configure).
  
* Create a secret (this example assumes the name `iap-oauth-client-id`) with the Oauth credentials created during the [Oauth creation screen](https://cloud.google.com/iap/docs/enabling-kubernetes-howto#oauth-credentials).

* Configure the users that should have access per [kubernetes howto](https://cloud.google.com/iap/docs/enabling-kubernetes-howto#iap-access)

* Create a DNS record matching the external ip of your ingress

## Deployment: Manual TLS Certificate
```
export SERVICE_NAME=myapp
export GKE_NAMESPACE=mynamespace
export EXTERNAL_IP_NAME=demo-kc-test
export INGRESS_NAME=myapp-ingress
export TLS_SECRET_NAME=myapp-tls-secret

cat <<EOF
---
---
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
  namespace: ${GKE_NAMESPACE}
  annotations:
    beta.cloud.google.com/backend-config: '{"default": "backend-config-default"}'
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    run: web
  type: NodePort
---
# see: https://cloud.google.com/iap/docs/enabling-kubernetes-howto#kubernetes-configure
# for more information on configuring the BackendConfig
apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  name: backend-config-default
  namespace: $GKE_NAMESPACE
spec:
  iap:
    enabled: true
    oauthclientCredentials:
      secretName: iap-oauth-client-id
---
apiVersion: networking.gke.io/v1beta1
kind: FrontendConfig
metadata:
  name: "tls12modernprofile"
  namespace: ${GKE_NAMESPACE}
  annotations:
    devops.documentation: "https://cloud.google.com/load-balancing/docs/https/setting-up-http-https-redirect"
spec:
  sslPolicy: "tls12modernprofile" # provided by Devops team
  redirectToHttps: # these lines redirect all unencrypted traffic to the HTTPS port
    enabled: true
    responseCodeName: PERMANENT_REDIRECT
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    devops.documentation: "https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features"
    kubernetes.io/ingress.global-static-ip-name: ${EXTERNAL_IP_NAME}
    networking.gke.io/v1beta1.FrontendConfig: "tls12modernprofile"
  name: ${INGRESS_NAME}
  namespace: ${GKE_NAMESPACE}
spec:
  tls:    
    - secretName: ${TLS_SECRET_NAME}
  backend:
    serviceName: ${SERVICE_NAME}
    servicePort: 8080
EOF
```

# Deployment: Google Managed Certificate
```
export SERVICE_NAME=myapp
export GKE_NAMESPACE=mynamespace
export EXTERNAL_IP_NAME=demo-kc-test
export INGRESS_NAME=myapp-ingress
export DOMAIN_NAME=myapp.example.com

cat <<EOF
---
apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  name: backend-config-default
  namespace: ${GKE_NAMESPACE}
spec:
  iap:
    enabled: true
    oauthclientCredentials:
      secretName: iap-oauth-client-id
---
apiVersion: networking.gke.io/v1beta1
kind: ManagedCertificate
metadata:
  name: ${SERVICE_NAME}
  namespace: ${GKE_NAMESPACE}
spec:
  domains:
    - ${DOMAIN_NAME}
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ${INGRESS_NAME}
  annotations:
    kubernetes.io/ingress.global-static-ip-name: ${EXTERNAL_IP_NAME}
    networking.gke.io/managed-certificates: ${SERVICE_NAME}
spec:
  backend:
    serviceName: ${SERVICE_NAME}
    servicePort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
  namespace: ${GKE_NAMESPACE}
  annotations:
    beta.cloud.google.com/backend-config: '{"default": "backend-config-default"}'
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    run: web
  type: NodePort
```