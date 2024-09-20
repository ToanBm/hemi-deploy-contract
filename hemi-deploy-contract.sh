#!/bin/bash

# Step 1: Initialize npm and install dependencies
mkdir my-project && cd my-project
npm init -y
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers @openzeppelin/contracts

# Step 2: Create the necessary Hardhat files manually instead of using npx hardhat init
mkdir contracts && mkdir scripts

# Step 4: Create MyToken.sol contract
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

# Step 5: Compile contracts
npx hardhat compile

# Step 6: Install dotenv package
npm install dotenv

# Step 7: Create .env file for storing private key
read -p "Enter your EVM wallet private key (without 0x): " PRIVATE_KEY

print_command "Generating .env file..."
cat <<EOF > .env
PRIVATE_KEY=$PRIVATE_KEY
EOF

# Step 8: Update hardhat.config.js with the proper configuration
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

# Step 9: Create deploy script
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

# Step 10: Deploy the contract to the Hemi network
npx hardhat run scripts/deploy.js --network hemi
