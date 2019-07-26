#!/usr/bin/pwsh
param
(
    $WorkspaceName = 'default'
)

Import-Module $PSScriptRoot/tfworkspace.psm1 -Force

if ($WorkspaceName -eq 'pst') {
    $AccoutPostFix = 'dev'
}
elseif ($WorkspaceName -eq 'prod') {
    $AccoutPostFix = 'prod'
}
else {
    $AccoutPostFix = 'dev'
}
$ProfileName = "aws-platform-services-$($AccoutPostFix):aws-platform-services-$AccoutPostFix-admin"
$ClusterName = "platform-services-eks-$AccoutPostFix"

$env:AWS_PROFILE = $ProfileName
Select-TerraformWorkspace $WorkspaceName
terraform init
terraform apply -auto-approve
