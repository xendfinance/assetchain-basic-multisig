// Sources flattened with hardhat v2.22.12 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol@v5.0.2

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.0.2

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/utils/Address.sol@v5.0.2

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v5.0.2

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}


// File contracts/MultiSigWallet.sol

pragma solidity 0.8.24;

// import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title MultiSigWallet
/// @notice A multi-signature wallet that requires multiple approvers to execute transfers.
/// @dev This contract allows for the management of multiple approvers, transfer requests, and approvals.
contract MultiSigWallet {
    using SafeERC20 for IERC20;

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

    struct ChangeProposal {
        address approver; // New quorum value or address for approver changes
        uint256 value; // New quorum value or address for approver changes
        uint256 approvals;
        mapping(address => bool) hasApproved;
    }

    enum ManagementOption {
        AddApprover,
        RemoveApprover,
        ChangeQuorum
    }

    address private constant _NATIVE =
        0x0000000000000000000000000000000000000001;

    address[] public approvers; // List of approver addresses
    mapping(address => bool) public isApprover; // Mapping to check if an address is an approver
    uint public quorum; // Minimum number of approvers required to approve a transfer
    string public name; // Name of the wallet

    mapping(uint => Transfer) internal _transfers; // Array of transfers
    mapping(uint => Transaction) internal _transactions; // Mapping of transaction IDs to transactions
    uint internal _transactionCount = 1; // Counter for transactions
    uint internal _transferCount = 1; // Counter for transfers

    mapping(address => mapping(uint => bool)) internal _approvals; // Mapping for transfer approvals
    mapping(address => mapping(uint => bool)) internal _transactionApprovals; // Mapping for transaction approvals

    mapping(ManagementOption => ChangeProposal) public proposals;

    // Events
    event TransferCreated(
        uint id,
        uint amount,
        address indexed to,
        address token
    );
    event TransferApproved(uint indexed id, address indexed approver);
    event TransferSent(
        uint indexed id,
        uint amount,
        address indexed to,
        address token
    );
    event TransferCancelled(uint indexed id);
    event TransactionCreated(uint indexed id, address indexed to, bytes data);
    event TransactionApproved(uint indexed id, address indexed approver);
    event TransactionExecuted(uint indexed id, address indexed to, bytes data);
    event TransactionCancelled(uint indexed id);
    event ApproverAdded(address indexed newApprover);
    event ApproverRemoved(address indexed removedApprover);
    event QuorumChanged(uint newQuorum);
    event NewApproverProposed(address indexed approver);
    event NewApproverApproved(address indexed approver);
    event RemoveApproverProposed(address indexed approver);
    event RemoveApproverApproved(address indexed approver);
    event ChangeQuorumProposed(uint newQuorum);
    event ChangeQuorumApproved(uint newQuorum);
    event ProposalCancelled(ManagementOption indexed proposal);

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

    // Modifier for approver-only functions
    modifier onlyApprover() {
        require(isApprover[msg.sender], "Only approver allowed");
        _;
    }

    /// @notice Get the list of approvers
    /// @return List of approver addresses
    function getApprovers() external view returns (address[] memory) {
        return approvers;
    }

    /// @notice Get the current transaction count
    /// @return Current transaction count
    function transactionCount() external view returns (uint) {
        return _transactionCount;
    }

    /// @notice Get the current transfer count
    /// @return Current transfer count
    function transferCount() external view returns (uint) {
        return _transferCount;
    }

    /// @notice Get Transfer by index
    /// @param index transfer Index
    /// @return Transfer structs
    function getTransfer(uint index) external view returns (Transfer memory) {
        require(index > 0 && index < _transferCount, "Transfer does not exist");
        return _transfers[index];
    }

    /// @notice Get Transaction by index
    /// @param index transaction Index
    /// @return Transaction structs
    function getTransaction(
        uint index
    ) external view returns (Transaction memory) {
        require(
            index > 0 && index < _transactionCount,
            "Transaction does not exist"
        );
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
        _transfers[_transferCount] = Transfer(
            _transferCount,
            amount,
            to,
            0,
            false,
            token
        );
        emit TransferCreated(_transferCount, amount, to, token);

        _transferCount++;
    }

    /// @notice Approve a transfer request
    /// @param id ID of the transfer to approve
    function approveTransfer(uint id) external onlyApprover {
        require(id > 0 && id < _transferCount, "Transfer does not exist");
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

                TOKEN.safeTransfer(to, amount);
            }

            emit TransferSent(id, amount, to, token);
        }
    }

    /// @notice Cancel a pending transfer request
    /// @param id ID of the transfer to cancel
    function cancelTransfer(uint id) external onlyApprover {
        require(id > 0 && id < _transferCount, "Transfer does not exist");
        require(_transfers[id].sent == false, "Transfer already sent");

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
        require(id > 0 && id < _transactionCount, "Transaction does not exist");
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
        require(id > 0 && id < _transactionCount, "Transaction does not exist");
        require(
            _transactions[id].executed == false,
            "Transaction already executed"
        );

        _transactions[id].executed = true; // Mark it as executed to prevent further approvals
        emit TransactionCancelled(id);
    }

    /// @notice Propose to add a new approver
    /// @param _newApprover Address of the new approver to add
    function proposeAddApprover(address _newApprover) external onlyApprover {
        require(_newApprover != address(0), "Invalid approver address");
        require(!isApprover[_newApprover], "Already an approver");

        ChangeProposal storage proposal = proposals[
            ManagementOption.AddApprover
        ];
        require(
            !proposal.hasApproved[msg.sender],
            "Cannot approve proposal twice"
        );

        if (proposal.approver == address(0)) {
            proposal.approver = _newApprover;
            emit NewApproverProposed(_newApprover);
        } else {
            require(
                proposal.approver == _newApprover,
                "Previous approver voting was not ended"
            );
        }

        proposal.approvals++;
        proposal.hasApproved[msg.sender] = true;
        emit NewApproverApproved(_newApprover);

        if (proposal.approvals >= quorum) {
            approvers.push(_newApprover);
            isApprover[_newApprover] = true;
            emit ApproverAdded(_newApprover);

            // added this loop to set all proposal.hasApproved to false. because for some reason is always set when approval addresses that have made proposals before
            // trys to register another proposal fails the require(!proposal.hasApproved[msg.sender],"Cannot approve proposal twice") check.Even when
            // delete proposals[ManagementOption.RemoveApprover]; is called
            for (uint256 i = 0; i < proposal.approvals; i++) {
                proposal.hasApproved[approvers[i]] = false;
            }
            // clear variables for the next proposal changes
            delete proposals[ManagementOption.AddApprover];
        }
    }

    /// @notice Propose to remove an existing approver
    /// @param _approverToRemove Address of the approver to remove
    function proposeRemoveApprover(
        address _approverToRemove
    ) external onlyApprover {
        require(isApprover[_approverToRemove], "Not an approver");
        require(approvers.length - 1 >= quorum, "Approvers below quorum");
        require(_approverToRemove != msg.sender, "Cannot remove yourself");

        ChangeProposal storage proposal = proposals[
            ManagementOption.RemoveApprover
        ];
        require(
            !proposal.hasApproved[msg.sender],
            "Cannot approve proposal twice"
        );

        if (proposal.approver == address(0)) {
            proposal.approver = _approverToRemove;
            emit RemoveApproverProposed(_approverToRemove);
        } else {
            require(
                proposal.approver == _approverToRemove,
                "Previous approver voting was not ended"
            );
        }

        proposal.approvals++;
        proposal.hasApproved[msg.sender] = true;
        emit RemoveApproverApproved(_approverToRemove);

        if (proposal.approvals >= quorum) {
            // Find and remove the approver
            for (uint i; i < approvers.length; i++) {
                if (approvers[i] == _approverToRemove) {
                    approvers[i] = approvers[approvers.length - 1];
                    approvers.pop();
                    isApprover[_approverToRemove] = false;

                    emit ApproverRemoved(_approverToRemove);
                    break;
                }
            }

            // added this loop to set all proposal.hasApproved to false. because for some reason is always set when approval addresses that have made proposals before
            // trys to register another proposal fails the require(!proposal.hasApproved[msg.sender],"Cannot approve proposal twice") check.Even when
            // delete proposals[ManagementOption.RemoveApprover]; is called

            for (uint256 i = 0; i < proposal.approvals; i++) {
                proposal.hasApproved[approvers[i]] = false;
            }
            // clear variables for the next proposal changes
            delete proposals[ManagementOption.RemoveApprover];
        }
    }

    /// @notice Propose to change the quorum
    /// @param _newQuorum New quorum value to propose
    function proposeChangeQuorum(uint _newQuorum) external onlyApprover {
        require(
            _newQuorum > 0 && _newQuorum <= approvers.length,
            "Invalid quorum value"
        );

        ChangeProposal storage proposal = proposals[
            ManagementOption.ChangeQuorum
        ];
        require(
            !proposal.hasApproved[msg.sender],
            "Cannot approve proposal twice"
        );

        if (proposal.value == 0) {
            proposal.value = _newQuorum;
            emit ChangeQuorumProposed(_newQuorum);
        } else {
            require(
                proposal.value == _newQuorum,
                "Previous quorum voting was not ended"
            );
        }

        proposal.approvals++;
        proposal.hasApproved[msg.sender] = true;
        emit ChangeQuorumApproved(_newQuorum);

        if (proposal.approvals >= quorum) {
            quorum = _newQuorum;
            emit QuorumChanged(_newQuorum);

            // added this loop to set all proposal.hasApproved to false. because for some reason is always set when approval addresses that have made proposals before
            // trys to register another proposal fails the require(!proposal.hasApproved[msg.sender],"Cannot approve proposal twice") check.Even when
            // delete proposals[ManagementOption.RemoveApprover]; is called
            for (uint256 i = 0; i < proposal.approvals; i++) {
                proposal.hasApproved[approvers[i]] = false;
            }
            // clear variables for the next proposal changes
            delete proposals[ManagementOption.ChangeQuorum];
        }
    }

    /// @notice Cancel a proposal
    /// @param _proposal proposal to canceled
    function cancelProposal(ManagementOption _proposal) external onlyApprover {
        require(
            !(proposals[_proposal].approver == address(0) &&
                proposals[_proposal].value == 0),
            "Proposal is not active"
        );
        for (uint256 i; i < proposals[_proposal].approvals; i++) {
            delete proposals[_proposal].hasApproved[approvers[i]];
        }
        delete proposals[_proposal];
        emit ProposalCancelled(_proposal);
    }

    // Fallback and receive functions to accept Ether
    receive() external payable {}

    fallback() external payable {}
}
