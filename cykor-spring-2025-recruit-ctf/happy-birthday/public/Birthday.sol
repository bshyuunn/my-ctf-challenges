// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Birthday {    
    address private birthdayPerson;
    uint256 public birthYear;
    uint256 public birthMonth;
    uint256 public birthDay;

    address public birthdayFacotry;
    mapping(address => bytes32) public birthdayMessages;

    constructor() payable {
        birthdayFacotry = msg.sender;
        birthYear = 2024;
    }

    function getBirthdayPerson() external view returns (address) {
        return birthdayPerson;
    }

    function getRemainingDays() external view returns (uint256) {
        uint256 birthdayTimestamp = _timestampFromDate(birthYear, birthMonth, birthDay);
        if (block.timestamp >= birthdayTimestamp) {
            return 0;
        }
        return (birthdayTimestamp - block.timestamp) / 1 days;
    }

    function setBirthdayMessage(address giver, bytes32 _message) external {
        if (msg.sender != giver && msg.sender != birthdayFacotry) {
            revert("You are not the giftGiver");
        }
        birthdayMessages[giver] = _message;
    }

    function donationGift() external payable {
        require(msg.value > 0, "Value must be greater than 0");
    }

    function receiveGift() external {
        require(msg.sender == birthdayPerson, "You are not the owner");  

        uint256 birthdayTimestamp = _timestampFromDate(birthYear, birthMonth, birthDay);
        require(block.timestamp >= birthdayTimestamp, "Your birthday has not arrived yet!");

        (bool success, ) = birthdayPerson.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function _timestampFromDate(uint256 _year, uint256 _month, uint256 _day) internal pure returns (uint256) {
        require(_month >= 1 && _month <= 12, "Invalid month");
        require(_day >= 1 && _day <= 31, "Invalid day");

        uint256[12] memory daysInMonth = [uint256(31), 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

        if (_year % 4 == 0 && (_year % 100 != 0 || _year % 400 == 0)) {
            daysInMonth[1] = 29;
        }

        require(_day <= daysInMonth[_month - 1], "Invalid day for given month");

        uint256 timestamp = (_year - 1970) * 365 days + (_year - 1969) / 4 * 1 days;
        for (uint256 i = 1; i < _month; i++) {
            timestamp += daysInMonth[i - 1] * 1 days;
        }
        timestamp += (_day - 1) * 1 days;

        return timestamp;
    }
}
