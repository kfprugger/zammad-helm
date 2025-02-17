#!/bin/bash
#
# use kubeconform to validate helm generated kubernetes manifest
#

set -o errexit
set -o pipefail

CHART_DIRS="$(git diff --find-renames --name-only "$(git rev-parse --abbrev-ref HEAD)" remotes/origin/main -- zammad | grep '[cC]hart.yaml' | sed -e 's#/[Cc]hart.yaml##g')"

# install kubeconform
curl --silent --show-error --fail --location --output /tmp/kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/"${KUBECONFORM_VERSION}"/kubeconform-linux-amd64.tar.gz
sudo tar -C /usr/local/bin -xf /tmp/kubeconform.tar.gz kubeconform

# validate charts
for CHART_DIR in ${CHART_DIRS};do
  echo "helm dependency build..."
  helm dependency build "${CHART_DIR}"

  echo "kubeconform(ing) ${CHART_DIR##charts/} chart..."
  helm template "${CHART_DIR}" | kubeconform --strict --kubernetes-version "${KUBERNETES_VERSION#v}"
done
