// babel.config.js
module.exports = function (api) {
  const defaultConfigFunc = require("shakapacker/package/babel/preset.js");
  const resultConfig = defaultConfigFunc(api);
  const isDevelopmentEnv = api.env("development");
  const isProductionEnv = api.env("production");
  const isTestEnv = api.env("test");

  const changesOnDefault = {
    presets: [
      [
        "@babel/preset-react",
        {
          development: isDevelopmentEnv || isTestEnv,
          useBuiltIns: true,
          runtime: "automatic", // Important for React 17 JSX transform
        },
      ],
    ].filter(Boolean),
    plugins: [
      // Don't add @babel/plugin-transform-runtime here since it's already in Shakapacker preset
      isProductionEnv && [
        "babel-plugin-transform-react-remove-prop-types",
        {
          removeImport: true,
        },
      ],
      process.env.WEBPACK_SERVE && "react-refresh/babel",
    ].filter(Boolean),
  };

  // Override the transform-runtime plugin instead of adding it
  const existingPlugins = resultConfig.plugins || [];
  const transformRuntimeIndex = existingPlugins.findIndex(
    (plugin) =>
      Array.isArray(plugin) && plugin[0] === "@babel/plugin-transform-runtime",
  );

  if (transformRuntimeIndex !== -1) {
    // Replace the existing transform-runtime plugin with our configuration
    resultConfig.plugins[transformRuntimeIndex] = [
      "@babel/plugin-transform-runtime",
      {
        helpers: true,
        regenerator: true,
        useESModules: true,
        version: require("@babel/runtime/package.json").version,
      },
    ];
  }

  resultConfig.presets = [...resultConfig.presets, ...changesOnDefault.presets];
  resultConfig.plugins = [...resultConfig.plugins, ...changesOnDefault.plugins];

  return resultConfig;
};
