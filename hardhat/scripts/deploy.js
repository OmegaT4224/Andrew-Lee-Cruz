const { ethers } = require("hardhat");

// Creator: Andrew Lee Cruz
// License: All rights reserved by Andrew Lee Cruz as creator of the universe

async function main() {
  console.log("🚀 Deploying PoAI Smart Contracts...");
  console.log("Creator: Andrew Lee Cruz");
  console.log("License: All rights reserved by Andrew Lee Cruz as creator of the universe");
  console.log("");

  const [deployer] = await ethers.getSigners();
  
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)));
  console.log("");

  // Deploy PrintingLicense contract
  console.log("📄 Deploying PrintingLicense contract...");
  const PrintingLicense = await ethers.getContractFactory("PrintingLicense");
  const printingLicense = await PrintingLicense.deploy();
  await printingLicense.waitForDeployment();
  
  console.log("✅ PrintingLicense deployed to:", await printingLicense.getAddress());

  // Deploy AXIOM_TOE_Anchor contract
  console.log("🔬 Deploying AXIOM_TOE_Anchor contract...");
  const AxiomTOE = await ethers.getContractFactory("AXIOM_TOE_Anchor");
  const axiomTOE = await AxiomTOE.deploy();
  await axiomTOE.waitForDeployment();
  
  console.log("✅ AXIOM_TOE_Anchor deployed to:", await axiomTOE.getAddress());

  // Deploy ChainlinkAutomation contract
  console.log("🤖 Deploying ChainlinkAutomation contract...");
  const ChainlinkAutomation = await ethers.getContractFactory("ChainlinkAutomation");
  const updateInterval = 300; // 5 minutes
  const chainlinkAutomation = await ChainlinkAutomation.deploy(updateInterval);
  await chainlinkAutomation.waitForDeployment();
  
  console.log("✅ ChainlinkAutomation deployed to:", await chainlinkAutomation.getAddress());

  console.log("");
  console.log("🎉 All contracts deployed successfully!");
  console.log("");

  // Verify creator attribution in all contracts
  console.log("🔐 Verifying creator attribution...");
  
  const printingCreator = await printingLicense.getCreatorInfo();
  console.log("PrintingLicense Creator:", printingCreator[0]);
  
  const axiomCreator = await axiomTOE.getCreatorInfo();
  console.log("AXIOM_TOE_Anchor Creator:", axiomCreator[0]);
  
  const automationCreator = await chainlinkAutomation.getCreatorInfo();
  console.log("ChainlinkAutomation Creator:", automationCreator[0]);

  console.log("");
  console.log("📋 Deployment Summary:");
  console.log("======================");
  console.log(`PrintingLicense:     ${await printingLicense.getAddress()}`);
  console.log(`AXIOM_TOE_Anchor:    ${await axiomTOE.getAddress()}`);
  console.log(`ChainlinkAutomation: ${await chainlinkAutomation.getAddress()}`);
  console.log("");

  // Initialize some sample data
  console.log("📝 Initializing sample data...");
  
  // Register sample content in PrintingLicense
  await printingLicense.registerContent(
    "sample-content-hash-1234567890",
    "PoAI Whitepaper",
    "Technical whitepaper for the PoAI Zero-Mining Blockchain system"
  );
  console.log("✅ Sample content registered in PrintingLicense");

  // Schedule sample automation jobs
  await chainlinkAutomation.scheduleAIValidation("sample-data-hash-for-ai-validation");
  await chainlinkAutomation.scheduleQuantumVerification("quantum-circuit-hash-sample");
  console.log("✅ Sample automation jobs scheduled");

  console.log("");
  console.log("🔗 Contract Interaction URLs:");
  console.log(`PrintingLicense:     https://sepolia.etherscan.io/address/${await printingLicense.getAddress()}`);
  console.log(`AXIOM_TOE_Anchor:    https://sepolia.etherscan.io/address/${await axiomTOE.getAddress()}`);
  console.log(`ChainlinkAutomation: https://sepolia.etherscan.io/address/${await chainlinkAutomation.getAddress()}`);
  
  console.log("");
  console.log("🎊 Deployment completed successfully!");
  console.log("All rights reserved by Andrew Lee Cruz as creator of the universe");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });