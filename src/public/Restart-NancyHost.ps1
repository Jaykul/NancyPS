function Restart-NancyHost {
#.Synopsis
#   Stop and Restart the Nancy self-hosted Server
[CmdletBinding()]
param()

    if(${script:Nancy Nancy Server}) {
        ${script:Nancy Nancy Server}.Stop()
        ${script:Nancy Nancy Server} = $null
    }

    if(($null -eq ${script:Nancy Host Configuration}) -or ($null -eq ${script:Nancy Uri})) {
        throw "There's no Host Configuration, you can't Restart-Nancy until after you start it. Try running:`nStart-Nancy -AutomaticUrlReservations"
    }

    ${script:Nancy Nancy Server} = New-Object -TypeName Nancy.Hosting.Self.NancyHost -ArgumentList ${script:Nancy Host Configuration}, ${script:Nancy Uri}
    ${script:Nancy Nancy Server}.Start();
}