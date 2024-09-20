#!/bin/bash

# Step 1: Initialize npm and install dependencies
npm init -y
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers @openzeppelin/contracts

# Step 2: Initialize Hardhat
npx hardhat init

# Step 3: Create empty hardhat.config.js
echo '/** @type import("hardhat/config").HardhatUserConfig */
module.exports = {};' > hardhat.config.js

# Step 4: Create contracts and scripts directories
mkdir contracts scripts

# Step 5: Create MyToken.sol contract
cat <<EOL > contracts/MyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }
}
EOL

# Step 6: Compile contracts
npx hardhat compile

# Step 7: Install dotenv package
npm install dotenv

# Step 8: Create .env file for storing private key
cat <<EOL > .env
PRIVATE_KEY=your_private_key
EOL
echo "Please replace 'your_private_key' with your actual private key in the .env file."

# Step 9: Update hardhat.config.js
rm hardhat.config.js
cat <<EOL > hardhat.config.js
/** @type import('hardhat/config').HardhatUserConfig */
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.20",
  networks: {
    hemi: {
      url: "https://testnet.rpc.hemi.network/rpc",
      chainId: 743111,
      accounts: [\`0x\${process.env.PRIVATE_KEY}\`],
    },
  }
};
EOL

# Step 10: Create deploy script
cat <<EOL > scripts/deploy.js
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    const initialSupply = ethers.utils.parseUnits("1000", "ether");

    const Token = await ethers.getContractFactory("MyToken");
    const token = await Token.deploy(initialSupply);

    console.log("Token deployed to:", token.address);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
EOL

# Step 11: Deploy the contract to the Hemi network
npx hardhat run scripts/deploy.js --network hemi
