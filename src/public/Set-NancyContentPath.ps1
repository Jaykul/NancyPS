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
