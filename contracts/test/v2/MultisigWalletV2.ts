import { expect } from "chai";
import hre from "hardhat";
const ethers = hre.ethers;
import { Contract, Signer } from "ethers";
import { ExternalContract, MultisigWalletV2, Token } from "../../typechain-types";

const _NATIVE = `0x0000000000000000000000000000000000000001`;

enum ManagementOption {
  AddApprover,
  RemoveApprover,
  ChangeQuorum,
}

describe("MultiSigWallet V2", () => {
  let wallet: MultisigWalletV2;
  let externalContract: ExternalContract;
  let token: Token;
  let address: string;
  let externalContractaddress: string;
  let accounts: Signer[];

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const MultiSigWalletV2 = await ethers.getContractFactory(
      "MultisigWalletV2"
    );
    const ExternalContract = await ethers.getContractFactory(
      "ExternalContract"
    );
    const Token = await ethers.getContractFactory("Token");
    wallet = await MultiSigWalletV2.deploy(
      [
        await accounts[0].getAddress(),
        await accounts[1].getAddress(),
        await accounts[2].getAddress(),
      ],
      2,
      "wallet"
    );
    externalContract = (await ExternalContract.deploy()) as ExternalContract;
    token = (await Token.deploy("Test Token", "TK", 6, 2000)) as Token;
    address = await wallet.getAddress();
    externalContractaddress = await externalContract.getAddress();
    await accounts[0].sendTransaction({
      value: ethers.parseEther("30"),
      to: address,
    });
    await accounts[1].sendTransaction({
      value: ethers.parseEther("30"),
      to: externalContractaddress,
    });
  });

  describe("Deployment", () => {
    it("should deploy with correct approvers, quorum and name", async () => {
      const approvers = await wallet.getApprovers();
      const quorum = await wallet.quorum();
      const name = await wallet.name();

      expect(approvers.length).to.equal(3);
      expect(approvers[0]).to.equal(await accounts[0].getAddress());
      expect(approvers[1]).to.equal(await accounts[1].getAddress());
      expect(approvers[2]).to.equal(await accounts[2].getAddress());
      expect(quorum).to.equal(2);
      expect(name).to.equal("wallet");
    });

    it("should receive funds", async () => {
      const balance = await ethers.provider.getBalance(address);
      expect(ethers.formatEther(balance)).to.equal("30.0");
    });
  });

  describe("Transfers (Native)", () => {
    it("should create a transfer", async () => {
      await wallet
        .connect(accounts[0])
        .createTransfer(
          ethers.parseEther("0.1"),
          await accounts[2].getAddress(),
          _NATIVE
        );

      const transfer = await wallet.getTransfer(1);

      expect(transfer.id).to.equal(1);
      expect(ethers.formatEther(transfer.amount)).to.equal("0.1");
      expect(transfer.to).to.equal(await accounts[2].getAddress());
      expect(transfer.approvals).to.equal(0);
      expect(transfer.sent).to.be.false;
    });

    it("should approve and send transfer if quorum reached", async () => {
      await wallet
        .connect(accounts[0])
        .createTransfer(
          ethers.parseEther("0.1"),
          await accounts[2].getAddress(),
          _NATIVE
        );
      await wallet.connect(accounts[0]).approveTransfer(1);
      await wallet.connect(accounts[1]).approveTransfer(1);

      const transfer = await wallet.getTransfer(1);

      expect(transfer.sent).to.be.true;
    });

    it("should not allow non-approver to create a transfer", async () => {
      await expect(
        wallet
          .connect(accounts[3])
          .createTransfer(
            ethers.parseEther("0.1"),
            await accounts[2].getAddress(),
            _NATIVE
          )
      ).to.be.revertedWith("Only approver allowed");
    });

    it("should not allow non-approver to approve a transfer", async () => {
      await expect(
        wallet.connect(accounts[3]).approveTransfer(0)
      ).to.be.revertedWith("Only approver allowed");
    });

    it("should not approve transfer twice by the same approver", async () => {
      await wallet
        .connect(accounts[0])
        .createTransfer(
          ethers.parseEther("0.1"),
          await accounts[2].getAddress(),
          _NATIVE
        );
      await wallet.connect(accounts[0]).approveTransfer(1);
      await expect(
        wallet.connect(accounts[0]).approveTransfer(1)
      ).to.be.revertedWith("Cannot approve transfer twice");
    });

    it("should not approve a transfer that has already been sent", async () => {
      await wallet
        .connect(accounts[0])
        .createTransfer(
          ethers.parseEther("0.1"),
          await accounts[2].getAddress(),
          _NATIVE
        );
      await wallet.connect(accounts[0]).approveTransfer(1);
      await wallet.connect(accounts[1]).approveTransfer(1);

      await expect(
        wallet.connect(accounts[2]).approveTransfer(1)
      ).to.be.revertedWith("Transfer already sent");
    });
    it("should cancel a trnsfer if it exists and has not been sent", async () => {
      await wallet
        .connect(accounts[0])
        .createTransfer(
          ethers.parseEther("0.1"),
          await accounts[2].getAddress(),
          _NATIVE
        );
      await wallet.connect(accounts[0]).cancelTransfer(1);
      const transfer = await wallet.getTransfer(1);
      expect(transfer.canceled).to.be.true;
    });
    it("should revert if trying to cancel a non-existent transfer", async () => {
      await expect(
        wallet.connect(accounts[0]).cancelTransaction(999)
      ).to.be.revertedWith("Transaction does not exist");
    });
  });

  describe("Transactions", () => {
    it("should create a transaction", async () => {
      const data = wallet.interface.encodeFunctionData("name");
      await wallet
        .connect(accounts[0])
        .createTransaction(await accounts[1].getAddress(), data, 0);

      const transaction = await wallet.getTransaction(1);
      expect(transaction.id).to.equal(1);
      expect(transaction.to).to.equal(await accounts[1].getAddress());
      expect(transaction.data).to.equal(data);
      expect(transaction.approvals).to.equal(1);
      expect(transaction.executed).to.be.false;
      expect(transaction.canceled).to.be.false;
    });

    it("should approve and execute transaction if quorum reached", async () => {
      const data = wallet.interface.encodeFunctionData("name");
      await wallet.connect(accounts[1]).createTransaction(address, data, 0);
      await wallet.connect(accounts[2]).approveTransaction(1);

      const transaction = await wallet.getTransaction(1);
      expect(transaction.executed).to.be.true;
    });

    it("should not allow non-approver to create a transaction", async () => {
      const data = wallet.interface.encodeFunctionData("name");
      await expect(
        wallet
          .connect(accounts[3])
          .createTransaction(await accounts[1].getAddress(), data, 0)
      ).to.be.revertedWith("Only approver allowed");
    });

    it("should not allow non-approver to approve a transaction", async () => {
      await expect(
        wallet.connect(accounts[3]).approveTransaction(1)
      ).to.be.revertedWith("Only approver allowed");
    });

    it("should not approve transaction twice by the same approver", async () => {
      const data = wallet.interface.encodeFunctionData("name");
      await wallet
        .connect(accounts[0])
        .createTransaction(await accounts[1].getAddress(), data, 0);
      await expect(
        wallet.connect(accounts[0]).approveTransaction(1)
      ).to.be.revertedWith("Cannot approve transaction twice");
    });

    it("should not approve a transaction that has already been executed", async () => {
      const data = wallet.interface.encodeFunctionData("name");
      await wallet
        .connect(accounts[0])
        .createTransaction(await accounts[1].getAddress(), data, 0);
      await wallet.connect(accounts[1]).approveTransaction(1);

      await expect(
        wallet.connect(accounts[2]).approveTransaction(1)
      ).to.be.revertedWith("Transaction already executed");
    });
    it("should expect correct result when excuting external contract functions", async () => {
      const withdrawalAdress = await accounts[0].getAddress();
      const amounttoSend = ethers.parseEther("1");
      const balanceOfAccount1Before = await ethers.provider.getBalance(
        withdrawalAdress
      );
      const data = externalContract.interface.encodeFunctionData("withdraw", [
        withdrawalAdress,
        amounttoSend,
      ]);
      await wallet
        .connect(accounts[1])
        .createTransaction(externalContractaddress, data, 0);
      await wallet.connect(accounts[2]).approveTransaction(1);

      const balanceOfAccount1After = await ethers.provider.getBalance(
        withdrawalAdress
      );

      expect(balanceOfAccount1Before + amounttoSend).equal(
        balanceOfAccount1After
      );
    });

    it("should send native value(if passed) when excuting external contract functions", async () => {
      const amounttoSend = ethers.parseEther("1");
      // await accounts[0].sendTransaction({
      //   value: amounttoSend,
      //   to: wallet.target,
      // });
      const balanceOfmultisigBefore = await ethers.provider.getBalance(
        wallet.target
      );
      const balanceOfExternalContractBefore = await ethers.provider.getBalance(
        externalContract.target
      );
      const data = externalContract.interface.encodeFunctionData("setValue", [
        100,
      ]);
      await wallet
        .connect(accounts[1])
        .createTransaction(externalContractaddress, data, amounttoSend);
      await wallet.connect(accounts[2]).approveTransaction(1);

      const balanceOfmultisigAfter = await ethers.provider.getBalance(
        wallet.target
      );
      const balanceOfExternalContractAfter = await ethers.provider.getBalance(
        externalContract.target
      );
      expect(balanceOfmultisigBefore - amounttoSend).equal(
        balanceOfmultisigAfter
      );
      expect(balanceOfExternalContractBefore + amounttoSend).equal(
        balanceOfExternalContractAfter
      );
      expect(await externalContract.storedValue()).equal(100);
    });

    it("should cancel a transaction if it exists and has not been executed", async () => {
      const withdrawalAdress = await accounts[0].getAddress();
      const amounttoSend = ethers.parseEther("1");

      const data = externalContract.interface.encodeFunctionData("withdraw", [
        withdrawalAdress,
        amounttoSend,
      ]);
      await wallet
        .connect(accounts[1])
        .createTransaction(externalContractaddress, data, 0);
      await wallet.connect(accounts[2]).cancelTransaction(1);

      const transaction = await wallet.getTransaction(1);

      expect(transaction.canceled).to.be.true;
    });

    it("should revert if trying to cancel a non-existent transaction", async () => {
      await expect(
        wallet.connect(accounts[0]).cancelTransaction(999)
      ).to.be.revertedWith("Transaction does not exist");
    });
  });

  describe("Propose Add Approver", () => {
    it("should propose a new approver", async () => {
      await wallet
        .connect(accounts[0])
        .proposeAddApprover(await accounts[3].getAddress());
      const proposal = await wallet.proposals(ManagementOption.AddApprover);
      expect(proposal.approver).to.equal(await accounts[3].getAddress());
    });

    it("should revert if proposing an already existing approver", async () => {
      await expect(
        wallet
          .connect(accounts[0])
          .proposeAddApprover(await accounts[1].getAddress())
      ).to.be.revertedWith("Already an approver");
    });

    it("should revert if proposing a zero address", async () => {
      await expect(
        wallet.connect(accounts[0]).proposeAddApprover(ethers.ZeroAddress)
      ).to.be.revertedWith("Invalid approver address");
    });

    it("should approve new approver", async () => {
      await wallet
        .connect(accounts[1])
        .proposeAddApprover(await accounts[3].getAddress());
      await wallet
        .connect(accounts[0])
        .proposeAddApprover(await accounts[3].getAddress());
      const isApprover = await wallet.isApprover(
        await accounts[3].getAddress()
      );

      expect(isApprover).to.be.true;
    });
  });

  describe("Propose Remove Approver", () => {
    it("should propose to prpose removin an existing approver", async () => {
      await wallet.connect(accounts[0]).proposeRemoveApprover(accounts[2]);
      const proposal = await wallet.proposals(ManagementOption.RemoveApprover);
      expect(proposal.approver).to.equal(accounts[2]);
    });

    it("should remove an existing approver", async () => {
      await wallet.connect(accounts[0]).proposeRemoveApprover(accounts[2]);
      await wallet.connect(accounts[1]).proposeRemoveApprover(accounts[2]);
      const proposal = await wallet.proposals(ManagementOption.RemoveApprover);

      const isApprover = await wallet.isApprover(accounts[2]);
      expect(proposal.approver).to.equal(ethers.ZeroAddress);
      expect(isApprover).to.be.false;
    });

    it("should revert if trying to remove a non-approver", async () => {
      await expect(
        wallet
          .connect(accounts[0])
          .proposeRemoveApprover(await accounts[4].getAddress())
      ).to.be.revertedWith("Not an approver");
    });

    it("should revert if trying to remove yourself", async () => {
      await expect(
        wallet
          .connect(accounts[0])
          .proposeRemoveApprover(await accounts[0].getAddress())
      ).to.be.revertedWith("Cannot remove yourself");
    });
  });
  describe("Propose Change Quorum", () => {
    it("should propose a new quorum", async () => {
      await wallet.connect(accounts[0]).proposeChangeQuorum(3);
      const proposal = await wallet.proposals(ManagementOption.ChangeQuorum);
      expect(proposal.value).to.equal(3);
    });

    it("should revert if proposing an invalid quorum", async () => {
      await expect(
        wallet.connect(accounts[0]).proposeChangeQuorum(0)
      ).to.be.revertedWith("Invalid quorum value");
    });
  });
  describe("cancelProposal", function () {
    it("should cancel an active proposal", async function () {
      // Propose a change (e.g., adding an approver)
      await wallet.connect(accounts[0]).proposeAddApprover(accounts[4]); // Replace with a valid address

      // Cancel the proposal
      await wallet
        .connect(accounts[1])
        .cancelProposal(ManagementOption.AddApprover);

      // Check that the proposal is canceled
      const proposal = await wallet.proposals(ManagementOption.AddApprover);
      expect(proposal.approver).to.equal(ethers.ZeroAddress);
    });

    it("should revert if no active proposal exists", async function () {
      await expect(
        wallet.cancelProposal(ManagementOption.AddApprover)
      ).to.be.revertedWith("Proposal is not active");
    });
  });
});
