# mokta
Mock Okta

## Build

`docker build -t citizensadvice/mokta .`

## Start

```
docker run
  -p 4001:4001
  -v your-okta-json-directory:/app/data
  --env MOKTA_ISSUER=https://cadev.oktapreview.com
  --env MOKTA_REDIRECT_URL=http://app.test:3001/session
  --env MOKTA_URL=http://okta.test:4001
citizensadvice/mokta
```

The login maps from `username@email` to `username.json` in the data folder.
You can link to your host folder with `-v your-okta-json-directory:/app/data`
Passwords are ignored as we are not testing Okta itself.

## Configuration

| Key name | Description |
|---|---|
| MOKTA_ISSUER | The issuer id must match the issuer in your claims
| MOKTA_REDIRECT_URL | The URL to redirect to (POST) after login
| MOKTA_URL | The current URL