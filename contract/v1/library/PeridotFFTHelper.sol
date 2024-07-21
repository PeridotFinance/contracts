// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '../fundraising/PeridotFFT.sol';

library PeridotFFTHelper {
  function getBytecode(string memory name, string memory symbol)
    public
    pure
    returns (bytes memory)
  {
    bytes memory bytecode = type(PeridotFFT).creationCode;
    return abi.encodePacked(bytecode, abi.encode(name, symbol));
  }
}
