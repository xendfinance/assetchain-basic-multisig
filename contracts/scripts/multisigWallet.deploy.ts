import hre from 'hardhat'

const approvals = ["0x4E5f57313e2a8be74115e0Dd4bAbdD6E45d266f7", "0x31f2b36E6a086De69B88F2a0D4444AaDF52038Fc"];
const name = "Wallet";
const quorem = 2;

async function main() {

    const MultiSigWallet = await hre.ethers.getContractFactory("MultiSigWallet");
    const multiSigWallet= await MultiSigWallet.deploy(approvals, quorem, name);
    
    console.log("multiSigWallet deployed to:", multiSigWallet.target);

}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });