function Add-Path { 
  param ( 
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    $Path 
  )

  if (-not (Test-Path -LiteralPath $Path -IsValid)) {
    Write-Output "'$Path' is not a valid path."
    return 
  }

  $EnvironmentScope = "User"
  $PATHVariable = [environment]::GetEnvironmentVariable("PATH", $EnvironmentScope)
  $ExistingPaths = $PATHVariable.Replace(";;", ";").Split(";")
  if ($ExistingPaths.Contains($Path)) {
    Write-Output "'$Path' is already in your environment PATH." 
  } else {
    $UpdatedPATHVariable = [system.String]::Join(";", $ExistingPaths + $Path).Replace(";;", ";") 
    [environment]::SetEnvironmentVariable("PATH", $UpdatedPATHVariable, $EnvironmentScope) 
  }
}

function Remove-Path {
  param ( 
    [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
    $Path
  )

  $EnvironmentScope = "User"
  $RemainingPaths = New-Object System.Collections.Generic.List[String]
  foreach ($existingPath in [environment]::GetEnvironmentVariable("PATH", $EnvironmentScope).Replace(";;", ";").Split(";")) {
    if (-not $existingPath.Equals($Path)) {
      $RemainingPaths.Add($existingPath)
    }
  }

  [environment]::SetEnvironmentVariable("PATH", [system.String]::Join(";", $RemainingPaths), $EnvironmentScope)
}