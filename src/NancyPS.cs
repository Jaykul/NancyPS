namespace NancyPS
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Linq;
    using System.Management.Automation;
    using System.Management.Automation.Runspaces;

    using Nancy;
    using Nancy.Bootstrapper;
    using Nancy.Diagnostics;
    using System.IO;
    using Nancy.Conventions;
    using System.Security;

    public enum NancyMethod
    {
        DELETE, GET, HEAD, OPTIONS, POST, PUT, PATCH
    }


    public class ScriptModule : NancyModule
    {
        public ScriptModule()
        {
            // Console.WriteLine("Set Runspace");
            Runspace.DefaultRunspace = StaticBootstrapper.DefaultRunspace;

            foreach (var handler in StaticBootstrapper.Handlers)
            {
                switch (handler.Verb)
                {
                    case NancyMethod.GET:
                        Get[handler.Path] = args => handler.Invoke(this, args);
                        break;

                    case NancyMethod.PUT:
                        Put[handler.Path] = args => handler.Invoke(this, args);
                        break;

                    case NancyMethod.POST:
                        Post[handler.Path] = args => handler.Invoke(this, args);
                        break;

                    case NancyMethod.DELETE:
                        Delete[handler.Path] = args => handler.Invoke(this, args);
                        break;

                    case NancyMethod.HEAD:
                        StaticConfiguration.EnableHeadRouting = true;
                        Head[handler.Path] = args => handler.Invoke(this, args);
                        break;

                    case NancyMethod.OPTIONS:
                        Options[handler.Path] = args => handler.Invoke(this, args);
                        break;

                    case NancyMethod.PATCH:
                        Patch[handler.Path] = args => handler.Invoke(this, args);
                        break;
                    default:
                        break;
                }
            }
        }
    }

    public struct ScriptHandler
    {
        public NancyMethod Verb;
        public string Path;
        public ScriptBlock Script;

        public dynamic Invoke(NancyModule instance, dynamic args)
        {
            // Console.WriteLine("Invoking {" + Script + "}");
            var variables = new List<PSVariable>(new[] { new PSVariable("this", instance) });
            IEnumerable<PSObject> output = Script.InvokeWithContext(null, variables, args);
            
            var stringResult = "";
            foreach (var result in output)
            {
                if (result.ImmediateBaseObject is Response)
                {
                    return result.ImmediateBaseObject;
                }
                else
                {
                    // Anything but an actual response object we convert to string.
                    stringResult += result.ToString();
                }
            }

            if (stringResult.Length > 0)
            {
                return stringResult;
            }
            else
            {
                return "Script has no output!";
            }
        }
    }

    public class HandlerCollection : IEnumerable<ScriptHandler>
    {
        internal static Dictionary<string, ScriptHandler> Handlers = new Dictionary<string, ScriptHandler>();

        public ScriptBlock this[NancyMethod verb, string path]
        {
            get
            {
                return Handlers[string.Format("{0}:{1}", verb, path)].Script;
            }
            set
            {
                if (null == value)
                {
                    Handlers.Remove(string.Format("{0}:{1}", verb, path));
                }
                else
                {
                    Handlers[string.Format("{0}:{1}", verb, path)] = new ScriptHandler()
                    {
                        Verb = verb,
                        Path = path,
                        Script = value
                    };
                }
            }
        }

        public void Clear()
        {
            Handlers.Clear();
        }

        public IEnumerator<ScriptHandler> GetEnumerator()
        {
            return Handlers.Values.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return Handlers.Values.GetEnumerator();
        }
    }

    public class StaticRootPathProvider : IRootPathProvider
    {
        public string GetRootPath()
        {
            return StaticBootstrapper.RootPath;
        }
    }

    public class StaticBootstrapper : DefaultNancyBootstrapper
    {
        public static HandlerCollection Handlers = new HandlerCollection();

        public static Runspace DefaultRunspace;

        public static string RootPath;

        public static string DiagnosticsPassword;

        public static Dictionary<string, string> StaticFolders = new Dictionary<string, string>();
        public static Dictionary<string, string> StaticFiles = new Dictionary<string, string>();

        protected override DiagnosticsConfiguration DiagnosticsConfiguration
        {
            get { return new DiagnosticsConfiguration { Password = DiagnosticsPassword }; }
        }

        protected override IRootPathProvider RootPathProvider
        {
            get { return new StaticRootPathProvider(); }
        }
        protected override void ConfigureConventions(NancyConventions nancyConventions)
        {
            base.ConfigureConventions(nancyConventions);

            foreach (var fs in StaticFolders)
            {
                nancyConventions.StaticContentsConventions.AddDirectory(fs.Key, fs.Value);
            }
            foreach (var fs in StaticFiles)
            {
                nancyConventions.StaticContentsConventions.AddFile(fs.Key, fs.Value);
            }
        }
    }
}