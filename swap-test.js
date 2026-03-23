const { ethers } = require("hardhat");
const crypto = require("crypto");

async function main() {
  const [alice, bob] = await ethers.getSigners();

  // 1. Alice generates a secret and its hash
  const preimage = crypto.randomBytes(32);
  const hashlock = ethers.keccak256(preimage);
  const swapId = ethers.randomBytes(32);

  console.log("Secret (Preimage):", preimage.toString('hex'));
  console.log("Hashlock:", hashlock);

  const HTLC = await ethers.getContractFactory("AtomicSwapHTLC");
  const htlc = await HTLC.deploy();
  await htlc.waitForDeployment();

  console.log("HTLC deployed to:", await htlc.getAddress());
  
  // Note: Alice would need to approve the HTLC contract for the token amount first.
  console.log("Ready to initiate swap with ID:", ethers.hexlify(swapId));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
