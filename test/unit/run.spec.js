import test from 'node:test'
import <project> from '../../index.js'

await test('#<project>()', async t => {
  let result = null

  await t.beforeEach(() => {
    result = <project>()
  })

  await t.test('says "hello world', t => {
    t.assert.strictEqual(result, 'hello world')
  })
})
