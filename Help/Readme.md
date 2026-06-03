# ElmoFire Add-In

The ElmoFire Add-In is an extension for LibreOffice Calc and Microsoft Excel powered by the [**RunFormula**](https://github.com/runnfla/RunFormula) scripting engine. It enables the evaluation of mathematical expressions and formulas with built-in physical unit awareness, completely eliminating the need to create macros. Expressions and short scripts are written directly inside the spreadsheet cells. The RunFormula syntax is supported in its entirety.

ElmoFire allows you to, among other things:
* **Perform computations** with complex numbers and intervals.
* **Validate physical dimensions** at every stage of the calculation.
* **Automatically determine** the unit of measurement for the final result.
* **Convert values seamlessly** from one unit system to another on the fly.


Как установить ElmoFire.

Поддерживаются LibreOffice Calc x64 для операционных систем MS Windows и Linux и
MS Excel x64 для Windows.

Установка в LibreOffice Calc:
1. Загрузите соответсвующий .oxt файл из каталога Add-In
2. В Меню выберите Tools --> Extensions
3. В открывшемся окне нажмите кнопку Add
4. Укажите путь к скачанному файлу `ElmoFire.oxt` и нажмите Открыть
5. Перезапустите LibreOffice Calc, чтобы изменения вступили в силу

Установка в Microsoft Excel:
1. Скачайте архив ElmoFire Excel.zip со страницы [Releases](ссылка_на_рел
2. Распакуйте его содержимое в любую удобную и постоянную папку на вашем компьютере
(например, `C:\Addins\ElmoFire\`)
3. Важно: не удаляйте и не перемещайте файлы .xlam и .dll после установки, иначе
надстройка перестанет работать
4. Запустите MS Excel
5. На Ленте нажмите вкладку Файл, выберите пункт Параметры (в самом низу левой панели)
6. В открывшемся окне выберите раздел Надстройки
7. В нижней части окна в выпадающем списке «Управление» выберите **Надстройки Excel** и нажмите кнопку **Перейти...**.
   * В открывшемся окне нажмите кнопку **Обзор...** и укажите путь к распакованному файлу `ElmoFire.xlam`.
   * Убедитесь, что в списке появилась надстройка `ElmoFire` и напротив нее стоит галочка. Нажмите **OK**.

