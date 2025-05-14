// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script} from "forge-std/Script.sol";
import {console} from "@forge-std/console.sol";
import {TeenFiAllowance} from "src/TeenFiAllowance.sol";

contract DeployTeenFiAllowance is Script {
  function run() external {
    vm.startBroadcast();

    TeenFiAllowance teenFiAllowance = new TeenFiAllowance(
      0xD464A84c5ed04d34B0431464c173b782ae5602F6, // _delegationManager (MockDelegationManager)
      0x56c97aE02f233B29fa03502Ecc0457266d9be00e, // _caveatEnforcer (ERC20StreamingEnforcer)
      0x3A4A2B75FA0e9c8dB60bC92A6B0616A3b473def6, // _actionsContract (MockActionsContract)
      0x65e302187f01745Eb8D9bc44CDC361f68d3339d7 // _streamingContract (MockStreamingContract)
    );

    console.log("TeenFiAllowance deployed to:", address(teenFiAllowance));

    vm.stopBroadcast();
  }
}