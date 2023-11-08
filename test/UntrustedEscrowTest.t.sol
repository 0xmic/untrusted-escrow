// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {StdCheats, console2} from "forge-std/StdCheats.sol";
import {BasicToken} from "../src/BasicToken.sol";
import {UntrustedEscrow} from "../src/UntrustedEscrow.sol";
import {DeployTokenAndEscrow} from "../script/DeployTokenAndEscrow.s.sol";

contract UntrustedEscrowTest is StdCheats, Test {
    BasicToken public basicToken;
    UntrustedEscrow public untrustedEscrow;
    DeployTokenAndEscrow public deployer;

    address public deployerAddress;
    address public withdrawUser;

    uint256 constant WAIT_DURATION = 3 days;

    function setUp() public {
        deployer = new DeployTokenAndEscrow();
        (basicToken, untrustedEscrow) = deployer.run();
        deployerAddress = deployer.deployerAddress();
        withdrawUser = deployer.withdrawUser();
    }

    // test token name
    function test_TokenName() public {
        assertEq(basicToken.name(), "BasicToken");
    }

    // test deployer address is escrow depositor
    function test_DeployerAddress() public {
        assertEq(deployerAddress, untrustedEscrow.buyer());
    }

    // test buyer is able to deposit basic tokens
    function test_EscrowDeposit() public {
        uint256 amount = 100 ether;
        vm.startPrank(deployerAddress);
        basicToken.approve(address(untrustedEscrow), amount);
        untrustedEscrow.deposit(amount);
        vm.stopPrank();
        assertEq(basicToken.balanceOf(address(untrustedEscrow)), amount);
    }

    function test_EscrowWithdraw() public {
        uint256 amount = 100 ether;
        
        // Deployer deposits tokens into escrow
        vm.startPrank(deployerAddress);
        basicToken.approve(address(untrustedEscrow), amount);
        untrustedEscrow.deposit(amount);
        vm.stopPrank();
        assertEq(basicToken.balanceOf(address(untrustedEscrow)), amount);
        assertEq(basicToken.balanceOf(deployerAddress), basicToken.totalSupply() - amount);

        // Fast forward time
        uint256 DEPOSIT_TIMESTAMP = untrustedEscrow.depositTimestamp();
        skip(DEPOSIT_TIMESTAMP + WAIT_DURATION + 1 days);

        // Withdraw user withdraws tokens from escrow
        vm.startPrank(withdrawUser);
        untrustedEscrow.withdraw();
        vm.stopPrank();

        assertEq(basicToken.balanceOf(address(untrustedEscrow)), 0);
        assertEq(basicToken.balanceOf(withdrawUser), amount);
    }
}