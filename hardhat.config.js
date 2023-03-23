require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  paths: {
    sources:  "./contracts",
    artifacts: './artifacts'
  },
  allowUnlimitedContractSize: true,
  etherscan: {
    apiKey: "RXWDRFIWDHDEQS6TA5GIMUN53YXDPS4YP5"
  },
  defaultNetwork: 'goerli',
  networks: {
    hardhat: {
      chainId: 1337,
    },
    goerli: {
      url: 'https://eth-goerli.g.alchemy.com/v2/k6FWDIy0oyWYJ8NCyfzAY6JJp_FvtYoR',
      accounts: ['39b50cd9075f70c00df3efda5b28d19a5f5d18b253bbbaeca48ddab5f7e06ff4']
    }
  }
};
