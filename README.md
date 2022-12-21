# Dynamic Authenticator Demo

This repository contains resources needed to demonstrate the usage of a Dynamic Authenticator in the Curity Identity Server.
The resources created with scripts from this repo are:

- Two separate instances of the Curity Identity Server that serve as two external OIDC Providers.
- A node API that serves configuration required by the dynamic authenticator.
- An instance of the Curity Identity Server with the dynamic authenticator configured.

## Prerequisites

The following tools are used by the script from this repo, and you will need them to run the demo:

- Docker Desktop
- openssl
- curl

Make sure that you have those installed and available in path before running the scripts.

You will also need a license for the Curity Identity Server. If you don't have one you can get a trial license from the
[Curity Developer portal](https://developer.curity.io/free-trial/).

## Starting the Demo

Follow these steps in order to run the demo:

- Copy the JSON license file to `/idsvr`.
- Add the following domains to `/etc/hosts`:

```
127.0.0.1 login.example.com provider1.example.com provider2.example.com provider3.example.com provider4.example.com
```

- Run the `./deploy.sh` script. It will create the required certificates and containers.

## Log In Using the Dynamic Authenticator

You can log in to the main instance of the Curity Identity Server, by starting an OAuth flow for the client `dynamic-authenticator-demo`,
e.g., navigate your browser to:

```
https://login.example.com:8443/oauth/v2/oauth-authorize?client_id=dynamic-authenticator-demo&response_type=code&scope=openid&redirect_uri=http://localhost
```

You will see an authentication method selection screen. Choose `Demo Login`.

![Authenticator selector](/docs/selector.jpg)

The authenticator needs a way of determining which configuration to use for the authentication. It first collects a username,
then calls the configuration API with the domain typed into the username field. Type `user1@provider1` or `user2@provider2` for federating to an OIDC provider,
`user3@provider3` or `user4@provider4` for federating to an SAML IdP.

![Username authenticator](/docs/username.jpg)

![Provider 1 login screen](/docs/provider1.jpg)

Use one of the following credentials to log in at the different providers:

| Provider  | Username | Password    |
|-----------|----------|-------------|
| provider1 | `user1`  | `Password1` |
| provider2 | `user2`  | `Password1` |
| provider3 | `user3`  | `Password1` |
| provider4 | `user4`  | `Password1` |

After logging in with a provider you will see a Debug Attribute Action screen, where you can study the attributes collected from the respective provider.
Note that even though `userX@providerX` was first used as the subject, the final subject is the one obtained from the provider.

### Customizing the Look and Feel

The [Look And Feel](https://curity.io/resources/learn/customize-look-and-feel-simple) editor provides a way of changing the theme of the login forms without the need of editing CSS files and templates. You can use it to quickly change the login screen look.

## The Created Resources

The demo creates the following resources. Some useful endpoints are provided for convenience.

### Provider 1

A Curity Identity Server instance that serves as an external OIDC Provider.

Endpoints:
- OIDC metadata: https://provider1.example.com:8444/oauth/v2/oauth-anonymous/.well-known/oidc-configuration
- admin UI: https://provider1.example.com:6750/admin

### Provider 2

A Curity Identity Server instance that serves as an external OIDC Provider.

Endpoints:
- OIDC metadata: https://provider2.example.com:8445/oauth/v2/oauth-anonymous/.well-known/oidc-configuration
- admin UI: https://provider2.example.com:6751/admin

### Provider 3

A Curity Identity Server instance that serves as an external SAML IdP.

Endpoints:
- SAML IdP URL: https://provider3.example.com:8446/authn/authentication
- admin UI: https://provider3.example.com:6752/admin

### Provider 4

A Curity Identity Server instance that serves as an external SAML IdP.

Endpoints:
- SAML IdP URL: https://provider4.example.com:8446/authn/authentication
- admin UI: https://provider4.example.com:6753/admin


### Main instance

A Curity Identity Server instance that uses the dynamic authenticator.

Endpoints:
- OIDC metadata: https://login.example.com:8443/oauth/v2/oauth-anonymous/.well-known/oidc-configuration
- admin UI: https://login.example.com:6749/admin

### The Configuration API

A node Express API that serves the configuration required by the dynamic authenticator.

Endpoints:
- http://localhost:8080/api/configuration?fid=(provider1|provider2)


## Updating the Resources

When you update the default configuration files or the API code you will have to redeploy the containers. Running `./deploy.sh` again
will restart all containers, and the Curity Identity Server instances will have the configurations and data reset.

If you change the API code, run the script with the `--rebuild-api` option. This will refresh the API code in the container.

If you need the certificates to be renewed, run the script with the `--regenerate-certs` option.

## Teardown

Once you're done with the demo, run the `./teardown.sh` script. This will free all the resources used in this demo.

## Further Reading

Have a look at this [tutorial](https://curity.io/resources/learn/dynamic-authenticator) that describes the Dynamic Authenticator in details.

If you want more information about the Curity Identity Server, Identity and Access Management, OAuth or OpenID Connect,
then have a look at the [resources](https://curity.io/resources/) section of the [Curity](https://curity.io) website.

If you have any questions or comments don't hesitate to open an issue in this repository or contact us.
