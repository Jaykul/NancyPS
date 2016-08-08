function Get-NancyRoot {
    #.Synopsis
    #   Get the root path for Nancy (used for view resolution)
    [CmdletBinding()]
    param()
    process {
        [NancyPS.StaticBootstrapper]::RootPath
    }
}