// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

library MultisigWalletV2Errors {
    error InsufficientBalance();
    error FailedToTransferNativeValue(address to, uint _amount);
}