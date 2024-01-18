
# Building and Deploying

We're building on top of the existing docker image with the tailscale extension and pushing this to our own ECR Repository.

See : https://github.com/rails-lambda/tailscale-extension

```bash
docker build . -t $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.eu-west-1.amazonaws.com/homeassistant

aws ecr get-login-password | docker login -u AWS --password-stdin "https://$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.us-east-1.amazonaws.com"

docker push $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.eu-west-1.amazonaws.com/homeassitant
```

Linking Account

https://github.com/fabsrc/home-assistant-alexa-proxy
https://github.com/tieum/haaska-tailscale

Temporarily issue long lived tokens


Use Cloudflare for cert issuing and redirects
Add record
Add Origin Rule 
Host = ha.throw-away.info 
Port 443 -> 8123

Enable redirects from anywhere (and locally for tailscale)

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1 # to allow tailscale serve
    - 0.0.0.0/0 # to allow traffic from cloudflare
```

Open Local Firewall