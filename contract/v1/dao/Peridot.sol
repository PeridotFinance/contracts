// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract PeridotToken is ERC20, ERC20Burnable, Ownable {
    uint256 public constant MAX_SUPPLY = 1e9 * 10**18; // 1 billion tokens, with 18 decimal places

    constructor() ERC20('Peridot Finance', 'Peridot') {
        // Mint 490 million tokens initially
        _mint(msg.sender, 490e6 * 10**18);
    }

    /**
     * @dev Allows the MasterChef contract to mint new tokens, ensuring the total supply does not exceed the maximum.
     * This function can only be called by the owner of the token contract.
     * @param to The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "PeridotToken: cannot exceed maximum supply");
        _mint(to, amount);
    }
}
