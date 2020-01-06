# Using Classes to Improve Data Import Functionality

Very often, we are given data in formats which can be imported into Powershell, but its usefullness as a object is lost in the procedure. Using custom classes will turn this formless string data into useful objects.

Some of the most common ways we receive data are:

* __Comma Seperated Value__ (CSV) files. Often as the output of an application, or provided by another deleloper.
* __JavaScript Object Notation__ (JSON) file or stream. Possibly provided by an Application Program Interface (API) or ``Invoke-WebRequest`` call.
* Spreadsheet. This data source, in this example, will be converted to CSV.

**There are two attached data files, ``emp_data_example.csv`` and ``emp_data_example.json`` for use with this tutorial. All values are randomly generated, including the names. These records do not, to the best of my knowledge, represent real people or factual PII.**

Powershell handles CSV and JSON nicely:

* ``ConvertFrom-Csv``
* ``ConvertFrom-Json``

Using these conversion commandlets will give you an object with the same data. Let's import a CSV file:

```powershell
$ImportedCsv = Get-Content .\emp_data_example.csv | ConvertFrom-Csv
```

Pulling the first five entries shows us the data we are working with.

```powershell
$ImportedCsv | Select-Object -First 5
```

```
Name              HireDate   EmployeeId Rate
----              --------   ---------- ----
Diaz, Delia       10/05/2016 8551       26.29
Maxwell, Oscar    12/27/2016 6901       20.27
Henderson, Denise 04/10/2017 5160       24.93
Tyler, Kenny      08/03/2018 5953       33.65
Hunter, Constance 02/05/2011 7939       25.73
```

Awesome, we are done, right? What if we want to perform calculations with this data? For example, how long has Delia Diaz worked here? Let's find out:

```
$ImportedCsv[0]
Name        HireDate   EmployeeId Rate
----        --------   ---------- ----
Diaz, Delia 10/05/2016 8551       26.29
```

```powershell
$(Get-Date) - $ImportedCsv[0].HireDate
```

```
Multiple ambiguous overloads found for "op_Subtraction" and the argument count: "2".
At line:1 char:3
+ $(Get-Date) - $ImportedCsv[0].HireDate
+   ~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [], MethodException
    + FullyQualifiedErrorId : MethodCountCouldNotFindBest
```

Powershell was unable to work with this date, because it is a string.

```powershell
$ImportedCsv[0].HireDate.GetType()
```

```
IsPublic IsSerial Name    BaseType
-------- -------- ----    --------
True     True     String  System.Object
```

Naturally, we could convert this value easily by piping the string value through ``Get-Date`` when we do this calculation, but Powershell is better than that. Let's define our objects with appropriate data types with a ``class``:

```powershell
class employee {
    [string]$Name
    [datetime]$HireDate
    [int]$EmployeeId
    [decimal]$Rate
}
```

Now, let's create a variable with Delia Diaz's information, cast as ``employee``:

```powershell
$Example = [employee]$($ImportedCsv[0])
$Example.HireDate.GetType()
```

```
IsPublic IsSerial Name      BaseType
-------- -------- ----      --------
True     True     DateTime  System.ValueType
```

So, how long has Delia Diaz worked here?

```powershell
$(Get-Date) - $Example.HireDate
```

```
Days              : 1188
Hours             : 14
Minutes           : 54
Seconds           : 51
Milliseconds      : 369
Ticks             : 1026968913692697
TotalDays         : 1188.62142788507
TotalHours        : 28526.9142692416
TotalMinutes      : 1711614.8561545
TotalSeconds      : 102696891.36927
TotalMilliseconds : 102696891369.27
```

Or...

```powershell
[math]::Round($(($(Get-Date) - $Example.HireDate).TotalDays / 365),2)
```

That's 3.26 years since Delia's start date. Now that it is a ``datetime`` object we can do all the date or time calculations we want, such as determining an anniversary, figuring out leave accrual rate, or reformatting the date to fit a database query with a defined ``datetime`` structure.

But what about our other employees? There are 100 of them in our CSV and JSON files.

Back to the beginning, let's import our CSV:

```powershell
$ImportedCsv = Get-Content .\emp_data_example.csv | ConvertFrom-Csv
```

Next, we need to create a new Array List:

```powershell
[System.Collections.ArrayList]$Employees = @()
```

Then we will loop through ``$ImportedCsv``:

```powershell
$ImportedCsv.ForEach({
    try{
        $Employees.Add([employee]$PSItem) | Out-Null
    } catch {
        Write-Host "Unable to add $PSItem"
        $Error[0]
    }
})
```

Notice the ``try``/``catch`` pair? That is to help us with our data. Running the above code will produce the following results:

```
Unable to add Cannot convert value "@{Name=Buchanan, Elmer; HireDate=13/32/2011; EmployeeId=9352; Rate=35.33}" to type "employee". Error: "Cannot convert value "13/32/2011" to type "System.DateTime". Error: "String was not recognized as a valid DateTime.""
```

Elmer Buchanan is the final entry in our CSV. His hire date is 13/32/2011. That is an invalid date format. Who is our last employee now?

```
$Employees[-1]

Name         HireDate              EmployeeId  Rate
----         --------              ----------  ----
Park, Ashley 10/9/2010 12:00:00 AM       5724 38.32
```

With some nicer logging, we could have imported the data, transformed it into valid data types, and then reported to our data provider any erroneous input. Whether Elmer's data was fat-fingered or the file compromised, Powershell caught the error and it can be dealth with.
