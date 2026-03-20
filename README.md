# docker-age

Docker image for [age](https://github.com/FiloSottile/age) — a simple, modern and secure file encryption tool.

This image packages the official prebuilt binaries from [age releases](https://github.com/FiloSottile/age/releases) into a minimal (`scratch`) Docker image, designed for use as a `COPY --from` source in multi-stage builds.

## Supported Architectures

- `linux/amd64`
- `linux/arm64`
- `linux/arm/v7`

## Usage

Use in your Dockerfile to copy the `age` binary without needing a package manager:

```dockerfile
COPY --from=ghcr.io/zachcheung/age /age /usr/local/bin/age
```

To also copy `age-keygen`:

```dockerfile
COPY --from=ghcr.io/zachcheung/age /age-keygen /usr/local/bin/age-keygen
```

Pin to a specific version:

```dockerfile
COPY --from=ghcr.io/zachcheung/age:1.3.1 /age /usr/local/bin/age
```

## License

[MIT](LICENSE)
