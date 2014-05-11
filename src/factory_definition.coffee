class FactoryDefinition
  constructor: (name) ->
    @name = name
    @adapter = Factory.adapter
    @attrs = {}
    @ignores = {}
    @sequences = {}
    @traits = {}
    @callbacks = []

  after: (callback) ->
    @callbacks.push callback

  attr: (attr, value) ->
    @attrs[attr] = (if typeof value is 'function' then value else -> value)

  ignore: (attr, value) ->
    @ignores[attr] = (if typeof value is 'function' then value else -> value)

  sequence: (attr, block) ->
    factory = @
    block = block or (i) -> i

    @attrs[attr] = ->
      factory.sequences[attr] = factory.sequences[attr] || 0
      block.call this, ++factory.sequences[attr]

  trait: (name, block) ->
    definition = new FactoryDefinition(name)
    block.call(definition) if typeof block is 'function'
    @traits[name] = definition

  attributes: (attrs, traits) ->
    attributes = @hash.merge {}, attrs
    ignoredAttributes = {}

    traits.forEach (trait) ->
      for attr of trait.attrs
        attributes[attr] = trait.attrs[attr]

    for attr of @attrs
      attributes[attr] = @attrs[attr] unless attributes.hasOwnProperty(attr)

    for attr of @ignores
      ignoredAttributes[attr] = if attributes.hasOwnProperty attr then attributes[attr] else @ignores[attr]
      delete attributes[attr]

    @hash.evaluate attributes
    @hash.evaluate ignoredAttributes

    return withIgnored: @hash.merge({}, attributes, ignoredAttributes), withoutIgnored: attributes

  applyCallbacks: (result, attributes) ->
    @callbacks.forEach (callback) -> callback.call(result, attributes)

  hash:
    merge: (dest, objs...) ->
      for obj in objs
        dest[k] = v for k, v of obj
      dest

    evaluate: (obj) ->
      for k of obj
        obj[k] =  if typeof obj[k] is 'function' then obj[k]() else obj[k]
