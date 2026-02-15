module.exports = {
  apps: [
    {
      name: 'stem-game-backend',
      script: 'src/server.js',
      watch: ['src'],
      env: {
        NODE_ENV: 'development',
        PORT: 3000
      }
    }
  ]
};
