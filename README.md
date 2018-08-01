# Powershell Console/Terminal Graph
Inputs data points and draws graph on the Powershell console

## Features and Benefits
* Color-coded output depending upon the Value of data point
* Colors codes can be customized by passing a color-map hash table
* Custom X an Y-Axis labels
* Graph in console is independent and fully customizable, not like Task Manager (Performance Tab)
* Could be incorporated in Powershell scripts
* Can consume data points generated during script run or Pre stored data like in a file or database.
* Independent of PowerShell version, and Works on PowerShell Core (Windows\Linux)

For example, in the function `Show-Graph` takes data points as input and plot them on a 2D graph
![](https://github.com/PrateekKumarSingh/PSConsoleGraph/blob/master/Images/Example1.jpg)

You can also customize the labels on X and Y-Axis and provide a graph title

![](https://github.com/PrateekKumarSingh/PSConsoleGraph/blob/master/Images/Example2.jpg)

The function `Show-Graph` can consume data points, generated during script execution or from a file or database like in the above example.

![](https://github.com/PrateekKumarSingh/PSConsoleGraph/blob/master/Images/Example3.jpg)


# To Do

* Soon to be uploaded to PowerShell Gallery, stay tuned!
