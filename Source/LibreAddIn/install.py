import sys
import uno

def createInstance(ctx):
#    if sys.platform != "win32" and not sys.platform.startswith("linux"):
#        raise RuntimeError(f"GaleFuncs Add-In ERROR: Operating system {sys.platform} is not supported")

#    if sys.maxsize <= 2**32:
#        raise RuntimeError("GaleFuncs Add-In ERROR: Only 64-bit systems are supported")

    import galefuncs
    return galefuncs.GaleFuncs(ctx)

# Initialize the helper only AFTER all functions are declared.
# In some LibreOffice builds, importing unohelper is strictly required before invocation.
# Alternatively: before the call / before execution.

import unohelper

g_ImplementationHelper = unohelper.ImplementationHelper()
g_ImplementationHelper.addImplementation(
    createInstance,
    "addin.runfla.galefuncs",
    ("com.sun.star.sheet.AddIn",),
)
