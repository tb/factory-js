class FactoryDefinition
  constructor: (name) ->
    @name = name
    @buildAdapter = new Factory.adapter(@)
    @attrs = {}
    @ignores = {}
    @sequences = {}
    @traits = {}
    @callbacks = []

  adapter: (adapter) ->
    @buildAdapter = new adapter(@)
    @

  build: (buildType, name, attrs) ->
    if @buildAdapter[buildType]
      @buildAdapter[buildType](name, attrs)
    else
      attrs

  after: (callback) ->
    @callbacks.push callback
    @

  attr: (attr, value) ->
    @attrs[attr] = (if typeof value is 'function' then value else -> value)
    @

  hasMany: (attr, factoryName) ->
    @ignore attr, []
    @after (attributes, factory) ->
      @[attr] = [] unless @[attr] instanceof Array

      Factory.buildList(factoryName, attributes[attr]).forEach (object) =>
        factory.buildAdapter['push'].call @, attr, object
    @

  ignore: (attr, value) ->
    @ignores[attr] = (if typeof value is 'function' then value else -> value)
    @

  sequence: (attr, block) ->
    factory = @
    block = block or (i) -> i

    @attrs[attr] = ->
      factory.sequences[attr] = factory.sequences[attr] || 0
      block.call @, ++factory.sequences[attr]
    @

  trait: (name, block) ->
    definition = new FactoryDefinition(name)
    block.call(definition) if typeof block is 'function'
    @traits[name] = definition
    @

  attributes: (attrs, traits) ->
    attributes = Factory.hash.merge {}, attrs
    ignoredAttributes = {}

    traits.forEach (trait) ->
      for attr of trait.attrs
        attributes[attr] = trait.attrs[attr]

    for attr of @attrs
      attributes[attr] = @attrs[attr] unless attributes.hasOwnProperty(attr)

    for attr of @ignores
      ignoredAttributes[attr] = if attributes.hasOwnProperty attr then attributes[attr] else @ignores[attr]
      delete attributes[attr]

    Factory.hash.evaluate attributes
    Factory.hash.evaluate ignoredAttributes

    return withIgnored: Factory.hash.merge({}, attributes, ignoredAttributes), withoutIgnored: attributes

  applyCallbacks: (result, attributes) ->
    @callbacks.forEach (callback) => callback.call(result, attributes, @)
