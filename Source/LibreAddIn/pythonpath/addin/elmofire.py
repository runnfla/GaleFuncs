import unohelper
from stormray import XElmoFire
from com.sun.star.sheet import XAddIn
from com.sun.star.lang import XLocalizable, XServiceName, Locale

class ElmoFire( unohelper.Base, XElmoFire,  XAddIn, XServiceName ):
    def __init__( self, ctx ):
        self.ctx = ctx
        self.locale = Locale("ja","JP", "" )

    def getServiceName( self ):
        return "ElmoFire"

    def setLocale( self, locale ):
        self.locale = locale

    def getLocale( self ):
        return self.locale

    def getProgrammaticFuntionName( self, aDisplayName ):
        return aDisplayName

    def getDisplayFunctionName( self, aProgrammaticName ):
        return aProgrammaticName

    def getFunctionDescription( self , aProgrammaticName ):
        if aProgrammaticName == "elmostr":
            return "Обработка строковых выражений в скриптовом движке Elmo"
        elif aProgrammaticName == "elmoval":
            return "Вычисление физических величин с автоматическим контролем размерностей"
        return ""

    def getArgumentDescription( self, aProgrammaticFunctionName, nArgument ):
        if aProgrammaticFunctionName == "elmostr":
            if nArgument == 0: return "Строка со скриптом или текстом для обработки"

        elif aProgrammaticFunctionName == "elmoval":
            if nArgument == 0: return "Математическое или физическое выражение"
            if nArgument == 1: return "Целевая единица измерения (например, m/s, kg)"
        return ""
    
    def getProgrammaticCategoryName( self, aProgrammaticFunctionName ):
        return "Add-In"

    def getDisplayArgumentName( self, aProgrammaticFunctionName, nArgument ):
        if aProgrammaticFunctionName == "elmostr":
            if nArgument == 0: return "ТекстСкрипта"

        elif aProgrammaticFunctionName == "elmoval":
            if nArgument == 0: return "Выражение"
            if nArgument == 1: return "ЕдиницаИзмерения"
        return ""

    def elmostr(self, *args) -> str:
        # Обрабатываем случай, когда аргументов нет
        if not args:
            return ""

        # Преобразуем все аргументы в строки и фильтруем None
        string_parts = []
        for value in args:
            if value is None:
                string_parts.append("ПУСТО")
            else:
                string_parts.append(str(value))

        # Конкатенируем все строки через пробел
        return " ".join(string_parts)

    def elmoval(self, *args) -> str:
        # Обрабатываем случай, когда аргументов нет
        if not args:
            return ""

        # Преобразуем все аргументы в строки и фильтруем None
        string_parts = []
        for value in args:
            if value is None:
                string_parts.append("ПУСТО")
            else:
                string_parts.append(str(value))

        # Конкатенируем все строки через пробел
        return " ".join(string_parts)

