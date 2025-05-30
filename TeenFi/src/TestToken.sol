// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
  constructor() ERC20("Test Token", "TST") {
    _mint(msg.sender, 1000000 ether); // 1M tokens
  }
}
