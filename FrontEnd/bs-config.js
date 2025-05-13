module.exports = {
  port: 3000,
  open: true,
  server: {
    baseDir: "./",
    https: {
      key: "./cert.key",
      cert: "./cert.crt"
    }
  }
};