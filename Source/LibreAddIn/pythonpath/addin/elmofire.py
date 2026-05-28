#*****************************************************
#  ElmoFire LibreOffice Add-In
#  Version 0.1.a
#  Released at 28.05.2026

#  Author: Alexander Torubarov
#  Contact: runfla@yandex.com

#  Filename: elmofire.py
#  Source Code: Python
#  Compatible: LibreOffice Calc x64 win10 26.2.3.2

#  Copyright (C) 2026 Alexander Torubarov
#  Licensed under the MIT License.
#  See the LICENSE file in the project root
#  or a copy available at https://opensource.org
#  for full license information.
#*****************************************************

import os
import sys
import ctypes
import uno
import unohelper
import locale
from addins import XElmoFire                      # addins is my unique identificator
from com.sun.star.sheet import XAddIn
from com.sun.star.lang import XLocalizable, XServiceName, Locale

class DataRec(ctypes.Structure):
    _pack_ = 1
    _fields_ = [
        ("DataType",  ctypes.c_int),        # 4 bytes
        ("AsSizeInt", ctypes.c_int64),      # 8 bytes
        ("AsDouble",  ctypes.c_double),     # 8 bytes
        ("AsPChar",   ctypes.c_void_p)      # 8 bytes pointer
    ]

lib = None

def fast_pack(args):
    """Flattens the guaranteed 2D Calc tuple and joins elements using 0x1F.
       Total check for any empty objects (None, empty tuples, empty strings)."""
    return b'\x1f'.join(
  #      b'""' if cell is None or not cell or str(cell).strip() == "" or str(cell) == "()" else
        b'""' if not cell else
        (
            f'{int(cell)}'.encode('utf-8') if isinstance(cell, float) and cell.is_integer() else
            f'{cell}'.encode('utf-8')
        ) if isinstance(cell, (int, float)) and not isinstance(cell, bool) else
        f'"{cell}"'.encode('utf-8')
        for row in args
        for cell in row
    )

def call_runfla(func_id, flat_args):
    global lib

    try:
        if lib is None:
            cx = uno.getComponentContext()
            pip = cx.getByName("/singletons/com.sun.star.deployment.PackageInformationProvider")
            oxt_url = pip.getPackageLocation("addin.elmofire")
            CURRENT_DIR = uno.fileUrlToSystemPath(oxt_url)

            if sys.platform == "win32":
                LIB_NAME = "elmofire64.dll"
            else:
                LIB_NAME = "elmofire64.so"

            LIB_PATH = os.path.join(CURRENT_DIR, LIB_NAME)

            if not os.path.exists(LIB_PATH):
                raise RuntimeError(f"Library not found at {LIB_PATH}")

            lib = ctypes.CDLL(LIB_PATH)

            lib.elmo_str_py.argtypes = [ctypes.c_char_p, ctypes.POINTER(DataRec)]
            lib.elmo_str_py.restype = ctypes.c_int

            lib.elmo_val_py.argtypes = [ctypes.c_char_p, ctypes.POINTER(DataRec)]
            lib.elmo_val_py.restype = ctypes.c_int

            lib.elmo_free_str.argtypes = [ctypes.c_char_p]
            lib.elmo_free_str.restype = ctypes.c_int

        # mapping function ID to the specific library method
        if func_id == 0:
            target_func = lib.elmo_str_py
        else:
            target_func = lib.elmo_val_py

        # fast byte buffer generation
        packed_bytes = fast_pack(flat_args)
        packed_data = ctypes.create_string_buffer(packed_bytes)

        # create structure locally in thread, not globally
        local_result = DataRec()

        # calling the function and passing a pointer to the structure
        target_func(packed_data, ctypes.byref(local_result))

        dtype = local_result.DataType

        if dtype == 1:
            return int(local_result.AsSizeInt)

        elif dtype == 2:
            return float(local_result.AsDouble)

        elif dtype == 3:
            ptr = local_result.AsPChar
            try:
                # direct memory reading
                result_str = ctypes.c_char_p(ptr).value.decode('utf-8')
            finally:
                # ensuring that a library crash won't close LibreCalc
                try:
                    lib.elmo_free_str(ptr)
                except Exception:
                    pass

            return result_str

        return ""

    except Exception as err:
        return f"ELMOFIRE ERROR: {str(err)}"

class ElmoFire(unohelper.Base, XElmoFire, XAddIn, XServiceName, XLocalizable):
    def __init__(self, ctx):
        self.ctx = ctx
        self.locale = Locale("en","US", "")

    def getServiceName(self):
        return "ElmoFire unit-aware scripting engine"

    def setLocale(self, locale):
        self.locale = locale

    def getLocale(self):
        return self.locale

    def getProgrammaticFuntionName(self, aDisplayName):
        return aDisplayName

    def getDisplayFunctionName(self, aProgrammaticName):
        return aProgrammaticName

    def getFunctionDescription(self , aProgrammaticName):
        if aProgrammaticName == "elmostr":
            return "Run Formula and returns a string with units"
        elif aProgrammaticName == "elmoval":
            return "Run Formula and returns a value without units"
        return ""

    def getArgumentDescription(self, aProgrammaticFunctionName, nArgument):
        return "odd: <variable>, even: <value>, <formula>"

    def getProgrammaticCategoryName(self, aProgrammaticFunctionName):
        return "Add-In"

    def getDisplayArgumentName(self, aProgrammaticFunctionName, nArgument):
        return "0"

    def elmostr(self, *args) -> str:
        return call_runfla(0, args)

    def elmoval(self, *args):
        return call_runfla(1, args)

