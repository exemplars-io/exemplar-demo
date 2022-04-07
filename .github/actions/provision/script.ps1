$Repo = "${`{ github.repository }`}"
$BaseUri = "https://api.github.com"
$ArtifactUri = "$BaseUri/repos/$Repo/actions/artifacts"

echo $ArtifactUri

$Token = "${`{ github.token }`}" | ConvertTo-SecureString -AsPlainText

$RestResponse = Invoke-RestMethod -Authentication Bearer -Uri $ArtifactUri -Token $Token | Select-Object -ExpandProperty artifacts
if ($RestResponse){
  $MostRecentArtifactURI = $RestResponse | Sort-Object -Property created_at -Descending | where name -eq "terraformstatefile" | Select-Object -First 1 | Select-Object -ExpandProperty archive_download_url
  Write-Host "Most recent artifact URI = $MostRecentArtifactURI"
  if ($MostRecentArtifactURI){
    Invoke-RestMethod -uri $MostRecentArtifactURI -Token $Token -Authentication bearer -outfile ./state.zip
    Expand-Archive state.zip
    openssl enc -d -in state/terraform.tfstate.enc -aes-256-cbc -pbkdf2 -pass pass:"${`{ inputs.encryptionkey }`}" -out terraform.tfstate
  }
}
terraform init
$terraformapply = "${`{ inputs.apply }`}"
$custom_plan_flags = "${`{ inputs.custom_plan_flags }`}"
$custom_apply_flags = "${`{ inputs.custom_apply_flags }`}"
if ($terraformapply -eq "false"){
  $terraformapply = $false
}
terraform plan $custom_plan_flags
if ($terraformapply){
  terraform apply -auto-approve $custom_apply_flags
}

$StateExists = Test-Path -Path terraform.tfstate -PathType Leaf
if ($StateExists){
  echo "state file found, encrypting with the key"
  openssl enc -in terraform.tfstate -aes-256-cbc -pbkdf2 -pass pass:"${`{ inputs.encryptionkey }`}" -out terraform.tfstate.enc
}   