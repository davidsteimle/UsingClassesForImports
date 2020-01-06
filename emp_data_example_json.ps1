#!/usr/bin/env pwsh

class employee {
    [string]$Name
    [datetime]$HireDate
    [int]$EmployeeId
    [decimal]$Rate
}

$ImportedJson = Get-Content .\emp_data_example.json | ConvertFrom-Json

[System.Collections.ArrayList]$Employees = @()

$ImportedJson.ForEach({
    try{
        $Employees.Add([employee]$PSItem) | Out-Null
    } catch {
        Write-Host "Unable to add $PSItem"
        $Error[0]
    }
})
