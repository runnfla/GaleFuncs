# ElmoFire Add-In

The ElmoFire Add-In is an extension for LibreOffice Calc and Microsoft Excel powered by the [RunFormula](https://github.com/runnfla/RunFormula) scripting engine. It allows you to evaluate mathematical expressions and formulas with physical unit awareness, completely eliminating the need to create macros. Expressions and short scripts are written directly inside the spreadsheet cells. The RunFormula syntax is fully supported.

With ElmoFire, you can:
* Perform computations with **complex numbers and intervals**
* **Validate physical dimensions** at every stage of the calculation
* **Automatically determine** the unit of measurement for the final result
* **Convert values** from one unit system to another

**Compatibility**\
\- LibreOffice Calc 64-bit on MS Windows\
\- LibreOffice Calc 64-bit on Linux\
\- Microsoft Excel 64-bit on MS Windows

**Installation in LibreOffice Calc**\
1\. Download the corresponding .oxt file from the [Add-In](https://github.com/runnfla/ElmoFire/tree/main/Add-In/LibreOffice%20Calc) directory\
2\. From the Calc menu, select Tools \-\-> Extensions\
3\. In the window that opens, click the Add button\
4\. Select the downloaded .oxt file and click Open\
5\. Restart LibreOffice Calc for the changes to take effect

**Installation in Microsoft Excel**\
1\. Download the ElmoFire Excel.zip archive from the [Add-In](https://github.com/runnfla/ElmoFire/tree/main/Add-In/MS%20Excel) directory\
2\. Extract the zip archive to any convenient and permanent folder on your computer (e.g., `C:\ElmoFire\`)\
3\. **Important:** Do not delete or move the .xlam and .dll files after installation, otherwise the add-in will stop working\
4\. Start MS Excel, click the File tab on the Ribbon and select Options (at the bottom of the left panel)\
5\. In the window that opens, select the Add-Ins section\
6\. At the bottom of the window, select Excel Add-ins from the Manage drop-down list and click Go\
7\. In the dialog box that appears, click Browse and select the path to the extracted ElmoFire Excel.xlam file\
8\. Make sure that the ElmoFire add-in appears in the list and is checked and click OK



```text
       A             B                C               D                                         E
  +-----------+--------------+--------------+------------------------------------------------------------------------+
1 |  Voltage  |   U Units    |  Resistance  |        Power                               |    Formula                |
  +-----------+--------------+--------------+--------------------------------------------+---------------------------+
2 |   0.22    |     kV       |    20`Ohm`   | =ELMOSTR("U", A2, "UX", B2, "R", C2, $E$2) |  qty(U, Ux)**2/value(R)   |
  +-----------+--------------+--------------+--------------------------------------------+---------------------------+
3 |   2.2    |      mV       |    0.1`kOhm` | =ELMOSTR("U", A3, "UX", B3, "R", C3, $E$2) |                           |
  +-----------+--------------+--------------+--------------------------------------------+---------------------------+
```







--\
**Author:** Alexander Torubarov\
**Contact:** runfla@yandex.com

Copyright (C) 2026 Alexander Torubarov\
Licensed under the MIT License.\
See the `LICENSE` file in the project root or a copy available at [opensource.org](https://opensource.org) for full license information.
