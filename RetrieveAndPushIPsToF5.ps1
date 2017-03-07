﻿#DECLARE VARIABLES
$testArray = [System.Collections.ArrayList]@()

#GET-LISTOFAZUREIPS FUNCTION
function Get-ListOfAzureIPs
{

$AzureIPRangesPage=Invoke-WebRequest -Uri https://www.microsoft.com/en-us/download/confirmation.aspx?id=41653 -Method Get -UseBasicParsing

[XML]$AzureIPRanges= Invoke-RestMethod -uri ($AzureIPRangesPage.Links |Where {$_.outerhtml -like "*Click here*"}).href[0]


    Foreach ($iprange in $Azureipranges.AzurePublicIpAddresses.region)
        { 
            if ($iprange.name -eq 'useast' -Or 
                $iprange.name -eq 'useast2' -Or
                $iprange.name -eq 'uswest' -Or
                $iprange.name -eq 'usnorth' -Or
                $iprange.name -eq 'uscentral'-Or
                $iprange.name -eq 'ussouth' -Or
                $iprange.name -eq 'uswest2' -Or
                $iprange.name -eq 'uswestcentral' -Or
                $iprange.name -eq 'uscentraleuap' -Or
                $iprange.name -eq 'useast2euap' -Or
                $iprange.name -eq 'brazilsouth' -Or 
                $iprange.name -eq 'canadaeast' -Or
                $iprange.name -eq 'canadacentral')      
            
		        {               
                    Foreach ($ipsubnet in $iprange.iprange.subnet)
                        {
                            $ArrayList = $testArray.Add($ipsubnet)
                        }                                      
                }
         }          
 }

 #Call Function
 Get-ListOfAzureIPs

#PUSH LIST OF IP RESULTS TO F5

#Add TunableSSL Validator Module
import-module -name "C:\Users\srinivas.gogineni\Downloads\Tunable-SSL-Validator-master\Tunable-SSL-Validator-master\TunableSSLValidator.psm1"


#Create a credential object | Azure Key Vault Request
$Username = "srinivas.gogineni"
$SecurePassword = convertto-securestring -string Mana6089 -asplaintext -force
#Stays
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword

#Create array of member objects | Perhaps a Loop
$WhitelistBody = @()
$WhitelistBody = @{"addresses"=$testArray}
#$WhitelistBody = @{"addresses"="1.1.1.15","1.1.1.16","1.1.1.18"}
#$WhitelistBodyFQDN = @{"fqdns"="www.microsoft.com","www.cisco.com","www.google.com"}

#Convert request to JSON
$JSONBody = $WhitelistBody | ConvertTo-Json
#$JSONBodyFQDN = $WhitelistBodyFQDN | ConvertTo-Json

#F5-RestAPI-Call -PUT-
Invoke-WebRequest -Method PUT -Uri "https://10.127.253.5:8443/mgmt/tm/security/firewall/address-list/RestAPITest" -Insecure -Credential $Credential -Body $JSONBody -Headers @{"Content-Type"="application/json"} 
#Invoke-WebRequest -Method PUT -Uri "https://10.127.253.5:8443/mgmt/tm/security/firewall/address-list/RestAPITest" -Insecure -Credential $Credential -Body $JSONBodyFQDN -Headers @{"Content-Type"="application/json"} 

#F5-RestAPI-Call -Get-
Invoke-WebRequest -Method GET -Uri "https://10.127.253.5:8443/mgmt/tm/security/firewall/address-list/RestAPITest" -Insecure -Credential $Credential -Headers @{"Content-Type"="application/json"} | write-host
  
