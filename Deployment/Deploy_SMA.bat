@Echo off
setlocal ENABLEDELAYEDEXPANSION
set /a cnt=0
for /f "tokens=1,2 delims=:{} " %%A in (SMAv2Template.parameters.json) do (
    set /a cnt=cnt+1
    If !cnt!==8 set subscription=%%~B
    If !cnt!==11 set rg=%%~B   
)
echo Parameters from SMAv2Template.parameters.json file:
echo Subscription ID: %subscription%
echo Resource Group: %rg%

setlocal
:PROMPT
SET /P AREYOUSURE=Are you sure you want to proceed (Y/[N])? 
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END

call az login --output none  --only-show-errors
call az account set --subscription %subscription%
call az deployment group create --name SMAv2Deployment --resource-group %rg% --template-file SMAv2Template.bicep --parameters @SMAv2Template.parameters.json


:END
endlocal

PAUSE