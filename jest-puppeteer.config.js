const headless = true;
const port = 4444;

module.exports = {
  server: {
    command: `./bin/rails s -e test -p ${port} -P tmp/pids/test-server.pid`,
    port,
    launchTimeout: (40 * 1000),
    debug: true,
    launch: {
      headless,
    },
  },
};
