require("@nomiclabs/hardhat-waffle");
const CONFIG = require("../config.json")

module.exports = {
  solidity: "0.8.1",
  networks: {
    goerli: {
      url: CONFIG.ALCHEMY_URL,
      accounts: [CONFIG.GOERLI_PRIVATE_KEY],
    },
  },
};