// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {UntrustedEscrow} from "../src/UntrustedEscrow.sol";
import {BasicToken} from "../src/BasicToken.sol";

contract DeployTokenAndEscrow is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether; // 1 million tokens with 18 decimal places
    
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    uint256 public deployerKey;
    address public deployerAddress;
    address public withdrawUser;

    function run() external returns (BasicToken, UntrustedEscrow) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }
        
        deployerAddress = vm.addr(deployerKey);
        withdrawUser = makeAddr("withdrawUser");

        vm.startBroadcast(deployerKey);
        BasicToken basicToken = new BasicToken(INITIAL_SUPPLY);
        UntrustedEscrow untrustedEscrow = new UntrustedEscrow(address(basicToken), withdrawUser);
        vm.stopBroadcast();
        return (basicToken, untrustedEscrow);
    }
}