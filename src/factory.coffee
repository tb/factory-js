class Factory
  @factories: {}
  @buildFn: (name, attrs) -> attrs
  @createFn: (name, attrs) -> attrs

  @clear: ->
    @factories = {}
    @buildFn = (name, attrs) -> attrs
    @createFn = (name, attrs) -> attrs

  @reset: ->
    for name,factory of @factories
      factory.sequences = {}

  @define: (name, block) ->
    definition = new FactoryDefinition(name, @buildFn, @createFn)
    block.call(definition) if typeof block is 'function'
    @factories[name] = definition

  @getFactory: (name) ->
    factory = @factories[name]
    factory ? factory : throw new Error("undefined factory \"#{name}\"")

  @getTrait: (factory, name) ->
    trait = factory.traits[name]
    trait ? trait : throw new Error("undefined trait \"#{name}\" for factory \"#{@name}\"")

  @abstractBuild: (names, attrs, build) ->
    names = names.split /\s+/
    name = names[0]

    factory = @getFactory(name)
    traits = names[1..names.length].map (name) => @getTrait factory, name

    attributes = factory.attributes(attrs, traits)
    result = if build then factory[build](name, attributes.withoutIgnored) else attributes.withoutIgnored

    traits.unshift(factory)
    traits.map (factory) -> factory.applyCallbacks result, attributes.withIgnored

    result

  @attributes: (names, attrs) -> @abstractBuild names, attrs
  @build: (names, attrs) -> @abstractBuild names, attrs, 'build'
  @create: (names, attrs) -> @abstractBuild names, attrs, 'create'

  @buildList:  (names, count, attrs) -> [0...count].map => @build names, attrs
  @createList: (names, count, attrs) -> [0...count].map => @create names, attrs

  @buildWith:  (fn) -> @buildFn = fn
  @createWith: (fn) -> @createFn = fn

if module?.exports then module.exports = Factory else window.Factory = Factory
