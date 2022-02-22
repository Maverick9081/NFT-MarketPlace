const { tasks } = require("hardhat/config");
const { getAccount, getEnvVariable } = require("./helpers");


task("check-balance", "Prints out the balance of your account").setAction(async function (taskArguments, hre) {
    const account = getAccount();
    console.log(`Account balance for ${account.address}: ${await account.getBalance()}`);
});

task("deploy-token", "Deploys the ERC20 contract").setAction(async function (taskArguments, hre) {
    const tokenContractFactory = await hre.ethers.getContractFactory("Token", getAccount());
    const token = await tokenContractFactory.deploy();
    console.log(`Contract deployed to address: ${token.address}`);
});

task("deploy-ERC721", "Deploys the ERC721 contract").setAction(async function (taskArguments, hre) {
    const nftContractFactory = await hre.ethers.getContractFactory("NFT", getAccount());
    const nft = await nftContractFactory.deploy("https://ipfs.io/ipfs/bafkreiecbxumwqrlr4yw6z4rlrlhjqdvmw36p27yxzg44pmv7pos4mgujy?filename=3");
    console.log(`Contract deployed to address: ${nft.address}`);
});

task("deploy-marketPlace", "Deploys the ERC20 contract").setAction(async function (taskArguments, hre) {
    const marketContractFactory = await hre.ethers.getContractFactory("MarketPlace", getAccount());
    const marketPlace = await marketContractFactory.deploy(getEnvVariable("TOKEN_ADDRESS"),getEnvVariable("NFT_CONTRACT_ADDRESS"));
    console.log(`Contract deployed to address: ${marketPlace.address}`);
});