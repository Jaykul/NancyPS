function Get-NancyHandler {
    #.Synopsis
    #   Gets the script handlers registered for Nancy
    [CmdletBinding()]
    param(
        [NancyPS.NancyMethod]$Verb,
        [string]$Path = "*"
    )
    [NancyPS.StaticBootstrapper]::Handlers.GetEnumerator() | Where {
        ($null -eq $Verb -or $_.Verb -eq $Verb) -and ($_.Path -like $Path)
    } 
}