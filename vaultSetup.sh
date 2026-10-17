#!/bin/bash
# =====================================================================
# Load the Vault dev server with TDI test settings (run on the Mac)
# Run in a second terminal after start-vault.sh, and again after every
# Vault restart (dev mode keeps nothing).
#
# Creates:
#	- AppRole auth method
#	- policy tdi-test:
#	  KV access under secret/apps/tdi/ only
#	  (also covers apps/tdi/test/, used by VaultConnectorTests.js)
#	  ACL policies, identity entities and groups named tdi-test-* only
#	  (used by the objectType policy, entity and group tests).
#	  tdi-test itself does not match tdi-test-*, so the connector cannot
#	  rewrite the policy it runs with.
#	- role tdi: tokens get tdi-test, 1h TTL, renewable up to 4h
#	- test secret secret/apps/tdi/db
# Prints the roleId and secretId to paste into testParams, and a
# wrappedSecretId for test 39 (T_WRAPPED_SECRET_ID in VaultConnectorTests.js).
#
# Dev server only: a token that can write policies and groups can, with
# some effort, grant itself more rights (e.g. a tdi-test-* group with its
# own entity as member). Never give a production connector these rights
# unless managing policies and identity is its job.
# =====================================================================

export VAULT_ADDR=http://10.211.55.2:8200
export VAULT_TOKEN=root

vault auth enable approle

vault policy write tdi-test - <<EOP
# KV v2 secrets
path "secret/data/apps/tdi/*"			{ capabilities = ["create", "read", "update", "delete"] }
path "secret/metadata/apps/tdi/*"		{ capabilities = ["read", "list", "delete"] }

# objectType policy
path "sys/policies/acl"				{ capabilities = ["list"] }
path "sys/policies/acl/tdi-test-*"		{ capabilities = ["create", "read", "update", "delete"] }

# objectType entity
path "identity/entity/name"			{ capabilities = ["list"] }
path "identity/entity/name/tdi-test-*"		{ capabilities = ["create", "read", "update", "delete"] }
path "identity/entity/id/*"			{ capabilities = ["read"] }
path "identity/entity-alias"			{ capabilities = ["create", "update"] }
path "identity/entity-alias/id/*"		{ capabilities = ["read", "update", "delete"] }

# objectType group
path "identity/group/name"			{ capabilities = ["list"] }
path "identity/group/name/tdi-test-*"		{ capabilities = ["create", "read", "update", "delete"] }
path "identity/group/id/*"			{ capabilities = ["read"] }
path "identity/group-alias"			{ capabilities = ["create", "update"] }
path "identity/group-alias/id/*"		{ capabilities = ["read", "update", "delete"] }

# Aliases: resolve an auth mount path (approle) to its accessor
path "sys/auth"					{ capabilities = ["read"] }
EOP

vault write auth/approle/role/tdi token_policies=tdi-test token_ttl=1h token_max_ttl=4h

vault kv put secret/apps/tdi/db username=tdi password=test123

echo "roleId:	$(vault read -field=role_id auth/approle/role/tdi/role-id)"
echo "secretId:	$(vault write -f -field=secret_id auth/approle/role/tdi/secret-id)"

# Single use and valid for 1 hour. For another test run, make a new one with:
#	vault write -wrap-ttl=1h -f -field=wrapping_token auth/approle/role/tdi/secret-id
echo "wrappedSecretId:	$(vault write -wrap-ttl=1h -f -field=wrapping_token auth/approle/role/tdi/secret-id)"