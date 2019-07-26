#!/usr/bin/env pwsh
param
(
    $WorkspaceName = 'default'
)

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
aws eks update-kubeconfig --name $ClusterName
Write-Host ""
Write-Host "http://localhost:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"
Write-Host ""
aws-iam-authenticator token -i $ClusterName --token-only
Write-Host ""
kubectl proxy --port=8080 --address='0.0.0.0' --disable-filter=true
