import hre from 'hardhat'
import {config} from 'dotenv'

config()


async function main() {
    const config = hre.network.config
    console.log(`Deploying...`)
    const MultisigWalletFactoryV2 = await hre.ethers.getContractFactory("MultisigWalletFactoryV2");
    const multisigWalletFactoryV2= await MultisigWalletFactoryV2.deploy()
    
    console.log("multisigWalletFactory v2 deployed to:", multisigWalletFactoryV2.target);

}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });