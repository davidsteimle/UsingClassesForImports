#!/usr/bin/env pwsh

class employee {
    [string]$Name
    [datetime]$HireDate
    [int]$EmployeeId
    [decimal]$Rate
}

$ImportedCsv = Get-Content .\emp_data_example.csv | ConvertFrom-Csv

$Employees = New-Object -TypeName System.Collections.ArrayList

$ImportedCsv.ForEach({
    try{
        $Employees.Add([employee]$PSItem) | Out-Null
    } catch {
        Write-Host "Unable to add $PSItem"
        $Error[0]
    }
})
