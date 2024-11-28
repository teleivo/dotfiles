return require('telescope').register_extension({
  exports = {
    test = require('telescope-test').test,
  },
})
