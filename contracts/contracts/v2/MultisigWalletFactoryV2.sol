// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./MultisigWalletV2.sol";
import {MultisigWalletFactoryV2Errors} from "./Errors/MultsigWalletFactoryV2Errors.sol";

contract MultisigWalletFactoryV2 {
    // Event to log the creation of a new MultiSigWallet
    event WalletCreated(address indexed walletAddress, address[] approvers, uint256 quorum, string _name);

    // Mapping from approvers to the list of wallets they are involved in
    mapping(address => address[]) private approverToWallets;

    // List of all wallets created by the factory
    address[] public allWallets;

    // Function to create a new MultiSigWallet
    function createWallet(address[] memory approvers, uint256 quorum, string calldata _name) external returns (address) {
        if (approvers.length <= 0) revert MultisigWalletFactoryV2Errors.ApproversRequired();
        if (quorum <= 0 && quorum > approvers.length) revert MultisigWalletFactoryV2Errors.InvalidQuorum(quorum, approvers.length);

        // Create a new instance of MultiSigWallet
        MultisigWalletV2 wallet = new MultisigWalletV2(approvers, quorum, _name);

        // Track the wallet in the mapping for each approver
        for (uint256 i = 0; i < approvers.length; i++) {
            approverToWallets[approvers[i]].push(address(wallet));
        }

        // Add the new wallet to the list of all wallets
        allWallets.push(address(wallet));

        // Emit the WalletCreated event with the address of the new wallet, approvers, and quorum
        emit WalletCreated(address(wallet), approvers, quorum, _name);

        // Return the address of the new wallet
        return address(wallet);
    }

    // Function to get the wallets an approver is part of
    function getWalletsForApprover(address approver) external view returns (address[] memory) {
        return approverToWallets[approver];
    }
}
