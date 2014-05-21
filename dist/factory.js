/*! factory 1.2.1 */
var Factory,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

Factory = (function() {
  var Adapter;

  function Factory() {}

  Factory.Adapter = Adapter = (function() {
    function Adapter(factory) {
      this.factory = factory;
    }

    Adapter.prototype.build = function(name, attrs) {
      return attrs;
    };

    Adapter.prototype.create = function(name, attrs) {
      return attrs;
    };

    Adapter.prototype.push = function(name, object) {
      return this[name].push(object);
    };

    return Adapter;

  })();

  Factory.factories = {};

  Factory.adapter = Factory.Adapter;

  Factory.clear = function() {
    this.factories = {};
    return this.adapter = Factory.Adapter;
  };

  Factory.reset = function() {
    var factory, name, _ref, _results;
    _ref = this.factories;
    _results = [];
    for (name in _ref) {
      factory = _ref[name];
      _results.push(factory.sequences = {});
    }
    return _results;
  };

  Factory.define = function(name, block) {
    var definition;
    definition = new FactoryDefinition(name);
    if (typeof block === 'function') {
      block.call(definition);
    }
    return this.factories[name] = definition;
  };

  Factory.getFactory = function(name) {
    var factory;
    factory = this.factories[name];
    return factory != null ? factory : {
      factory: (function() {
        throw new Error("undefined factory \"" + name + "\"");
      })()
    };
  };

  Factory.getTrait = function(factory, name) {
    var trait;
    trait = factory.traits[name];
    return trait != null ? trait : {
      trait: (function() {
        throw new Error("undefined trait \"" + name + "\" for factory \"" + this.name + "\"");
      }).call(this)
    };
  };

  Factory.abstractBuild = function(buildType, names, attrs) {
    var attributes, factory, name, result, traits;
    names = names.split(/\s+/);
    name = names[0];
    factory = this.getFactory(name);
    traits = names.slice(1, +names.length + 1 || 9e9).map((function(_this) {
      return function(name) {
        return _this.getTrait(factory, name);
      };
    })(this));
    attributes = factory.attributes(attrs, traits);
    result = factory.build(buildType, name, attributes.withoutIgnored);
    traits.unshift(factory);
    traits.map(function(factory) {
      return factory.applyCallbacks(result, attributes.withIgnored);
    });
    return result;
  };

  Factory.abstractBuildList = function(buildType, names, list, attrs) {
    var _i, _results;
    if (typeof list === 'number') {
      return (function() {
        _results = [];
        for (var _i = 0; 0 <= list ? _i < list : _i > list; 0 <= list ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this).map((function(_this) {
        return function() {
          return _this.abstractBuild(buildType, names, attrs);
        };
      })(this));
    } else if (list instanceof Array) {
      return list.map((function(_this) {
        return function(listItem) {
          if (typeof listItem === 'string') {
            return _this.abstractBuild(buildType, "" + names + " " + listItem, attrs);
          } else if (listItem.constructor === Object) {
            return _this.abstractBuild(buildType, names, _this.hash.merge({}, attrs, listItem));
          } else {
            return listItem;
          }
        };
      })(this));
    }
  };

  Factory.attributes = function(names, attrs) {
    return this.abstractBuild('attributes', names, attrs);
  };

  Factory.build = function(names, attrs) {
    return this.abstractBuild('build', names, attrs);
  };

  Factory.create = function(names, attrs) {
    return this.abstractBuild('create', names, attrs);
  };

  Factory.buildList = function(names, list, attrs) {
    return this.abstractBuildList('build', names, list, attrs);
  };

  Factory.createList = function(names, list, attrs) {
    return this.abstractBuildList('create', names, list, attrs);
  };

  Factory.setupForEmber = function(namespace) {
    if (namespace == null) {
      throw new Error("undefined \"" + namespace + "\"");
    }
    Factory.EmberDataAdapter = (function(_super) {
      __extends(EmberDataAdapter, _super);

      function EmberDataAdapter() {
        return EmberDataAdapter.__super__.constructor.apply(this, arguments);
      }

      EmberDataAdapter.prototype.build = function(name, attrs) {
        return Ember.run(function() {
          return namespace.__container__.lookup('store:main').createRecord(name, attrs);
        });
      };

      EmberDataAdapter.prototype.create = function(name, attrs) {
        return this.build(name, attrs);
      };

      EmberDataAdapter.prototype.push = function(name, object) {
        return Ember.run((function(_this) {
          return function() {
            return _this.get(name).addObject(object);
          };
        })(this));
      };

      return EmberDataAdapter;

    })(Factory.Adapter);
    return Factory.adapter = Factory.EmberDataAdapter;
  };

  Factory.hash = {
    merge: function() {
      var dest, k, obj, objs, v, _i, _len;
      dest = arguments[0], objs = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      for (_i = 0, _len = objs.length; _i < _len; _i++) {
        obj = objs[_i];
        for (k in obj) {
          v = obj[k];
          dest[k] = v;
        }
      }
      return dest;
    },
    evaluate: function(obj) {
      var k, _results;
      _results = [];
      for (k in obj) {
        _results.push(obj[k] = typeof obj[k] === 'function' ? obj[k]() : obj[k]);
      }
      return _results;
    }
  };

  return Factory;

})();

if (typeof module !== "undefined" && module !== null ? module.exports : void 0) {
  module.exports = Factory;
} else {
  window.Factory = Factory;
}

var FactoryDefinition;

FactoryDefinition = (function() {
  function FactoryDefinition(name) {
    this.name = name;
    this.buildAdapter = new Factory.adapter(this);
    this.attrs = {};
    this.ignores = {};
    this.sequences = {};
    this.traits = {};
    this.callbacks = [];
  }

  FactoryDefinition.prototype.adapter = function(adapter) {
    return this.buildAdapter = new adapter(this);
  };

  FactoryDefinition.prototype.build = function(buildType, name, attrs) {
    if (this.buildAdapter[buildType]) {
      return this.buildAdapter[buildType](name, attrs);
    } else {
      return attrs;
    }
  };

  FactoryDefinition.prototype.after = function(callback) {
    return this.callbacks.push(callback);
  };

  FactoryDefinition.prototype.attr = function(attr, value) {
    return this.attrs[attr] = (typeof value === 'function' ? value : function() {
      return value;
    });
  };

  FactoryDefinition.prototype.hasMany = function(attr, factoryName) {
    this.ignore(attr, []);
    return this.after(function(attributes, factory) {
      if (!(this[attr] instanceof Array)) {
        this[attr] = [];
      }
      return Factory.buildList(factoryName, attributes[attr]).forEach((function(_this) {
        return function(object) {
          return factory.buildAdapter['push'].call(_this, attr, object);
        };
      })(this));
    });
  };

  FactoryDefinition.prototype.ignore = function(attr, value) {
    return this.ignores[attr] = (typeof value === 'function' ? value : function() {
      return value;
    });
  };

  FactoryDefinition.prototype.sequence = function(attr, block) {
    var factory;
    factory = this;
    block = block || function(i) {
      return i;
    };
    return this.attrs[attr] = function() {
      factory.sequences[attr] = factory.sequences[attr] || 0;
      return block.call(this, ++factory.sequences[attr]);
    };
  };

  FactoryDefinition.prototype.trait = function(name, block) {
    var definition;
    definition = new FactoryDefinition(name);
    if (typeof block === 'function') {
      block.call(definition);
    }
    return this.traits[name] = definition;
  };

  FactoryDefinition.prototype.attributes = function(attrs, traits) {
    var attr, attributes, ignoredAttributes;
    attributes = Factory.hash.merge({}, attrs);
    ignoredAttributes = {};
    traits.forEach(function(trait) {
      var attr, _results;
      _results = [];
      for (attr in trait.attrs) {
        _results.push(attributes[attr] = trait.attrs[attr]);
      }
      return _results;
    });
    for (attr in this.attrs) {
      if (!attributes.hasOwnProperty(attr)) {
        attributes[attr] = this.attrs[attr];
      }
    }
    for (attr in this.ignores) {
      ignoredAttributes[attr] = attributes.hasOwnProperty(attr) ? attributes[attr] : this.ignores[attr];
      delete attributes[attr];
    }
    Factory.hash.evaluate(attributes);
    Factory.hash.evaluate(ignoredAttributes);
    return {
      withIgnored: Factory.hash.merge({}, attributes, ignoredAttributes),
      withoutIgnored: attributes
    };
  };

  FactoryDefinition.prototype.applyCallbacks = function(result, attributes) {
    return this.callbacks.forEach((function(_this) {
      return function(callback) {
        return callback.call(result, attributes, _this);
      };
    })(this));
  };

  return FactoryDefinition;

})();
