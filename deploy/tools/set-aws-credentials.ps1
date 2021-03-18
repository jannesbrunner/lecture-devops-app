$GITLAB_ACCESS_TOKEN = "xy3_3KrLwC9FhWxskeyw"
$AWS_ACCESS_KEY_ID = Read-Host -Prompt 'AWS_ACCESS_KEY_ID'
$AWS_SECRET_ACCESS_KEY = Read-Host -Prompt 'AWS_SECRET_ACCESS_KEY'
$AWS_SESSION_TOKEN = Read-Host -Prompt 'AWS_SESSION_TOKEN'
[System.Environment]::SetEnvironmentVariable('AWS_ACCESS_KEY_ID', $AWS_ACCESS_KEY_ID,[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('AWS_SECRET_ACCESS_KEY', $AWS_SECRET_ACCESS_KEY,[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('AWS_SESSION_TOKEN', $AWS_SESSION_TOKEN,[System.EnvironmentVariableTarget]::User)

# Update variables on gitlab
Invoke-WebRequest -method 'PUT' -header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" -URI "https://beuth-hochschule.de/api/v4/projects/s40929/lecture-devops-app/variables/AWS_ACCESS_KEY_ID" --form "value=$AWS_ACCESS_KEY_ID"
Invoke-WebRequest -method 'PUT' -header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" -URI "https://beuth-hochschule.de/api/v4/projects/s40929/lecture-devops-app/variables/AWS_SECRET_ACCESS_KEY" --form "value=$AWS_SECRET_ACCESS_KEY"
Invoke-WebRequest -method 'PUT' -header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" -URI "https://beuth-hochschule.de/api/v4/projects/s40929/lecture-devops-app/variables/AWS_SESSION_TOKEN" --form "value=$AWS_SESSION_TOKEN"
