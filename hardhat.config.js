require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  paths: {
    sources:  "./contracts",
    artifacts: './artifacts'
  },
  allowUnlimitedContractSize: true,
  //abaixo goerli/eth
  // etherscan: {
  //   apiKey: "RXWDRFIWDHDEQS6TA5GIMUN53YXDPS4YP5"
  // },
  //abaixo api da polygon
  etherscan:{
    apiKey: "XS33Y7XEMA2YGDHDSHV5ZYH3FQ372M18TU"
  },
  defaultNetwork: 'goerli',
  networks: {
    hardhat: {
      chainId: 1337,
    },
    goerli: {
      url: 'https://eth-goerli.g.alchemy.com/v2/k6FWDIy0oyWYJ8NCyfzAY6JJp_FvtYoR',
      accounts: ['39b50cd9075f70c00df3efda5b28d19a5f5d18b253bbbaeca48ddab5f7e06ff4']
    },
    mumbai: {
      url: 'https://polygon-mumbai.g.alchemy.com/v2/di4KdLr9SEe1oT-DO1muEFJzSsBWZD5F',
      accounts: ['39b50cd9075f70c00df3efda5b28d19a5f5d18b253bbbaeca48ddab5f7e06ff4']
    }
  }
};
