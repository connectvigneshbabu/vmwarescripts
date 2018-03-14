#*****************************************************************************************
# PowerShell script to check for VM snapshots and send Email report 
# Name: snap.ps1
# 
# Release: 1.0
# Date: 31.12.2015 (DDMMYY)
# 
# 
# Contents of path
#	snap.ps1 - Main script file which need to execute from path.
#	snap.ps1 mail content – Add recipients email ID in this file.
# Script Description: This script will connect to multiple VCs > collect snapshot Report > Save OutPut as HTML format > Send email.   			
#*****************************************************************************************


add-pssnapin VMware.VimAutomation.Core
Connect-VIServer -Server '' -User '' -Password ''

# HTML formatting
$a = "<style>"
$a = $a + "BODY{background-color:white;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;foreground-color: black;background-color: LightBlue}"
$a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;foreground-color: black;background-color: white}"
$a = $a + "</style>"

# Main section of check
Write-Host "Checking VMs for for snapshots"
$date = get-date
$datefile = get-date -uformat '%m-%d-%Y-%H%M%S'
$filename = "D:\umesh\snapshot\Snaps_" + $datefile + ".htm"

# Get list of VMs with snapshots
# Note:  It may take some time for the  Get-VM cmdlet to enumerate VMs in larger environments
$ss = Get-vm | Get-Snapshot
Write-Host "   Complete" -ForegroundColor Green
Write-Host "Generating VM snapshot report"
#$ss | Select-Object vm, name, sizeGB, description, powerstate | Sort-Object sizeGB |ConvertTo-HTML -head $a -body "<H2>VM Snapshot Report</H2>"| Out-File $filename
$ss | Select-Object vm, name, sizeGB, description | Sort-Object sizeGB –Descending | ConvertTo-HTML -head $a -body "<H2>VM Snapshot Report</H2>"| Out-File $filename
Write-Host "   Complete" -ForegroundColor Green
Write-Host "Your snapshot report has been saved to:" $filename

# Create mail message
$server = ""
$port = 25
$to      = ""
$from    = ""
$subject = "VM Snapshot Report"
$body = Get-Content $filename

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