@echo off
rem =====================================================================
rem Start the Vault dev server for the TDI tests (Windows 11)
rem Same as startVault.sh. Leave this window open: closing it stops Vault.
rem Dev mode keeps nothing, so run setup.bat in a second window after
rem every start.
rem
rem VAULT_LISTEN must match VAULT_ADDR in setup.bat and vaultUrl in the
rem connector (testParams.vaultUrl), e.g. http://127.0.0.1:8200.
rem	127.0.0.1:8200	Vault and TDI on this same Windows machine
rem	this-PC-IP:8200	TDI on another machine. Windows Firewall asks
rem			to allow vault.exe the first time
rem =====================================================================
setlocal
set VAULT_LISTEN=127.0.0.1:8200

where vault >nul 2>nul
if errorlevel 1 (
	echo vault.exe was not found. Put its folder in PATH, or run this from that folder.
	exit /b 1
)

vault server -dev -dev-listen-address=%VAULT_LISTEN% -dev-root-token-id=root
