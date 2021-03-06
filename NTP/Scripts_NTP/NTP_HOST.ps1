$user = 'root'
$pswd = ''
$plink = 'D:\Vignesh\software\plink.EXE'
$plinkoptionsPre = " -pw $Pswd"
$plinkoptions = " -batch -pw $Pswd"
$cmd1 = 'ntpq -p'
$remoteCommand = '"' + $cmd1 + '"'

$sMail = @{

    From = ''
    To = ''
    SmtpServer = ''
    Subject = 'NTP Report for the Production Vcenter'
    BodyAsHtml = $true
    Body =  Get-VMHost | Select Name,
            @{N='NTP Service Running';E={Get-VMHostService -VMHost $_ | where{$_.Key -eq 'ntpd'} | select -ExpandProperty Running}},
            @{N='NTP Server(s)';E={(Get-View -Id $_.ExtensionData.ConfigManager.DatetimeSystem).DateTimeInfo.NtpConfig.Server -join '| '}},
            @{N='Reach';E={
                $serviceSSH = Get-VMHostService -VMHost $_ | Where{$_.Label -eq 'SSH'}
                $command = "echo Y | " + $plink + " " + $plinkoptionsPre + " " + $User + "@" + $_.Name + " " + """exit"""
                $dummy = Invoke-Expression -Command $command
                $command = $plink + " " + $plinkoptions + " " + $User + "@" + $_.Name + " " + $remoteCommand
                $msg = Invoke-Expression -command $command
                $script:fields = (($msg | where{$_ -match '^\*'}) -replace '\s+',' ').Split(' ')
                $script:fields[6]}},
            @{N='Delay';E={$script:fields[7]}},
            @{N='Offset';E={$script:fields[8]}},
            @{N='Jitter';E={$script:fields[9]}} | ConvertTo-Html -CssUri "style.css" -Body | Out-String
}

Send-MailMessage @SMail