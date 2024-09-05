const HtmlWebpackPlugin = require("html-webpack-plugin");
const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const { CleanWebpackPlugin } = require('clean-webpack-plugin');

let demo = process.env.DEMO
module.exports = {
	entry: "./src/index.ts",
	mode: "development",
	output: {
		filename: "bundle.[fullhash].js",
		path: path.resolve(__dirname,  "..", "snowballs", "renderer"),
	},
	plugins: [
		new CleanWebpackPlugin(), 
		new HtmlWebpackPlugin({
			template: demo ? `./demos/${demo}.html` : "./src/index.html",
		}),
		new MiniCssExtractPlugin(),
	],
	resolve: {
		modules: [__dirname, "src", "node_modules"],
		extensions: ["*", ".js", ".jsx", ".tsx", ".ts"],
	},
	module: {
		rules: [
			{
				test: /\.(js|ts)x?$/,
				exclude: /node_modules/,
				use: ["babel-loader"],
			},
			{
				test: /\.(png|svg|jpg|gif)$/,
				exclude: /node_modules/,
				use: ["file-loader"],
			},
			{
				test: /\.css$/i,
				use: [
					MiniCssExtractPlugin.loader,
					{
						loader: require.resolve("css-loader"),
						options: {
							url: false,
						},
					},
				],
			},
		],
	},
};
