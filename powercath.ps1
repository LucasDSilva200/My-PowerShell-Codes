#!/usr/bin/env pwsh

param(
    [Parameter(Mandatory = $true)]
    [string]$url,
    [Parameter(Mandatory = $false)]
    [switch]$getcode,
    [Parameter(Mandatory = $false)]
    [switch]$text,
    [Parameter(Mandatory = $false)]
    [string]$HeadersFile,
    [Parameter(Mandatory = $false)]
    [string[]]$header
    
)


function parse_headers {
    param(
        [Parameter(Mandatory = $false)]
        [string]$filepath,
        [Parameter(Mandatory = $false)]
        [string[]]$args_headers
    )
    $req_headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        
    if ($filepath -ne '' -and (Test-Path $filepath)) {
        $file_lines = Get-Content $filepath
        foreach ($line in $file_lines) {
            if ($line -match ":") {
                $key = $line.Substring(0, $line.IndexOf(":"))
                $value = $line.Substring($line.IndexOf(":") + 1).Trim()
                $req_headers.Add($key, $value)
            }
        }
    }
    elseif ($args_headers -ne '' -and ($args_headers.Length -gt 0)) {
        foreach ($line in $args_headers) {
            if ($line -match ":") {
                $key = $line.Substring(0, $line.IndexOf(":"))
                $value = $line.Substring($line.IndexOf(":") + 1).Trim()
                $req_headers.Add($key, $value)
            }
        }
    }
    return $req_headers

}


function print_status_code {
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$url,
        [Parameter(Mandatory = $true)]
        [int]$code
    
    )
    
    
    
    Write-Host "$url " -NoNewline 
    
    if ($code -ige 200 -and ($code -lt 300)) {

        Write-Host "<$code>" -ForegroundColor Green

    }
    elseif ($code -ige 300 -and ($code -lt 400)) {
    
        Write-Host "<$code>" -ForegroundColor Yellow

    }
    elseif ($code -ige 400 -and ($code -lt 500)) {

        Write-Host "<$code>" -ForegroundColor Red

    }

}


function request {
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$url,
        [Parameter(Mandatory = $false)]
        $headers
    )
    
    
    try {
   
        $response = Invoke-WebRequest -Uri $url -Headers $headers 


        $code = $response.StatusCode
    }
    catch {
        $erro = $_.Exception.Message
        if ($erro -like "*404*") {
            $code = 404
        }
        elseif ($erro -like "*403*") {
            $code = 403
        }
        elseif ($url -notmatch "http(s)?://") {
            Write-Host "Valid URL must start with http:// or https://." -ForegroundColor Red
            exit
        }
        else {
            Write-Host $_.Exception.Message -ForegroundColor Red
            exit
        }

    }
    return $code, $response

}


if ($HeadersFile -ne '') {
    $headers = parse_headers -filepath $HeadersFile -args_headers $header
    $status_code, $html = request -url $url -headers $headers
}
elseif ($null -ne $header) {
    $headers = parse_headers -args_headers $header
    $status_code, $html = request -url $url -headers $headers
} 

else {
    $status_code, $html = request -url $url
}

if ($getcode) {
    print_status_code -url $url -code $status_code
}
elseif ($text) {
    Write-Host $html
}


#Write-Host "`n`n`n $response"