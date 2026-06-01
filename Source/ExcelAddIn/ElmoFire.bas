Attribute VB_Name = "ElmoFire"
Option Explicit

' --- Окна Windows API для работы с памятью и библиотеками ---
Private Declare PtrSafe Function LoadLibrary Lib "kernel32" Alias "LoadLibraryA" (ByVal lpLibFileName As String) As LongPtr
Private Declare PtrSafe Function GetModuleHandle Lib "kernel32" Alias "GetModuleHandleA" (ByVal lpModuleName As String) As LongPtr
Private Declare PtrSafe Function lstrcpyA Lib "kernel32" (ByVal lpString1 As String, ByVal lpString2 As LongPtr) As LongPtr
Private Declare PtrSafe Function lstrlenA Lib "kernel32" (ByVal lpString As LongPtr) As Long
Private Declare PtrSafe Function CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (ByRef Destination As Any, ByRef Source As Any, ByVal Length As Long) As Long

' --- Объявление функций вашей FreePascal/Delphi DLL ---
' Передаем все параметры строго как числовые указатели памяти (ByVal LongPtr)
Private Declare PtrSafe Function elmo_str_vba Lib "elmofire64.dll" (ByVal pStr As LongPtr, ByVal pStruct As LongPtr) As Long
Private Declare PtrSafe Function elmo_val_vba Lib "elmofire64.dll" (ByVal pStr As LongPtr, ByVal pStruct As LongPtr) As Long
Private Declare PtrSafe Function elmo_free_vba Lib "elmofire64.dll" (ByVal ptr As LongPtr) As Long

Private hLibModule As LongPtr

' Проверка и динамическая загрузка DLL из папки надстройки
Private Function EnsureDllLoaded() As Boolean
    If hLibModule <> 0 Then
        EnsureDllLoaded = True
        Exit Function
    End If
    hLibModule = GetModuleHandle("elmofire64.dll")
    If hLibModule = 0 Then
        Dim dllPath As String
        dllPath = ThisWorkbook.Path & "\elmofire64.dll"
        If Dir(dllPath) <> "" Then hLibModule = LoadLibrary(dllPath)
    End If
    EnsureDllLoaded = (hLibModule <> 0)
End Function

' Упаковка аргументов через разделитель 0x1F (Аналог fast_pack)
' --- Настоящий и строгий аналог функции fast_pack на VBA (без диапазонов) ---
Private Function FastPack(ByVal Args As Variant) As String
    Dim result As String
    Dim i As Long
    Dim cellStr As String
    
    result = ""
    
    ' Напрямую обходим плоский список аргументов, переданных в формулу
    For i = LBound(Args) To UBound(Args)
        cellStr = ProcessCell(Args(i))
        
        ' Склеиваем аргументы строго через разделитель 0x1F
        If result = "" Then
            result = cellStr
        Else
            result = result & Chr(&H1F) & cellStr
        End If
    Next i
    
    FastPack = result
End Function

