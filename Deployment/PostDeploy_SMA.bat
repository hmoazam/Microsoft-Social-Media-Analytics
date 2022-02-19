@echo off & setlocal
set batchPath=%~dp0
powershell.exe -noprofile -noexit -file "%batchPath%scripts\PostDeploy_Wrapper.ps1"