# Guidelines

> always do *less*

- avoid verbosity, dependencies, build-systems, steps, processes
- this bunch of featherweight guidelines are more than enough.

## Testing

should run in *milliseconds*, have short, descriptive titles
and read-out as if they are describing to a non-techie what
this is about.

## Todos

[View todos][todos].

## Versioning

follows [Semantic Versioning][semver]

## Code changes

follows [GitHub flow][github-flow]

### commit messages

follows [conventional commits][conv-comm]

### before commit

```bash
npm test
npm run checks
```
*must* pass locally

[semver]: https://semver.org/
[conv-comm]: https://www.conventionalcommits.org/en/v1.0.0/#summary
[github-flow]: https://docs.github.com/en/get-started/using-github/github-flow
[todos]: ./TODO.md
