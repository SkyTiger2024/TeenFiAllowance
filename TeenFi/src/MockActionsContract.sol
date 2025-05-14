// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface IERC7715Actions {
  struct Action {
    address target;
    uint256 value;
    bytes data;
  }

  function execute(address delegate, Action[] calldata actions) external payable returns (bytes[] memory);
  function revoke(address delegate) external;
  function isValidDelegate(address signer, address delegate) external view returns (bool);
}

contract MockActionsContract is IERC7715Actions {
  function execute(address delegate, Action[] calldata actions) external payable override returns (bytes[] memory) {
    bytes[] memory results = new bytes[](actions.length);
    for (uint i = 0; i < actions.length; i++) {
      (bool success, bytes memory result) = actions[i].target.call{value: actions[i].value}(actions[i].data);
      require(success, "Action failed");
      results[i] = result;
    }
    return results;
  }

  function revoke(address delegate) external override {}

  function isValidDelegate(address signer, address delegate) external view override returns (bool) {
    return true;
  }
}