' Универсальное форматирование элемента: числа — без кавычек, всё остальное — в кавычках
Private Function ProcessCell(ByVal cell As Variant) As String
    ' 1. Обработка пустых ячеек (Empty, Null или пустая строка) -> строго ""
    If IsEmpty(cell) Or IsNull(cell) Or CStr(cell) = "" Then
        ProcessCell = """"""
        Exit Function
    End If
    
    ' 2. Проверка типа данных ячейки через VarType
    ' Числовые типы: vbInteger=2, vbLong=3, vbSingle=4, vbDouble=5, vbCurrency=6, vbLongLong=20
    Select Case VarType(cell)
        Case 2, 3, 4, 5, 6, 20
            ' Это ЧИСЛО -> передается без кавычек
            If CLngLng(cell) = cell Then
                ' Для целых чисел отбрасываем дробную часть
                ProcessCell = CStr(CLngLng(cell))
            Else
                ' Для дробных чисел заменяем локальную запятую на точку
                ProcessCell = Replace(CStr(cell), ",", ".")
            End If
            
        Case Else
            ' Строки (vbString=8), логические (vbBoolean=11) и прочее -> СТРОГО в кавычки спереди и сзади
            ' Удваиваем внутренние кавычки, чтобы не ломать парсер вашей DLL
            Dim cleanText As String
            cleanText = Replace(CStr(cell), """", """""")
            ProcessCell = """" & cleanText & """"
    End Select
End Function

' Чтение ANSI/UTF-8 строки из указателя PAnsiChar
Private Function StringFromPtr(ByVal ptr As LongPtr) As String
    Dim length As Long, buffer As String
    length = lstrlenA(ptr)
    If length > 0 Then
        buffer = Space$(length)
        lstrcpyA buffer, ptr
        ' Раскомментируйте строку ниже, если ваша DLL возвращает UTF-8:
        ' StringFromPtr = StrConv(buffer, vbUnicode)
        StringFromPtr = buffer
    End If
End Function

' Единый диспетчер вызовов
Private Function CallRunfla(ByVal funcId As Long, ByVal Args As Variant) As Variant
    On Error GoTo ErrorHandler

    If Not EnsureDllLoaded() Then
        CallRunfla = "ElmoFire Add-In ERROR: Library elmofire64.dll not found."
        Exit Function
    End If

    Dim packedStr As String
    packedStr = FastPack(Args)
    
    ' Преобразуем входящую строку в ANSI-строку (PAnsiChar) с нулем на конце
    Dim ansiBytes() As Byte
    ansiBytes = StrConv(packedStr & Chr(0), vbFromUnicode)
    
    ' СОЗДАЕМ ПОЛНОСТЬЮ УПАКОВАННЫЙ БУФЕР (Имитация TDataRec = packed record)
    ' DataType(4) + AsSizeInt(8) + AsDouble(8) + AsPChar(8) = ровно 28 байт
    Dim rawBuffer(0 To 27) As Byte
    Dim status As Long
    
    ' Вызов функции DLL. Передаем указатели на начало массивов в памяти
    If funcId = 0 Then
        status = elmo_str_vba(VarPtr(ansiBytes(0)), VarPtr(rawBuffer(0)))
    Else
        status = elmo_val_vba(VarPtr(ansiBytes(0)), VarPtr(rawBuffer(0)))
    End If
    
    ' Побайтово извлекаем DataType из первых 4 байт буфера (индексы 0-3)
    Dim DataType As Long
    CopyMemory DataType, rawBuffer(0), 4
    
    ' Разбираем ответ на основе DataType
    Select Case DataType
        Case 1
            ' Извлекаем 8-байтное целое Int64 (индексы 4-11)
            Dim AsSizeInt As LongLong
            CopyMemory AsSizeInt, rawBuffer(4), 8
            CallRunfla = CLngLng(AsSizeInt)
            
        Case 2
            ' Извлекаем 8-байтное число с плавающей точкой Double (индексы 12-19)
            Dim AsDouble As Double
            CopyMemory AsDouble, rawBuffer(12), 8
            CallRunfla = CDbl(AsDouble)
            
        Case 3
            ' Извлекаем 8-байтный указатель PAnsiChar (индексы 20-27)
            Dim AsPChar As LongPtr
            CopyMemory AsPChar, rawBuffer(20), 8
            
            If AsPChar <> 0 Then
                CallRunfla = StringFromPtr(AsPChar)
                ' Безопасно вызываем очистку памяти в DLL
                On Error Resume Next
                elmo_free_vba AsPChar
                On Error GoTo ErrorHandler
            Else
                CallRunfla = ""
            End If
            
        Case Else
            CallRunfla = "Error: Unknown DataType (" & DataType & ")"
    End Select
    Exit Function

ErrorHandler:
    CallRunfla = "ElmoFire Add-In ERROR: " & Err.Description
End Function

' --- Пользовательские функции для листов Excel ---

Public Function ELMOSTR(ParamArray args() As Variant) As Variant
    ELMOSTR = CallRunfla(0, args)
End Function

Public Function ELMOVAL(ParamArray args() As Variant) As Variant
    ELMOVAL = CallRunfla(1, args)
End Function