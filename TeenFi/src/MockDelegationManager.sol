// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IDelegationManager} from "./TeenFiAllowance.sol";

contract MockDelegationManager is IDelegationManager {
    mapping(address => mapping(address => bool)) public delegations;

    function redeemDelegations(
        bytes[] calldata permissionContexts,
        bytes[] calldata modes,
        bytes[] calldata executionCallDatas
    ) external payable override returns (bool) {
        require(permissionContexts.length == 1, "Invalid permission contexts");
        require(modes.length == 1, "Invalid modes");
        require(executionCallDatas.length == 1, "Invalid execution call datas");

        // Decode the delegation
        IDelegationManager.Delegation memory delegation = abi.decode(permissionContexts[0], (IDelegationManager.Delegation));
        require(delegation.delegate != address(0), "Invalid delegate");
        require(delegation.delegator != address(0), "Invalid delegator");

        // Simulate successful delegation redemption
        delegations[delegation.delegator][delegation.delegate] = true;

        return true;
    }

    // Helper function to check delegation status
    function isDelegated(address delegator, address delegate) external view returns (bool) {
        return delegations[delegator][delegate];
    }
}