connection: {
		// Vault server
		vaultUrl:				{ param: "vaultUrl",					def: "http://10.211.55.2:8200" },
		namespace:				{ param: "vaultNamespace",				def: "" },		// Enterprise/HCP only
		timeoutMs:				{ param: "timeoutMs",					def: "10000" },		// urlConnection transport only
		httpTransport:			{ param: "httpTransport",				def: "auto",		opt: ["auto", "httpClient", "urlConnection"] },		// auto | httpClient | urlConnection
													// auto = HTTP Client Connector, unless this
													// connector has its own TLS stores (cert auth)

		// What the standard modes work on
		objectType:				{ param: "objectType",					def: "kvSecret",	opt: ["kvSecret", "policy", "entity", "group"] },	// see objectTypes
		kvMount:				{ param: "kvMount",						def: "secret" },	// KV v2 mount path
		updateMethod:			{ param: "updateMethod",				def: "patch",		opt: ["patch", "replace"] },		// Update mode: patch | replace (see attributes)
		deleteMode:				{ param: "deleteMode",					def: "soft",		opt: ["soft", "permanent"] },		// kvSecret only: soft | permanent

		// Authentication
		authMethod:				{ param: "authMethod",					def: "approle",		opt: ["approle", "cert", "token"] },	// approle | cert | token
		authMount:				{ param: "authMount",					def: "" },		// empty = same as authMethod
		roleId:					{ param: "roleId",						def: "deb9023e-1480-f8ef-8acc-8a1064f1ad5d" },		// approle
		secretId:				{ param: "secretId",					def: "03efd7b8-0892-190b-4983-6f81c9b31ff8" },		// approle: secret_id, or wrapping token
		secretIdWrapped:		{ param: "secretIdWrapped",				def: "false",		opt: ["true", "false"] },		// approle: true = secretId is a wrapping token
		certRole:				{ param: "certRole",					def: "" },		// cert: role name, empty = any matching role
		token:					{ param: "vaultToken",					def: "" },		// token: for testing only

		// TLS: truststore for any auth method, keystore for cert auth
		tlsTruststore:			{ param: "tlsTruststore",				def: "" },		// empty = JVM default truststore
		tlsTruststorePassword:	{ param: "tlsTruststorePassword",		def: "" },
		tlsKeystore:			{ param: "tlsKeystore",					def: "" },		// client certificate + private key
		tlsKeystorePassword:	{ param: "tlsKeystorePassword",			def: "" },
		tlsStoreType:			{ param: "tlsStoreType",				def: "PKCS12",		opt: ["PKCS12", "JKS", "JCEKS"] },		// PKCS12 | JKS | JCEKS
		tlsProtocol:			{ param: "tlsProtocol",					def: "TLSv1.2",		opt: ["TLSv1.2", "TLSv1.3", "TLS"] },		// TLS = highest version both sides support

		// Startup checks
		healthCheck:			{ param: "healthCheck",					def: "true",		opt: ["true", "false"] },		// sys/health before login
		capabilityCheckPath:	{ param: "capabilityCheckPath",			def: "" },		// sample path or name for the objectType, e.g. apps/tdi/db
		requiredCapabilities:	{ param: "requiredCapabilities",		def: "read",		opt: ["read", "create, update", "read, create, update", "read, delete", "read, create, update, delete"] }		// per mode: Lookup | AddOnly | Update | Delete | all. Editable: any comma list of create, read, update, delete, list, sudo
	},