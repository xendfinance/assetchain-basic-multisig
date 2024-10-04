import hre from 'hardhat'
import {config} from 'dotenv'

config()

const approvals = [process.env.APPROVAL1!, process.env.APPROVAL2!, process.env.APPROVAL3!];
const name = "Wallet";
const quorem = 2;

async function main() {
    const config = hre.network.config
    console.log(`Deploying...`)
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