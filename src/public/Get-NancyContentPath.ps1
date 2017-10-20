function Get-NancyContentPath {
    #.Synopsis
    #   List the configured static files and folders
    process {
        [NancyPS.StaticBootstrapper]::StaticPaths.GetEnumerator() | Select @{ Name = "RelativePath"; Expr = { $_.Key } }, @{ Name = "Path"; Expr = { $_.Value } }
    }
}
