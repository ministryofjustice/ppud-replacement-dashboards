# ppud-replacement-dashboards

Smashing dashboards for the PPUD Replacement team

Ref: http://smashing.github.io/smashing for more information.


### Installation

Requires:
* ruby - version defined in .ruby-version (recommend [asdf](https://github.com/asdf-vm/asdf) for ruby version management)

* `brew install openssl`
* `brew install pkg-config`
* `gem install bundler`
* `export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"`
* `bundle install`

### Run

You will need to add a CircleCI API token to your environment:
`export CIRCLE_CI_AUTH_TOKEN='TOKEN'`

`smashing start`

Services should be available on http://localhost:3030