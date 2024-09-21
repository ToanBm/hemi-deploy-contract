#!/bin/bash

# Step 3: Install hardhat
npm init -y

npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers @openzeppelin/contracts

npm install dotenv

# Step 4: Automatically choose "Create an empty hardhat.config.js"
yes "3" | npx hardhat init

echo "Hardhat project initialized with an empty hardhat.config.js."


# Step 4: Create MyToken.sol contract
mkdir contracts 

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
mkdir scripts

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

# Step 5: Compile contracts
npx hardhat compile

# Step 10: Deploy the contract to the Hemi network
npx hardhat run scripts/deploy.js --network hemi
