Function Get-FileShare {
    Param([string]$ComputerName = $env:computername,
          [string]$Share = "")

    $Filter = ""
    If ($Share -ne "") {
        $Filter = "Name='{0}'" -f $Share
    }

    Get-WmiObject -Class Win32_Share -ComputerName $ComputerName -Filter $Filter
}

Function Add-FileShare {
    Param([string]$Computername=$env:computername,
          [string]$Path = $(Throw "You must enter a path for the new share."),
          [string]$Share = $(Throw "You must enter a name for the new share."),
          [string]$Comment,
          [int]$Connections = 10)
          
    $FILE_SHARE = 0

    $WmiShare = Get-WmiObject -Class Win32_Share -List -ComputerName $Computername
    $Result = $WmiShare.Create($Path, $Share, $FILE_SHARE, $Connections, $Comment)
    Switch ($Result.returnvalue) {
        0 {$rvalue = "Success"}
        2 {$rvalue = "Access Denied"} 
        8 {$rvalue = "Unknown Failure"}     
        9 {$rvalue = "Invalid Name"}     
        10 {$rvalue = "Invalid Level"}     
        21 {$rvalue = "Invalid Parameter"}     
        22 {$rvalue = "Duplicate Share"}     
        23 {$rvalue = "Redirected Path"}     
        24 {$rvalue = "Unknown Device or Directory"}
        25 {$rvalue = "Net Name Not Found"}
    }
    
    if ($Result.returnvalue -ne 0) {
        Write-Error ("Failed to create share {0} for {1} on {2}. Error: {3}" -f $share, $path, $computername, $rvalue) 
    }
}

Function Remove-FileShare {
    Param([string]$ComputerName = $env:computername,
          [string]$Share = $(Throw "You must enter the name of the share to remove."))

    $Filter = "Name='{0}'" -f $Share
    $WmiShare = Get-WmiObject -Class Win32_Share -ComputerName $ComputerName -Filter $Filter
    $Result = $WmiShare.Delete()
    Switch ($Result.returnvalue) {
        0 {$RValue = "Success"}
        2 {$RValue = "Access Denied"}     
        8 {$RValue = "Unknown Failure"}     
        9 {$RValue = "Invalid Name"}
        10 {$RValue = "Invalid Level"}
        21 {$RValue = "Invalid Parameter"}
        22 {$RValue = "Duplicate Share"}     
        23 {$RValue = "Redirected Path"}     
        24 {$RValue = "Unknown Device or Directory"}
        25 {$RValue = "Net Name Not Found"}
    }
    
    if ($Result.returnvalue -ne 0) {
        Write-Error ("Failed to delete share {0} on {2}. Error: {3}" -f $Share, $ComputerName, $RValue) 
    }
}