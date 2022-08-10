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

- Copy `hooks/pre-commit` to `./git/hooks`. (This is an optional step, and you should do it if you plan to commit anything to this repo.
  The hook will make sure that you don't accidentally commit the license.)
- Copy the JSON license file to `/idsvr`.
- Add the following domains to `/etc/hosts`:

```
127.0.0.1 provider1.example.com provider2.example.com
```

- Run the `./deploy.sh` script. It will create the required certificates and containers.

## Log In Using the Dynamic Authenticator

You can log in to the main instance of the Curity Identity Server, by starting an OAuth flow for the client `dynamic-authenticator-demo`,
e.g., navigate your browser to: `https://localhost:8443/oauth/v2/oauth-authorize?client_id=dynamic-authenticator-demo&response_type=code&scope=openid&redirect_uri=http://localhost`.
(You can use [OAuth.tools](https://curity.io/resources/learn/test-using-oauth-tools/) to perform OAuth flows, but you will
need to expose the main instance of the Curity Identity Server to the Internet. Here is a
[tutorial](https://curity.io/resources/learn/expose-local-curity-ngrok/) that shows how to do it using a free tool called `ngrok`.)

You will see an authentication method selection screen. Choose `Dynamic Authenticator`.

![Authenticator selector](/docs/selector.jpg)

The authenticator needs a way of determining which configuration to use for the authentication. It first collects a username,
then calls the configuration API with the domain typed into the username field. Type `user1@provider1` or `user2@provider2` to be redirected
to the corresponding provider.

![Username authenticator](/docs/username.jpg)

![Provider 1 login screen](/docs/provider1.jpg)

At provider1 you can log in with `user1/Password1`. At provider2 log in with `user2/Password1`.

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
- admin UI: https://localhost:6750/admin

### Provider 2

A Curity Identity Server instance that serves as an external OIDC Provider.

Endpoints:
- OIDC metadata: https://provider2.example.com:8445/oauth/v2/oauth-anonymous/.well-known/oidc-configuration
- admin UI: https://localhost:6751/admin

### Main instance

A Curity Identity Server instance that uses the dynamic authenticator.

Endpoints:
- OIDC metadata: https://localhost:8443/oauth/v2/oauth-anonymous/.well-known/oidc-configuration
- admin UI: https://localhost:6749/admin

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
