<#
.Synopsis
   Gets environment paths
.DESCRIPTION
   Gets environment paths for the specified scope
.EXAMPLE
   Gets User scope paths

   Get-Path
.EXAMPLE
   Gets Machine scope paths

   Get-Path -Scope Machine
#>
Function Get-Path
{
    Param(
        [EnvironmentVariableTarget]$Scope = [EnvironmentVariableTarget]::User
    )

    $environmentPath = [environment]::GetEnvironmentVariable("PATH", $Scope)
    Write-Debug "Environment path read: $environmentPath"
    If ($environmentPath -eq $null)
    {
        Return @()
    }

    $environmentPath.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) |
        Select-Object -Property @{ Name = "Path"; Expression = {$_} } |
        Sort-Object -Property Path
}

<#
.Synopsis
   Add path to the environment
.DESCRIPTION
   Add path to the environment for the specified scope
.EXAMPLE
   Add a path to the Machine scope environment

   Add-Path C:\windows -Scope Machine
.EXAMPLE
   Adds several paths to the User scope environment

   Add-Path C:\Windows,C:\Windows\System32
.EXAMPLE
   Add several paths to the Machine scope environment using the pipeline

   echo C:\Windows C:\Windows\System32 | Add-Path -Scope Machine
#>
Function Add-Path
{
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName=$True)]
        [String[]]$Path,
        [EnvironmentVariableTarget]$Scope = [EnvironmentVariableTarget]::User
    )

    Begin
    {
        $paths = @(Get-Path -Scope $Scope | ForEach-Object { $_.Path })
        Write-Debug "Existing paths: $paths"
    }

    Process
    {
        If (-not (Test-Path -LiteralPath $Path -IsValid))
        {
            Write-Verbose "'$Path' is not a valid path."
            Return
        }

        foreach ($p in $paths)
        {
            If ($p -like $Path)
            {
                Write-Verbose "Path '$Path' is already set"
                Return
            }
        }

        Write-Debug "Adding path '$Path'"
        $paths += $Path
    }

    End
    {
        $environmentPath = [System.String]::Join(";", $paths)
        Write-Debug "Saving new environment path: $environmentPath"
        Set-Path $environmentPath -Scope $Scope
    }
}

Function Remove-Path
{
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True)]
        [String[]]$Path,
        [EnvironmentVariableTarget]$Scope = [EnvironmentVariableTarget]::User
    )

    Begin
    {
        $paths = @(Get-Path -Scope $Scope)
    }

    Process
    {
        Write-Verbose "Removing '$Path' from environment PATH"
        $paths = $paths | Where-Object { $_.Path -ne $Path }
    }

    End
    {
        $paths = @($paths | ForEach-Object { $_.Path })
        $newPathVariable = [system.String]::Join(";", $paths)
        Set-Path $newPathVariable -Scope $Scope
    }
}

Function Clear-Path
{
    Param(
        [EnvironmentVariableTarget]$Scope = [EnvironmentVariableTarget]::User
    )

    Set-Path -Value "" -Scope $Scope
}

Function Set-Path
{
    Param(
        [String]$Value,
        [EnvironmentVariableTarget]$Scope = [EnvironmentVariableTarget]::User
    )
    
    [Environment]::SetEnvironmentVariable("PATH", $Value, $Scope)
}
