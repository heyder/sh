#!/usr/bin/env bash

content_type='Accept: application/vnd.github.v3+json'
creds="${GITHUB_USER}:${GITHUB_TOKEN}"

declare -a params
params=( $(echo $1 |  awk -F[/] '{print $4,$5}') )

main_user=${params[0]}
repo=${params[1]}

function get_last_commit_date() {
  curl -s  -H $content_type -u $creds  $1 | jq -r '(first (.[] | {commit})) | .commit  | .author | .date '
}

last_commit_date=$(get_last_commit_date "https://api.github.com/repos/$main_user/$repo/commits")

for page in $(seq 1 50);  do 
  for fork in $(
    curl -s  -H  $content_type -u $creds  "https://api.github.com/repos/$main_user/$repo/forks?per_page=100&page=$page" | jq -r '.[] | .owner | .login'
  ); do 
    fork_last_commit_date=$(get_last_commit_date "https://api.github.com/repos/$fork/$repo/commits")
    
    if [[ $fork_last_commit_date > $last_commit_date ]];
    then
      echo "$fork_last_commit_date:https://github.com/$fork/$repo"
    fi
  done; 
done; 
