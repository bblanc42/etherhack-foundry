// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {console} from "../../utils/Console.sol";
import {DSTest} from "ds-test/test.sol";
import {Utilities} from "../../utils/Utilities.sol";
import {Vm} from "forge-std/Vm.sol";

import {Azino777} from "../Azino777.sol";

contract Azino777Test is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    uint256 internal constant CONTRACT_ETHER = 10 ether;
    uint256 internal constant USER_ETHER = 1 ether;
    Utilities internal utils;
    address payable internal attacker;

    Azino777 internal a777;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        attacker = users[0];
        vm.label(attacker, "Attacker");
        vm.deal(address(attacker), USER_ETHER);

        a777 = new Azino777();
        vm.label(address(a777), "Azino777");
        vm.deal(address(a777), CONTRACT_ETHER);

        assertEq(address(attacker).balance, USER_ETHER);
        assertEq(address(a777).balance, CONTRACT_ETHER);
    }

    function testExploit() public {
        vm.roll(1);
        vm.prank(address(attacker));
        a777.spin{value: 0.01 ether}(100);

        assertEq(address(attacker).balance, CONTRACT_ETHER + USER_ETHER);
        assertEq(address(a777).balance, 0);
    }
}
