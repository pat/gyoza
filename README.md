# Gyoza

## Streamlined Editing for GitHub Pages

[Gyoza](http://gyozadoc.com) provides a dynamic web interface for contributing edits to GitHub Pages for GitHub repositories.

## Usage

Gyoza is hosted at http://gyozadoc.com - so you can just use it there if you'd like. If you want to host it elsewhere, that's cool, but you'll need to ensure the following environment variables are set:

* `GITHUB_APP_ID`: The OAuth Client ID from GitHub.
* `GITHUB_SECRET`: The OAuth Client Secret from GitHub.
* `GITHUB_USERNAME`: The username for the GitHub account generating pull requests.
* `GITHUB_PASSWORD`: The password for the GitHub account generating pull requests.
* `GITHUB_DOMAIN`: The domain for GitHub. Defaults to `github.com`, you'll only need to customise this if you're using GitHub Enterprise.
* `GITHUB_PRIVATE_KEY`: The private key used for pushing commits to GitHub. The public key should be attached to the GitHub account.

## Limitations

Currently Gyoza only supports editing of files within the gh-pages branch of a repository - so, it works perfectly for GitHub Pages sites for repositories, but not sites for GitHub accounts.

## Contributing

Contributions are very much welcome - but please keep patches in a separate branch, and ideally add tests to cover whatever you're changing.

## Credits

Copyright (c) 2013, Gyoza is developed and maintained by [Pat Allan](http://freelancing-gods.com), and is released under the open MIT Licence. It began its life at [Rails Camp 3 New Zealand](http://railscamps.com).
