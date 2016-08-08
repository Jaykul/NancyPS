function Stop-NancyHost {
    # Stop the Nancy self-hosted server
    [CmdletBinding()]
    param()    
    if(${script:Nancy Nancy Server}) {
        ${script:Nancy Nancy Server}.Stop()
        ${script:Nancy Nancy Server} = $null
    }
}