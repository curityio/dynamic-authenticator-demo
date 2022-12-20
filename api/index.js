const express = require('express')
const app = express()
const port = 8080

const configurations = {
    "provider1": {
        "configuration-url": "https://provider1.example.com:8444/oauth/v2/oauth-anonymous/.well-known/openid-configuration",
        "client-id": "federation-client",
        "client-secret": "Password1",
        "http-client": "dynamic-authenticator-api-client-https",
        "scope": "nonexistentscope openid profile",
        "use-subject-for-login-hint": true
    },
    "provider2": {
        "configuration-url": "https://provider2.example.com:8445/oauth/v2/oauth-anonymous/.well-known/openid-configuration",
        "client-id": "federation-client-2",
        "client-secret": "Password1",
        "http-client": "dynamic-authenticator-api-client-https",
        "use-subject-for-login-hint": true
    },
    "provider3": {
      "authentication-context-class-reference": "urn:se:curity:authentication:html-form:Username-Password",
      "idp-entity-id": "com.example",
      "idp-url": "https://provider3.example.com:8446/authn/authentication",
      "issuer-entity-id": "federation-client-3",
      "request-signing-key": "default-signing-key",
      "request-options": {
        "nameid-format": "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified"
      },
      "force-authn": "if-requested-by-client",
      "wants-assertion-signed": false,
      "wants-response-signed": false
      // "signature-verification-key": "provider3-signature-verification-key"
    },
    "provider4": {
      "authentication-context-class-reference": "urn:se:curity:authentication:html-form:Username-Password",
      "idp-entity-id": "com.example",
      "idp-url": "https://provider4.example.com:8447/authn/authentication",
      "issuer-entity-id": "federation-client-4",
      "wants-assertion-signed": false,
      "wants-response-signed": false
    }
}

app.get('/api/configuration', (req, res) => {
    const fid = req.query['fid']

    console.log(`Loading configuration for ${fid}`)
    const config = configurations[fid]

    if (!config) {
        return res.status(400).json({"code": "unknown_provider"})
    }

    return res.json(config)
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})
