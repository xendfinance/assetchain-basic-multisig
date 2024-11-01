import hre from 'hardhat'
import {config} from 'dotenv'

config()

const approvals = [process.env.APPROVAL1!, process.env.APPROVAL2!];
const name = "Wallet";
const quorem = 2;

async function main() {
    const config = hre.network.config
    console.log(`Deploying...`)
    const MultiSigWalletV2 = await hre.ethers.getContractFactory("MultisigWalletV2");
    const multiSigWalletv2= await MultiSigWalletV2.deploy(approvals, quorem, name);
    
    console.log("multiSigWallet v2 deployed to:", multiSigWalletv2.target);

}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });