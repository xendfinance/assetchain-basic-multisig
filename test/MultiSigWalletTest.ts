import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
  import { expect } from "chai";

  import hre from "hardhat";

  describe("Multi-Signature Contract", function(){

    async function deployContractFixture(){

      
        const [owner, approver1, approver2,nonApprover] = await hre.ethers.getSigners();
  
        const externalContractFactory = await hre.ethers.getContractFactory("ExternalContract");
        const externalContract = await externalContractFactory.deploy();

        const multiSigContractFactory = await hre.ethers.getContractFactory("MultiSigWallet");
        const multiSigContract = await multiSigContractFactory.deploy([owner.address, approver1.address, approver2.address], 2);

        return {owner, approver1, approver2, externalContract,multiSigContract, nonApprover };
        
    }

    describe("Mult-Sig - External Contract Interaction", function(){

        // it("Should call the external contract setValue function",async function(){

        //     const { owner, approver1, approver2, externalContract,multiSigContract, nonApprover } = await loadFixture(deployContractFixture);
        //     const externalContractAddress = await externalContract.getAddress();
        //     const multiSigContractAddress = await multiSigContract.getAddress();

        //     console.log("External Contract Address: %s, Multi-Sig Contract Address: %s",externalContractAddress, multiSigContractAddress);

        //     // Create an Interface for the ExternalContract

        //     const externalContractInterface = new hre.ethers.Interface(["function setValue(uint256)"]);
        //     const setValueData = externalContractInterface.encodeFunctionData("setValue", [42]);

        //     // Encode the call data for the external contract's setValue function
        //     const setValueSig = setValueData.slice(0,10); // first 4 bytes of the keccak256 hash

        //     console.log( "setValueData: %s", setValueData);
        //     console.log( "setValueSig: %s", setValueSig);

        //     const storedValueBefore = await externalContract.storedValue();
        //     console.log("Stored Value:%s", hre.ethers.formatEther(storedValueBefore));

        //     // Create a transfer in the multi-sig wallet
        //     await multiSigContract.connect(owner).createTransfer(0, externalContractAddress, setValueData, setValueSig);

        //     // Approve the transfer by the required quorum
        //     await multiSigContract.connect(owner).approveTransfer(0);
        //     await multiSigContract.connect(approver1).approveTransfer(0);

        //     // Check if the external contract's storedValue has been set
        //     const storedValue = await externalContract.storedValue();
        //     console.log("Stored Value:%s", hre.ethers.formatEther(storedValue));
        //     expect(storedValue).to.equal(42);

            
        // });

        it("should allow multi-sig wallet to call external contract", async function () {
            const { owner, approver1, approver2, externalContract,multiSigContract, nonApprover } = await loadFixture(deployContractFixture);
            const externalContractAddress = await externalContract.getAddress();
            const multiSigContractAddress = await multiSigContract.getAddress();

            console.log("External Contract Address: %s, Multi-Sig Contract Address: %s",externalContractAddress, multiSigContractAddress);
            
            // Create an Interface for the ExternalContract
            const externalContractInterface = new hre.ethers.Interface(["function setValue(uint256)"]);
        
            // Encode the call data for the external contract's setValue function
            const setValueData = externalContractInterface.encodeFunctionData("setValue", [42]);
        
            console.log( "setValueData: %s", setValueData);

            // Create a transfer in the multi-sig wallet
            await multiSigContract.connect(owner).createTransfer(0, externalContractAddress, setValueData);
        
            //  Store value data before transfer
            const storedValueBefore = await externalContract.storedValue();
            console.log("Stored Value Before Call:%s", storedValueBefore);

            // Approve the transfer by the required quorum
            await multiSigContract.connect(owner).approveTransfer(0);
            await multiSigContract.connect(approver1).approveTransfer(0);
        
            // Check if the external contract's storedValue has been set
            const storedValue = await externalContract.storedValue();
            console.log("Stored Value After Call :%s", storedValue);

            expect(storedValue).to.equal(42);
          });

    });


  });