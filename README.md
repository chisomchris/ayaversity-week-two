# Ayaversity Home Study Task 2

This project is a task for ayaversity home study course.

This project runs a script which interacts with a Banking Smart contract deployed on hardhat local network.

## Smart Contract Interaction Project

This project demonstrates basic interaction with smart contract using ethers js. Contract is deployed on a local hardhat network and connected to via a JSONRPC.

See how to use below:

- clone repo
- run `npm install` to install dependencies
- run `npx hardhat compile` to compile contracts
- run `npx hardhat node` to start a local sever
- run `npx hardhat run --network localhost  scripts/deploy.js` to deploy contract to local server
- uncomment functions as they appear in order and run `node scripts/banking.js` to at each stage
- feel free to play around
