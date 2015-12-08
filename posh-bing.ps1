Function Search-Bing
{
    [CmdletBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "Specify the search query")]$Query,
        [Switch]$Browse,
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens the nth search result")]
        [ValidateRange(1, 50)]
        [int]$GoTo
    )

    Add-Type -AssemblyName System.Web
    If ($Browse)
    {
        $encodedQuery = [System.Web.HttpUtility]::UrlEncode("$Query")
        Start "http://www.bing.com/search?q=$encodedQuery"
        Write-Verbose "Search for '$Query' launched in browser"
        Return
    }
    
    $appId = ""
    $encodedQuery = [System.Web.HttpUtility]::UrlEncode("'$Query'")
    $url = "https://api.datamarket.azure.com/Bing/SearchWeb/v1/Web?Query=$encodedQuery"
    Write-Debug "Target Url: $url"

    $client = New-Object System.Net.WebClient
    $client.Proxy = [System.Net.WebRequest]::GetSystemWebProxy()
    $client.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
    $client.Credentials = New-Object System.Net.NetworkCredential($appId, $appId)
    
    Try
    {
        [Xml]$response = $client.DownloadString($url)
        Write-Debug "Response $($response.InnerXml)"
    }
    Catch [System.Net.WebException]
    {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Host $reader.ReadToEnd()
        Return
    }
    
    $numberOfResults = $response.feed.entry.Count
    $result =
        foreach ($index in 1..$numberOfResults)
        {
            $entry = $response.feed.entry[$index - 1]
            $properties = @{
                Index = $index
                Title = $entry.content.properties.Title.InnerText
                Url = $entry.content.properties.Url.InnerText }
            New-Object PSObject -Property $properties
        }

    if ($GoTo)
    {
        start $result[$GoTo - 1].Url
    }

    return $result
}

Set-Alias -Name bing -Value Search-Bing