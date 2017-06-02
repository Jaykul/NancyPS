function Start-NancyHost {
    # Starts the Nancy self-hosted server with the NancyPS ScriptModule... 
    [CmdletBinding(DefaultParameterSetName="Simple")]
    param(
        # The URL for Nancy to run on
        [Parameter(Position=0)]
        $Uri="http://localhost:8282",
 
        # If set, the /_Nancy/ diagnostics pages will be enabled (and protected by this password)
        [Alias("Password")]
        [string]$DiagnosticsPassword,
        
        # If set, UrlReservations will  be created automatically
        [Parameter(ParameterSetName="Simple")]
        [switch]$AutomaticUrlReservations,

        # For advanced configuration, you can set UrlReservations manually here
        [Parameter(ParameterSetName="ManualUrlReservations")]
        [Nancy.Hosting.Self.UrlReservations]$UrlReservations = @{
            CreateAutomatically = [bool]$AutomaticUrlReservations
        }, 

        # For advanced configuration, you can set anything you need to on the HostConfiguration
        # Note that UrlReservations are part of the HostConfiguration, so this overrides that
        [Parameter(ParameterSetName="ManualHostConfiguration")]
        [Nancy.Hosting.Self.HostConfiguration]$HostConfiguration = @{
            RewriteLocalhost = $true
            UrlReservations = $UrlReservations
        },

        # Enables tracing of requests for debugging purposes.
        # If you're having trouble figuring out why your handler isn't invoked, or why a view can't be found, turn this on, and set a DiagnosticsPassword, then visit /_Nancy/ on your hosted site... 
        [Parameter()]
        [switch]$EnableRequestTracing,

        # Make Urls, parameters, etc. case-sensitive.
        # This option is here for completeness sake only ;-)
        [Parameter()]
        [switch]$CaseSensitive,

        # Enable exception traces when there are errors 
        # If you use this on a public URL, you should leave this off
        # The majority of the time it's not useful, since the errors will be in the PowerShell script anyway
        [Parameter()]
        [switch]$EnableErrorTraces, 

        # If set, don't launch a browser or Write-Host the successs message
        [switch]$Quiet
    )

    begin { 
        [NancyPS.StaticBootstrapper]::DefaultRunspace = $Host.Runspace
    }

    end {
        [Nancy.StaticConfiguration]::EnableRequestTracing = $EnableRequestTracing
        [Nancy.StaticConfiguration]::DisableErrorTraces = !$EnableErrorTraces
        [Nancy.StaticConfiguration]::CaseSensitive = $CaseSensitive

        if(![string]::IsNullOrEmpty($DiagnosticsPassword)){
            [NancyPS.StaticBootstrapper]::DiagnosticsPassword = $DiagnosticsPassword
        }

        if(!(Get-NancyHander)){
            # If they call Start without having any handlers, let's at least add a base one
            Set-NancyHandler -Path "/" -Handler { "Welcome to Nancy" }
        }

        ${script:Nancy Host Configuration} = $HostConfiguration
        ${script:Nancy Uri} = $Uri

        ${script:Nancy Nancy Server} = [Nancy.Hosting.Self.NancyHost]::new(${script:Nancy Host Configuration}, ${script:Nancy Uri})
        ${script:Nancy Nancy Server}.Start();

        if(!$Quiet) {
        # Open it in the browser to prove it works
            Start-Process ${script:Nancy Uri}
            Write-Host "Nancy running on ${script:Nancy Uri}, call Stop-NancyHost to stop it"
        }
    }
}