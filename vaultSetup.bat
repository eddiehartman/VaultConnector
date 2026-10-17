@echo off
rem =====================================================================
rem Load the Vault dev server with TDI test settings (Windows 11)
rem Same as setup.sh. Run in a second window after startVault.bat, and
rem again after every Vault restart (dev mode keeps nothing).
rem
rem Creates:
rem	- AppRole auth method
rem	- policy tdi-test:
rem	  KV access under secret/apps/tdi/ only
rem	  (also covers apps/tdi/test/, used by VaultConnectorTests.js)
rem	  ACL policies, identity entities and groups named tdi-test-* only
rem	  (used by the objectType policy, entity and group tests).
rem	  tdi-test itself does not match tdi-test-*, so the connector cannot
rem	  rewrite the policy it runs with.
rem	- role tdi: tokens get tdi-test, 1h TTL, renewable up to 4h
rem	- test secret secret/apps/tdi/db
rem Prints the roleId and secretId to paste into testParams, and a
rem wrappedSecretId for test 39 (T_WRAPPED_SECRET_ID in VaultConnectorTests.js).
rem
rem Dev server only: a token that can write policies and groups can, with
rem some effort, grant itself more rights (e.g. a tdi-test-* group with its
rem own entity as member). Never give a production connector these rights
rem unless managing policies and identity is its job.
rem =====================================================================
setlocal
set VAULT_ADDR=http://127.0.0.1:8200
set VAULT_TOKEN=root

where vault >nul 2>nul
if errorlevel 1 (
	echo vault.exe was not found. Put its folder in PATH, or run this from that folder.
	exit /b 1
)

vault auth enable approle

rem Batch has no heredoc: the policy goes through a temporary file
set POLICY_FILE=%TEMP%\tdi-test-policy.hcl
(
	echo # KV v2 secrets
	echo path "secret/data/apps/tdi/*"			{ capabilities = ["create", "read", "update", "delete"] }
	echo path "secret/metadata/apps/tdi/*"		{ capabilities = ["read", "list", "delete"] }
	echo.
	echo # objectType policy
	echo path "sys/policies/acl"				{ capabilities = ["list"] }
	echo path "sys/policies/acl/tdi-test-*"		{ capabilities = ["create", "read", "update", "delete"] }
	echo.
	echo # objectType entity
	echo path "identity/entity/name"			{ capabilities = ["list"] }
	echo path "identity/entity/name/tdi-test-*"		{ capabilities = ["create", "read", "update", "delete"] }
	echo path "identity/entity/id/*"			{ capabilities = ["read"] }
	echo path "identity/entity-alias"			{ capabilities = ["create", "update"] }
	echo path "identity/entity-alias/id/*"		{ capabilities = ["read", "update", "delete"] }
	echo.
	echo # objectType group
	echo path "identity/group/name"			{ capabilities = ["list"] }
	echo path "identity/group/name/tdi-test-*"		{ capabilities = ["create", "read", "update", "delete"] }
	echo path "identity/group/id/*"			{ capabilities = ["read"] }
	echo path "identity/group-alias"			{ capabilities = ["create", "update"] }
	echo path "identity/group-alias/id/*"		{ capabilities = ["read", "update", "delete"] }
	echo.
	echo # Aliases: resolve an auth mount path (approle^) to its accessor
	echo path "sys/auth"					{ capabilities = ["read"] }
) > "%POLICY_FILE%"
vault policy write tdi-test "%POLICY_FILE%"
del "%POLICY_FILE%"

vault write auth/approle/role/tdi token_policies=tdi-test token_ttl=1h token_max_ttl=4h

vault kv put secret/apps/tdi/db username=tdi password=test123

rem for /f runs the command and captures its output. Inside it, = must be written ^=
for /f "delims=" %%i in ('vault read -field^=role_id auth/approle/role/tdi/role-id') do set ROLE_ID=%%i
for /f "delims=" %%i in ('vault write -f -field^=secret_id auth/approle/role/tdi/secret-id') do set SECRET_ID=%%i

rem Single use and valid for 1 hour. For another test run, make a new one with:
rem	vault write -wrap-ttl=1h -f -field=wrapping_token auth/approle/role/tdi/secret-id
for /f "delims=" %%i in ('vault write -wrap-ttl^=1h -f -field^=wrapping_token auth/approle/role/tdi/secret-id') do set WRAPPED_SECRET_ID=%%i

echo.
echo roleId:		%ROLE_ID%
echo secretId:		%SECRET_ID%
echo wrappedSecretId:	%WRAPPED_SECRET_ID%
