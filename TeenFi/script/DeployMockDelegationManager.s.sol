// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MockDelegationManager} from "../src/MockDelegationManager.sol";

contract DeployMockDelegationManager is Script {
    function run() external {
        vm.startBroadcast();
        MockDelegationManager mockDM = new MockDelegationManager();
        console.log("MockDelegationManager deployed to:", address(mockDM));
        vm.stopBroadcast();
    }
}