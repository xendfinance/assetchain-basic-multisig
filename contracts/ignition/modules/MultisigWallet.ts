import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const approvals = ["0xA5d439D40AB03bB908102ca99aeC9f1eF74bb1b5", "0xA81733D57f62dc268137b4c31ad9C803BF2F18Cf"];
const name = "Wallet";
const quorem = 2;

const MultiSigWalletModule = buildModule("MultiSigWalletModule", (m) => {
  const multiSigWallet = m.contract("MultiSigWallet", [
    approvals,
    quorem,
    name,
  ]);

  return { multiSigWallet };
});

export default MultiSigWalletModule;
