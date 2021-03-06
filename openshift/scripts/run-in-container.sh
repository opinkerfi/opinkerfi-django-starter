#!/bin/bash

# Use this script to run one-off commands inside a container of a pod where your
# Python application code lives in.

# You can accomplish the same results by using regular commands from OpenShift.
# This script is just wrapping calls to `oc` to make it a little more
# convenient to use. In the future, the `oc` cli tool might incorporate changes
# that make this script obsolete.

# Related GitHub issues:
# - https://github.com/GoogleCloudPlatform/kubernetes/issues/8876
# - https://github.com/openshift/origin/issues/2001


# Usage examples:
#
#     ./run-in-container.sh ./manage.py migrate
#     ./run-in-container.sh ./manage.py createsuperuser
#     ./run-in-container.sh ./manage.py shell
#

POD_NAME=opinkerfi-django-starter

# Get name of a currently deployed pod by label and index
POD_INSTANCE_NAME=`oc get pods \
  -l "name=${POD_NAME:-django-frontend}" \
  --template "{{ with index .items ${POD_INDEX:-0} }}{{ .metadata.name }}{{ end }}"`

# Run command in a container of the specified pod:
oc exec "$POD_INSTANCE_NAME" -it -- bash -c "${@:-echo}"
