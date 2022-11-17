#!/usr/bin/env bash

# Helper script for using terraform commands in a workspace.
# Don't use this script if doing anything other then mundane main commands like
# console, plan, apply, or destroy.

set -o nounset
set -o pipefail
set -o errexit

# Should be console, plan, apply, or destroy
terraform_command=$1

test $(basename $PWD) = "_infra" || (echo "Must run this script from the _infra directory." && exit 1)

# The workspace name is the folder that contains the terra.sh script.
script_dir=$(dirname $(realpath $0))
workspace=$(basename $script_dir)
project_dir=$(dirname $PWD)

project_version=$(jq -r '.version' $project_dir/package.json)

artifact_dist_tar_gz=puzzle-massive-$project_version.tar.gz
test -e $project_dir/$artifact_dist_tar_gz || (echo "Must create a versioned artifact file at path $project_dir/$artifact_dist_tar_gz before running this command." && exit 1)

project_description="Temporary instance for acceptance"

echo "Terraform workspace is: $workspace"
echo "Project description will be: '$project_description'"
echo "Using versioned artifact dist file: '$project_dir/$artifact_dist_tar_gz'"

set -x

existing_artifact="$(echo $script_dir/puzzle-massive-*.tar.gz)"
if [ ! -e "$existing_artifact" -o "$(md5sum $existing_artifact | cut -f1 -d ' ')" != "$(md5sum $project_dir/$artifact_dist_tar_gz | cut -f1 -d ' ')" ]; then
  rm -f $script_dir/puzzle-massive-*.tar.gz
  cp $project_dir/$artifact_dist_tar_gz $script_dir/
fi

# The Acceptance environment should be set up with a recent copy of the
# production sqlite database dump file or just use an empty one.
recent_database_dump_file=$script_dir/db.dump.gz
test -e $recent_database_dump_file || (echo "No sqlite db dump file found at: $recent_database_dump_file" && exit 1)
test -z "$(find $recent_database_dump_file -mtime +1)" || (echo "The sqlite db dump file is older than 24 hours: $recent_database_dump_file" && exit 1)

terraform workspace select $workspace || \
  terraform workspace new $workspace

test "$workspace" = "$(terraform workspace show)" || (echo "Sanity check to make sure workspace selected matches environment has failed." && exit 1)

terraform $terraform_command -var-file="$script_dir/config.tfvars" \
    -var-file="$script_dir/private.tfvars" \
    -var "artifact=$artifact_dist_tar_gz" \
    -var "project_version=$project_version" \
    -var "project_description=$project_description"
