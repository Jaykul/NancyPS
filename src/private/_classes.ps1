if(!$NancyPSRoot) {
    $NancyPSRoot = $PSScriptRoot
}

Add-Type -Path $NancyPSRoot\NancyPS.cs -ReferencedAssemblies Microsoft.CSharp, ([Nancy.NancyModule].Assembly)
