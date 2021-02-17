$AWS_ACCESS_KEY_ID = Read-Host -Prompt 'AWS_ACCESS_KEY_ID'
$AWS_SECRET_ACCESS_KEY = Read-Host -Prompt 'AWS_SECRET_ACCESS_KEY'
$AWS_SESSION_TOKEN = Read-Host -Prompt 'AWS_SESSION_TOKEN'
[System.Environment]::SetEnvironmentVariable('AWS_ACCESS_KEY_ID', $AWS_ACCESS_KEY_ID,[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('AWS_SECRET_ACCESS_KEY', $AWS_SECRET_ACCESS_KEY,[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('AWS_SESSION_TOKEN', $AWS_SESSION_TOKEN,[System.EnvironmentVariableTarget]::User)