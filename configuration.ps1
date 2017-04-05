Configuration HybridWorker
{
    param(
        [Parameter(Mandatory=$true)][pscredential] $AutomationCredential,
        [Parameter(Mandatory=$true)][string] $HybridWorkerGroup
    )

    Script WinRM
    {
        GetScript = {
            return @{ Result = (winrm get winrm/config) }
        }

        SetScript = {
            $cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName $env:COMPUTERNAME
            Enable-PSRemoting -SkipNetworkProfileCheck -Force
            New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $cert.Thumbprint -Force
            New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "Windows Remote Management (HTTPS-In)" -Profile Any -LocalPort 5986 -Protocol TCP
        }

        TestScript = {
            return -not -not (Get-Item WSMan:\\localhost\Listener\Listener*\Port | where { $_.Value -eq 5986 })
        }
    }

    Script HybridWorkerGroup
    {
        GetScript = {
            return @{ Result = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\HybridRunbookWorker -Erroraction Ignore | Out-String) }
        }

        SetScript = {
            Add-HybridRunbookWorker `
                -Url ($using:AutomationCredential).UserName `
                -Key ($using:AutomationCredential).GetNetworkCredential().Password `
                -GroupName $using:HybridWorkerGroup `
                -CertificateDays 3650
        }

        TestScript = {
            return -not -not (Test-Path -Path HKLM:\SOFTWARE\Microsoft\HybridRunbookWorker)
        }
    }
} 

 



 

