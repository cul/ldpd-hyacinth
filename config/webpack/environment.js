const { environment } = require('@rails/webpacker');

// Add aliases
const aliasConfig = require('./aliases');

environment.config.merge(aliasConfig);

module.exports = environment;
