// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BirthdayFactory} from "./BirthdayFactory.sol";
import {Birthday} from "./Birthday.sol";

contract Setup {
    BirthdayFactory public birthdayFactoryContract;

    constructor() {
        birthdayFactoryContract = new BirthdayFactory();
    }

    function isSolved() public view returns (bool) {
        return birthdayFactoryContract.lastBirthdayContract().birthYear() == 2025;
    }

}