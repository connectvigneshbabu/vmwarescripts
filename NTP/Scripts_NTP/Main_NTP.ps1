#*****************************************************************************************
# PowerCli script to generate the NTP report
# Name: Main_NTP.ps1
# Author: Vigneshbabu 
# version : 1.0 (Baseline report)
#  			
#*****************************************************************************************
add-pssnapin VMware.VimAutomation.Core
Connect-VIServer -Server '' -User '' -Password ''
cd 'D:\Vignesh\Scripts_vishal\'
.\function_nTP.ps1
$a = "<style>"
$a = $a + "BODY{background-color:white;}"
$a = $a + "TABLE{border-width: 2px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color: #4CAF50;color:white;}"
$a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;}"
$a = $a + ".right {float: right;width:200px;background-color:white;border: 3px solid #73AD21;padding: 5px}.center{float: center;}.left{float: left;}"
$a = $a + "</style>"
$header = @"
                     <H1>NTP Report Esxi</H1>
"@
$tit = "NTP Script Automation"
$pre = @"

  <div class="right">
  <b> Threshold Values</b> </br> Reach = 377 </br> Delay = 2 MS or Less </br>Offset = 0 to -1</br> Jitter = 0</br><a href="https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1005092">Click here for solution</a>
  </div>    
"@

$post = @" 
         </br> NTP Report Automation for ESXi : <b> </b> </br></br> Author : Vigneshbabu
"@
$date= Get-Date -format dd-MM-yyyy_HH-mm
 Import-Csv -Path "D:\Vignesh\Scripts_vishal\output.csv" | Export-Clixml -Encoding UTF8 -Path "D:\Vignesh\Scripts_vishal\NTPOutputfiles\output_$date.xml"
 Import-Csv -Path "D:\Vignesh\Scripts_vishal\output.csv" | ConvertTo-Html -Body $a   -Head $header | Out-File -FilePath "D:\Vignesh\Scripts_vishal\output.htm" 
 $body= Get-Content "D:\Vignesh\Scripts_vishal\output.htm"
 $bodycon = $body | Out-String

Send-MailMessage -From "" -To "" -Cc "" -SmtpServer "" -Subject "ESXi Production NTP Report"  -BodyAsHtml -Body $bodycon 
