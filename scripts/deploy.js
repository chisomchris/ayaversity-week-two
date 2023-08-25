const hre = require("hardhat");

async function main() {
  const banking = await hre.ethers.deployContract("Banking");

  await banking.waitForDeployment();
  console.log(`Banking deployed to ${banking.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
