[![test-workflow][test-badge]][test-workflow] [![codeql-workflow][codeql-badge]][codeql-workflow]

# <project>

> <description>

## Usage

### Install

```bash
npm i https://github.com/<author>/<project>
```

## Checklist

- [ ] run: `npm i -D @eslint/js globals`
  - make sure it used `globals.node` instead of `globals.browser`
    in `./eslint.config.js`
- [ ] replace word `esm` with module name, everywhere
- [ ] rename or replace `./src/esm/` folder
- [ ] Add coveralls
  - If needed
    - [ ] Add repo in coveralls dashboard, get `secrets.COVERALLS_REPO_TOKEN`
    - In this repo, Settings -> Secrets and Variables -> Actions -> Secrets
        - [ ] Add it as environment secret
    - [ ] Rename `./github/workflows/test:coverage.sample` to `./github/workflows/test:coverage.yml`
    - [ ] Add this on top of `README`: `[![coverage-workflow][coverage-badge]][coverage-report]`
    - [ ] Add this at the bottom of `README`, next to other badge refs:
      ```
      [coverage-badge]: https://coveralls.io/repos/github/<author>/esm/badge.svg?branch=main
      [coverage-report]: https://coveralls.io/github/<author>/esm?branch=main
      ```
  - If not
    - [ ] Delete that workflow file
    - [ ] Delete `npm run test:coverage` from "Test" section of `README`
- [ ] in `package.json`
  - [ ] Replace occurences of `esm` with module name
  - [ ] Replace `name`
  - [ ] Replace `description`
  - [ ] Add keywords
  - [ ] Add minimum Nodejs supported version `engine`
- [ ] in `README`
  - [ ] change top title
  - [ ] change top description
- [ ] Edit Github repo description

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

[@<author>]

## License

[MIT-0 "No Attribution" License][license]

[test-badge]: https://github.com/<author>/<project>/actions/workflows/test:unit.yml/badge.svg
[test-workflow]: https://github.com/<author>/<project>/actions/workflows/test:unit.yml

[codeql-badge]: https://github.com/<author>/<project>/actions/workflows/codeql.yml/badge.svg
[codeql-workflow]: https://github.com/<author>/<project>/actions/workflows/codeql.yml

[<author>]: https://github.com/<author>
[license]: ./LICENSE
