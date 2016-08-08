# using namespace Nancy
# using namespace Nancy.Hosting.Self
if(!$NancyPSRoot) {
    $NancyPSRoot = $PSScriptRoot
}

. .\private\_classes.ps1
. .\public\Get-NancyHandler.ps1
. .\public\Get-NancyRoot.ps1
. .\public\NancyContentPath.ps1
. .\public\Remove-NancyHandler.ps1
. .\public\Restart-NancyHost.ps1
. .\public\Set-NancyHandler.ps1
. .\public\Set-NancyRoot.ps1
. .\public\Start-NancyHost.ps1
. .\public\Stop-NancyHost.ps1
