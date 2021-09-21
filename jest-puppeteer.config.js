const headless = true;
const port = 4444;

module.exports = {
  server: {
    command: `RAILS_ENV=test ./bin/rails s -e test -p ${port} -P tmp/pids/test-server.pid`,
    port,
    launchTimeout: 40000,
    debug: true,
    launch: {
      headless,
    },
  },
};
