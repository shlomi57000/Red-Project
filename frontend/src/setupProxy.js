const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = function(app) {
  app.use(
    '/api',
    createProxyMiddleware({
      // target: 'http://backend:3001',
      target: `http://${process.env.REACT_APP_BACKEND}:3001`,
      changeOrigin: true,
    })
  );
};