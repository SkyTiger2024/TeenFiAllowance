// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "@forge-std/Script.sol";
import {console} from "@forge-std/console.sol";
import {MockActionsContract} from "../src/MockActionsContract.sol";
import {MockStreamingContract} from "../src/MockStreamingContract.sol";

contract DeployMocks is Script {
  function run() external {
    vm.startBroadcast();

    MockActionsContract actionsContract = new MockActionsContract();
    MockStreamingContract streamingContract = new MockStreamingContract();

    console.log("_actionsContract:", address(actionsContract));
    console.log("_streamingContract:", address(streamingContract));

    vm.stopBroadcast();
  }
}