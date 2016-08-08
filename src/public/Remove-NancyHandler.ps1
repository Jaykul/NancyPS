function Remove-NancyHandler {
    #.Synopsis
    #   Remove registered script handlers from NancyPS
    [CmdletBinding()]
    param(
        # The verb (Http Method) to remove a handler from
        [Parameter(Mandatory, ParameterSetName="Named")]
        [NancyPS.NancyMethod]$Verb,

        # The path to remove the handler from (must be the same as used to register the handler)
        [Parameter(Mandatory, ParameterSetName="Named")]
        [string]$Path,

        # If set, remove all handlers
        [Parameter(Mandatory, ParameterSetName="All")]
        [switch]$All
    )
    if($All) {
        [NancyPS.StaticBootstrapper]::Handlers.Clear()
    } else {
        [NancyPS.StaticBootstrapper]::Handlers[$Verb, $Path] = $null
    }
}