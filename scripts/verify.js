async function main() {
  await hre.run('verify:verify', {
    address: 'ContractName',
    constructorArguments: [
      'NFTName',
      'NFTSymbol'
    ],
  });
};

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
});