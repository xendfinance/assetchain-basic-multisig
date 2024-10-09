import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from 'dotenv'

config()

const approvals = [process.env.APPROVAL1!, process.env.APPROVAL2!, process.env.APPROVAL3!];
const name = "Wallet";
const quorem = 2;

console.log(approvals)

const MultiSigWalletModule = buildModule("MultiSigWalletModule", (m) => {
  const multiSigWallet = m.contract("MultiSigWallet", [
    approvals,
    quorem,
    name,
  ]);

  return { multiSigWallet };
});

export default MultiSigWalletModule;
