Attribute VB_Name = "ElmoFire"
Option Explicit

' --- Windows API for Memory and Libraries ---
Private Declare PtrSafe Function LoadLibrary Lib "kernel32" Alias "LoadLibraryA" (ByVal lpLibFileName As String) As LongPtr
Private Declare PtrSafe Function GetModuleHandle Lib "kernel32" Alias "GetModuleHandleA" (ByVal lpModuleName As String) As LongPtr
Private Declare PtrSafe Function lstrcpyA Lib "kernel32" (ByVal lpString1 As String, ByVal lpString2 As LongPtr) As LongPtr
Private Declare PtrSafe Function lstrlenA Lib "kernel32" (ByVal lpString As LongPtr) As Long
Private Declare PtrSafe Function CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (ByRef Destination As Any, ByRef Source As Any, ByVal length As Long) As Long

' --- ElmoFire DLL functions ---
' Pass all parameters strictly as numeric memory pointers (ByVal LongPtr)
Private Declare PtrSafe Function elmo_str_vba Lib "elmofire64.dll" (ByVal pStr As LongPtr, ByVal pStruct As LongPtr) As Long
Private Declare PtrSafe Function elmo_val_vba Lib "elmofire64.dll" (ByVal pStr As LongPtr, ByVal pStruct As LongPtr) As Long
Private Declare PtrSafe Function elmo_free_vba Lib "elmofire64.dll" (ByVal ptr As LongPtr) As Long

Private hLibModule As LongPtr

Private Function DllLoader() As Boolean
    If hLibModule <> 0 Then
        DllLoader = True
        Exit Function
    End If
    hLibModule = GetModuleHandle("elmofire64.dll")
    If hLibModule = 0 Then
        Dim dllPath As String
        dllPath = ThisWorkbook.Path & "\elmofire64.dll"
        If Dir(dllPath) <> "" Then hLibModule = LoadLibrary(dllPath)
    End If
    DllLoader = (hLibModule <> 0)
End Function

' Packing arguments using 0x1F delimiter (as fast_pack)
Private Function FastPack(ByVal args As Variant) As String
    Dim result As String
    Dim i As Long
    Dim cellStr As String
    
    result = ""
    
    ' Directly iterating through a flat list of arguments passed to the formula
    For i = LBound(args) To UBound(args)
        cellStr = ProcessCell(args(i))
        
        ' Concatenating arguments strictly using the 0x1F delimiter
        If result = "" Then
            result = cellStr
        Else
            result = result & Chr(&H1F) & cellStr
        End If
    Next i
    
    FastPack = result
End Function

' Universal element formatting: numbers are unquoted, everything else is quoted
Private Function ProcessCell(ByVal cell As Variant) As String
    ' 1. Empty, Null, or blank cells are strictly handled as ""
    If IsEmpty(cell) Or IsNull(cell) Or CStr(cell) = "" Then
        ProcessCell = """"""
        Exit Function
    End If
    
    ' 2. Check cell data type using VarType
    ' Numeric: vbInteger=2, vbLong=3, vbSingle=4, vbDouble=5, vbCurrency=6, vbLongLong=20
    Select Case VarType(cell)
        Case 2, 3, 4, 5, 6, 20
            ' Value is NUMERIC -> passed unquoted
            ' Using Str$ completely bypasses regional settings, always producing a dot "." decimal separator
            Dim numStr As String
            numStr = Trim$(Str$(cell))

            ' Strip trailing dot if Str$ left it for integer-like values (e.g. "12.")
            If Right$(numStr, 1) = "." Then
                ProcessCell = Left$(numStr, Len(numStr) - 1)
            Else
                ProcessCell = numStr
            End If
            
        Case Else
            ' Strings (vbString=8), booleans (vbBoolean=11), etc. -> STRICTLY wrapped in quotes
            ' Double internal quotes
            Dim cleanText As String
            cleanText = Replace(CStr(cell), """", """""")
            ProcessCell = """" & cleanText & """"
    End Select
End Function

' Extracting ANSI/UTF-8 string from PAnsiChar pointer
Private Function StringFromPtr(ByVal ptr As LongPtr) As String
    Dim length As Long, buffer As String
    length = lstrlenA(ptr)
    If length > 0 Then
        buffer = Space$(length)
        lstrcpyA buffer, ptr
        ' Uncomment the following line if the DLL returns UTF-8:
        ' StringFromPtr = StrConv(buffer, vbUnicode)
        StringFromPtr = buffer
    End If
End Function

' Unified call dispatcher
Private Function CallRunfla(ByVal funcId As Long, ByVal args As Variant) As Variant
    On Error GoTo ErrorHandler

    If Not DllLoader() Then
        CallRunfla = "ElmoFire Add-In ERROR: Library elmofire64.dll not found."
        Exit Function
    End If

    Dim packedStr As String
    packedStr = FastPack(args)
    
    ' Convert the incoming string to a null-terminated ANSI string (PAnsiChar)
    Dim ansiBytes() As Byte
    ansiBytes = StrConv(packedStr & Chr(0), vbFromUnicode)
    
    ' Creating a fully packed buffer (Simulating TDataRec = packed record)
    ' DataType(4) + AsSizeInt(8) + AsDouble(8) + AsPChar(8) = 28 bytes
    Dim rawBuffer(0 To 27) As Byte
    Dim status As Long
    
    ' Calling the DLL function, passing pointers to the start of arrays in memory
    If funcId = 0 Then
        status = elmo_str_vba(VarPtr(ansiBytes(0)), VarPtr(rawBuffer(0)))
    Else
        status = elmo_val_vba(VarPtr(ansiBytes(0)), VarPtr(rawBuffer(0)))
    End If
    
    ' Extracting DataType byte-by-byte from the first 4 bytes of the buffer (indices 0–3)
    Dim DataType As Long
    CopyMemory DataType, rawBuffer(0), 4
    
    ' Decoding the response based on DataType
    Select Case DataType
        Case 1
            ' Extracting 8-byte Int64 integer (indices 4–11)
            Dim AsSizeInt As LongLong
            CopyMemory AsSizeInt, rawBuffer(4), 8
            CallRunfla = CLngLng(AsSizeInt)
            
        Case 2
            ' Extracting 8-byte Double float (indices 12–19)
            Dim AsDouble As Double
            CopyMemory AsDouble, rawBuffer(12), 8
            CallRunfla = CDbl(AsDouble)
            
        Case 3
            ' Extracting 8-byte PAnsiChar pointer (indices 20–27)
            Dim AsPChar As LongPtr
            CopyMemory AsPChar, rawBuffer(20), 8
            
            If AsPChar <> 0 Then
                CallRunfla = StringFromPtr(AsPChar)
                ' Safely calling memory cleanup in the DLL
                On Error Resume Next
                elmo_free_vba AsPChar
                On Error GoTo ErrorHandler
            Else
                CallRunfla = ""
            End If
            
    End Select
    Exit Function

ErrorHandler:
    CallRunfla = "ElmoFire Add-In ERROR: " & Err.Description
End Function

' --- Excel User-Defined Functions ---

Public Function ELMOSTR(ParamArray args() As Variant) As Variant
    ELMOSTR = CallRunfla(0, args)
End Function

Public Function ELMOVAL(ParamArray args() As Variant) As Variant
    ELMOVAL = CallRunfla(1, args)
End Function
