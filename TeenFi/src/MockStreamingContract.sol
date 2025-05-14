// src/MockStreamingContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interface for ERC-7715 Token Streaming
interface IERC7715TokenStreaming {
    function createStream(
        address recipient,
        address token,
        uint256 amountPerSecond,
        uint256 duration
    ) external returns (uint256 streamId);
    
    function cancelStream(uint256 streamId) external;
    function withdrawFromStream(uint256 streamId, uint256 amount) external;
    function getStream(uint256 streamId) external view returns (
        address sender,
        address recipient,
        address token,
        uint256 amountPerSecond,
        uint256 startTime,
        uint256 duration,
        uint256 withdrawnAmount
    );
}

contract MockStreamingContract is IERC7715TokenStreaming {
  mapping(uint256 => Stream) private streams;
  uint256 private streamIdCounter;

  struct Stream {
    address sender;
    address recipient;
    address token;
    uint256 amountPerSecond;
    uint256 startTime;
    uint256 duration;
    uint256 withdrawnAmount;
  }

  function createStream(
    address recipient,
    address token,
    uint256 amountPerSecond,
    uint256 duration
  ) external override returns (uint256 streamId) {
    streamId = streamIdCounter++;
    streams[streamId] = Stream({
      sender: msg.sender,
      recipient: recipient,
      token: token,
      amountPerSecond: amountPerSecond,
      startTime: block.timestamp,
      duration: duration,
      withdrawnAmount: 0
    });
  }

  function cancelStream(uint256 /*streamId*/) external override {}
  function withdrawFromStream(uint256 /*streamId*/, uint256 /*amount*/) external override {}
  function getStream(uint256 streamId) external view override returns (
    address sender, address recipient, address token, uint256 amountPerSecond,
    uint256 startTime, uint256 duration, uint256 withdrawnAmount
  ) {
    Stream memory stream = streams[streamId];
    return (
      stream.sender, stream.recipient, stream.token, stream.amountPerSecond,
      stream.startTime, stream.duration, stream.withdrawnAmount
    );
  }
}