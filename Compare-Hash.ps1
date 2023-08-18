#!/usr/bin/env pwsh

<#
.SYNOPSIS
Este programa compara hashs de arquivos com um hash passado como parâmetro.

.DESCRIPTION
Este programa compara hashs de arquivos com um hash passado como parâmetro.

.PARAMETER FilePath
Caminho completo do arquivo que será verficado.

.PARAMETER Algorithm
O algoritmo que será usado para calcular o hash.
Hashs: md5, sha1, sha256, sha384, sha512

.PARAMETER Hash
O hash que será comparado com o hash do arquivo.

.EXAMPLE
./Compare-Hash.ps1 -FilePath "./Caminho/para/o/arquivo" -Algorithm md5 -Hash "C2EB69D59922122FFE105F1336FEA057"

.NOTES
Nome do Arquivo: Compare-Hash.ps1
Autor: Lucas Silva
Versão: 1.0

#>

param(
    [Parameter(Mandatory = $false)]
    [string]$FilePath,
    [Parameter (Mandatory = $false)]
    [string]$Hash,
    [Parameter (Mandatory = $false)]
    [string]$Algorithm,
    [switch]$help
)


function compare_hash {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string]$Hash_to_compare,
        [Parameter(Mandatory = $true)]
        [string]$Algorithm
    )
    $hash_file = Get-FileHash $FilePath -Algorithm $Algorithm
    $hash_file = $hash_file.Hash
    if ($hash_file -eq $Hash_to_compare) {
        <# Action to perform if the condition is true #>
        Write-Host "As hashs são iguais. O arquivo não foi alterado." -ForegroundColor Green
    }
    else {
        <# Action when all if and elseif conditions are false #>
        Write-Host "As hash são diferentes. Provavelmente o arquivo foi alterado." -ForegroundColor Red
    }
}

if ($help) {
    Get-Help -Name $MyInvocation.MyCommand.Definition
    exit
}
elseif (-not $FilePath -or -not $Hash -or -not $Algorithm) {
    <# Action when this condition is true #>
    Write-Host "Parâmetros insuficientes. Use -help para obter ajuda." -ForegroundColor Red
    Get-Help -Name $MyInvocation.MyCommand.Definition
    exit
}
else { compare_hash -FilePath $FilePath -Hash_to_compare $Hash -Algorithm $Algorithm }
