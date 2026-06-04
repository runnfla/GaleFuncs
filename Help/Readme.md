# ElmoFire Add-In

The ElmoFire Add-In is an extension for LibreOffice Calc and Microsoft Excel powered by the [RunFormula](https://github.com/runnfla/RunFormula) scripting engine. It allows you to evaluate mathematical expressions and formulas with physical unit awareness, completely eliminating the need to create macros. Expressions and short scripts are written directly inside the spreadsheet cells. The RunFormula syntax is fully supported.

With ElmoFire, you can:
* Perform evaluations with **complex numbers and intervals**
* **Check physical dimensions** at every operation
* **Automatically determine** the unit of measurement for the final result
* **Convert values** between different unit systems

**Compatibility**\
\- LibreOffice Calc x86‑64 on Windows and Linux\
\- Microsoft Excel 64-bit on Windows

**Installation in LibreOffice Calc**\
1\. Download the corresponding `.oxt` file from the [Add-In](https://github.com/runnfla/ElmoFire/tree/main/Add-In/LibreOffice%20Calc) directory\
2\. In LibreOffice Calc, go to **Tools \-\-> Extensions**\
3\. In the **Extensions** manager window, click the **Add** button\
4\. Select the downloaded `.oxt` file and click **Open**\
5\. Restart LibreOffice Calc for the changes to take effect

**Installation in Microsoft Excel**\
1\. Download the `ElmoFire Excel.zip` archive from the [Add-In](https://github.com/runnfla/ElmoFire/tree/main/Add-In/MS%20Excel) directory\
2\. Extract files from the ZIP archive to a convenient and permanent folder on your computer (e.g., `C:\ElmoFire\`)\
3\. **Important:** Do not delete or move the `.xlam` and `.dll` files after installation - otherwise, the add-in will stop working\
4\. Open MS Excel. Click the **File** tab on the Ribbon and select **Options** (at the bottom of the left panel)\
5\. In the **Excel Options** window, select the **Add-Ins** section\
6\. At the bottom of the window, select **Excel Add-ins** from the **Manage** drop-down list and click **Go**\
7\. In the **Add-Ins** dialog box, click **Browse**, select the extracted `ElmoFire Excel.xlam` file and click **OK**\
8\. Make sure that the **ElmoFire Excel** add-in appears in the list and is checked and click **OK**

**How to use**\
After installing the add‑in, two new functions will become available in your spreadsheet: ELMOSTR() and ELMOVAL(). They have the same parameters.\
The ELMOSTR() function returns a text string containing the calculation result, including units of measurement if applicable.\
The ELMOVAL() function returns a raw, dimensionless number (or string) suitable for further calculations.\
Parameters are passed in the following order: first, the variables used in the formula and their values are specified in pairs, followed by the formula (expression or script) itself at the end.

`ELMOSTR/ELMOVAL([variable1, value1,]...[variableN, valueN,] formula)`

The number of variables is unlimited. Variables may be omitted (i.e., you can pass just the formula). All parameters are separated by commas. If the text of a variable, value, or formula is provided directly in the parameters of the ELMOSTR/ELMOVAL functions, it must be enclosed in double quotation marks.

**Example**\
```text
       A             B                C               D                                           E
  +-----------+--------------+--------------+-----------------------------------------------------------------------+
1 |  Voltage  |   U Units    |  Resistance  |        Power                               |      Formula             |
  +-----------+--------------+--------------+--------------------------------------------+--------------------------+
2 |   0.22    |     kV       |    20`Ohm`   | =ELMOSTR("U", A2, "UX", B2, "R", C2, $E$2) |  qty(U, Ux)**2/value(R)  |
  +-----------+--------------+--------------+--------------------------------------------+--------------------------+
3 |   2.2     |     mV       |   0.1`kOhm`  | =ELMOSTR("U", A3, "UX", B3, "R", C3, $E$2) |                          |
  +-----------+--------------+--------------+--------------------------------------------+---------------------------+
```







--\
**Author:** Alexander Torubarov\
**Contact:** runfla@yandex.com

Copyright (C) 2026 Alexander Torubarov\
Licensed under the MIT License.\
See the `LICENSE` file in the project root or a copy available at [opensource.org](https://opensource.org) for full license information.
