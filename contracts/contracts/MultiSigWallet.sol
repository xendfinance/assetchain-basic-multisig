// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title MultiSigWallet
/// @notice A multi-signature wallet that requires multiple approvers to execute transfers.
/// @dev This contract allows for the management of multiple approvers, transfer requests, and approvals.
contract MultiSigWallet {

    address private constant _NATIVE = 0x0000000000000000000000000000000000000001;

    address[] public approvers; // List of approver addresses
    mapping(address => bool) public isApprover; // Mapping to check if an address is an approver
    uint public quorum; // Minimum number of approvers required to approve a transfer
    string public name; // Name of the wallet


    Transfer[] internal _transfers; // Array of transfers
    mapping(uint => Transaction) internal _transactions; // Mapping of transaction IDs to transactions
    uint internal _transactionCount = 1; // Counter for transactions

    mapping(address => mapping(uint => bool)) internal _approvals; // Mapping for transfer approvals
    mapping(address => mapping(uint => bool)) internal _transactionApprovals; // Mapping for transaction approvals


    struct Transfer {
        uint id; 
        uint amount;
        address payable to; 
        uint approvals;
        bool sent;
        address token;
    }


    struct Transaction {
        uint id;
        address to;
        bytes data;
        uint approvals;
        bool executed;
    }

    // Events
    event TransferCreated(uint id, uint amount, address indexed to, address token);
    event TransferApproved(uint indexed id, address indexed approver);
    event TransferSent(uint indexed id, uint amount, address indexed to, address token);
    event TransferCancelled(uint indexed id);
    event TransactionCreated(uint indexed id, address indexed to, bytes data);
    event TransactionApproved(uint indexed id, address indexed approver);
    event TransactionExecuted(uint indexed id, address indexed to, bytes data);
    event TransactionCancelled(uint indexed id);
    event ApproverAdded(address indexed newApprover);
    event ApproverRemoved(address indexed removedApprover);
    event QuorumChanged(uint newQuorum);

    /// @notice Constructor to initialize the MultiSigWallet
    /// @param _approvers List of approvers
    /// @param _quorum Minimum number of approvers required
    /// @param _name Name of the wallet
    constructor(
        address[] memory _approvers,
        uint _quorum,
        string memory _name
    ) {
        require(_approvers.length > 0, "Approvers required");
        require(_quorum > 0 && _quorum <= _approvers.length, "Invalid quorum");

        approvers = _approvers;
        quorum = _quorum;
        name = _name;

        for (uint i = 0; i < _approvers.length; i++) {
            isApprover[_approvers[i]] = true;
        }
    }

    /// @notice Get the list of approvers
    /// @return List of approver addresses
    function getApprovers() external view returns (address[] memory) {
        return approvers;
    }

    /// @notice Get the list of transfers
    /// @return Array of Transfer structs
    function getTransfers() external view returns (Transfer[] memory) {
        return _transfers;
    }

    /// @notice Get the current transaction count
    /// @return Current transaction count
    function transactionCount() external view returns (uint) {
        return _transactionCount;
    }

    /// @notice Get Transfer by index
    /// @param index transfer Index
    /// @return Transfer structs
    function getTransfer(uint index) external view returns (Transfer memory) {
        return _transfers[index];
    }

    /// @notice Get Transaction by index
    /// @param index transaction Index
    /// @return Transaction structs
    function getTransaction(uint index) external view returns (Transaction memory) {
        return _transactions[index];
    }

    /// @notice Create a new transfer request
    /// @param amount Amount to be transferred
    /// @param to Recipient address
    /// @param token Address of the ERC20 token (0x0 for Ether)
    function createTransfer(
        uint amount,
        address payable to,
        address token
    ) external onlyApprover {
        require(amount > 0, "Transfer amount must be greater than 0");
        require(to != address(0), "Invalid recipient address");
        require(token != address(0), "Invalid token address");
        

        _transfers.push(Transfer(_transfers.length, amount, to, 0, false, token));
        emit TransferCreated(_transfers.length - 1, amount, to, token);
    }

    /// @notice Approve a transfer request
    /// @param id ID of the transfer to approve
    function approveTransfer(uint id) external onlyApprover {
        require(_transfers[id].sent == false, "Transfer already sent");
        require(
            _approvals[msg.sender][id] == false,
            "Cannot approve transfer twice"
        );

        _approvals[msg.sender][id] = true;
        _transfers[id].approvals++;

        emit TransferApproved(id, msg.sender);

        if (_transfers[id].approvals >= quorum) {
            _transfers[id].sent = true;
            address payable to = _transfers[id].to;
            uint amount = _transfers[id].amount;
            address token = _transfers[id].token;

            if (token == _NATIVE) {
                // Transfer Ether
                require(
                    address(this).balance >= amount,
                    "Insufficient contract balance"
                );

                (bool success, ) = to.call{value: amount}("");
                require(success, "Transfer failed.");
            } else {
                // Transfer ERC20 token
                IERC20 TOKEN = IERC20(token);
                require(
                    TOKEN.balanceOf(address(this)) >= amount,
                    "Insufficient token balance"
                );

                require(TOKEN.transfer(to, amount), "Token transfer failed.");
            }

            emit TransferSent(id, amount, to, token);
        }
    }

    /// @notice Cancel a pending transfer request
    /// @param id ID of the transfer to cancel
    function cancelTransfer(uint id) external onlyApprover {
        require(_transfers[id].sent == false, "Transfer already sent");
        require(_transfers[id].approvals < quorum, "Transfer already approved");

        _transfers[id].sent = true; // Mark it as sent to prevent further approvals
        emit TransferCancelled(id);
    }

    /// @notice Create a new transaction request
    /// @param to Recipient address
    /// @param data Transaction data
    function createTransaction(
        address to,
        bytes calldata data
    ) external onlyApprover {
        require(to != address(0), "Invalid recipient address");

        _transactions[_transactionCount] = Transaction(
            _transactionCount,
            to,
            data,
            1,
            false
        );
        _transactionApprovals[msg.sender][_transactionCount] = true;

        emit TransactionCreated(_transactionCount, to, data);
        emit TransactionApproved(_transactionCount, msg.sender);

        _transactionCount++;
    }

    /// @notice Approve a transaction request
    /// @param id ID of the transaction to approve
    function approveTransaction(uint id) external onlyApprover {
        require(
            _transactions[id].executed == false,
            "Transaction already executed"
        );
        require(
            _transactionApprovals[msg.sender][id] == false,
            "Cannot approve transaction twice"
        );

        _transactionApprovals[msg.sender][id] = true;
        _transactions[id].approvals++;

        emit TransactionApproved(id, msg.sender);

        if (_transactions[id].approvals >= quorum) {
            _transactions[id].executed = true;
            (bool success, ) = _transactions[id].to.call(
                _transactions[id].data
            );
            require(success, "Transaction execution failed");

            emit TransactionExecuted(
                id,
                _transactions[id].to,
                _transactions[id].data
            );
        }
    }

    /// @notice Cancel a pending transaction request
    /// @param id ID of the transaction to cancel
    function cancelTransaction(uint id) external onlyApprover {
        require(_transactions[id].executed == false, "Transaction already executed");
        require(_transactions[id].approvals < quorum, "Transaction already approved");

        _transactions[id].executed = true; // Mark it as executed to prevent further approvals
        emit TransactionCancelled(id);
    }


    /// @notice Add a new approver
    /// @param newApprover Address of the new approver
    function addApprover(address newApprover) external onlyApprover {
        require(newApprover != address(0), "Invalid approver address");
        require(!isApprover[newApprover], "Already an approver");

        approvers.push(newApprover);
        isApprover[newApprover] = true;
        emit ApproverAdded(newApprover);
    }

    /// @notice Remove an existing approver
    /// @param approverToRemove Address of the approver to remove
    function removeApprover(address approverToRemove) external onlyApprover {
        require(isApprover[approverToRemove], "Not an approver");
        require(approvers.length - 1 >= quorum, "Approvers below quorum");
        require(approverToRemove != msg.sender, "Cannot remove yourself");

        // Find and remove the approver
        for (uint i = 0; i < approvers.length; i++) {
            if (approvers[i] == approverToRemove) {
                approvers[i] = approvers[approvers.length - 1];
                approvers.pop();
                isApprover[approverToRemove] = false;
                emit ApproverRemoved(approverToRemove);
                break;
            }
        }
    }

    /// @notice Change the quorum value
    /// @param newQuorum New quorum value
    function changeQuorum(uint newQuorum) external onlyApprover {
        require(newQuorum <= approvers.length, "Quorum too high");
        quorum = newQuorum;
        emit QuorumChanged(newQuorum);
    }

    // Fallback and receive functions to accept Ether
    receive() external payable {}

    fallback() external payable {}

    // Modifier for approver-only functions
    modifier onlyApprover() {
        require(isApprover[msg.sender], "Only approver allowed");
        _;
    }
}
