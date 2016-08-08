function Set-NancyHandler {
    #.Synopsis
    #   Sets a script handler for an HTTP method and request path
    #.Description
    #   Registers an HTTP method for a variable path to a ScriptBlock handler.  The handler has access to an $args dictionary defined by the Path, and $this NancyModule, including the request and context.
    #.Example
    #   Set-NancyHandler -Path "/" -Handler { "Hello World" }
    #
    #   A simple handler for the root of a site
    [CmdletBinding()]
    param(
        # The Verb (or Http Method) defaults to "Get"
        [Parameter()]
        [Alias("Method")]
        [NancyPS.NancyMethod]$Verb="Get",

        # The Path is the partial URL this handler is for.
        # Supports named variable parts like "/invoke/{noun}/{verb}"
        [Parameter(mandatory, Position="0")]
        [string]$Path,

        # The ScriptBlock to execute. Has access to $args from the path, plus the NancyModule $this
        [ScriptBlock]$Handler = {"Hello World"}
    )
    [NancyPS.StaticBootstrapper]::Handlers[$Verb, $Path] = $Handler
}