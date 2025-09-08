param(
  [Parameter(Mandatory=$true)] [string] $GatewayId,
  [string] $Region = "us-east-1",
  [string] $Profile
)
function awsx { param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
  if ($Profile) { aws @Args --profile $Profile } else { aws @Args } }

$fn = awsx cloudformation describe-stacks --stack-name healthcare-cfn-stack --query "Stacks[0].Outputs[?OutputKey=='APIGWCognitoLambdaName'].OutputValue" --output text --region $Region

Write-Host "==> Disable Cognito authorizer"
'{"RequestType":"Delete"}' | Set-Content -Encoding ascii -NoNewline payload.json
awsx lambda invoke --function-name $fn response.json --payload fileb://payload.json --cli-binary-format raw-in-base64-out --region $Region | Out-Null

Write-Host "==> Delete AgentCore gateway/target"
python .\setup_fhir_mcp.py --op_type Delete --gateway_id $GatewayId

Write-Host "==> Delete CloudFormation stack"
awsx cloudformation delete-stack --stack-name healthcare-cfn-stack --region $Region
Write-Host "Done."
