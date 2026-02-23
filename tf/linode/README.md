# Linode-based infra

We will be relying on:
* Linode for VPS, VPC, Storage
* Cloudflare for DNS

## Credential setup

### SSH
We use SSH keys to configure the

### Linode
1. Create a linode account
2. Create a linode [personal access token][linode pat] (might be simplest to allow
   full read/write access)
3. Create a new github secret called `LINODE_TOKEN` and paste in the token we created
   in the previous step.

### Cloudflare
1. Create a cloudflare account, or use an existing one.
2. Purchase a domain on cloudflare (or use an existing domain). We will use example.com.
3. Create a cloudflare [account token][cloudflare token]. We recommend the following
   permissions: TODO insert pic
4. Create a new github secret called `CLOUDFLARE_API_TOKEN` and paste in the token we created
   in the previous step.
5. Create a new github variable called `TOPLEVEL_DOMAIN` and paste in the name of the
   domain you are using for your infrastructure. Example: thebutlah.com

[linode pat]: https://techdocs.akamai.com/linode-api/reference/get-started#personal-access-tokens
[cloudflare token]: https://developers.cloudflare.com/fundamentals/api/get-started/account-owned-tokens/#create-an-account-owned-token
