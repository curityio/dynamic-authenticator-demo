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
    }
}

app.get('/api/configuration', (req, res) => {
    const fid = req.query['fid']
    const config = configurations[fid]

    if (!config) {
        return res.status(400).json({"code": "unknown_provider"})
    }

    return res.json(config)
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})
