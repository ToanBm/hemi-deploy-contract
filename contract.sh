#!/bin/bash
# Logo
curl -s https://raw.githubusercontent.com/ToanBm/user-info/main/logo.sh | bash
sleep 3

show() {
    echo -e "\033[1;35m$1\033[0m"
}

# Step 1: Install hardhat
echo "Install Hardhat..."
npm init -y
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers @openzeppelin/contracts
echo "Install dotenv..."
npm install dotenv

# Step 2: Automatically choose "Create an empty hardhat.config.js"
echo "Creating project with an empty hardhat.config.js..."
yes "3" | npx hardhat init

# Step 3: Create MyToken.sol contract
echo "Create ERC20 contract..."
mkdir contracts 
cat <<EOL > contracts/MyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Hemi Token Test", "HEMI") {
        _mint(msg.sender, initialSupply);
    }
}
EOL

# Step 4: Create .env file for storing private key
echo "Create .env file..."

read -p "Enter your EVM wallet private key (without 0x): " PRIVATE_KEY
cat <<EOF > .env
PRIVATE_KEY=$PRIVATE_KEY
EOF

# Step 5: Update hardhat.config.js with the proper configuration
echo "Creating new hardhat.config file..."
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

# Step 6: Create deploy script
echo "Creating deploy script..."
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

# Step 7: Compile contracts
echo "Compile your contracts..."
npx hardhat compile

# "Waiting before deploying..."
sleep 10

# Step 8: Deploy the contract to the Hemi network
echo "Deploy your contracts..."
npx hardhat run scripts/deploy.js --network hemi

echo "Thank you!"

