set -e

echo AWS_ACCESS_KEY_ID
read INPUT_AAKI

echo AWS_SECRET_ACCESS_KEY
read INPUT_ASAK

echo AWS_SESSION_TOKEN
read INPUT_AST

export AWS_ACCESS_KEY_ID=$INPUT_AAKI
export AWS_SECRET_ACCESS_KEY=$INPUT_ASAK
export AWS_SESSION_TOKEN=$INPUT_AST

curl --method 'PUT' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" -URI "https://beuth-hochschule.de/api/v4/projects/s40929/lecture-devops-app/variables/AWS_ACCESS_KEY_ID" --form "value=$AWS_ACCESS_KEY_ID"
curl --method 'PUT' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" -URI "https://beuth-hochschule.de/api/v4/projects/s40929/lecture-devops-app/variables/AWS_SECRET_ACCESS_KEY" --form "value=$AWS_SECRET_ACCESS_KEY"
curl --method 'PUT' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" -URI "https://beuth-hochschule.de/api/v4/projects/s40929/lecture-devops-app/variables/AWS_SESSION_TOKEN" --form "value=$AWS_SESSION_TOKEN"
