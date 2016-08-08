function Set-NancyContentPath {
    #.Synopsis
    #   Add files or folders to the static paths
    #.Example
    #   Set-NancyRoot ./sample
    #   Set-NancyContentPath "/" "./sample/static"
    #
    #   This example shows how you can map the root of your new "website" to a "static" folder inside your site root.
    #.Example 
    #   Get-ChildItem ./sample/static/*.html, ./sample/static/*.png | Set-NancyContentPath -WebPath { $_.Name }
    #
    #   A more complex example maps only html and png files into the root so they're accessible on the web server.
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName, Position=0)]
        [string]$WebPath,

        [Parameter(ValueFromPipeline, Position=1)]
        [Alias("PSPath")]
        [string]$Path
    )
    begin {
        if(![NancyPS.StaticBootstrapper]::RootPath) {
            throw "Static paths must be within the RootPath. If you haven't Set-NancyRoot yet, set that first."
        }
    }
    process {
        $FullPath = Resolve-Path $Path -ErrorAction Stop

        Push-Location ([NancyPS.StaticBootstrapper]::RootPath)

        if($RelativePath = Resolve-Path $FullPath -Relative) {

            if(Test-Path $FullPath -Type Container) {
                [NancyPS.StaticBootstrapper]::StaticFolders[$WebPath] = $RelativePath
            } else {
                [NancyPS.StaticBootstrapper]::StaticFiles[$WebPath] = $RelativePath
            }
        }

        Pop-Location
    }
}

function Get-NancyContentPath {
    #.Synopsis
    #   List the configured static files and folders 
    process {
        [NancyPS.StaticBootstrapper]::StaticPaths.GetEnumerator() | Select @{ Name = "RelativePath"; Expr = { $_.Key } }, @{ Name = "Path"; Expr = { $_.Value } }
    }
}

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