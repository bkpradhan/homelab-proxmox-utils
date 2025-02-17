Warning: Test code..

credentials are dummy test values, pls set as per your Proxmox environment in Datacenter > Permissions > API Tokens > Add

```
cd to terraform

terraform % docker compose -f docker-compose.yml run --rm terraform init 
terraform % docker compose -f docker-compose.yml run --rm terraform plan 
terraform % docker compose -f docker-compose.yml run --rm terraform apply
```
