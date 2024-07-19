[//]: # (overview-start)
ES module template, zero dependencies, zero config, all native.

Comes with unit tests, CodeQL & a tiny `git` hook to ensure commit messages
follow [conventional commits][cc].\
[ESLint][lint] is optional.

- click: `Use this as a template`
- run: `npm run setup`

> runs a bash script that sets *everything* up, replaces all `{{token}}`
then deletes itself
---
[//]: # (overview-end)

[![test-workflow][test-badge]][test-workflow] [![codeql-workflow][codeql-badge]][codeql-workflow]

# esm-zero

> {{description}}

## Usage

### Install

```bash
npm i @{{author}}/{{project}}
```

## Tests

Install deps

```bash
npm ci
```

Run unit tests

```bash
npm test
```

Run test coverage

```bash
npm run test:coverage
```

## Authors

[@{{author}}][{{author}}]

## License

[MIT-0 "No Attribution" License][license]

[test-badge]: https://img.shields.io/badge/tests:unit-passing-green
[test-workflow]: https://github.com/{{author}}/{{project}}/actions/workflows/test:unit.yml

[codeql-badge]: https://img.shields.io/badge/CodeQL-passing-green
[codeql-workflow]: https://github.com/{{author}}/{{project}}/actions/workflows/codeql.yml

[{{author}}]: https://github.com/{{author}}
[license]: ./LICENSE

[esm]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules
[lint]: https://eslint.org/
[cql]: https://codeql.github.com/
[ci]: https://github.com/features/actions
[cc]: https://www.conventionalcommits.org/en/about/
