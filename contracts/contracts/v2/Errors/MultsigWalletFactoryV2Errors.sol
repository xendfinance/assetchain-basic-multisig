// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

library MultisigWalletFactoryV2Errors {
    error ApproversRequired();
    error InvalidQuorum(uint value, uint approvalLength);
}