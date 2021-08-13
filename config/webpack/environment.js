const { environment } = require('@rails/webpacker');

const environmentConfig = environment.config;
const outputConfig = environmentConfig.get('output');
const { fileName } = outputConfig;
outputConfig.chunkFilename = fileName;

module.exports = environment;
