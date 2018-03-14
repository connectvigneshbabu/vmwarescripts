add-pssnapin VMware.VimAutomation.Core
Connect-VIServer -Server '' -User '' -Password ''

$VMHosts = Get-VMHost  | ? { $_.ConnectionState -eq "Connected" } | Sort-Object -Property Name
$results= @()
 
foreach ($VMHost in $VMHosts) {
# Get-VMHostStorage -RescanAllHba -VMHost $VMHost | Out-Null
[ARRAY]$HBAs = $VMHost | Get-VMHostHba -Type "FibreChannel"
 
    foreach ($HBA in $HBAs) {
    $pathState = $HBA | Get-ScsiLun | Get-ScsiLunPath | Group-Object -Property state
    $pathStateActive = $pathState | ? { $_.Name -eq "Active"}
    $pathStateDead = $pathState | ? { $_.Name -eq "Dead"}
    $pathStateStandby = $pathState | ? { $_.Name -eq "Standby"}
    $results += "{0},{1},{2},{3},{4},{5}" -f $VMHost.Name, $HBA.Device, $VMHost.Parent, [INT]$pathStateActive.Count, [INT]$pathStateDead.Count, [INT]$pathStateStandby.Count
    }
 
}
ConvertFrom-Csv -Header "VMHost","HBA","Cluster","Active","Dead","Standby" -InputObject $results | Export-Csv -Path d:\umesh\Deadpath\deadpath.csv -Encoding ascii -NoTypeInformation

$a = "<style>"
$a = $a + "BODY{background-color:peachpuff;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:palegoldenrod}"
$a = $a + "</style>"

Import-Csv -Path D:\umesh\Deadpath\deadpath.csv | Select-Object VMHost, HBA, Cluster, Active, Dead, Standby | Sort-Object Dead -Descending | export-csv -path D:\umesh\Deadpath\deadpathsorted.csv -notypeinformation
Import-Csv -Path D:\umesh\Deadpath\deadpathsorted.csv | Select-Object VMHost, HBA, Cluster, Active, Dead, Standby | ConvertTo-HTML -head $a -body "<H2>Dead Path Status On PROD ESXi HOSTS</H2>" | Out-File D:\umesh\Deadpath\deadpath.htm

# Create mail message
$server = ""
$port = 25
$to      = ""
$from    = ""
$subject = "Prod ESXi Dead Path Report"
$body = Get-Content d:\umesh\deadpath\deadpath.htm

$message = New-Object system.net.mail.MailMessage $from, $to, $subject, $body

# Create SMTP client
$client = New-Object system.Net.Mail.SmtpClient $server, $port
# Credentials are necessary if the server requires the client # to authenticate before it will send e-mail on the client's behalf.
$client.Credentials = [system.Net.CredentialCache]::DefaultNetworkCredentials

# Try to send the message

try {
   
# Convert body to HTML
    $message.IsBodyHTML = $true
# Uncomment these lines if you want to attach the html file to the email message
#   $attachment = new-object Net.Mail.Attachment($filename)
#   $message.attachments.add($attachment)
   
# Send message
    $client.Send($message)
    "Message sent successfully"

}

#Catch error

catch {

    "Exception caught in CreateTestMessage1(): "

}