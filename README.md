# Deploy an ERC-20 Token
- Open [Github Codespace](https://github.com/codespaces)
- Paste the below command to Deploy an ERC-20 Token
## 1. Initialize Your NPM Project
```Bash
npm init -y
```
## 2. Install Hardhat & Ethers.js Plugin
```Bash
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers @openzeppelin/contracts
```
## 3. Create a HardHat Project
```Bash
npx hardhat init
```
## 4. Add Folder
```Bash
mkdir contracts && mkdir scripts
```
## 5. Write Your Contract
```Bash
nano contracts/MyToken.sol
```
```Bash
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }
}
```
## 6. Compile Your Contract
```Bash
npx hardhat compile
```
## 7. Secure Your Private Key for Deployment
```Bash
npm install dotenv
```
```Bash
nano .env
```
```Bash
PRIVATE_KEY=your_private_key
```
## 8. Configure Hardhat for the Testnet
```Bash
nano hardhat.config.js
```
```Bash
/** @type import('hardhat/config').HardhatUserConfig */
require('dotenv').config()
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.20",
  networks: {
    hemi: {
      url: "https://testnet.rpc.hemi.network/rpc",
      chainId: 743111,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  }
};
```
## 9. Write a Deployment Script
```Bash
nano scripts/deploy.js
```
```Bash
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
```
## 10. Deploy the Contract
```Bash
npx hardhat run scripts/deploy.js --network hemi
```
## Done!

















