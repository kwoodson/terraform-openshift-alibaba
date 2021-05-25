#!/bin/sh

# these value match ../terraform.autovars.tf
export CLUSTER_NAME=kwoodson
export BASE_DOMAIN=openshift.com
export SSH_PUBLIC_KEY=$(cat ~/.ssh/proxy_id_rsa.pub)
export PULL_SECRET=$(cat pull_secret.json | jq -c)

DIR=cluster

rm -rf $DIR && mkdir $DIR
cat install-config-templ.yaml | envsubst > $DIR/install-config.yaml
openshift-install create manifests --dir=$DIR
sed -i -e 's/  mastersSchedulable: true/  masterSchedulable: false/' $DIR/manifests/cluster-scheduler-02-config.yml
openshift-install create ignition-configs --dir=$DIR
