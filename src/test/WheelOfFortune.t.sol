// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {console} from "../../utils/Console.sol";
import {DSTest} from "ds-test/test.sol";
import {Utilities} from "../../utils/Utilities.sol";
import {Vm} from "forge-std/Vm.sol";

import {WheelOfFortune} from "../WheelOfFortune.sol";

contract WheelOfFortuneTest is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    uint256 internal constant CONTRACT_ETHER = 10 ether;
    uint256 internal constant USER_ETHER = 1 ether;
    Utilities internal utils;
    address payable internal attacker;

    WheelOfFortune internal wof;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        attacker = users[0];
        vm.label(attacker, "Attacker");
        vm.deal(address(attacker), USER_ETHER);

        wof = new WheelOfFortune();
        vm.label(address(wof), "WheelOfFortune");
        vm.deal(address(wof), CONTRACT_ETHER);

        assertEq(address(attacker).balance, USER_ETHER);
        assertEq(address(wof).balance, CONTRACT_ETHER);
    }

    function testExploit() public {
        assertEq(address(attacker).balance, CONTRACT_ETHER + USER_ETHER);
        assertEq(address(wof).balance, 0);
    }
}
