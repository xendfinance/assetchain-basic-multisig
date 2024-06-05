// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

contract MultiSigWallet {
    address[] public approvers;
    uint public quorum;
    mapping(address => mapping(uint => bool)) public approvals;
    Transfer[] public transfers;

    // struct Transfer {
    //     uint id;
    //     address payable to;
    //     uint amount;
    //     uint approvals;
    //     bool sent;
    //     bytes data; // added data field to store external contract call data
    //     bytes4 sig; // added sig field to store external contract function signature
    // }
    struct Transfer {
        uint id;
        address payable to;
        uint amount;
        uint approvals;
        bool sent;
        bytes data;
    }

    constructor(address[] memory _approvers, uint _quorum) {
        approvers = _approvers;
        quorum = _quorum;
    }

    function getApprovers() external view returns(address[] memory) {
        return approvers;
    }

    function getTransfers() external view returns(Transfer[] memory) {
        return transfers;
    }

    // function createTransfer(uint amount, address payable to, bytes memory data, bytes4 sig) external onlyApprover() {
    //     transfers.push(Transfer(transfers.length, to, amount, 0, false, data, sig));
    // }

    // function approveTransfer(uint id) external onlyApprover() {
    //     require(transfers[id].sent == false, 'Transfer has already been sent');
    //     require(approvals[msg.sender][id] == false, 'cannot approve transfer twice');
    //     approvals[msg.sender][id] = true;
    //     transfers[id].approvals++;
    //     if (transfers[id].approvals >= quorum) {
    //         transfers[id].sent = true;
    //         address payable to = transfers[id].to;
    //         uint amount = transfers[id].amount;
    //         bytes memory data = transfers[id].data;
    //         bytes4 sig = transfers[id].sig;

    //         // Create the call data
    //         bytes memory callData = abi.encodePacked(sig, data);

    //         // Call external contract function
    //         (bool success, ) = to.call{value: amount}(callData);
    //         require(success, 'External contract call failed');
    //     }
    // }
    function createTransfer(uint amount, address payable to, bytes memory data) external onlyApprover() {
        transfers.push(Transfer(transfers.length, to, amount, 0, false, data));
    }

    function approveTransfer(uint id) external onlyApprover() {
        require(transfers[id].sent == false, "Transfer has already been sent");
        require(approvals[msg.sender][id] == false, "cannot approve transfer twice");

        approvals[msg.sender][id] = true;
        transfers[id].approvals++;

        if (transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            bytes memory data = transfers[id].data;
            (bool success, ) = to.call(data);
            require(success, "External contract call failed");
        }
    }
     modifier onlyApprover() {
        bool allowed = false;
        for (uint i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                allowed = true;
                break;
            }
        }
        require(allowed == true, "Only approver allowed");
        _;
    }

    // Function to receive RWA
    receive() external payable {}
}