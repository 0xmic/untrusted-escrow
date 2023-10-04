// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract BasicToken is ERC20, Ownable2Step {
    constructor(uint256 initialSupply) ERC20("BasicToken", "BT") {
        _mint(msg.sender, initialSupply);
    }
}