# Healthcare Appointment Agent

Conversational agent that checks a child’s immunization schedule and books vaccine appointments.
It uses **Amazon Bedrock Agent Runtime** + **AgentCore Gateway/Target** to call a **FHIR API** hosted behind **API Gateway + Lambda** that queries **AWS HealthLake**.

![flow](docs/healthcare_gateway_flow.png)

## Architecture (10,000-ft)
- **Agent Runtime** (Bedrock) decides actions/tools from user prompts.
- **AgentCore Gateway** authenticates and forwards tool calls to…
- **Gateway Target → API Gateway → Lambda → HealthLake**.
- OAuth tokens are stored/retrieved via **Cognito + Secrets Manager**.

## Prerequisites
- Windows + PowerShell 7, Python 3.12
- AWS CLI v2 configured for an account with the policies from the sample
- Region: `us-east-1`
- Repo cloned locally and a virtualenv created
- **Claude 3.5 Sonnet** enabled in Bedrock

## Quickstart (PowerShell, Windows)

```powershell
# 0) Create/activate venv and install deps
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# 1) Bootstrap infra & print your gateway_id (edit bucket/profile/region if needed)
.\scripts\bootstrap.ps1 -BucketName "sid-healthcare-agent" -Region "us-east-1"

# (output shows API endpoint, Cognito lambda name, and gateway_id)
# Save your gateway_id, e.g. healthcare-fhir-gateway-2-xxxx

# 2) Run the agent (Strands or LangGraph)
$env:AWS_REGION="us-east-1"
python .\strands_agent.py   --gateway_id "<your_gateway_id>"
# or
python .\langgraph_agent.py --gateway_id "<your_gateway_id>"
