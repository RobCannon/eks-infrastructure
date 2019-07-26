#!/usr/bin/pwsh
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