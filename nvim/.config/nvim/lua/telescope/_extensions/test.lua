return require('telescope').register_extension({
  exports = {
    test = require('my-test').test_picker,
  },
})
