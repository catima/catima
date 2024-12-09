module.exports = {
  ci: {
    collect: {
      numberOfRuns: 3,
      url: [
        'http://localhost:3001/one/en',
        'http://localhost:3001/one/en/authors',
        'http://localhost:3001/one/en/authors/525911936-author-with-images'
      ],
      startServerCommand: 'rails server -p 3001',
    },
    upload: {
      target: 'filesystem',
      outputDir: 'lhci-reports',
    },
  },
};
