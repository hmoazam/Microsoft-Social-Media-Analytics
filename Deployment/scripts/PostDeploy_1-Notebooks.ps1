$template = @"
{
  "name": "###nbname###",
  "folder": "",
  "properties": {
    "description": "###nbname###",
    "nbformat": 4,
    "nbformat_minor": 2,
    "bigDataPool": {
      "referenceName": "###sparkpoolname###",
      "type": "BigDataPoolReference"
    },
    "sessionProperties": {
      "driverMemory": "28g",
      "driverCores": 4,
      "executorMemory": "28g",
      "executorCores": 4,
      "numExecutors": 1
    },
    "metadata": {
      "language_info": {
        "name": "python"
      },
      "kernelspec": {
        "name": "exampleName",
        "display_name": "exampleDisplayName"
      }
    },
    "cells": [
      ###cells###
    ]
  }
}
"@ 
foreach ($nb in (ls .\Spark\*.py))
{
    $n = $nb.basename
    
    $uri = "https://$workspaceName.dev.azuresynapse.net/notebooks/$n`?api-version=2020-12-01"
    $body =gc $nb.FullName | ? {$_.trim() -ne "" }
    $notebook = $template -replace "###nbname###",$n
    $notebook = $notebook -replace "###sparkpoolname###",$sparkName
    
    $cells = @()
    $lines = @()
    foreach ($line in $body)
    {
        
        if ($line.startswith("# In["))
        {
	   if ($line -like "*Parameters") {$isParamCell=$true}
	   else {$isParamCell=$false}

            if ($lines.Count -gt 0)
            {
                $cells+= ($cell -replace "###code###", $lines)+","
            }
            $lines = @()
            $cell = "{`"cell_type`": `"code`",
        `"metadata`": {},
        `"source`": [
          ###code###
        ],
        `"attachments`": {},
        `"outputs`": []"
	if ($isParamCell)
	{
		$cell+=",
	`"metadata`": {
        `"tags`": [
          `"parameters`"
        	]
      		}"
	}
	$cell+="}"
	
	
            
        }
        elseif (!$line.StartsWith("#!/usr/bin/env python") -and !$line.StartsWith("# coding: utf-8") )
        {
            $line = $line -replace "###location###",$location
            $line = $line -replace "###KeyVaultName###",$kvName

            $line = $line -replace '[\\]',"\\"
            $line = $line -replace '"','\"'
            $line = '"'+$line+'\n",'
            $lines+=$line

        }
        
    }
    if ($lines.Count -gt 0)
    {
        $cells+= ($cell -replace "###code###", $lines)
    }
    $notebook = $notebook -replace "###cells###",$cells
    
    $global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $notebook  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"
    
}
