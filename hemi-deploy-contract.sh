#!/bin/bash

# Step 1: Install Node.js (if not installed)
if ! command -v node &> /dev/null
then
    echo "Node.js not found. Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js is already installed."
fi

# Step 2: Install npx if not installed
if ! command -v npx &> /dev/null
then
    echo "npx not found. Installing npx..."
    npm install -g npx
else
    echo "npx is already installed."
fi

# Step 3: Install hardhat
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers @openzeppelin/contracts

# Step 4: Automatically choose "Create an empty hardhat.config.js"
yes "" | npx hardhat

echo "Hardhat project initialized with an empty hardhat.config.js."


# Step 2: Create the necessary Hardhat files manually instead of using npx hardhat init

# Step 4: Create MyToken.sol contract
rm  contracts/Lock.sol
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

cat <<EOF > .env
PRIVATE_KEY=$PRIVATE_KEY
EOF

# Step 8: Update hardhat.config.js with the proper configuration
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
