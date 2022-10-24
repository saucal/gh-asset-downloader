# gh-asset-downloader

Script adapted from a [SO answer](http://stackoverflow.com/a/35688093/55075) in way that:

1. When `GITHUB_API_TOKEN` cannot be found in `~/.secret` the user is asked to provide it.
2. When an asset name is not provided, the 1st asset found on the release will be returned.
3. When a release tag is not provided, the "latest" tag will be used instead.
4. Owner & repo are provided in a single argument. For example `saucal/gh-asset-downloader`

So the most basic usage can be simplified to: 

```./gh-asset-downloader.sh owner/repo```

Or get it & run it at once with:

```bash -c "$(curl https://raw.githubusercontent.com/saucal/gh-asset-downloader/main/gh-asset-downloader.sh)" -s owner/repo```

