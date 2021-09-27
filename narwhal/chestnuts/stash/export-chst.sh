#!/bin/bash
# exporter
# just an exporter

export COMMON_NAME=gitlab-test.app.med.umich.edu
export CLUSTER=dev-tooling
export PROJECT_ID=hits-devops-tooling
export DB_USER=gitlabhq_dev_owner


#snazziman jamz
export DB_POD=$(kubectl get po -n devops-psql -l app=db-interface --output=jsonpath='{.items[0].metadata.name}')

