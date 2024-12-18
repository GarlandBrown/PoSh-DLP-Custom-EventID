$ssnPattern = "\b\d{3}-\d{2}-\d{4}\b"
#ccPattern = "\b\d{4}-\d{4}-\d{4}-\d{4}\b"
$hostname = hostname
$results = ""
$directory = "C:\Temp"
$source = "ScheduledTask_Custom_Script"

get-ChildItem -Path $directory -Recurse -File | ForEach-Object {
    $fileContent = Get-Content -Path $_.FullName -raw
    $infoType = @()
    if ($fileContent -match $ssnPattern){
        $infoType += "SSN"
    }
    if ($fileContent -match $ccPattern){
        $infoType += "Credit Card"
    }
    if ($infoType.Count -gt 0){
        $Filename = $($_.FullName)
        $CreationTime = $($_.CreationTime)
        $FileOwner = $($(get-acl $_.FullName).owner)

        $results += "$($Filename)`n $($CreationTime) `n $($FileOwner)"

        if (-not [System.Diagnostics.EventLog]::SourceExists($source)){
            New-EventLog -LogName Application -Source $source
        }
        Write-EventLog -LogName Application -Source $source -EventId 10001 -EntryType FailureAudit -Message $results -Computernae $hostname
    }
}
