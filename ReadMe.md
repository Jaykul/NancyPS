NancyPS was [Nancy](https://github.com/NancyFx/Nancy), in PowerShell

My goal was to produce an easy to use PowerShell layer on top of Nancy so that I can spin up micro-web-services in PowerShell in my dev and test environments.

### Nancy itself is basically _done_

In the new ASP.NET Core, the main concepts of Nancy were built directly into ASP.NET and the Nancy team felt they had, in some sense won -- there was no longer a real need to release a .NeT Core version of Nancy. One core contributor has created an offshot: [Carter](https://github.com/CarterCommunity/Carter) which has some of the functionality ... but in any case, without a release Nancy on .NET Standard, this module is effectively stuck on Windows PowerShell.

### Please try [Polaris](https://github.com/PowerShell/Polaris)

Since the goal of Nancy was *never* to make a something that would scale, nor to make a management tool for end users, nor even to manage hundreds of machines or services, my personal interest was always limited -- I build web apps in C#, not in PowerShell. This project is therefore archived/abandoned, and I have to recommend that if you want something like this, you try Polaris, which is built on .NET Standard directly, without the need for Nancy, now that they've rearchitected the underlying bits.



### NancyPS is self-hosting in your current PowerShell runspace. 

This means that it has *one* runspace. It is, effectively, single-threaded; it processes each request in the PowerShell runspace that it's started from. The reason I chose to do it this way is that it means my micro services have access to variables and functions (and providers) and modules that were already loaded there, and it populates the $Errors, etc. Unlike [flancy](https://github.com/toenuff/flancy), it doesn't create a new runspace for each request, so it's not stateles, and won't scale very far.  However, the handlers/configuration can be modified at any time, and a simple restart brings the latest configuration online...

## The super-duper-happy-path:

To borrow the phrase from the Nancy community, the goal here is to make something that "just works" and is "easily customizable" with a low degree of code or friction. Here's what "Hello World" looks like in NancyPS:

```posh
Set-NancyHandler -Path "/" -Handler { "Hello World" }

Start-NancyHost -AutomaticUrlReservations
```

Of course, that's so simple it's really not useful, so let's look at doing something a little more impressive, and more particularly, useful to me. 

I generate several websites with my [PowerSite](https://github.com/Jaykul/PowerSite) module to static files, and the browser view of web pages doesn't always work right when you open them from disk, so I want to host them in a web server.  I also generate reports with my [HtmlReport](https://github.com/Jaykul/HtmlReport) module, and sometimes I just want to host them for co-workers to view, or even run on demand. 

### Serving static content from a folder... 

Hosting static files in Nancy is as simple as calling a cmdlet, but first you need to have your Nancy site in a folder, with a _sub-folder_ for your static content. As an example, we'll use `sample` as the root of our website, and the path `sample/static` to put our web-visivle files in:

```posh
# Remember, static content folders must be inside your root:
Set-NancyRoot ./sample
Set-NancyContentPath "./sample/static" -WebPath "/"

# For bonus points, automatically redirect to the index:
Set-NancyHandler -Path "/" -Handler {
    [Nancy.Responses.RedirectResponse]::new( "/index.html" )
}

# And now restart the web host
Restart-NancyHost
```

### Writing script handlers

As we've already seen in both the examples above, PowerShell script handlers are easy with NancyPS. To make them more powerful, you need to be able to take parameters.

The easiest way to do that in Nancy is the basic REST api method where the last parts of the URL are actually variable. You can simply tag the variable part of a path with curly braces like `/hello/{name}` ... and `name` will show up as a named property of `$args`. You can also handle `?var=value` query syntax via `$this.Request.Query` ...

Within your script handler you have access to the full session scope, and the [NancyModule](https://github.com/NancyFx/Nancy/blob/1.x-WorkingBranch/src/Nancy/NancyModule.cs) (`$this`).  The module includes properties for the [Context](https://github.com/NancyFx/Nancy/blob/1.x-WorkingBranch/src/Nancy/NancyContext.cs), as well as the [Request](https://github.com/NancyFx/Nancy/blob/1.x-WorkingBranch/src/Nancy/Request.cs) and [Response](https://github.com/NancyFx/Nancy/blob/1.x-WorkingBranch/src/Nancy/DefaultResponseFormatter.cs). 

```posh
Set-NancyHandler -Path "/hello/{name}" -Handler { 
    [PSCustomObject]@{
        From = $args.name.ToString()
        Greeting = "Hello $($args.name), $($this.Request.Query.message)"
    } | ConvertTo-Json
}

Restart-NancyHost

# The URL should stay the same, so this should trigger our handler:
Invoke-RestMethod "http://localhost:8282/hello/Jaykul?message=How are you?"
```

Note: if you start copying examples from Nancy blogs, there's something you need to know. As with most modern .Net projects, a lot of the Nancy API is exposed as static extension methods. Unfortunately, PowerShell [doesn't yet support extension methods (vote!)](https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/11087607-powershell-should-support-net-extension-methods). 


### Future work

Because of the extension methods, it's harder to work with some of Nancy's core objects than it needs to be. The C# redirect handler:

```csharp
Request.Response.AsRedirect("~/index.html");

```

becomes:

```posh
[Nancy.FormatterExtensions]::AsRedirect( $this.Request.Response, "~/index.html", "SeeOther")
```

We _can_ patch over those rough spots with PowerShell's extensible type system or with helper functions, as the need arises, but this represents extra work that shouldn't be necessary in a modern .Net language.

Based on the [issues that flancy has had](https://github.com/toenuff/flancy/issues), I suspect that some of the first questions are going to be about making this work with Nancy 2.0 so it will run on .Net Core and Nano (and Windows containers), and about integrating authentication. 

Feel free to file issues so we can build a backlog, and to 
