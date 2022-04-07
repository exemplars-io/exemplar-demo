$Repo = ${Env:GITHUB_REPOSITORY}
echo $Repo
$BaseUri = "https://api.github.com"
echo $BaseUri
$ArtifactUri = "$BaseUri/repos/$Repo/actions/artifacts"
echo $ArtifactUri
$Token = ${Env:GITHUB_TOKEN} | ConvertTo-SecureString -AsPlainText
echo $Token
