// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script} from "@forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TeenFiAllowance} from "../src/TeenFiAllowance.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MockDelegationManager} from "../src/MockDelegationManager.sol";

contract TestTeenFi is Script {
    // Deployed contract addresses
    address constant TEENFI_ADDRESS = 0x4a631b162D58756C2568F03744d63037Bd4348d9; // TeenFiAllowance address
    address constant TOKEN_ADDRESS = 0x1230591e26044F0AA562c24b4d7Fd002b227E69c;
    address constant DELEGATION_MANAGER = 0xD464A84c5ed04d34B0431464c173b782ae5602F6; // MockDelegationManager address

    // Test parameters
    address teen = 0xfFF8f28f6E86C72FB3c11003dC6c3a05E9ea3E91;
    uint256 weeklyAmount = 100 ether;
    uint256 spendingCap = 400 ether;
    bytes delegationTerms = abi.encode("test terms");

    function run() external {
        vm.startBroadcast();

        TeenFiAllowance teenFi = TeenFiAllowance(TEENFI_ADDRESS);
        IERC20 token = IERC20(TOKEN_ADDRESS);
        MockDelegationManager mockDM = MockDelegationManager(DELEGATION_MANAGER);

        // Register parent-teen relationship
        console.log("Registering parent for teen...");
        (bool success, bytes memory data) = address(teenFi).call(
            abi.encodeWithSignature("addParent(address,address)", msg.sender, teen)
        );
        if (!success) {
            console.log("Raw revert data:");
            console.logBytes(data);
            string memory reason;
            if (data.length >= 68) {
                (, reason) = abi.decode(data, (bytes4, string));
            } else {
                reason = "Unknown error";
            }
            console.log("addParent failed:", reason);
            revert("addParent failed");
        }
        console.log("Parent registered");

        // Approve TeenFiAllowance to spend tokens
        console.log("Approving TeenFiAllowance for configureAllowance...");
        (success, data) = address(token).call(
            abi.encodeWithSignature("approve(address,uint256)", TEENFI_ADDRESS, 1000 ether)
        );
        if (!success) {
            console.log("Raw revert data:");
            console.logBytes(data);
            string memory reason;
            if (data.length >= 68) {
                (, reason) = abi.decode(data, (bytes4, string));
            } else {
                reason = "Unknown error";
            }
            console.log("Approval failed:", reason);
            revert("Approval failed");
        }
        console.log("Approval successful");

        // Configure allowance with delegation
        console.log("Calling configureAllowance...");
        (success, data) = address(teenFi).call{gas: 500000}(
            abi.encodeWithSignature(
                "configureAllowance(address,address,uint256,uint256,bytes)",
                teen,
                TOKEN_ADDRESS,
                weeklyAmount,
                spendingCap,
                delegationTerms
            )
        );
        if (!success) {
            console.log("Raw revert data:");
            console.logBytes(data);
            string memory reason;
            if (data.length >= 68) {
                (, reason) = abi.decode(data, (bytes4, string));
            } else {
                reason = "Unknown error";
            }
            console.log("configureAllowance failed:", reason);
            revert("configureAllowance failed");
        }
        console.log("configureAllowance successful");

        // Verify delegation
        console.log("Verifying delegation...");
        bool isDelegated = mockDM.isDelegated(msg.sender, teen);
        console.log("Delegation status:", isDelegated);
        require(isDelegated, "Delegation not created");

        // Test modifyAllowance
        console.log("Calling modifyAllowance...");
        (success, data) = address(teenFi).call{gas: 500000}(
            abi.encodeWithSignature(
                "modifyAllowance(address,uint256,uint256)",
                teen,
                weeklyAmount,
                spendingCap
            )
        );
        if (!success) {
            console.log("Raw revert data:");
            console.logBytes(data);
            string memory reason;
            if (data.length >= 68) {
                (, reason) = abi.decode(data, (bytes4, string));
            } else {
                reason = "Unknown error";
            }
            console.log("modifyAllowance failed:", reason);
            revert("modifyAllowance failed");
        }
        console.log("modifyAllowance successful");

        vm.stopBroadcast();
    }
}