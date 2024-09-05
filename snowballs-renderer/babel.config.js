
module.exports = {
  presets: [
    [
      '@babel/preset-env',
      {
        targets: '> 0.25%, not dead', // This ensures compatibility with a wide range of browsers
        useBuiltIns: 'usage',
        corejs: 3,
      },
    ],
    '@babel/preset-react', // Transforms JSX syntax
    '@babel/preset-typescript', // Transforms TypeScript
  ],
  plugins: [
    // Add any plugins you need
  ],
};