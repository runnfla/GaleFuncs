import uno
import unohelper

def createInstance( ctx ):
    import addin.elmofire
    return addin.elmofire.ElmoFire( ctx )

# pythonloader looks for a static g_ImplementationHelper variable
g_ImplementationHelper = unohelper.ImplementationHelper()
g_ImplementationHelper.addImplementation( \
	createInstance,"addin.ElmoFire",
        ("com.sun.star.sheet.AddIn",),)
