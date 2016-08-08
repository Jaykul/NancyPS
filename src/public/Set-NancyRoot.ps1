function Set-NancyRoot {
    #.Synopsis
    #   Set the root path for Nancy (used for view resolution)
    [CmdletBinding()]
    param(
        # The actual FileSystem folder 
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("PSPath")]
        [string]$Path
    )
    process {
        $ResolvedPath = Resolve-Path $Path -PathType Container -ErrorAction Stop
        if($ResolvedPath.Provider.Name -ne "FileSystem")
        {
            throw "The Nancy root must be a folder path that exists on the FileSystem"
        }

        [NancyPS.StaticBootstrapper]::RootPath = $ResolvedPath.Path
    }
}