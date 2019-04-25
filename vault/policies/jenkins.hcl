path "aws/creds/jenkins"
{
        capabilities = ["read", "list"]
}

path "sys/auth"
{
        capabilities= ["read", "list"]
}

path "sys/health"
{
        capabilities = ["read", "sudo"]
}
