# Integrating Home Assistant with Alexa using Tailscale

The repository below builds upon the instructions and source code for the home assistant [smart home integration](https://www.home-assistant.io/integrations/alexa.smart_home/)

## Prerequisites

* An AWS Account
* A Domain hosted by cloudflare


# Preparing Home Assistant

In order for the integration to work, there are some basic tasks that need to be made in home assistant.  Each of these is temporary and can be reverted after setup is complete.

## Exposing to the internet via cloudflare

Enable the smart home integration and redirects from anywhere

```yaml
alexa:
  smart_home:

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1 # to allow tailscale serve
    - 0.0.0.0/0 # to allow traffic from cloudflare
```

## Issuing Long Lived Tokens

Without making the change below, Alexa will be logged out after 30 minutes

Credit to : https://github.com/tieum/haaska-tailscale

```
docker exec -it homeassistant bash
sed -i  s/minutes=30/days=3650/   /usr/src/homeassistant/homeassistant/auth/const.py
exit
docker restart homeassistant
```

## Configuring Cloudflare

Use Cloudflare for cert issuing and redirects

1. Add record for your domain.
2. Add Origin Rule 

Host = ha.`yourdomain.com`

Port 443 -> 8123

## Expose Home Port 8123 to the internet on your local router

* Instructions will differ

# Building and Deploying the Lambda

We're building on top of the existing docker image with the tailscale extension and pushing this to our own ECR Repository.  The python code is that taken from the smart home integration and modified to connect via tailscale.

See : https://github.com/rails-lambda/tailscale-extension

```bash
docker build . -t $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.eu-west-1.amazonaws.com/homeassistant

aws ecr get-login-password | docker login -u AWS --password-stdin "https://$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.us-east-1.amazonaws.com"

docker push $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.eu-west-1.amazonaws.com/homeassitant
```

## Tailscale Ephemeral Token

Generate a [reusable ephemeral](https://tailscale.com/kb/1085/auth-keys) token for tailscale


## Setup

From this point you are hopefully able to follow the instructions as per the [smart home integration](https://www.home-assistant.io/integrations/alexa.smart_home/).

When it comes to setting up the lambda function, the instructions differ slightly in that we are running from the docker image rather than python and we require additional environment variables for tailscale


  * `TS_KEY` - Required. Your ephemeral key.
  * `TS_HOSTNAME` - Optional. The value of --hostname parameter. Default lambda.
  * `SOCKS_PROXY_URL` - Required and should be set to: *socks5h://localhost:1055*


## Revert Changes

Once complete, you should revert the changes

* In cloudflare
* In your local router
* That issued the long lived token to alexa

```
docker exec -it homeassistant bash
sed -i  s/days=3650/minutes=30/   /usr/src/homeassistant/homeassistant/auth/const.py
exit
docker restart homeassistant
```