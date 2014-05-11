var Factory;

Factory = (function() {
  var Adapter;

  function Factory() {}

  Factory.Adapter = Adapter = (function() {
    function Adapter() {}

    Adapter.prototype.build = function(factory, name, attrs) {
      return attrs;
    };

    Adapter.prototype.create = function(factory, name, attrs) {
      return attrs;
    };

    return Adapter;

  })();

  Factory.factories = {};

  Factory.adapter = new Adapter();

  Factory.clear = function() {
    this.factories = {};
    return this.adapter = new Adapter();
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

  Factory.abstractBuild = function(names, attrs, build) {
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
    result = build ? factory.adapter[build](factory, name, attributes.withoutIgnored) : attributes.withoutIgnored;
    traits.unshift(factory);
    traits.map(function(factory) {
      return factory.applyCallbacks(result, attributes.withIgnored);
    });
    return result;
  };

  Factory.attributes = function(names, attrs) {
    return this.abstractBuild(names, attrs);
  };

  Factory.build = function(names, attrs) {
    return this.abstractBuild(names, attrs, 'build');
  };

  Factory.create = function(names, attrs) {
    return this.abstractBuild(names, attrs, 'create');
  };

  Factory.buildList = function(names, count, attrs) {
    var _i, _results;
    return (function() {
      _results = [];
      for (var _i = 0; 0 <= count ? _i < count : _i > count; 0 <= count ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this).map((function(_this) {
      return function() {
        return _this.build(names, attrs);
      };
    })(this));
  };

  Factory.createList = function(names, count, attrs) {
    var _i, _results;
    return (function() {
      _results = [];
      for (var _i = 0; 0 <= count ? _i < count : _i > count; 0 <= count ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this).map((function(_this) {
      return function() {
        return _this.create(names, attrs);
      };
    })(this));
  };

  return Factory;

})();

if (typeof module !== "undefined" && module !== null ? module.exports : void 0) {
  module.exports = Factory;
} else {
  window.Factory = Factory;
}

var FactoryDefinition,
  __slice = [].slice;

FactoryDefinition = (function() {
  function FactoryDefinition(name) {
    this.name = name;
    this.adapter = Factory.adapter;
    this.attrs = {};
    this.ignores = {};
    this.sequences = {};
    this.traits = {};
    this.callbacks = [];
  }

  FactoryDefinition.prototype.after = function(callback) {
    return this.callbacks.push(callback);
  };

  FactoryDefinition.prototype.attr = function(attr, value) {
    return this.attrs[attr] = (typeof value === 'function' ? value : function() {
      return value;
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
    attributes = this.hash.merge({}, attrs);
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
    this.hash.evaluate(attributes);
    this.hash.evaluate(ignoredAttributes);
    return {
      withIgnored: this.hash.merge({}, attributes, ignoredAttributes),
      withoutIgnored: attributes
    };
  };

  FactoryDefinition.prototype.applyCallbacks = function(result, attributes) {
    return this.callbacks.forEach(function(callback) {
      return callback.call(result, attributes);
    });
  };

  FactoryDefinition.prototype.hash = {
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

  return FactoryDefinition;

})();
