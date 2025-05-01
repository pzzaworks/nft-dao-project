const hre = require("hardhat");

async function main() {
    const Contract = await hre.ethers.getContractFactory('ContractName');
    const contract = await Contract.deploy(
        'NFTName',
        'NFTSymbol'
    );

    await contract.deployed();
    console.log(`Contract deployed to ${contract.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
});
    