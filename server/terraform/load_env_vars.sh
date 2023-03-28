#!/bin/bash

# Load environment variables from the .env file
set -o allexport
source ../.env
set +o allexport

# Set Terraform variables using environment variables
for varname in $(printenv | awk -F= '{print $1}'); do
  export TF_VAR_${varname}="$(printenv ${varname})"
done
