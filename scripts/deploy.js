const hre = require ('hardhat');
	
async function main() {
  const LegalBlocks = await hre.ethers.getContractFactory("LegalBlocksOZ");
  const lb = await LegalBlocks.deploy();

  await lb.deployed();

  console.log(
    `deployed to ${lb.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
