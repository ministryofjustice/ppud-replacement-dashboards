# ppud-replacement-dashboards

[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=for-the-badge&logo=github&label=MoJ%20Compliant&query=%24.data%5B%3F%28%40.name%20%3D%3D%20%22ppud-replacement-dashboards%22%29%5D.status&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fgithub_repositories)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories#ppud-replacement-dashboards "Link to report")

Smashing dashboards for the PPUD Replacement team

Ref: http://smashing.github.io/smashing for more information.

### Installation

Requires:

- ruby - version defined in `.tool-versions` (recommend [asdf](https://github.com/asdf-vm/asdf) for ruby/nodejs version management)
- nodejs - version defined in `.tool-versions` (recommend [asdf](https://github.com/asdf-vm/asdf) for ruby/nodejs version management)

- `brew install openssl`
- `brew install pkg-config`
- `gem install bundler`
- `export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"`
- `bundle install`

### Run

You will need to add a CircleCI API token to your environment:
`export CIRCLE_CI_AUTH_TOKEN='TOKEN'`

```sh
./scripts/start-local.sh
```

Services should be available on http://localhost:3030
