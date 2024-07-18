const greet = name => {
  if (!name)
    throw new Error(`"name" must be a String with some length`)

  return `Hello ${name}`
}

export default greet
