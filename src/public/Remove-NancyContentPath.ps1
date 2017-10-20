function Remove-NancyContentPath {
    param(
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="ByRelative")]
        [Alias("Path")]
        [string]$RelativePath,

        [Parameter(Mandatory, ParameterSetName="All")]
        [switch]$All
    )
    if($All) {
        [NancyPS.StaticBootstrapper]::StaticPaths.Clear()
    } elseif($RelativePath) {
        [NancyPS.StaticBootstrapper]::StaticPaths.Remove($RelativePath)
    }
}