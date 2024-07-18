import test from 'node:test'
import main from '../../index.js'

await test('#greet(name)', async t => {
  let result = null

  await t.test('"name" parameter', async t => {
    await t.test('is present & valid', async t => {
      await t.beforeEach(() => {
        result = main('John')
      })

      await t.test('greets the user', t => {
        t.assert.strictEqual(result, 'Hello John')
      })
    })

    await t.test('is missing', async t => {
      await t.test('throws a descriptive Error', async t => {
        t.assert.throws(() => main(), {
          name: 'Error',
          message: '"name" must be a String with some length'
        })
      })
    })
  })
})
