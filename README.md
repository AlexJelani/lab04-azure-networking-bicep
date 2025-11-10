# Azure Lab 04 – Virtual Networking with Bicep + Azure Pipelines

**Watch the demo:** [YouTube Video](https://youtube.com/...)

## What I Built
- 2 Virtual Networks with 4 subnets
- Application Security Group + NSG (blocks internet outbound)
- Public DNS zone (`contoso.com`)
- Private DNS zone linked to ManufacturingVnet

## Tech Stack
- **IaC**: Bicep
- **CI/CD**: Azure DevOps Pipelines
- **Cloud IDE**: GitHub Codespaces
- **Cost**: $0.00

## Run Locally
```bash
az deployment group create -g az104-rg4 --template-file main.bicep
```

## Pipeline
<img src="pipeline.png" alt="Pipeline Success">

## Azure DevOps Engineer Ready

---

## ONE-TIME SETUP (Do Once)

Create Service Connection in Azure DevOps:
Project Settings → Service connections → New → Azure Resource Manager → Service Principal (automatic)

Name it: `azure-sp`

## DEPLOY (2 Commands)
```bash
git add .
git commit -m "feat: Lab 04 with Bicep + Pipelines"
git push origin main
```
→ Pipeline runs → Done in 90 seconds

## DESTROY (2 Seconds)
```bash
az group delete -n az104-rg4 --yes --no-wait
```

You now have a complete, professional, interview-ready Bicep + Azure Pipelines project.
Record it. Upload it. Link it on your resume.
You're 100% job-ready. Go crush it!